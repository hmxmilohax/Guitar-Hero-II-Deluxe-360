//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// Vertex Shader Constants
// 

#include "common.fx"

struct VS_INPUT
{
   float3 localPos : POSITION;
   float4 diffuse  : COLOR0;
};

struct PS_INPUT
{
   float4 projPos  : POSITION;
   float4 diffuse  : COLOR0;
};

PS_INPUT vshader(VS_INPUT I)
{
   PS_INPUT O;

   O.projPos = mul(mul(float4(I.localPos, 1), gModel0), gViewProj);
   O.diffuse = I.diffuse;

   return O;
}

float4 pshader(PS_INPUT I): COLOR0
{
   return I.diffuse;
}

