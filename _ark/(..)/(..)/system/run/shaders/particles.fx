//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------

#include "common.fx"
#include "lighting.fx"
#include "standard_ps.fx"
#include "standard_vs.fx"

float4 pshader(PS_INPUT I): COLOR
{
   return standard_pshader(I);
}

PS_INPUT vshader( int index : INDEX )
{
   const float2 gCorner[4] =
   {
      float2(0.f, 0.f),
      float2(0.f, 1.f),
      float2(1.f, 1.f),
      float2(1.f, 0.f)
   };

   int pointIndex = index / 4;

   // Fetch particle position, etc
   float4 pos;
   float4 color;
   float4 scale;
   asm
   {
      vfetch pos,   pointIndex, position0;
      vfetch color, pointIndex, color0;
      vfetch scale, pointIndex, texcoord0;
   };
   
   // Get the quad corner we're working with
   float2 corner = gCorner[ index % 4 ];
   
   VS_INPUT I;
   I.localNorm = float3(0,0,0);
   I.diffuse   = color;
   I.uv.xy     = corner;
   
   corner = expand(corner);
   
   float2 rot;
   sincos(scale.y, rot.x, rot.y);
   rot *= scale.x;
   
   // Offset our position to the corner
   pos.xyz += (corner.x * rot.y - corner.y * rot.x) * gParticleRight;
   pos.xyz -= (corner.x * rot.x + corner.y * rot.y) * gParticleUp;
   
   I.localPos  = pos.xyz;

   // Send our offset vertex thru the standard shader.
   return standard_vshader( I );
}

