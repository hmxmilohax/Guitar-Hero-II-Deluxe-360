//----------------------------------------------------------------------------
//
//  Copyright (c) 1995-2000 Harmonix Music Systems Inc., All Rights Reserved.
//
//----------------------------------------------------------------------------

#include "common.fx"
#include "lighting.fx"
#include "standard_ps.fx"
#include "standard_vs.fx"

PS_INPUT vshader(VS_INPUT I)
{
	return standard_vshader(I);
}

float4 pshader(PS_INPUT I): COLOR
{
	return standard_pshader(I);
}
