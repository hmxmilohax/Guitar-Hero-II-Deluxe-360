//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Vertex Shader Constants
// 

#include "common.fx"
#include "depth.fx"

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

float ComputeDepthBlur( float z )
{
   return clamp(abs(z * gDepthOfField.x + gDepthOfField.y), gDepthOfField.z, gDepthOfField.w);
}

float4 DOFPixel( float4 tapHi, float depth, float2 screenPos )
{	
	float4 tapLo   = tex2D( gFocalBlurLoRes, screenPos );
 	return lerp( tapHi, tapLo, abs(ComputeDepthBlur( depth )) );
}

float4 BloomPixel( float4 input, float2 screenPos )
{
	float4 bloomedPixel = tex2D( gFocalBlurBloom, screenPos );
	bloomedPixel.rgb += bloomedPixel.a; // add white bloom
		
	return input + (bloomedPixel*gBloomIntensity);
}

float4 LuminanceMapPixel( float4 input, float2 screenPos )
{
	const float3 LuminanceVector = float3(0.2125f, 0.7154f, 0.0721f);
	
	float lum = pack_color(dot(input.rgb, LuminanceVector));
	float newLum = tex1D( gLuminanceMap, lum ).r;

//   lum = max(lum, 1.f);
//   newLum *= 1.f / lum;
//   or  if( lum > 1.f )numLum /= lum;
//   This makes white always neutral, making
//   say 3.5 map to 1.0, just like the saturate would have done.
   newLum *= lum > 1.f ? 1.f / lum : 1.f;
   	
//return float4(lum, lum, lum, input.a);
//return float4(newLum, newLum, newLum, input.a);

   return float4(input.rgb * newLum, input.a);
}

float3 ColorRemap( float3 input )
{
   return mul(gColorXfm, float4(input.x, input.y, input.z, 1.f)).xyz;
}

float3 Noise( float3 input, float2 screenPos )
{
   float3 noise0 = tex2D( gNoiseMap, (screenPos + gNoisePhase.xy ) * gNoiseScale.xy );
   float3 noise1 = tex2D( gNoiseMap, (screenPos + gNoisePhase.zw ) * gNoiseScale.xy * gNoiseScale.z );
   return input + ( noise0 * noise1 * gNoiseScale.w );
}

float3 Posterize( float3 input )
{
   float gNumPosterLevels = 3.f;
   
   float3 output;
   input *= gNumPosterLevels;
   modf( input, output );

   return output / gNumPosterLevels; 
}

float3 BlendPreviousNoAlphaBuffer(float3 input, float2 screenPos)
{
   float3 prev = tex2D( gPreviousFrame, screenPos );
	float intensity = dot(prev.xyz, gPreviousSelect.zzz);
	
   prev = intensity.xxx < gPreviousSelect.xxx ? gPreviousSelect.www : prev;
	
   prev *= gPreviousSelect.y;
   
   return max(input, prev);
}

float4 BlendPreviousAlphaBuffer(float3 input, float2 screenPos)
{
   // Get previous frame value
   float4 prev = tex2D( gPreviousFrame, screenPos );
   
   // Decay
   prev.rgb = saturate(prev.rgb - gPreviousSelect.yyy);
   
   // average the components (gPreviousSelect.z == 1/3)
   float prevTest = dot(prev.rgb, gPreviousSelect.zzz);
   
   // If greater than thresh
   //    keep value
   // else
   //    multiply value by alpha.
   // So we keep the value if (value > thresh) || (prev.a == 1.f)
   // Note this assumes alpha is either 0 or 1.
   prevTest = prevTest > gPreviousSelect.x ? prevTest : prevTest * prev.a;
   
   // Compute an equivalent luminance val for comparison
   float inputTest = dot(input, gPreviousSelect.zzz);
   
   // If prev is brighter
   //    take prev color and set alpha to 1
   // else
   //    keep color value same and set alpha to 0
   float4 output = prevTest > inputTest 
                           ? float4(prev.r, prev.g, prev.b, 1.f)
                           : float4(input.r, input.g, input.b, 0.f);

   return output;
}

float4 NewHUDOldWorld( float2 screenPos )
{
	float depth = 1.0f - tex2D( gFocalBlurDepth, screenPos ).x;	
	if ( depth > gUIPlaneDistance )
	{
	   return tex2D( gPreviousFrame, screenPos );
	}
	else
	{
   	return unpack_color( tex2D( gFocalBlurHiRes, screenPos ) );
	}
}

float4 FogPixel( float4 input, float zDepth, float2 screenPos )
{
   float2 density = tex2D( gFogDensityMap, screenPos );
   
   density = NonLinearDistance(density, 0.125f);  
   
   density *= gFogDensity.yw;
   density += gFogDensity.xz;

   float4 fogDepth = tex2D( gFogDepth, screenPos );
   fogDepth *= density.xxxy;
   
//fogDepth = NonLinearDistance(fogDepth, 0.125f);
   
   float wDepth = ZtoW(zDepth);
   
   float fog = saturate((wDepth - gFogRange.z) * gFogRange.w);
//float fog = NonLinearDistance(fbDepth, gFogRange.z);
   density.y *= fog;

   input.rgb = lerp(input.rgb, gFogAmbient.rgb, fogDepth.a);
   input.rgb += fogDepth.rgb * gFogRange.x;
 
//return fogDepth.aaaa;  
   return input;
}

float4 ProcessWorldOnly( float4 input, float2 screenPos )
{
   float4 output = input;
   
	float depth = 1.0f - tex2D( gFocalBlurDepth, screenPos ).x;	
	if ( depth > gUIPlaneDistance )
	{
#if DOF
		output = DOFPixel( output, depth, screenPos );
#endif

#if BLOOM
		output = BloomPixel( output, screenPos );
#endif

#if FOG
      output = FogPixel(output, depth, screenPos);
#endif

#if NOISE
      output.rgb = Noise( output, screenPos );
#endif // NOISE

#if COLORXFM
      output.rgb = ColorRemap( output );
#endif // COLORXFM

#if BLENDPREVIOUS
//      output.rgb = BlendPreviousNoAlphaBuffer( output, screenPos );
      output = BlendPreviousAlphaBuffer(output, screenPos);
//      output.rgb = output.a;
#endif // BLENDPREVIOUS

#if LUMMAP
	output = LuminanceMapPixel( output, screenPos );
#endif
	}
	
	return output;
}

#define PROCESSWORLD (DOF || BLOOM || COLORXFM || NOISE || BLENDPREVIOUS || LUMMAP)

float4 pshader( PS_INPUT I ) : COLOR0
{
#if !COPYPREVIOUS
	float4 output = unpack_color( tex2D( gFocalBlurHiRes, I.uv ) );
	
#if PROCESSWORLD

   output = ProcessWorldOnly(output, I.uv);
   
#endif // PROCESSWORLD

#else // !COPYPREVIOUS

   float4 output = NewHUDOldWorld( I.uv );
   
#endif // !COPYPREVIOUS

	return output;
}
