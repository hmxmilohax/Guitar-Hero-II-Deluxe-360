//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Structs
// 
struct VS_INPUT
{
   float3 localPos  : POSITION;
   float3 localNorm : NORMAL;
   float4 diffuse   : COLOR0;
   float2 uv        : TEXCOORD0;
#if NUM_WEIGHTS > 0
   float3 weights   : BLENDWEIGHT;
#endif
#if ENABLE_NORMAL_MAP
   float4 tangent   : TANGENT;
#endif
};

//----------------------------------------------------------------------------
// Vertex Shader
// 
#include "transform.fx"
#include "depth.fx"

PS_INPUT standard_vshader(VS_INPUT I)
{
   PS_INPUT O;

   float3 weights = 0;
#if NUM_WEIGHTS > 0
   weights = I.weights;
#endif

   float3 pos  = I.localPos;
   float3 norm = I.localNorm;
   float3 tang = 0;
#if ENABLE_NORMAL_MAP
   tang = I.tangent.xyz;
#endif

	// billboards are already in view space.
   Transform(weights, pos, norm, tang);

#if 0 || EXTRUDE
//   pos = ExtrudePosition(pos, norm);
pos = ExtrudeToPlane(pos, norm);
#endif // EXTRUDE

   O.worldPos.xyz = pos;
   O.projPos      = Project(pos);

   float3 viewDir = normalize(gCamera._41_42_43 - pos);

#if ENABLE_NORMAL_MAP
   O.tangent = tang;
   O.bitangent = cross(norm, tang) * I.tangent.w;
#endif

   float4 diffuse  = 0;
   float4 specular = 0;

#if !PER_PIXEL_LIGHTING && ((NUM_LIGHTS - PROJ_LIGHTS) > 0)
   ApplyLights(pos, norm, viewDir, 0, gSpecular, diffuse.rgb, specular.rgb);
   diffuse *= gDiffuse;
#endif

#if PRELIT
   #if USE_ENVIRON
      diffuse += I.diffuse * float4(gEnvAmbient, 1);
   #else
      diffuse += I.diffuse * float4(gAmbient, 1);
   #endif
#else
   #if USE_ENVIRON
      diffuse +=  gDiffuse * float4(gEnvAmbient, 1);
   #else
      diffuse +=  gDiffuse * float4(gAmbient, 1);
   #endif
#endif

   O.diffuse = diffuse + specular;
   
#if (FADE_OUT==1) || (FADE_OUT==2) || (FADE_OUT==3)
   // Initialize the last channels of our uv to one (the neutral no-op value), 
   // in case we don't use it.
   O.uv.zw = 1.f;
#endif
#if TEX_GEN == 1
   // transform world-space normal
   O.uv.xy = mul(float4(norm, 1), gTexCoord);
#elif TEX_GEN == 2
   // transform world-space position
   O.uv.xy = mul(float4(pos, 1), gTexCoord);
#elif TEX_GEN == 3
   // transform world-space reflection
   O.uv.xy = mul(float4(reflect(-viewDir, norm), 1), gTexCoord);
#else
   // transform mesh texture coords
   O.uv.xy = mul(float4(I.uv, 0, 1), gTexCoord);
#endif
   
#if ENABLE_ENVIRON_MAP || (PER_PIXEL_LIGHTING && NUM_LIGHTS > 0) || PROJ_LIGHTS
   O.viewDir = viewDir;
   O.worldNorm = norm;
#endif
   
#if SHADOW_BUFFER
   O.lightProjPos = mul( float4(pos, 1), gWorldToLightProj );
#endif

#if FOG || (FADE_OUT==1) || (FADE_OUT==2) || (FADE_OUT==3)
   float d = O.projPos.w;
#endif

#if FADE_OUT == 3
   O.depthPos = O.projPos;
#endif

#if FOG
   O.worldPos.w = saturate((gFogRange.x - d) * gFogRange.y);
#else
   O.worldPos.w = 0;
#endif

#if FADE_OUT == 1 // Fade the alpha to zero
   // Fade alpha only, so the z channel (color interp) stays at 1 (no change)
   // and the w is the fade interp value
   O.uv.w = saturate((gFadeRange.x - d) * gFadeRange.y);
#elif FADE_OUT == 2 // Fade the color to the dest color
   // Want to fade color only, so set z but leave w alone.
   O.uv.z = saturate((gFadeRange.x - d) * gFadeRange.y);
#elif FADE_OUT == 3 // Fade out both color and alpha
   O.uv.zw = saturate((gFadeRange.x - d) * gFadeRange.y).xx;
//O.uv.zw = float2(1.f, 1.f);
#endif

   return O;
}
