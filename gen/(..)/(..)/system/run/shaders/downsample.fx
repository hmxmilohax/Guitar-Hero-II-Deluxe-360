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
   float3 localPos  : POSITION;
   float2 uv        : TEXCOORD0;
};

struct PS_INPUT
{
	float4 projPos   : POSITION;
	float2 uv        : TEXCOORD0;
};

PS_INPUT vshader(VS_INPUT I)
{
   PS_INPUT output;
   output.projPos = mul(mul(float4(I.localPos, 1), gModel0), gViewProj);
   output.uv = I.uv;
   
   return output;
}

float4 pshader( PS_INPUT I ) : COLOR0
{
    float4 sample0, sample1, sample2, sample3;
    float2 uv = I.uv;
    asm {
        tfetch2D sample0, uv,
                 gDiffuseMap, OffsetX = -0.5, OffsetY = -0.5
        tfetch2D sample1, uv,
                 gDiffuseMap, OffsetX =  0.5, OffsetY = -0.5
        tfetch2D sample2, uv,
                 gDiffuseMap, OffsetX = -0.5, OffsetY =  0.5
        tfetch2D sample3, uv,
                 gDiffuseMap, OffsetX =  0.5, OffsetY =  0.5
    };
    
    return (sample0 + sample1 + sample2 + sample3) / 4.0;        
}