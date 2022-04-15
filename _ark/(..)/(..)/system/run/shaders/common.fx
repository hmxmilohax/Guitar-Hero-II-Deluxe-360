//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------

#ifndef VS_PS_COMMON_FX
#define VS_PS_COMMON_FX

//----------------------------------------------------------------------------
// Common Shader Constants
// 
// These are used in both vertex/pixel shaders; declared here only once.
//
float4 gDiffuse    : register(c0);
float4 gSpecular   : register(c2);  // rgb = color if no map, a = power

float4x4 gTexCoord : register(c20);

float4 gLight[7]   : register(c64); // reg [64..70]
float4 gLightCol[7]: register(c72); // reg [72..78]


//----------------------------------------------------------------------------
// Vertex Shader Constants
// 
float3 gAmbient    : register(c1);

float4x4 gViewProj : register(c4);
float4x4 gView	    : register(c8);
float4x4 gCamera   : register(c16);

float4x4 gModel0   : register(c24);
float4x4 gModel1   : register(c28);
float4x4 gModel2   : register(c32);
float4x4 gModel3   : register(c36);
float4x4 gWorldToLightProj : register(c40);

float4 gExtrudePos : register(c44);
float4 gExtrudeDir : register(c45);
float4 gExtrudePlane : register(c46);

float4 gParticleRight : register(c47); // local-space basis, scaled by 0.5
float4 gParticleUp    : register(c48);

float3 gEnvAmbient : register(c71);

float  gMultiMeshIndices : register(c89);
float4 gFadeRange : register(c90);
float4 gFogRange  : register(c91);  // x == end, y == (end - start)^-1

float4x4 gTransformList[32] : register(c92);

//----------------------------------------------------------------------------
// Pixel Shader Constants
// 
float4 gMultipliers          : register(c5);   // x:emissive, y:intensity
float4 gBloomIntensity		  : register(c6);   // Bloom intensity
float4 gBloomThresholds		  : register(c7);   // Bloom thresholds

// The following are in projection space
float4 gDepthOfField          : register(c24); // Depth of field parameters
// Couple of unused slots here
float  gUIPlaneDistance		  : register(c28); // Near-z point to disable focal blur
float2 gFOVPixelSizeLow		  : register(c29); // Pixel size for focal blur buffer
float2 gFOVPixelSizeHigh	  : register(c30); // Pixel size for screen buffer
float4 gBlurSampleOffsets[16] : register(c31); // Blur filter
float4 gBlurSampleWeights[16] : register(c47); // Blur weights

float4 gNoisePhase            : register(c78);
float4 gNoiseScale            : register(c79);
float4 gPreviousSelect        : register(c80);
float4 gFogRamp               : register(c81);
float4 gFogDensity            : register(c82);
float4 gFogXfm                : register(c83); // xy = scale, zw = offset
float4 gFogAmbient            : register(c84);
float4 gScreenSize            : register(c85); // (w,h,1/w,1/h);
float4 gSpotPos               : register(c86);
float4 gSpotDir               : register(c87);
float4 gSpotRight             : register(c88);
float4 gZRange                : register(c89); // (n,f,minZ, minZ/(maxZ-minZ))

float4 gFogColor              : register(c90);
row_major float3x4 gColorXfm            : register(c92); // registers 92-94

float4x3 gProjXfm                : register(c95); // reg 95-103
float4x3 gProjXfm1               : register(c98); // reg 95-103
float4x3 gProjXfm2               : register(c101  ); // reg 95-103

float4 gFadeColor             : register(c104);

// Maps must be (s0-s3) for vertex shader, (s0-s15) for pixel shader.
sampler2D   gDiffuseMap : register(s0);
sampler2D   gNormalMap  : register(s1);
sampler2D   gSpecularMap: register(s2);
sampler2D   gGlowMap    : register(s3);
samplerCUBE gEnvironMap : register(s4);
sampler2D	gShadowMap  : register(s5);
sampler2D	gShadowMap1	: register(s6);
sampler2D	gShadowMap2	: register(s7);
sampler2D   gFloorSpot  : register(s8);
sampler2D   gFloorSpot1 : register(s9);
sampler2D   gFloorSpot2 : register(s10);
sampler1D   gCustomDiffuse : register(s11);
sampler2D	gFocalBlurHiRes : register(s7);
sampler2D   gFocalBlurLoRes : register(s8);
sampler2D	gFocalBlurDepth : register(s9);
sampler2D	gFocalBlurBloom : register(s10);
sampler1D	gLuminanceMap : register(s11);
sampler2D   gDownsampleCollapseSrc1 : register(s7);
sampler2D   gDownsampleCollapseSrc2 : register(s8);
sampler2D   gBloomSource : register(s7);
sampler2D	gPoissonRotationTex : register(s15);
sampler2D   gPreviousFrame : register(s14);
sampler2D   gFogDepth : register(s12);
sampler2D   gFogDensityMap : register(s6);
sampler1D   gSpotXSectionMap : register(s11);
sampler2D   gNoiseMap : register(s13);

// put color into 10-bit format
float  pack_color(float  x)   { return x / 4; }
float2 pack_color(float2 x)   { return x / 4; }
float3 pack_color(float3 x)   { return x / 4; }
float4 pack_color(float4 x)   { return float4(x.rgb / 4, x.a); }

// restore color from 10-bit format
float  unpack_color(float  x)   { return x * 4; }
float2 unpack_color(float2 x)   { return x * 4; }
float3 unpack_color(float3 x)   { return x * 4; }
float4 unpack_color(float4 x)   { return float4(x.rgb * 4, x.a); }

// expand: [0, 1] => [-1, +1]
float  expand(float  x) { return (2*x) - 1; }
float2 expand(float2 x) { return (2*x) - 1; }
float3 expand(float3 x) { return (2*x) - 1; }
float4 expand(float4 x) { return (2*x) - 1; }

// narrow: [-1, +1] => [0, 1]
float  narrow(float  x) { return (x+1) / 2; }
float2 narrow(float2 x) { return (x+1) / 2; }
float3 narrow(float3 x) { return (x+1) / 2; }
float4 narrow(float4 x) { return (x+1) / 2; }

#endif // VS_PS_COMMON_FX
