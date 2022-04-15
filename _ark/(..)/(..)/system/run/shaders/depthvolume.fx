
#include "common.fx"

#include "transform.fx"
#include "depth.fx"

struct VS_INPUT
{
   float3 position         : POSITION;
   float3 normal           : NORMAL;
#if NUM_WEIGHTS > 0
   float3 weights   : BLENDWEIGHT;
#endif
};

struct PS_INPUT
{
   float4 projPos   : POSITION;
   float4 depth     : TEXCOORD0;
   float3 worldPos  : TEXCOORD1;
};

float CrossSection(float3 worldPos)
{
   float3 del = (worldPos - gSpotPos.xyz);
   float delDotDir = dot(del, gSpotDir.xyz);
   float delDotRight = dot(del, gSpotRight.xyz);
   
   float denom = gSpotDir.w + gSpotRight.w * delDotDir;
   
//return denom / 31.f;

//return delDotRight / 61.f * 0.5f + 0.5f;

   float u = abs(delDotRight / denom);
 
//return u;
  
   float mapped = tex1D( gSpotXSectionMap, u).x;

   return 1.f - gSpotPos.w + mapped * gSpotPos.w;
}

#if EXTRUDE // extrusion of body for cutouts

float4 pshader( PS_INPUT pIn ) : COLOR0
{
   return float4(0.f, 0.f, 0.f, 1.f); // we don't use this shader, it's Z-only
}

#elif DENSITY // blit the density buffer onto the cone depth buffer

float4 pshader( PS_INPUT pIn ) : COLOR0
{
return float4(1.f, 1.f, 1.f, 1.f);

   // Read the depth buffer
   // Since we're doing this with a blit, the incoming screen
   // position is in actual pixel units, unstead of the more useful
   // NDC.
   float2 screenPos = pIn.depth.xy;
   float fbDepth = ScreenW(screenPos.xy * gScreenSize.zw, gFocalBlurDepth);
   
   // Read the density map
   float2 denseUV = screenPos * gFogXfm.xy + gFogXfm.zw;
   float2 density = tex2D( gFogDensityMap, denseUV ).xy;
   
   density *= gFogDensity.yw;
   density += gFogDensity.xz;
   
   float fog = saturate((fbDepth - gFogRange.z) * gFogRange.w);
//float fog = NonLinearDistance(fbDepth, gFogRange.z);
   density.y *= fog;

   return density.xxxy;
}

#else // Render cone depths

float4 pshader( PS_INPUT pIn ) : COLOR0
{
   float2 screenPos = pIn.depth.xy / pIn.depth.ww;
   
   float2 del = (gFogRamp.xy - screenPos) * gFogRamp.zw;
   float illum = saturate(1.f - length(del));

   illum *= illum;
   
#if 1
   float xsection = CrossSection(pIn.worldPos);
//return float4(xsection, xsection, xsection, xsection);

   illum *= xsection;
#endif
   
   screenPos *= float2(0.5f, -0.5f);
   screenPos += float2(0.5f, 0.5f);

   float fbDepth = ScreenW(screenPos, gFocalBlurDepth);
   float cutOutDepth = ScreenW(screenPos, gFogDepth);

   fbDepth = min(fbDepth, cutOutDepth);

   float depth = min(fbDepth, pIn.depth.w);

   depth += gFogRange.y; // Bias back by closest point
   depth = saturate(depth * gFogRange.x);

   float2 density = tex2D( gFogDensityMap, screenPos ).xy;
 
   density.y = NonLinearDistance(density.y, 0.125f);  
   
   density.y *= gFogDensity.w;
   density.y += gFogDensity.z;
   float fog = saturate((pIn.depth.w - gFogDensity.x) * gFogDensity.y);
//float fog = NonLinearDistance(pIn.depth.w, gFogDensity.x);
   depth *= 1.f - saturate(density.y * fog);

   return float4(gFogColor.xyz * depth * illum, 0.f);
}

#endif //

PS_INPUT vshader( VS_INPUT vIn )
{
   PS_INPUT pOut;
   
   float3 weights = 0;
#if NUM_WEIGHTS > 0
   weights = vIn.weights;
#endif

   float3 pos  = vIn.position;
   float3 norm = vIn.normal;
   float3 tang = 0;

   Transform(weights, pos, norm, tang);

#if EXTRUDE
//   pos = ExtrudePosition(pos, norm);
pos = ExtrudeToPlane(pos, norm);
#endif // EXTRUDE

   pOut.worldPos     = pos;
   pOut.projPos      = Project(pos);
   pOut.depth        = pOut.projPos;

   return pOut;
}

