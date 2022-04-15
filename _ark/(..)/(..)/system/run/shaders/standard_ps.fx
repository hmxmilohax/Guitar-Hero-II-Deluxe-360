//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------


#if COST_ESTIMATE
#include "cost_estimate.fx"
#endif

#if FADE_OUT == 3
#include "depth.fx"
#endif // FADE_OUT == 3

struct PS_INPUT
{
	float4 projPos   : POSITION;
	float4 diffuse   : COLOR0;
#if (FADE_OUT != 1) && (FADE_OUT != 2) && (FADE_OUT != 3)
	float2 uv        : TEXCOORD0;
#else
	float4 uv        : TEXCOORD0;
#endif
   float4 worldPos  : TEXCOORD1;    // worldPos.w == fog factor
#if ENABLE_ENVIRON_MAP || (PER_PIXEL_LIGHTING && NUM_LIGHTS > 0) || PROJ_LIGHTS
	float3 viewDir   : TEXCOORD2;
	float3 worldNorm : TEXCOORD3;
#endif
#if ENABLE_NORMAL_MAP
	float3 tangent   : TEXCOORD4;
   float3 bitangent : TEXCOORD5;
#endif
#if SHADOW_BUFFER
	float4 lightProjPos : TEXCOORD6;
#endif
#if FADE_OUT==3
   float4 depthPos   : TEXCOORD7;
#endif
};


float4 standard_pshader(PS_INPUT I): COLOR
{
   //----------------------------------------------------------------------
   // Determine world-space normal and view directions.
   //
#if ENABLE_ENVIRON_MAP || (PER_PIXEL_LIGHTING && NUM_LIGHTS > 0) || PROJ_LIGHTS
   float3 normal;
#if ENABLE_NORMAL_MAP

   float3 N = I.worldNorm;
   float3 T = I.tangent;
   float3 B = I.bitangent;
#if NORMALIZE
   N = normalize(N);
   T = normalize(T);
   B = normalize(B);
#endif

   float3x3 TBN = float3x3(T, B, N);

#ifdef HX_XBOX
   normal.yx = expand(tex2D(gNormalMap, I.uv.xy).xy); // note dest swizzle

   // Slightly cheaper than: z = sqrt(1 - x^2 - y^2)
   normal.z = saturate(1.35 - abs(normal.x) - abs(normal.y));
#else
   normal = expand(tex2D(gNormalMap, I.uv.xy).xyz);
#endif

#if TEX_GEN == 0
   // TODO  Even without this, for other TEX_GEN, the uv is going to be
   // in a strange place for the normal map; should we disable normal maps?
   normal = mul(normal, gTexCoord);
#endif
   normal = mul(normal, TBN);

#else
   normal = I.worldNorm;
#endif

   float3 worldView = normalize(I.viewDir);
   float3 worldNorm = normalize(normal);
#endif

   //----------------------------------------------------------------------
   // Determine specular "factor"; rgb contains modulation/masking, alpha
   // contains "shinyness" (or "blur" w/ environment map enabled).
   //
   float4 specFactor;
#if ENABLE_SPECULAR_MAP
   specFactor = tex2D(gSpecularMap, I.uv.xy);
   specFactor.a *= gSpecular.a;
   specFactor.a = max(specFactor.a, 0.1f);
#else
   specFactor = gSpecular;
#endif
   

   //----------------------------------------------------------------------
   // Emissive component of lighting
   //
   float4 emissive = 0;
#if ENABLE_GLOW_MAP
   emissive.rgb = tex2D(gGlowMap, I.uv.xy).rgb;
#endif

   //----------------------------------------------------------------------
   // Diffuse and specular components of lighting
   // Note that a portion of the diffuse component (I.diffuse) is
   // calculated in the vertex shader.
   //
   float4 diffuse  = 0;
   float4 specular = 0;

#if SHADOW_BUFFER
   float4 lightProjPos = I.lightProjPos;
#else
   float4 lightProjPos = 0;
#endif

#if (PER_PIXEL_LIGHTING && (NUM_LIGHTS > 0)) || PROJ_LIGHTS
   ApplyLights(I.worldPos, worldNorm, worldView, lightProjPos,
               specFactor, diffuse.rgb, specular.rgb);
   diffuse *= gDiffuse;
#endif

   diffuse += I.diffuse;
#if ENABLE_DIFFUSE_MAP
   diffuse *= tex2D(gDiffuseMap, I.uv.xy) * gMultipliers.y;
#endif

   //----------------------------------------------------------------------
   // Environment mapping
   // Replaces specular component (which should be zero at this point
   // if environment mapping enabled)
   //
#if ENABLE_ENVIRON_MAP
   float4 worldReflect;

   // Note: yz swizzled for Rnd->DX basis change
   worldReflect.xzy = reflect(-worldView, worldNorm);  
   worldReflect.w = specFactor.a;

   specular.rgb = texCUBEbias(gEnvironMap, worldReflect) * specFactor.rgb;
#endif


   //----------------------------------------------------------------------
   // Final color output combines lighting components
   float4 output = emissive*gMultipliers.x + diffuse + specular;

#if FOG
   output = lerp(gFogColor, output, I.worldPos.w);
#endif

   // Might be cheaper to always do this lerp than have another shader variation.
#if (FADE_OUT == 1) || (FADE_OUT == 2) || (FADE_OUT == 3)
   output = lerp(gFadeColor, output, I.uv.zzzw);
#endif

#if FADE_OUT == 3
   output.rgb = DepthFade(output.rgb, I.depthPos);
#endif

#if COST_ESTIMATE
   output = (0.25 * output) + (0.75 * pixel_cost());
#endif

#if HDR
   return pack_color(output); // pack color into 10-bit format
#else
   return output;
#endif
}
