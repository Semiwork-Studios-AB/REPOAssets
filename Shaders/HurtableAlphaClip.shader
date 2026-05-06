// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hurtable/Hurtable Alpha Clip"
{
	Properties
	{
		_ColorOverlay("Color Overlay", Color) = (1,0,0,0)
		_ColorOverlayAmount("Color Overlay Amount", Range( 0 , 1)) = 0
		[Header(Albedo)][NoScaleOffset][SingleLineTexture]_AlbedoTexture("Albedo Texture", 2D) = "black" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.15
		_AlbedoColor("Albedo Color", Color) = (1,1,1,0)
		[Header(Normal)][NoScaleOffset][Normal][SingleLineTexture]_NormalTexture("Normal Texture", 2D) = "white" {}
		_NormalStrength("Normal Strength", Range( -5 , 5)) = 0
		[Header(Metallic)][NoScaleOffset][SingleLineTexture]_MetallicTexture("Metallic Texture", 2D) = "white" {}
		[Header(Other)]_Metallic("Metallic", Range( 0 , 1)) = 0
		[NoScaleOffset][SingleLineTexture]_SmoothnessTexture("Smoothness Texture", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		[Header(Tiling)]_TilingX("Tiling X", Float) = 1
		_TilingY("Tiling Y", Float) = 1
		[Header(Offset)]_OffsetX("Offset X", Float) = 1
		_OffsetY("Offset Y", Float) = 1
		[Header(Emission)][NoScaleOffset][SingleLineTexture]_EmissionTexture("Emission Texture", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[Header(Fresnel)]_FresnelAmount("Fresnel Amount", Range( 0 , 1)) = 0
		_FresnelColor("Fresnel Color", Color) = (0,0,0,0)
		_FresnelScale("Fresnel Scale", Float) = 0
		_FresnelPower("Fresnel Power", Float) = 0
		_FresnelBias("Fresnel Bias", Float) = 0
		_FresnelEmission("Fresnel Emission", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEIsFrontFacing : VFACE;
		};

		uniform sampler2D _NormalTexture;
		uniform float _TilingX;
		uniform float _TilingY;
		uniform float _OffsetX;
		uniform float _OffsetY;
		uniform float _NormalStrength;
		uniform float4 _FresnelColor;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float _FresnelAmount;
		uniform sampler2D _AlbedoTexture;
		uniform float4 _AlbedoColor;
		uniform float4 _ColorOverlay;
		uniform float _ColorOverlayAmount;
		uniform float4 _EmissionColor;
		uniform sampler2D _EmissionTexture;
		uniform float _FresnelEmission;
		uniform sampler2D _MetallicTexture;
		uniform float _Metallic;
		uniform sampler2D _SmoothnessTexture;
		uniform float _Smoothness;
		uniform float _Cutoff = 0.15;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 appendResult21 = (float2(_TilingX , _TilingY));
			float2 appendResult25 = (float2(_OffsetX , _OffsetY));
			float2 uv_TexCoord15 = i.uv_texcoord * appendResult21 + appendResult25;
			float2 UV40 = uv_TexCoord15;
			float3 Normal54 = UnpackScaleNormal( tex2D( _NormalTexture, UV40 ), _NormalStrength );
			o.Normal = Normal54;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV48 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode48 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV48, _FresnelPower ) );
			float switchResult101 = (((i.ASEIsFrontFacing>0)?(fresnelNode48):(0.0)));
			float Fresnel49 = switchResult101;
			float4 lerpResult70 = lerp( float4( 0,0,0,0 ) , ( _FresnelColor * Fresnel49 ) , _FresnelAmount);
			float4 tex2DNode2 = tex2D( _AlbedoTexture, UV40 );
			float4 Albedo68 = ( lerpResult70 + ( tex2DNode2 * _AlbedoColor ) );
			float4 lerpResult4 = lerp( Albedo68 , _ColorOverlay , _ColorOverlayAmount);
			float4 AlbedoFinal51 = lerpResult4;
			o.Albedo = AlbedoFinal51.rgb;
			float4 color93 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float4 lerpResult92 = lerp( color93 , ( _EmissionColor * tex2D( _EmissionTexture, UV40 ) ) , _EmissionColor.a);
			float4 Fresnel_Color71 = lerpResult70;
			float4 lerpResult96 = lerp( float4( 0,0,0,0 ) , Fresnel_Color71 , _FresnelEmission);
			float4 Emission57 = ( lerpResult92 + lerpResult96 );
			float4 lerpResult36 = lerp( Emission57 , _ColorOverlay , _ColorOverlayAmount);
			float4 EmissionFinal52 = lerpResult36;
			o.Emission = EmissionFinal52.rgb;
			float4 Metallic78 = ( tex2D( _MetallicTexture, UV40 ) * _Metallic );
			o.Metallic = Metallic78.r;
			float4 Smoothness84 = ( tex2D( _SmoothnessTexture, UV40 ) * _Smoothness );
			o.Smoothness = Smoothness84.r;
			o.Alpha = 1;
			float Opacity59 = tex2DNode2.a;
			clip( Opacity59 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19303
Node;AmplifyShaderEditor.CommentaryNode;102;-2832,464;Inherit;False;1008.932;404.1415;;6;49;101;48;46;47;45;Fresnel;0.9404017,0.6556604,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2784,544;Inherit;False;Property;_FresnelBias;Fresnel Bias;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2784,736;Inherit;False;Property;_FresnelPower;Fresnel Power;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2784,640;Inherit;False;Property;_FresnelScale;Fresnel Scale;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;48;-2544,544;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2784,-96;Inherit;False;Property;_TilingX;Tiling X;11;1;[Header];Create;True;1;Tiling;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2784,-32;Inherit;False;Property;_TilingY;Tiling Y;12;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2784,64;Inherit;False;Property;_OffsetX;Offset X;13;1;[Header];Create;True;1;Offset;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2784,128;Inherit;False;Property;_OffsetY;Offset Y;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;101;-2288,544;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-2608,-48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;-2608,48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-2080,544;Inherit;False;Fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-2384,-32;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;64;-1888,-1040;Inherit;False;Property;_FresnelColor;Fresnel Color;18;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;62;-1856,-864;Inherit;False;49;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-2112,-16;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1424,-880;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-1552,-768;Inherit;False;Property;_FresnelAmount;Fresnel Amount;17;1;[Header];Create;True;1;Fresnel;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;70;-1184,-880;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;26;-1472,640;Inherit;True;Property;_EmissionTexture;Emission Texture;15;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;1;Emission;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;42;-1440,832;Inherit;False;40;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-2144,-560;Inherit;False;40;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;17;-2176,-768;Inherit;True;Property;_AlbedoTexture;Albedo Texture;2;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;1;Albedo;0;0;False;0;False;None;3c8b3514d49f8fa428dfbe3e00174336;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;29;-1136,464;Inherit;False;Property;_EmissionColor;Emission Color;16;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;27;-1184,704;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-800,-880;Inherit;False;Fresnel Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;39;-1840,-576;Inherit;False;Property;_AlbedoColor;Albedo Color;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1904,-768;Inherit;True;Property;_texutresamp;texutre samp;1;0;Create;True;0;0;0;False;0;False;-1;None;ebe12bd571d52a8438b91571128a7735;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-768,528;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-544,752;Inherit;False;71;Fresnel Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;93;-848,768;Inherit;False;Constant;_Color1;Color 1;16;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;98;-576,880;Inherit;False;Property;_FresnelEmission;Fresnel Emission;22;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1376,-672;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;92;-448,544;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;96;-256,768;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-960,-736;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-64,544;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-800,-736;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-672,1344;Inherit;False;40;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-1872,1344;Inherit;False;40;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;91;-1936,1120;Inherit;True;Property;_MetallicTexture;Metallic Texture;7;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;1;Metallic;0;0;False;0;False;None;c83d8d53e54d9f2438c76061592bcb27;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;81;-704,1120;Inherit;True;Property;_SmoothnessTexture;Smoothness Texture;9;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;112,544;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;18;-1360,-96;Inherit;True;Property;_NormalTexture;Normal Texture;5;4;[Header];[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;1;Normal;0;0;False;0;False;None;None;True;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1328,96;Inherit;False;40;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;3;-160,-448;Inherit;False;Property;_ColorOverlay;Color Overlay;0;0;Create;False;0;0;0;False;0;False;1,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;58;-128,-272;Inherit;False;57;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-224,-176;Inherit;False;Property;_ColorOverlayAmount;Color Overlay Amount;1;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-144,-528;Inherit;False;68;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;82;-432,1120;Inherit;True;Property;_TextureSample2;Texture Sample 1;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-1632,1344;Inherit;False;Property;_Metallic;Metallic;8;1;[Header];Create;True;1;Other;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;75;-1632,1120;Inherit;True;Property;_TextureSample1;Texture Sample 1;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-448,1360;Inherit;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1376,192;Inherit;False;Property;_NormalStrength;Normal Strength;6;0;Create;True;0;0;0;False;0;False;0;0;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-944,-64;Inherit;True;Property;_tesss;tesss;4;1;[Header];Create;True;1;Normal;0;0;False;0;False;-1;None;a8230ab1334e66942a339b7f8f0bd7f6;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;4;176,-464;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;36;192,-320;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-80,1184;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1280,1184;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-624,-64;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;384,-448;Inherit;False;AlbedoFinal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;384,-304;Inherit;False;EmissionFinal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-800,-496;Inherit;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;78;-1104,1184;Inherit;False;Metallic;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;80,1184;Inherit;False;Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StickyNoteNode;30;-2240,-1136;Inherit;False;1742.888;786.5748;;Albedo;1,1,1,1;;0;0
Node;AmplifyShaderEditor.StickyNoteNode;31;-1504,-176;Inherit;False;1130.538;501.9589;;Normal;1,1,1,1;;0;0
Node;AmplifyShaderEditor.StickyNoteNode;32;-1552,384;Inherit;False;2087.162;603.2119;;Emission;1,1,1,1;;0;0
Node;AmplifyShaderEditor.StickyNoteNode;33;-2848,-176;Inherit;False;969.8907;423.8679;;Tiling;1,1,1,1;;0;0
Node;AmplifyShaderEditor.StickyNoteNode;34;-1984,1024;Inherit;False;1119.281;488.7639;;Metallic;1,1,1,1;;0;0
Node;AmplifyShaderEditor.StickyNoteNode;37;-291,-576;Inherit;False;1004.46;508.0621;;Color Overlay;1,1,1,1;;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;768,16;Inherit;False;51;AlbedoFinal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;768,96;Inherit;False;54;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;736,176;Inherit;False;52;EmissionFinal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;768,256;Inherit;False;78;Metallic;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;768,416;Inherit;False;59;Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StickyNoteNode;87;-784,1024;Inherit;False;1119.281;488.7639;;Smoothness;1,1,1,1;;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;768,336;Inherit;False;84;Smoothness;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1056,16;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Hurtable/Hurtable Alpha Clip;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.15;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;50;0,0,0,1;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;3;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;48;1;45;0
WireConnection;48;2;46;0
WireConnection;48;3;47;0
WireConnection;101;0;48;0
WireConnection;21;0;19;0
WireConnection;21;1;22;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;49;0;101;0
WireConnection;15;0;21;0
WireConnection;15;1;25;0
WireConnection;40;0;15;0
WireConnection;65;0;64;0
WireConnection;65;1;62;0
WireConnection;70;1;65;0
WireConnection;70;2;100;0
WireConnection;27;0;26;0
WireConnection;27;1;42;0
WireConnection;71;0;70;0
WireConnection;2;0;17;0
WireConnection;2;1;44;0
WireConnection;28;0;29;0
WireConnection;28;1;27;0
WireConnection;38;0;2;0
WireConnection;38;1;39;0
WireConnection;92;0;93;0
WireConnection;92;1;28;0
WireConnection;92;2;29;4
WireConnection;96;1;95;0
WireConnection;96;2;98;0
WireConnection;66;0;70;0
WireConnection;66;1;38;0
WireConnection;94;0;92;0
WireConnection;94;1;96;0
WireConnection;68;0;66;0
WireConnection;57;0;94;0
WireConnection;82;0;81;0
WireConnection;82;1;80;0
WireConnection;75;0;91;0
WireConnection;75;1;76;0
WireConnection;9;0;18;0
WireConnection;9;1;43;0
WireConnection;9;5;12;0
WireConnection;4;0;73;0
WireConnection;4;1;3;0
WireConnection;4;2;5;0
WireConnection;36;0;58;0
WireConnection;36;1;3;0
WireConnection;36;2;5;0
WireConnection;83;0;82;0
WireConnection;83;1;7;0
WireConnection;77;0;75;0
WireConnection;77;1;6;0
WireConnection;54;0;9;0
WireConnection;51;0;4;0
WireConnection;52;0;36;0
WireConnection;59;0;2;4
WireConnection;78;0;77;0
WireConnection;84;0;83;0
WireConnection;0;0;53;0
WireConnection;0;1;55;0
WireConnection;0;2;56;0
WireConnection;0;3;79;0
WireConnection;0;4;86;0
WireConnection;0;10;61;0
ASEEND*/
//CHKSM=2496846F87C50375A83CD294589483C883946194