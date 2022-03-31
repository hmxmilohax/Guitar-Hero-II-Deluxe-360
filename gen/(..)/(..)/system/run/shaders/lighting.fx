//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------
#ifndef SH_LIGHTING_FX
#define SH_LIGHTING_FX

#if PIXEL_SHADER 
   #if PER_PIXEL_LIGHTING
      #define NUM_REGULAR_LIGHTS (NUM_LIGHTS - PROJ_LIGHTS)
   #else //PER_PIXEL_LIGHTING
      #define NUM_REGULAR_LIGHTS (0)
   #endif // PER_PIXEL_LIGHTING

   #define NUM_PROJECTED_LIGHTS (PROJ_LIGHTS)
   
   #define PROJ_BASE (NUM_REGULAR_LIGHTS)
   #define REGULAR_BASE (0)

#else // VERTEX_SHADER

   #if PER_PIXEL_LIGHTING
      #define NUM_REGULAR_LIGHTS (0)
   #else //PER_PIXEL_LIGHTING
      #define NUM_REGULAR_LIGHTS (NUM_LIGHTS - PROJ_LIGHTS)
   #endif // PER_PIXEL_LIGHTING

   #define NUM_PROJECTED_LIGHTS (0)
   
   #define PROJ_BASE (0)
   #define REGULAR_BASE (0)

#endif // VERTEX_SHADER

#define NUM_TOTAL_LIGHTS (NUM_REGULAR_LIGHTS + NUM_PROJECTED_LIGHTS)


#include "shadowfactor.fx"

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
// Specular function used all over
////////////////////////////////////////////////////////////////////
float3 Specular(const in float3 norm, const in float3 liDir, 
               const in float3 viDir, const in float power)
{
   float3 refl = reflect(-liDir, norm);
   return pow(saturate(dot(refl, viDir)), power);
}

////////////////////////////////////////////////////////////////////
// Diffuse function used all over
////////////////////////////////////////////////////////////////////
float3 Diffuse(const in float3 normal, const in float3 lightDir)
{
#if ENABLE_CUSTOM_DIFFUSE
   return tex1D(gCustomDiffuse, narrow(dot(normal, lightDir)));
#else
   return saturate(dot(normal, lightDir));
#endif
}

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
// figure effect of shadow
////////////////////////////////////////////////////////////////////
void ShadowPoint(const in float3 pos, const in float3 norm, 
               const in float3 liDir, const in float4 lightProjPos, 
               inout float3 diffuse, inout float3 specular)
{
   float shadowFactor = ComputeShadowFactor( pos, lightProjPos );
//   shadowFactor = saturate(1.f - saturate(dot(norm, liDir) * saturate(1.f - shadowFactor)));

   diffuse  *= shadowFactor;
#if ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
   specular *= shadowFactor;
#endif

}

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
// Projected texture spot lights
float3 ProjSpot(float3 wPos, float4x3 xfm)
{
   float3 uvw = mul(float4(wPos.xyz, 1.f), xfm);
   
   return uvw;
}

float3 ProjSpotAtten(float3 wPos, float4x3 xfm, sampler2D tex, sampler2D shadow)
{

   float3 uvw = ProjSpot(wPos, xfm);

   uvw.xy /= uvw.z;
   uvw.xy *= 0.5f;
   uvw.xy += 0.5f;
   float3 atten = tex2D(tex, uvw.xy);
   float satten = tex2D(shadow, uvw.xy).w;
//float3 satten = float3(1.f, 0.f, 1.f);
   
   return (uvw.z > 0.f) ? (atten * (1.f - satten)) : float3(0.f, 0.f, 0.f);
}


////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
// Point lights section, helpers first
////////////////////////////////////////////////////////////////////
void AttenuatePoint(const in float3 norm, 
                     const in float distanceAtten, 
                     inout float3 dir,
                     out float attenDist, out float attenNorm)
{
   float invLen = rsqrt(dot(dir, dir));
   float len = 1.f / invLen;

   dir *= invLen;
   
   attenDist = saturate(len * distanceAtten);
   attenNorm = Diffuse(norm, dir).x;
}

////////////////////////////////////////////////////////////////////
void GetPointAtten(const in float3 pos, const in float3 norm,
            const in float3 liPos, const in float4 liCol,
            const in float3 viDir, const in float specFac,
            out float attenDist, out float attenNorm, out float3 liDir,
            inout float3 specular)
{
   liDir = liPos - pos;
   AttenuatePoint(norm, liCol.w, liDir, attenDist, attenNorm);
   
#if ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
   specular += liCol.rgb * Specular(norm, liDir, viDir, specFac) * (1.f - attenDist);
#endif // ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
}

////////////////////////////////////////////////////////////////////
void PointLights(const in float3 pos,
                  const in float3 norm,
                  const in float4 specFactor,
                  const in float3 viewDir,
                  in float4 lightProjPos, 
                  inout float3 diffuse,
                  inout float3 specular)
{
   float4 attenDist = float4(0.f, 0.f, 0.f, 0.f);
   float4 attenNorm = float4(0.f, 0.f, 0.f, 0.f);
   
   for( int i = 0; i < NUM_REGULAR_LIGHTS; ++i )
   {
      float3 dir;

      GetPointAtten(pos, norm, 
                     gLight[REGULAR_BASE + i].xyz, gLightCol[REGULAR_BASE + i], 
                     viewDir, specFactor.a,
                     attenDist[REGULAR_BASE + i], attenNorm[REGULAR_BASE + i], dir,
                     specular);
#if SHADOW_BUFFER
      if( !i )
         ShadowPoint(pos, norm, dir, lightProjPos, diffuse, specular);
#endif // SHADOW_BUFFER
   }
   
   
   // we want (1 - attenDist) * attenNorm
   // so (attenNorm - attenDist * attenNorm) for a mad.
   float4 atten = -attenDist * attenNorm + attenNorm;
   for( int j = 0; j < NUM_REGULAR_LIGHTS; ++j )
      diffuse.rgb += gLightCol[REGULAR_BASE + j] * atten[REGULAR_BASE + j];
      
   diffuse.rgb *= gDiffuse.rgb;

#if ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
   specular *= specFactor.rgb;
#endif   
   
}

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
// Dir lights next, helpers first
////////////////////////////////////////////////////////////////////

void DirLightSpec(const in float3 norm,
               const in float3 liDir,
               const in float3 liCol,
               const in float3 viDir,
               const in float specFac,
               inout float3 diffuse,
               inout float3 specular)
{
   diffuse += liCol * Diffuse(norm, liDir);

#if ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
   specular += liCol.rgb * Specular(norm, liDir, viDir, specFac);
#endif //ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
}

////////////////////////////////////////////////////////////////////

void DirLightOne(const in float3 norm,
               const in float3 liDir,
               const in float3 liCol,
               const in float3 viDir,
               const in float specFac,
               inout float3 diffuse,
               inout float3 specular)
{
   diffuse += liCol * Diffuse(norm, liDir);
}

////////////////////////////////////////////////////////////////////

void ProjLights(const in float3 pos, 
               const in float3 normal, 
               const in float4 specFactor, 
               const in float3 viewDir, 
               const in float4 lightProjPos, 
               inout float3 diffuse, 
               inout float3 specular)
{
#if PROJ_LIGHTS > 0
   {
      float3 tempDiff = 0;
      float3 tempSpec = 0;

      DirLightSpec(normal, 
                   gLight[PROJ_BASE].xyz,
                   gLightCol[PROJ_BASE].rgb,
                   viewDir,
                   specFactor.a, 
                   tempDiff, 
                   tempSpec);

      float3 projAtten = ProjSpotAtten(pos, gProjXfm, gFloorSpot, gShadowMap);
      tempDiff *= projAtten;
      diffuse += tempDiff;
#if ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
      tempSpec *= projAtten;
      specular += tempSpec;
#endif // ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
   }

#if PROJ_LIGHTS > 1

   {
      float3 tempDiff = 0;
      float3 tempSpec = 0;

      DirLightSpec(normal, 
                   gLight[PROJ_BASE+1].xyz,
                   gLightCol[PROJ_BASE+1].rgb,
                   viewDir,
                   specFactor.a, 
                   tempDiff, 
                   tempSpec);

      float3 projAtten = ProjSpotAtten(pos, gProjXfm1, gFloorSpot1, gShadowMap1);
      tempDiff *= projAtten;
      diffuse += tempDiff;
#if ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
      tempSpec *= projAtten;
      specular += tempSpec;
#endif // ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
   }

#if PROJ_LIGHTS > 2

   {
      float3 tempDiff = 0;
      float3 tempSpec = 0;

      DirLightSpec(normal, 
                   gLight[PROJ_BASE+2].xyz,
                   gLightCol[PROJ_BASE+2].rgb,
                   viewDir,
                   specFactor.a, 
                   tempDiff, 
                   tempSpec);

      float3 projAtten = ProjSpotAtten(pos, gProjXfm2, gFloorSpot2, gShadowMap2);
      tempDiff *= projAtten;
      diffuse += tempDiff;
#if ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
      tempSpec *= projAtten;
      specular += tempSpec;
#endif // ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
   }

#endif // PROJ_LIGHTS > 2
#endif // PROJ_LIGHTS > 1
#endif // PROJ_LIGHTS > 0
}

void DirLights( const in float3 pos,
                  const in float3 norm,
                  const in float4 specFactor,
                  const in float3 viewDir,
				      const in float4 lightProjPos, // position of this pixel in light's projection
                  inout float3 diffuse,
                  inout float3 specular)
{

//#define MF_USE_LOOP
#ifdef MF_USE_LOOP

#define NUM_SPECULAR (4)
   
   for( int i = 0; i < NUM_REGULAR_LIGHTS; ++i )
   {
      if( i < NUM_SPECULAR )
         DirLightSpec(norm, 
                     gLight[REGULAR_BASE + i].xyz, 
                     gLightCol[REGULAR_BASE + i].rgb, 
                     viewDir, 
                     specFactor.a, 
                     diffuse, 
                     specular);
      else
         DirLightOne(norm, 
                     gLight[REGULAR_BASE + i].xyz, 
                     gLightCol[REGULAR_BASE + i].rgb, 
                     viewDir, 
                     specFactor.a, 
                     diffuse, 
                     specular);
                     
#if SHADOW_BUFFER
      if( !i )
         ShadowPoint(pos, norm, gLight[REGULAR_BASE + 0], lightProjPos, diffuse, specular);
#endif // SHADOW_BUFFER
   }
   
#else // !MF_USE_LOOP

#if NUM_REGULAR_LIGHTS > 0
   DirLightSpec(norm, 
               gLight[REGULAR_BASE + 0].xyz, 
               gLightCol[REGULAR_BASE + 0].rgb, 
               viewDir, 
               specFactor.a, 
               diffuse, 
               specular);
#if SHADOW_BUFFER
   ShadowPoint(pos, norm, gLight[REGULAR_BASE + 0], lightProjPos, diffuse, specular);
#endif // SHADOW_BUFFER
   
#if NUM_REGULAR_LIGHTS > 1
   DirLightSpec(norm, 
               gLight[REGULAR_BASE + 1].xyz, 
               gLightCol[REGULAR_BASE + 1].rgb, 
               viewDir, 
               specFactor.a, 
               diffuse, 
               specular);

#if NUM_REGULAR_LIGHTS > 2
   DirLightSpec(norm, 
               gLight[REGULAR_BASE + 2].xyz, 
               gLightCol[REGULAR_BASE + 2].rgb, 
               viewDir, 
               specFactor.a, 
               diffuse, 
               specular);

#if NUM_REGULAR_LIGHTS > 3
   DirLightSpec(norm, 
               gLight[REGULAR_BASE + 3].xyz, 
               gLightCol[REGULAR_BASE + 3].rgb, 
               viewDir, 
               specFactor.a, 
               diffuse, 
               specular);

#if NUM_REGULAR_LIGHTS > 4
   DirLightOne(norm, 
               gLight[REGULAR_BASE + 4].xyz, 
               gLightCol[REGULAR_BASE + 4].rgb, 
               viewDir, 
               specFactor.a, 
               diffuse, 
               specular);

#if NUM_REGULAR_LIGHTS > 5
   DirLightOne(norm, 
               gLight[REGULAR_BASE + 5].xyz, 
               gLightCol[REGULAR_BASE + 5].rgb, 
               viewDir, 
               specFactor.a, 
               diffuse, 
               specular);

#if NUM_REGULAR_LIGHTS > 6
   DirLightOne(norm, 
               gLight[REGULAR_BASE + 6].xyz, 
               gLightCol[REGULAR_BASE + 6].rgb, 
               viewDir, 
               specFactor.a, 
               diffuse, 
               specular);
#endif // > 6
#endif // > 5
#endif // > 4
#endif // > 3
#endif // > 2
#endif // > 1
#endif // > 0

#endif // !MF_USE_LOOP

   diffuse.rgb *= gDiffuse.rgb;

#if ENABLE_SPECULAR && !ENABLE_ENVIRON_MAP
   specular *= specFactor.rgb;
#endif   

}

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
// Entry point, just passes off to the correct kind of light
////////////////////////////////////////////////////////////////////

void ApplyLights(const in float3 pos,
                 const in float3 normal,
                 const in float3 viewDir,
                 const in float4 lightProjPos,
                 const in float4 specFactor,
                 inout float3 diffuse,
                 inout float3 specular)
{
#if DIR_LIGHTS > 0
   // This covers regular dirs and fake spots.

   DirLights(pos, 
            normal, 
            specFactor, 
            viewDir, 
            lightProjPos, 
            diffuse, 
            specular);

#else // Point lights

   PointLights(pos,
              normal,
              specFactor,
              viewDir,
              lightProjPos, 
              diffuse,
              specular);

#endif // POINT_TEST

#if PROJ_LIGHTS > 0

#if 1
   ProjLights(pos, 
               normal, 
               specFactor, 
               viewDir, 
               lightProjPos, 
               diffuse, 
               specular);
#else
float4x3 xxx;
xxx[0] = float3(1.f, 0.f, 0.f); 
xxx[1] = float3(0.f, -1.f, 0.f);
xxx[2] = float3(0.f, 0.f, -.296f);
xxx[3] = float3(14.75f, -43.1932f, 63.2f);

#if 0
= float3x4(1.f, 0.f, 0.f, 14.75f, 
                        0.f, -1.f, 0.f, -43.1932f,
                        0.f, 0.f, -0.296f, 63.2f);
#endif

float3 uvw = ProjSpot(float4(pos.xyz, 1.f), xxx);
uvw.xy /= uvw.z;
diffuse.rg = uvw.xy;
#endif
#endif // PROJ_LIGHTS > 0

}

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

#endif // SH_LIGHTING_FX
