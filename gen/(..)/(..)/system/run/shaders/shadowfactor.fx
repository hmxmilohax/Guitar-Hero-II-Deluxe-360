
#ifndef PS_SHADOW_FACTOR_FX
#define PS_SHADOW_FACTOR_FX

#ifdef HX_XBOX
float ComputeShadowFactor( float3 pos, float4 lightProjPos )
{
   const int kPoissonTaps = 8;
   const float2 kPoissonFilter[kPoissonTaps] = 
   {
      float2( 0.000000f, 0.000000f ),
      float2( 0.527837f,-0.085868f ),
      float2(-0.040088f, 0.536087f ),
      float2(-0.670445f,-0.179949f ),
      float2(-0.419418f,-0.616039f ),
      float2( 0.440453f,-0.639399f ),
      float2(-0.757088f, 0.349334f ),
      float2( 0.574619f, 0.685879f ),
   };
   const float InvShadowMapScale = 1.0f / 256.0f;

   lightProjPos.xyz /= lightProjPos.w;

   // Essentialy random angle for each screen pixel
   float fAngle = (tex2D( gPoissonRotationTex, pos.xy ).x * 2.0 - 1.0) * 3.14159;

   // Rotation and scale
   float4 rotScale;
   sincos(fAngle, rotScale.x, rotScale.y);
   rotScale.xyw = rotScale.xyx * InvShadowMapScale;
   rotScale.z = -rotScale.y;

   float2 coord1 = lightProjPos.xy + (kPoissonFilter[0].x * rotScale.xy) + (kPoissonFilter[0].y * rotScale.zw);
   float2 coord2 = lightProjPos.xy + (kPoissonFilter[1].x * rotScale.xy) + (kPoissonFilter[1].y * rotScale.zw);
   float2 coord3 = lightProjPos.xy + (kPoissonFilter[2].x * rotScale.xy) + (kPoissonFilter[2].y * rotScale.zw);
   float2 coord4 = lightProjPos.xy + (kPoissonFilter[3].x * rotScale.xy) + (kPoissonFilter[3].y * rotScale.zw);
   float2 coord5 = lightProjPos.xy + (kPoissonFilter[4].x * rotScale.xy) + (kPoissonFilter[4].y * rotScale.zw);
   float2 coord6 = lightProjPos.xy + (kPoissonFilter[5].x * rotScale.xy) + (kPoissonFilter[5].y * rotScale.zw);
   float2 coord7 = lightProjPos.xy + (kPoissonFilter[6].x * rotScale.xy) + (kPoissonFilter[6].y * rotScale.zw);
   float2 coord8 = lightProjPos.xy + (kPoissonFilter[7].x * rotScale.xy) + (kPoissonFilter[7].y * rotScale.zw);

   // Fetch the bilinear filter fractions and four samples from the depth texture. The LOD for the 
   // fetches from the depth texture is computed using aniso filtering so that it is based on the 
   // minimum of the x and y gradients (instead of the maximum).  
   float LOD;
   LOD = 0.f;
   float4 d1, d2;
   asm 
   {
//      getCompTexLOD2D LOD.x, lightProjPos.xy, gShadowMap, AnisoFilter=max16to1
         setTexLOD LOD.x

         tfetch2D d1.x___, coord1.xy, gShadowMap, UseComputedLOD=false, UseRegisterLOD=true
         tfetch2D d1._x__, coord2.xy, gShadowMap, UseComputedLOD=false, UseRegisterLOD=true
         tfetch2D d1.__x_, coord3.xy, gShadowMap, UseComputedLOD=false, UseRegisterLOD=true
         tfetch2D d1.___x, coord4.xy, gShadowMap, UseComputedLOD=false, UseRegisterLOD=true

         tfetch2D d2.x___, coord5.xy, gShadowMap, UseComputedLOD=false, UseRegisterLOD=true
         tfetch2D d2._x__, coord6.xy, gShadowMap, UseComputedLOD=false, UseRegisterLOD=true
         tfetch2D d2.__x_, coord7.xy, gShadowMap, UseComputedLOD=false, UseRegisterLOD=true
         tfetch2D d2.___x, coord8.xy, gShadowMap, UseComputedLOD=false, UseRegisterLOD=true
   };

#if 0
   float kZBias = -0.005f;
   lightProjPos.z += kZBias;
#endif

   float4 attenuation1 = 1.f - step( d1, lightProjPos.z );
   float4 attenuation2 = 1.f - step( d2, lightProjPos.z );

   float4 weights = { 1.0 / kPoissonTaps, 1.0 / kPoissonTaps, 
      1.0 / kPoissonTaps, 1.0 / kPoissonTaps };

   return dot( attenuation1, weights ) + dot( attenuation2, weights );
   
}

#else // HX_PC

float ComputeShadowFactor( float3 pos, float4 lightProjPos )
{
   float  SampleWeight = 0.0625;
   float  zBias        = -0.005;

   // Jittered sample offset table for 1k shadow maps
   const float4 offsetTable[8] = {
      { -0.000692, -0.000868, -0.002347,  0.000450 },
      {  0.000773, -0.002042, -0.001592,  0.001880 },
      { -0.001208, -0.001198, -0.000425, -0.000915 },
      { -0.000050,  0.000105, -0.000753,  0.001719 },
      { -0.001855, -0.000004,  0.001140, -0.001212 },
      { 0.000684,   0.000273,  0.000177,  0.000647 },
      { -0.001448,  0.002095,  0.000811,  0.000421 },
      { 0.000542,   0.001491,  0.000537,  0.002367 }
   };

   lightProjPos.xyz /= lightProjPos.w;

   // Add z-bias to incoming light-space depth to avoid z-fighting
   float depthWithBias = lightProjPos.z + zBias;    

   float4 jittered[16];
   jittered[0]  = lightProjPos + offsetTable[0].xyzw;
   jittered[1]  = lightProjPos + offsetTable[0].wzyx;
   jittered[2]  = lightProjPos + offsetTable[1].xyzw;
   jittered[3]  = lightProjPos + offsetTable[1].wzyx;
   jittered[4]  = lightProjPos + offsetTable[2].xyzw;
   jittered[5]  = lightProjPos + offsetTable[2].wzyx;
   jittered[6]  = lightProjPos + offsetTable[3].xyzw;
   jittered[7]  = lightProjPos + offsetTable[3].wzyx;
   jittered[8]  = lightProjPos + offsetTable[4].xyzw;
   jittered[9]  = lightProjPos + offsetTable[4].wzyx;
   jittered[10] = lightProjPos + offsetTable[5].xyzw;
   jittered[11] = lightProjPos + offsetTable[5].wzyx;
   jittered[12] = lightProjPos + offsetTable[6].xyzw;
   jittered[13] = lightProjPos + offsetTable[6].wzyx;
   jittered[14] = lightProjPos + offsetTable[7].xyzw;
   jittered[15] = lightProjPos + offsetTable[7].wzyx;

   float taps[16];
   for( int i = 0; i < 16; i++ )
   {
      taps[i] = tex2D( gShadowMap, jittered[i] ).x;
   }

   float4 shadowFactor = (float4)0;

   for( int i = 0; i < 16; i+=4 )
   {
      float4 swizzledTap;
      swizzledTap.x = taps[i+0];
      swizzledTap.y = taps[i+1];
      swizzledTap.z = taps[i+2];
      swizzledTap.w = taps[i+3];
      swizzledTap = depthWithBias - swizzledTap;

      float4 res = (swizzledTap < 0.0);
      shadowFactor += dot( res, SampleWeight );
   }

   return shadowFactor.x;
}
#endif // HX_PC

#endif // PS_SHADOW_FACTOR_FX
