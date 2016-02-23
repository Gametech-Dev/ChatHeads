
//--------------------------------------------------------------------------------------
// Copyright 2014 Intel Corporation
// All Rights Reserved
//
// Permission is granted to use, copy, distribute and prepare derivative works of this
// software for any purpose and without fee, provided, that the above copyright notice
// and this statement appear in all copies.  Intel makes no representations about the
// suitability of this software for any purpose.  THIS SOFTWARE IS PROVIDED "AS IS."
// INTEL SPECIFICALLY DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, AND ALL LIABILITY,
// INCLUDING CONSEQUENTIAL AND OTHER INDIRECT DAMAGES, FOR THE USE OF THIS SOFTWARE,
// INCLUDING LIABILITY FOR INFRINGEMENT OF ANY PROPRIETARY RIGHTS, AND INCLUDING THE
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  Intel does not
// assume any responsibility for any errors which may appear in this software nor any
// responsibility to update it.
//--------------------------------------------------------------------------------------
// Generated by ShaderGenerator.exe version 0.13
//--------------------------------------------------------------------------------------
#define UV_LAYER_1

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

// -------------------------------------
layout (std140, row_major) uniform cbPerModelValues
{
   mat4 World;
   mat4 NormalMatrix;
   mat4 WorldViewProjection;
   mat4 InverseWorld;
   mat4 LightWorldViewProjection;
   vec4 BoundingBoxCenterWorldSpace;
   vec4 BoundingBoxHalfWorldSpace;
   vec4 BoundingBoxCenterObjectSpace;
   vec4 BoundingBoxHalfObjectSpace;
};

// -------------------------------------
layout (std140, row_major) uniform cbPerFrameValues
{
   mat4  View;
   mat4  InverseView;
   mat4  Projection;
   mat4  ViewProjection;
   vec4  AmbientColor;
   vec4  LightColor;
   vec4  LightDirection;
   vec4  EyePosition;
   vec4  TotalTimeInSeconds;
};

#ifdef GLSL_VERTEX_SHADER

#define POSITION  0
#define NORMAL    1
#define BINORMAL  2
#define TANGENT   3
#define COLOR   4
#define TEXCOORD0 5
#define TEXCOORD1 6

// -------------------------------------
layout (location = POSITION)  in vec3 Position; // Projected position
layout (location = NORMAL)    in vec3 Normal;
layout (location = TANGENT)   in vec3 Tangent;
layout (location = BINORMAL)  in vec3 Binormal;
layout (location = TEXCOORD0) in vec2 UV0;
#ifdef UV_LAYER_1
layout (location = TEXCOORD1) in vec2 UV1;
#endif
// -------------------------------------
out vec4 outPosition;
out vec3 outNormal;
#ifdef USE_NORMALMAP
out vec3 outTangent;
out vec3 outBinormal;
#endif

out vec2 outUV0;
#ifdef UV_LAYER_1
out vec2 outUV1;
#endif
out vec3 outWorldPosition; // Object space position 
#endif //GLSL_VERTEX_SHADER

#ifdef GLSL_VERTEX_SHADER
// -------------------------------------
void main( )
{

    outPosition      = vec4( Position, 1.0) * WorldViewProjection;
    outWorldPosition = (vec4( Position, 1.0) * World ).xyz;

    // TODO: transform the light into object space instead of the normal into world space
    outNormal   = Normal   * mat3(World);
#ifdef USE_NORMALMAP
	outTangent = Tangent * mat3(World);
	outBinormal = Binormal * mat3(World);
#endif
    outUV0 = UV0;
#ifdef UV_LAYER_1
    outUV1 = UV1;
#endif
    gl_Position = outPosition;
}

#endif //GLSL_VERTEX_SHADER


#ifdef GLSL_FRAGMENT_SHADER
// -------------------------------------
in vec4 outPosition;
in vec3 outNormal;
in vec2 outUV0;
#ifdef USE_NORMALMAP
in vec3 outTangent;
in vec3 outBinormal;
#endif
#ifdef UV_LAYER_1
in vec2 outUV1;
#endif
in vec3 outWorldPosition; // Object space position 

/*
Requires Diffuse, specular, specularity, ambient 
Optional defines (for material file):
    UV_LAYER_1
    USE_NORMALMAP (allows normal function)
    USE_EMISSIVE  (allows emissive function)
*/

// -------------------------------------
uniform sampler2D texture_ST;
uniform sampler2D texture_DM;
uniform sampler2D texture_SM;
uniform sampler2D texture_NM;
uniform sampler2D texture_AO;
// -------------------------------------
vec4 DIFFUSE( )
{
    return texture(texture_DM,(((outUV0)) *(2.000000)) );
}

// -------------------------------------
vec4 SPECULARTMP( )
{
    return texture(texture_SM,(((outUV0)) *(20.000000)) );
}

// -------------------------------------
float SPECULARITY( )
{
    return ((( (texture(texture_ST,(((outUV0)) *(20.000000)) ) ).r )) *(128.000000)) +(4.000000);
}

// -------------------------------------
vec4 NORMALS( )
{
    return texture(texture_NM,(((outUV0)) *(2.000000)) ) * 2.0 - 1.0;
}

// -------------------------------------
vec4 SPECULAR( )
{
    return (SPECULARTMP()) *(50.000000);
}

// -------------------------------------
vec4 AMBIENTOCC( )
{
    return texture(texture_AO,((outUV1)) );
}

// -------------------------------------
vec4 AMBIENT( )
{
    return ((DIFFUSE()) *(AMBIENTOCC())) *(5.000000);
}

// -------------------------------------


// -------------------------------------
out vec4 fragColor;
// -------------------------------------
vec3 ComputeNormal()
{
    vec3 normal;
#ifdef USE_NORMALMAP
    mat3 tangentToWorld = mat3(outTangent, outBinormal, outNormal);
    normal = normalize( tangentToWorld * NORMALS().rgb );
#else
    normal = normalize(outNormal);
#endif
    return normal;
}
void main( )
{
    vec4 result = vec4(0.0, 0.0, 0.0, 1.0);
#ifdef ENABLE_CLIP
    result.a = ALPHA().a;
    if(result.a < CLIPTHRESHOLD().a)
        discard;
#endif
    vec3 normal = ComputeNormal();

    // Specular-related computation
    vec3 eyeDirection  = normalize(outWorldPosition - EyePosition.xyz);
    vec3 Reflection    = reflect( eyeDirection, normal );
    float  shadowAmount = 1.0;

    // Ambient-related computation
    vec3 ambientLight = AmbientColor.rgb * AMBIENT().rgb;
    
    vec3 lightDirection = -LightDirection.xyz;

    // Diffuse-related computation
    float  nDotL = max( 0.0, dot( normal, lightDirection ) );
    vec3 diffuseLight = LightColor.rgb * nDotL * shadowAmount  * DIFFUSE().rgb;
    result = vec4((diffuseLight + ambientLight), DIFFUSE().a);
	if(nDotL > 0.0)
	{
		float  rDotL = max(0.0, dot( Reflection, lightDirection ));
		vec3 specular = pow(rDotL, SPECULARITY() ) * SPECULAR().rgb * LightColor.rgb;
		result.xyz += specular;
	}
#ifdef USE_EMISSIVE
	result.xyz += EMISSIVE().xyz;
#endif
    fragColor =  result;
}

#endif //GLSL_FRAGMENT_SHADER
