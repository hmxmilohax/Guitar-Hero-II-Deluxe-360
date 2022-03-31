
#ifndef VS_DEPTH_FX
#define VS_DEPTH_FX

// Collection of simple depth related helper funcs.

float3 ExtrudeToPlane(float3 pos, float3 norm)
{
   float3 toPt = (pos - gExtrudePos.xyz);
   float denom = dot(toPt, gExtrudePlane.xyz);
   float numer = gExtrudePlane.w - dot(pos, gExtrudePlane.xyz);
   float3 extrude = toPt * numer / denom;

//extrude = toPt;
   extrude = dot(norm, extrude) > 0.f ? extrude : float3(0.f, 0.f, 0.f);
   float fadeOut = dot(gExtrudeDir.xyz, normalize(toPt)) - gExtrudeDir.w;
   fadeOut = fadeOut > 0.f ? 1.f : 0.f;
   extrude *= fadeOut;
   
   return pos + extrude;
}

float3 ExtrudePosition(float3 pos, float3 norm)
{
   float3 toPt = (pos - gExtrudePos.xyz);
   float invLen = rsqrt(dot(toPt, toPt));
   toPt *= invLen;
   float len = 1.f / invLen;
   
   float extrudeDist = gExtrudePos.w > len ? gExtrudePos.w - len : 0.f;

   toPt = dot(norm, toPt) > 0.f ? toPt : float3(0.f, 0.f, 0.f);
   float fadeOut = dot(gExtrudeDir.xyz, toPt) - gExtrudeDir.w;
   fadeOut = fadeOut > 0.f ? 1.f : 0.f;
   toPt *= fadeOut;

   pos += toPt * extrudeDist;

   return pos;
}

float NonLinearDistance(float depth, float halfMark)
{
   return 1.f - saturate(halfMark / (halfMark + depth));
}

float2 NonLinearDistance(float2 depth, float halfMark)
{
   return 1.f - saturate(halfMark / (halfMark + depth));
}

float3 NonLinearDistance(float3 depth, float halfMark)
{
   return 1.f - saturate(halfMark / (halfMark + depth));
}

float4 NonLinearDistance(float4 depth, float halfMark)
{
   return 1.f - saturate(halfMark / (halfMark + depth));
}

float ZtoW(float z)
{
   z = z * gZRange.z - gZRange.w;
//   z = z / 1.111111f - 0.1f / 1.111111f;
   float zn = gZRange.x;
   float zf = gZRange.y;
   float w = zn * zf / (zf - z * (zf - zn));
   
   return w;
}

float ScreenW(float2 screenPos, sampler2D depthTex)
{
   
   float fbDepth = 1.f - tex2D( depthTex, screenPos ).x;
   fbDepth = ZtoW(fbDepth);
   
   return fbDepth;
}

float3 DepthFade(float3 color, float4 projPos)
{
   float2 screenPos = projPos.xy / projPos.ww;
   screenPos *= float2(0.5f, -0.5f);
   screenPos += float2(0.5f, 0.5f);
   float fbDepth = ScreenW(screenPos, gFocalBlurDepth);

   float fade = saturate((fbDepth - projPos.w) * gFogRange.x);

   return color * fade;
}

#endif // VS_DEPTH_FX
