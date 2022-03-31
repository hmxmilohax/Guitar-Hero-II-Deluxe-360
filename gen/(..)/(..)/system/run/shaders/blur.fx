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
    float4 output = 0;
    for( int i=0; i < NUM_TAPS+1; i++ )
    {
		float4 fetch;
		float2 uv = I.uv + gBlurSampleOffsets[i].xy;		
#ifdef HX_XBOX
		asm 
		{
			tfetch2D fetch, uv, gDiffuseMap
		};
#else // HX_PC
      fetch = tex2D(gDiffuseMap, uv);
#endif // HX_PC
        output += gBlurSampleWeights[i] * fetch;
    }
    return output;
}