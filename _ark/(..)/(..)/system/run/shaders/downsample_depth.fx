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

void pshader( PS_INPUT I, 
			  out float4 oColor : COLOR,
              out float oDepth : DEPTH  )
{
	float2 uv = I.uv;

#define EIGHT_TAP
#ifdef EIGHT_TAP
   const float InvShadowMapScale = 1.0f / 512.0f;
   
   const float2 kTaps0 = float2(  0.0,  0.0 ) + uv;
   const float2 kTaps1 = float2(  0.0,  1.0 ) * InvShadowMapScale + uv;
   const float2 kTaps2 = float2(  1.0,  1.0 ) * InvShadowMapScale + uv;
   const float2 kTaps3 = float2(  1.0,  0.0 ) * InvShadowMapScale + uv;
   const float2 kTaps4 = float2(  1.0, -1.0 ) * InvShadowMapScale + uv;
   const float2 kTaps5 = float2(  0.0, -1.0 ) * InvShadowMapScale + uv;
   const float2 kTaps6 = float2( -1.0, -1.0 ) * InvShadowMapScale + uv;
   const float2 kTaps7 = float2( -1.0,  0.0 ) * InvShadowMapScale + uv;
#endif // EIGHT_TAP

    // Fetch the four samples
    float4 sampledDepth0;
    float4 sampledDepth1;
    asm {
#ifndef EIGHT_TAP
        tfetch2D sampledDepth0.x___, uv, gDiffuseMap, OffsetX = -0.5, OffsetY = -0.5
        tfetch2D sampledDepth0._x__, uv, gDiffuseMap, OffsetX =  0.5, OffsetY = -0.5
        tfetch2D sampledDepth0.__x_, uv, gDiffuseMap, OffsetX = -0.5, OffsetY =  0.5
        tfetch2D sampledDepth0.___x, uv, gDiffuseMap, OffsetX =  0.5, OffsetY =  0.5
#else
        tfetch2D sampledDepth0.x___, kTaps0, gDiffuseMap
        tfetch2D sampledDepth0._x__, kTaps1, gDiffuseMap
        tfetch2D sampledDepth0.__x_, kTaps2, gDiffuseMap
        tfetch2D sampledDepth0.___x, kTaps3, gDiffuseMap
        
        tfetch2D sampledDepth1.x___, kTaps4, gDiffuseMap
        tfetch2D sampledDepth1._x__, kTaps5, gDiffuseMap
        tfetch2D sampledDepth1.__x_, kTaps6, gDiffuseMap
        tfetch2D sampledDepth1.___x, kTaps7, gDiffuseMap
#endif
    };
    
    // Find the maximum.
#ifdef EIGHT_TAP
    sampledDepth0 = max(sampledDepth0, sampledDepth1);
#endif
    sampledDepth0.xy = max( sampledDepth0.xy, sampledDepth0.zw );
    sampledDepth0.x = max( sampledDepth0.x, sampledDepth0.y );

    oColor = sampledDepth0.x;
    oDepth = sampledDepth0.x;   
}