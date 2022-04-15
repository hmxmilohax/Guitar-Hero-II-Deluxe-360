
//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------

#ifndef VS_TRANSFORM_FX
#define VS_TRANSFORM_FX

#include "common.fx"

void Transform(float3 weights,
               inout float3 pos,
               inout float3 norm,
               inout float3 tang)
{
   float4x4 trans;

#if NUM_WEIGHTS == 0
   trans = gModel0;
#endif

#if NUM_WEIGHTS == 1
   float w = 1 - weights.x;
   trans  = (weights.x * gModel0);
   trans += (w         * gModel1);
#endif

#if NUM_WEIGHTS == 2
   float w = 1 - (weights.x + weights.y);
   trans  = (weights.x * gModel0);
   trans += (weights.y * gModel1);
   trans += (w         * gModel2);
#endif

#if NUM_WEIGHTS == 3
   float w = 1 - (weights.x + weights.y + weights.z);
   trans  = (weights.x * gModel0);
   trans += (weights.y * gModel1);
   trans += (weights.z * gModel2);
   trans += (w         * gModel3);
#endif

#if 0
   float3 cameraRight = gCamera._11_12_13;
   float3 cameraUp    = gCamera._21_22_23;

   // align to camera
   trans = float4x4( float4(cameraRight, 0),
                     float4(cross(cameraRight, cameraUp), 0),
                     float4(cameraUp, 0),
                     float4(trans._41_42_43, 1) );
#endif

   pos  = mul(float4(pos, 1),  trans);
   norm = mul(norm, (float3x3) trans);
   tang = mul(tang, (float3x3) trans);
}

float4 Project(float3 pos)
{
   return mul(float4(pos, 1), gViewProj);
}

#endif // VS_TRANSFORM_H
