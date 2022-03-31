//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------


#include "transform.fx"

struct VS_INPUT
{
   float3 localPos  : POSITION;
#if NUM_WEIGHTS > 0
   float3 weights   : BLENDWEIGHT;
#endif
};

void vshader( VS_INPUT I, 
		      out float4 oPos : POSITION
#ifdef HX_PC		      
		      , out float2 oDepth : TEXCOORD0
#endif
		      )
{
   float3 weights = 0;
#if NUM_WEIGHTS > 0
   weights = I.weights;
#endif

   float3 tang = 0;
   float3 norm = 0;

   float3 worldPos  = I.localPos;
   Transform(weights, worldPos, norm, tang);
        
   oPos = Project(worldPos);
   
#ifdef HX_PC
   oDepth.xy = oPos.zw;
#endif
}

#ifdef HX_PC
float4 pshader( float2 Depth : TEXCOORD0 ) : COLOR
{
    //
    // Depth is z / w
    //
    return Depth.x/Depth.y;
}
#else
float4 pshader() : COLOR { return float4(0,0,0,0); }
#endif
