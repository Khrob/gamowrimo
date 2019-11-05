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
#define MAX_STEPS        100

struct
Capsule
{
    float4  start;
    float4  end;
};

struct
Uniforms
{
    float          t;
    packed_float4  camera;
    float          camera_yaw;
    float          camera_pitch;
    int            capsule_count;
};

float
dot2 (vector_float3 v)
{
    return dot(v,v);
}

float
round_cone (vector_float3 p, vector_float3 a, vector_float3 b, float r1, float r2)
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
sphere ( vector_float3 p, vector_float3 c, float r )
{
    float4 sphere = vector_float4(c,r);
    return length(p - sphere.xyz) - sphere.w;
}

float
get_distance (float3 p, constant Capsule * capsules, Uniforms uniforms)
{
    float plane_distance = p.y;
    
    float cd = MAX_DISTANCE;
    
    for (int i=0; i<uniforms.capsule_count; i++) {
        Capsule c = capsules[i];
        float d0 = round_cone(p, c.start.xyz, c.end.xyz, c.start.w, c.end.w);
        if (d0 < cd) { cd = d0; }
    }
    
    return min (cd, plane_distance);
}

float
ray_march (float3 origin, float3 direction, constant Capsule * capsules, Uniforms uniforms)
{
    float distance = 0.;
    for (int i=0; i<MAX_STEPS; i++)
    {
        float3 p = origin + direction * distance;
        float ds = get_distance(p, capsules, uniforms);
        distance += ds;
        if (ds < SURFACE_DISTANCE || distance > MAX_DISTANCE) break;
    }
    return distance;
}

float3
get_normal (vector_float3 p, constant Capsule * capsules, Uniforms uniforms)
{
    float d = get_distance(p, capsules, uniforms);
    vector_float2 e = float2(0.01, 0);
    
    float3 normal = d - float3(get_distance(p-e.xyy, capsules, uniforms),
                               get_distance(p-e.yxy, capsules, uniforms),
                               get_distance(p-e.yyx, capsules, uniforms));
    
    return normalize(normal);
}

float
get_light (float3 p, Uniforms uniforms, constant Capsule * capsules)
{
    vector_float3 light_pos = float3(0, 5, 6);
//    light_pos.xz += vector_float2(sin(uniforms.t), cos(uniforms.t)) * 4;
    vector_float3 l = normalize(light_pos-p);
    vector_float3 n = get_normal(p, capsules, uniforms);
    float diff = clamp(dot(n,l), 0., 1.);
    float d = ray_march(p+n*SURFACE_DISTANCE*2., l, capsules, uniforms);
    if (d < length(light_pos-p)) diff *= .5;
    return diff;
}

float3x3
setCamera (vector_float3 ro, vector_float3 ta, float cr )
{
    vector_float3 cw = normalize(ta-ro);
    vector_float3 cp = vector_float3(sin(cr), cos(cr),0.0);
    vector_float3 cu = normalize ( cross(cw,cp) );
    vector_float3 cv =           ( cross(cu,cw) );
    return float3x3( cu, cv, cw );
}

kernel
void
compute (texture2d<float, access::write> output [[texture(0)]],
         uint2 gid [[thread_position_in_grid]],
         constant Uniforms &uniforms [[ buffer(0) ]],
         constant Capsule  &capsules [[ buffer(1) ]])
{
    int width = output.get_width();
    int height = output.get_height();
    float2 resolution = float2(width,height);
    
    vector_float2 uv = vector_float2(float2(gid)-.5*resolution)/resolution[1];
    vector_float3 look_at = uniforms.camera.xyz;
    
    look_at.z += cos(uniforms.camera_yaw);
    look_at.x += sin(uniforms.camera_yaw);
    
    vector_float3 origin  = uniforms.camera.xyz;
    float3x3 ca = setCamera( origin, look_at, M_PI_F );
    float fov = 0.5;
    float3 direction = ca * normalize( float3(uv, fov) );
    float  d = ray_march (origin, direction, &capsules, uniforms);
    float3 p = origin + (direction * d);
    float  diffuse = get_light(p, uniforms, &capsules);
    diffuse = pow(diffuse, 0.4545);
    float4 colour = float4 (float3(diffuse),1.);
    output.write (colour, gid);
}


float3x3
set_camera (vector_float3 origin, vector_float3 at, float roll )
{
    vector_float3 cw = normalize(at-origin);
    vector_float3 cp = vector_float3(sin(roll), cos(roll),0.0);
    vector_float3 cu = normalize( cross(cw,cp) );
    vector_float3 cv =          ( cross(cu,cw) );
    return float3x3( cu, cv, cw );
}
