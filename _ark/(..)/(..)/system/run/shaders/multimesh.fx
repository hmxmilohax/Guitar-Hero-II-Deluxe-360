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

PS_INPUT vshader( int Index : INDEX )
{
    // Compute the instance index
	int instanceIndex = ( Index + 0.5 ) / gMultiMeshIndices;
	
	float4x4 transform = gTransformList[instanceIndex];

#if BILLBOARD	
	float3 cameraRight = gCamera._11_12_13;
   float3 cameraUp    = gCamera._21_22_23;
	
   transform = float4x4( float4(gCamera._11_12_13, 0),
                         float4(gCamera._31_32_33, 0),
                         float4(gCamera._21_22_23, 0),
                         float4(transform._41_42_43, 1) );
#endif
	
	// Compute the mesh index - this is the index to fetch within the current instance
	int meshIndex = Index - ( instanceIndex * gMultiMeshIndices );
	
    // Fetch the mesh index value
	int4 meshIndexValue = 0;
	asm
	{
	    vfetch meshIndexValue, meshIndex, position1;
	};

	// Now fetch the actual mesh vertex data
   float4 localPos;
   float4 localNorm;
   float4 diffuse;
   float4 uv;
#if NUM_WEIGHTS > 0
   float4 weights;
#endif
#if ENABLE_NORMAL_MAP
   float4 tangent;
#endif
	asm
	{
		vfetch localPos, meshIndexValue.x, position0;
		vfetch localNorm, meshIndexValue.x, normal;
		vfetch diffuse, meshIndexValue.x, color0;
		vfetch uv, meshIndexValue.x, texcoord0;
#if	NUM_WEIGHTS > 0
		vfetch weights, meshIndexValue.x, blendweight;
#endif
#if ENABLE_NORMAL_MAP
		vfetch tangent, meshIndexValue.x, tangent;
#endif
	};
	
	// Combine the instance position with the mesh position
	localPos = mul( float4(localPos.xyz, 1), transform );
	localNorm = mul( float4(localNorm.xyz, 0), transform );
	
	VS_INPUT I;
	I.localPos = localPos.xyz;
	I.localNorm = localNorm.xyz;
	I.diffuse = diffuse;
	I.uv = uv.xy;
#if NUM_WEIGHTS > 0
	I.weights = weights.xyz;
#endif
#if ENABLE_NORMAL_MAP
	I.tangent = tangent;
#endif
	
	// Now that we have a real vertex, send it on down through the standard shader.
	return standard_vshader( I );
}
