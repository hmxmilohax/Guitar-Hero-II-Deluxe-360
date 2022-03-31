//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------

float light_cost(float4 light)
{
   float k = 0;

#if ENABLE_ENVIRON_MAP

#if ENABLE_CUSTOM_DIFFUSE
   if (light.w)
      k = 0.35;
   else
      k = 0.31;
#else
   if (light.w)
      k = 0.28;
   else
      k = 0.15;
#endif
   
#else

#if ENABLE_CUSTOM_DIFFUSE

#if ENABLE_SPECULAR
   if (light.w)
      k = 0.97;
   else
      k = 0.89;
#else
   if (light.w)
      k = 0.46;
   else
      k = 0.31;
#endif

#else

#if ENABLE_SPECULAR
   if (light.w)
      k = 0.74;
   else
      k = 0.57;
#else
   if (light.w)
      k = 0.43;
   else
      k = 0.15;
#endif

#endif   // ENABLE_CUSTOM_DIFFUSE

#endif   // ENABLE_ENVIRON_MAP

   return k;
}

float4 pixel_cost()
{
   float cost = 0;

#if !NUM_LIGHTS
   // !use_environ


#if ENABLE_DIFFUSE_MAP
   cost += 0.08;
#endif
#if ENABLE_GLOW_MAP
   cost += 0.11;
#endif
#if ENABLE_ENVIRON_MAP
   cost += 0.305;
#endif


#else
   // use_environ


#if ENABLE_DIFFUSE_MAP
   cost += 0.102;
#endif
#if ENABLE_GLOW_MAP
   cost += 0.083;
#endif
#if ENABLE_NORMAL_MAP
   cost += 0.583;
#endif

#if ENABLE_ENVIRON_MAP
   cost += 0.309;
#endif

   cost += light_cost(gLight[0]);
#if NUM_LIGHTS > 1
   cost += light_cost(gLight[1]);
#if NUM_LIGHTS > 2
   cost += light_cost(gLight[2]);
#if NUM_LIGHTS > 3
   cost += light_cost(gLight[3]);
#endif
#endif
#endif


#endif

#if !ENABLE_DIFFUSE_RGB && !ENABLE_DIFFUSE_ALPHA
   //prelit
   cost *= 1.19;
#endif

   // estimatated scale to [0, 1]
   cost /= 3;  // 4? 5? 5.5?

   float4 shade;

   shade.r = saturate(2*cost);
   shade.g = saturate(2 - 2*cost);
   shade.b = 0;
   shade.a = 1;

   return shade;
}

