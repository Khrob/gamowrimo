//
//  Renderer.metal
//  gamo
//
//  Created by Khrob Edmonds on 11/1/19.
//  Copyright © 2019 TangoSoup. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//
// I learned a lot of this from Inigo Quilez and @The_ArtOfCode
//
// https://www.shadertoy.com/view/Xds3zN
// https://www.youtube.com/playlist?list=PLGmrMu-IwbgtMxMiV3x4IrHPlPmg7FD-P
//

#define SURFACE_DISTANCE 0.01
#define MAX_DISTANCE     100.0
#define MAX_STEPS        64

struct
Round_Cone
{
    float4  start;
    float4  end;
    
    // Bounding Sphere
    packed_float3  bs_centre;
    float   bs_radius;
};

struct
Capsule
{
    float3  start;
    float3  end;
    float   radius;
    
    // Bounding Sphere
    packed_float3  bs_centre;
    float   bs_radius;
};

struct
Uniforms
{
    float          t;
    packed_float3  camera_origin;
    packed_float3  camera_lookat;
    int            capsule_count;
};

float
dot2 (vector_float3 v)
{
    return dot(v,v);
}

float
plane_flat (float3 p)
{
    return p.y;
}

float
plane (float3 p, float3 n)
{
    return dot(p, normalize(n)) - (sin(p.x) / 3) - (sin(p.z) / 6.);
}

float
sphere ( vector_float3 p, vector_float3 c, float r )
{
    float4 sphere = vector_float4(c,r);
    return length(p - sphere.xyz) - sphere.w;
}

float
round_cone (vector_float3 p, vector_float3 a, vector_float3 b, float r1, float r2, float3 bounding_centre, float bounding_radius)
{   
    // sampling independent computations (only depend on shape)
    vector_float3  ba = b - a;
    float l2 = dot(ba,ba);
    float rr = r1 - r2;
    float a2 = l2 - rr*rr;
    float il2 = 1.0/l2;
    
    // sampling dependant computations
    vector_float3 pa = p - a;
    float y = dot(pa,ba);
    float z = y - l2;
    float x2 = dot2( pa*l2 - ba*y );
    float y2 = y*y*l2;
    float z2 = z*z*l2;

    // single square root!
    float k = sign(rr)*rr*rr*x2;
    if( sign(z)*a2*z2 > k ) return  sqrt(x2 + z2)        *il2 - r2;
    if( sign(y)*a2*y2 < k ) return  sqrt(x2 + y2)        *il2 - r1;
                            return (sqrt(x2*a2*il2)+y*rr)*il2 - r1;
}

float
cylinder (float3 p, Capsule c)
{
    float3 ps = p-c.start, es = c.end - c.start;
    float  h = dot(ps, es)/dot(es,es);
    h = clamp(h, 0.0, 1.0);
    return length( ps - es*h ) - c.radius;
}

float
get_distance (float3 p, constant Round_Cone * capsules, Uniforms uniforms)
{
    float plane_distance = plane(p, float3(0,1,0));
    
    float cd = MAX_DISTANCE;
    
    for (int i=0; i<uniforms.capsule_count; i++) {
        Round_Cone c = capsules[i];
        float d0 = round_cone(p, c.start.xyz, c.end.xyz, c.start.w, c.end.w, c.bs_centre, c.bs_radius);
        if (d0 < cd) { cd = d0; }
    }
    
    return min (cd, plane_distance);
}

float
ray_march (float3 origin, float3 direction, constant Round_Cone * capsules, Uniforms uniforms)
{
    float distance = 0.;
    for (int i=0; i<MAX_STEPS; i++)
    {
        float3 p = origin + direction * distance;
        float ds = get_distance(p, capsules, uniforms);
        distance += ds;
        if (ds < SURFACE_DISTANCE || abs(distance) > MAX_DISTANCE) break;
    }
    return distance;
}

float3
get_normal (vector_float3 p, constant Round_Cone * capsules, Uniforms uniforms)
{
    float d = get_distance(p, capsules, uniforms);
    vector_float2 e = float2(0.01, 0);
    
    float3 normal = d - float3(get_distance(p-e.xyy, capsules, uniforms),
                               get_distance(p-e.yxy, capsules, uniforms),
                               get_distance(p-e.yyx, capsules, uniforms));
    
    return normalize(normal);
}

float
get_light (float3 p, Uniforms uniforms, constant Round_Cone * capsules)
{
    vector_float3 light_pos = float3(0, 5, 6);
    light_pos.xz += vector_float2(sin(uniforms.t), cos(uniforms.t)) * 4;
    vector_float3 l = normalize(light_pos-p);
    vector_float3 n = get_normal(p, capsules, uniforms);
    float diff = clamp(dot(n,l), 0.15, 1.);
    float d = ray_march(p+n*SURFACE_DISTANCE*2., l, capsules, uniforms);
    if (d < length(light_pos-p)) diff *= .15;
    return diff;
}

float3x3
set_camera (vector_float3 origin, vector_float3 at, float roll )
{
    vector_float3 cw = normalize(at-origin);
    vector_float3 cp = vector_float3(sin(roll), cos(roll), 0.0);
    vector_float3 cu = normalize(cross(cw,cp));
    vector_float3 cv = cross(cu,cw);
    return float3x3 ( cu, cv, cw );
}


kernel
void
compute (texture2d<float, access::write> output [[texture(0)]],
         uint2    gid                     [[ thread_position_in_grid ]],
         constant Uniforms   &uniforms    [[ buffer(0) ]],
         constant Round_Cone &round_cones [[ buffer(1) ]],
         constant Capsule    &capsules    [[ buffer(2) ]])
{
    float2 resolution = float2(output.get_width(),output.get_height());
    float2 uv = float2(float2(gid)-0.5*resolution)/output.get_height();
    
    float3x3 ca = set_camera( uniforms.camera_origin, uniforms.camera_lookat, M_PI_F );
    float  fov = 0.5;
    float3 direction = ca * normalize( float3(uv, fov) );
    float  d = ray_march (uniforms.camera_origin, direction, &round_cones, uniforms);
    float3 p = uniforms.camera_origin + (direction * d);
    float  diffuse = get_light(p, uniforms, &round_cones);
    diffuse = pow(diffuse, 0.4545);
    float4 colour = float4 (float3(diffuse),1.);
    output.write (colour, gid);
}


