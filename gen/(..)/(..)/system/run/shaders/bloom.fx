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
	float3 LuminanceVector  = float3(0.2125f, 0.7154f, 0.0721f);
	
    float4 tap;
    float2 uv = I.uv;
    asm { tfetch2D tap, uv, gBloomSource, MagFilter=point, MinFilter=point };	
	tap = unpack_color( tap );
	
	float lum = dot( tap.rgb, LuminanceVector );	

	float bloom_white = smoothstep( gBloomThresholds.a, 4.0, lum );
	float3 bloom = saturate((tap.rgb - gBloomThresholds.rgb) * 1024.f);
	bloom = saturate( bloom - saturate( bloom_white ) );
	
	return float4(bloom.r,bloom.g,bloom.b,bloom_white);
}