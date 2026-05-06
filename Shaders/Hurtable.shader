// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hurtable/Hurtable"
{
	Properties
	{
		_ColorOverlay("Color Overlay", Color) = (1,0,0,0)
		_ColorOverlayAmount("Color Overlay Amount", Range( 0 , 1)) = 0
		[Header(Albedo)][NoScaleOffset][SingleLineTexture]_AlbedoTexture("Albedo Texture", 2D) = "white" {}
		_AlbedoColor("Albedo Color", Color) = (1,1,1,0)
		[Header(Normal)][NoScaleOffset][Normal][SingleLineTexture]_NormalTexture("Normal Texture", 2D) = "white" {}
		_NormalStrength("Normal Strength", Range( -5 , 5)) = 0
		[Header(Metallic)][NoScaleOffset][SingleLineTexture]_MetallicTexture("Metallic Texture", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		[Header(Smoothness)][NoScaleOffset][SingleLineTexture]_SmoothnessTexture("Smoothness Texture", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		[Header(Tiling)]_TilingX("Tiling X", Float) = 1
		_TilingY("Tiling Y", Float) = 1
		[Header(Offset)]_OffsetX("Offset X", Float) = 1
		_OffsetY("Offset Y", Float) = 1
		[Header(Emission)][NoScaleOffset][SingleLineTexture]_EmissionTexture("Emission Texture", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		[Header(Fresnel)]_FresnelAmount("Fresnel Amount", Range( 0 , 1)) = 0
		_FresnelScale("Fresnel Scale", Float) = 0
		_FresnelPower("Fresnel Power", Float) = 0
		_FresnelBias("Fresnel Bias", Float) = 0
		_FresnelColor("Fresnel Color", Color) = (0,0,0,0)
		_FresnelEmission("Fresnel Emission", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
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

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 appendResult21 = (float2(_TilingX , _TilingY));
			float2 appendResult25 = (float2(_OffsetX , _OffsetY));
			float2 uv_TexCoord15 = i.uv_texcoord * appendResult21 + appendResult25;
			float2 UV82 = uv_TexCoord15;
			float3 Normal104 = UnpackScaleNormal( tex2D( _NormalTexture, UV82 ), _NormalStrength );
			o.Normal = Normal104;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV46 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode46 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV46, _FresnelPower ) );
			float Fresnel47 = fresnelNode46;
			float4 lerpResult54 = lerp( float4( 0,0,0,0 ) , ( _FresnelColor * Fresnel47 ) , _FresnelAmount);
			float4 Albedo88 = ( lerpResult54 + ( tex2D( _AlbedoTexture, UV82 ) * _AlbedoColor ) );
			float4 lerpResult4 = lerp( Albedo88 , _ColorOverlay , _ColorOverlayAmount);
			float4 AlbedoFinal100 = lerpResult4;
			o.Albedo = AlbedoFinal100.rgb;
			float4 color42 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float4 lerpResult41 = lerp( color42 , ( _EmissionColor * tex2D( _EmissionTexture, UV82 ) ) , _EmissionColor.a);
			float4 Fresnel_Color58 = lerpResult54;
			float4 lerpResult61 = lerp( float4( 0,0,0,0 ) , Fresnel_Color58 , _FresnelEmission);
			float4 Emission98 = ( lerpResult41 + lerpResult61 );
			float4 lerpResult36 = lerp( Emission98 , _ColorOverlay , _ColorOverlayAmount);
			float4 EmissionFinal101 = lerpResult36;
			o.Emission = EmissionFinal101.rgb;
			float4 Metallic92 = ( tex2D( _MetallicTexture, UV82 ) * _Metallic );
			o.Metallic = Metallic92.r;
			float4 Smoothness95 = ( tex2D( _SmoothnessTexture, UV82 ) * _Smoothness );
			o.Smoothness = Smoothness95.r;
			o.Alpha = 1;
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
Node;AmplifyShaderEditor.CommentaryNode;48;-2576,432;Inherit;False;756;339;;5;43;44;45;46;47;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2528,576;Inherit;False;Property;_FresnelScale;Fresnel Scale;17;0;Create;True;0;0;0;False;0;False;0;1.62;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2528,672;Inherit;False;Property;_FresnelPower;Fresnel Power;18;0;Create;True;0;0;0;False;0;False;0;3.24;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2528,496;Inherit;False;Property;_FresnelBias;Fresnel Bias;19;0;Create;True;1;Fresnel;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2784,128;Inherit;False;Property;_OffsetY;Offset Y;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2784,-32;Inherit;False;Property;_TilingY;Tiling Y;11;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2784,-96;Inherit;False;Property;_TilingX;Tiling X;10;1;[Header];Create;True;1;Tiling;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2784,64;Inherit;False;Property;_OffsetX;Offset X;12;1;[Header];Create;True;1;Offset;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;46;-2288,496;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;5;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-2608,-48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;-2608,48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-2048,496;Inherit;False;Fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-2384,-32;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;52;-1488,-816;Inherit;False;47;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;56;-1504,-1008;Inherit;False;Property;_FresnelColor;Fresnel Color;20;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.9668982,0.8915094,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-2096,48;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1232,-720;Inherit;False;Property;_FresnelAmount;Fresnel Amount;16;1;[Header];Create;True;1;Fresnel;0;0;False;0;False;0;0.754;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1168,-832;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;54;-928,-768;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;26;-1536,560;Inherit;True;Property;_EmissionTexture;Emission Texture;14;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;1;Emission;0;0;False;0;False;None;3a3db287a3a3cf74fa339a99abba096f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;85;-1504,752;Inherit;False;82;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;17;-1920,-736;Inherit;True;Property;_AlbedoTexture;Albedo Texture;2;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;1;Albedo;0;0;False;0;False;None;07d4240e67557064fa57272af815af30;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;87;-1856,-512;Inherit;False;82;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-688,-768;Inherit;False;Fresnel Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;27;-1184,720;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;29;-1136,512;Inherit;False;Property;_EmissionColor;Emission Color;15;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;1,0.1857836,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1584,-736;Inherit;True;Property;_texutresamp;texutre samp;1;0;Create;True;0;0;0;False;0;False;-1;None;ebe12bd571d52a8438b91571128a7735;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;39;-1520,-544;Inherit;False;Property;_AlbedoColor;Albedo Color;3;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,0.6650667,0.5330188,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;42;-768,736;Inherit;False;Constant;_Color0;Color 0;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-816,528;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-448,752;Inherit;False;Property;_FresnelEmission;Fresnel Emission;21;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-384,672;Inherit;False;58;Fresnel Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1184,-592;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;41;-512,560;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;61;-80,720;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;97;-304,1040;Inherit;False;1204;371;;6;69;84;70;7;72;95;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-1600,1040;Inherit;False;1204;371;;6;65;83;66;6;68;92;Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-704,-608;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;64,576;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-544,-592;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;65;-1552,1088;Inherit;True;Property;_MetallicTexture;Metallic Texture;6;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;1;Metallic;0;0;False;0;False;None;c83d8d53e54d9f2438c76061592bcb27;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;83;-1520,1280;Inherit;False;82;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;69;-256,1104;Inherit;True;Property;_SmoothnessTexture;Smoothness Texture;8;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;1;Smoothness;0;0;False;0;False;None;79b4e2246709c374b872083a640275da;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;84;-240,1312;Inherit;False;82;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;224,576;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;18;-1360,-96;Inherit;True;Property;_NormalTexture;Normal Texture;4;4;[Header];[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;1;Normal;0;0;False;0;False;None;7e4c7c1438900e946916282da224e43f;True;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;86;-1328,208;Inherit;False;82;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;66;-1216,1088;Inherit;True;Property;_texutresamp1;texutre samp;1;0;Create;True;0;0;0;False;0;False;-1;None;ebe12bd571d52a8438b91571128a7735;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-1216,1296;Inherit;False;Property;_Metallic;Metallic;7;0;Create;True;1;Other;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;70;80,1104;Inherit;True;Property;_texutresamp2;texutre samp;1;0;Create;True;0;0;0;False;0;False;-1;None;ebe12bd571d52a8438b91571128a7735;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;80,1312;Inherit;False;Property;_Smoothness;Smoothness;9;0;Create;True;0;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;16,-96;Inherit;False;98;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-64,-16;Inherit;False;Property;_ColorOverlayAmount;Color Overlay Amount;1;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;0,-272;Inherit;False;Property;_ColorOverlay;Color Overlay;0;0;Create;False;0;0;0;False;0;False;1,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;89;32,-352;Inherit;False;88;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1424,96;Inherit;False;Property;_NormalStrength;Normal Strength;5;0;Create;True;0;0;0;False;0;False;0;0.9;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-944,-64;Inherit;True;Property;_tesss;tesss;4;1;[Header];Create;True;1;Normal;0;0;False;0;False;-1;None;a8230ab1334e66942a339b7f8f0bd7f6;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-864,1184;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;416,1200;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;4;336,-272;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;36;352,-112;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;106;752,288;Inherit;False;628;547;;6;105;102;103;93;0;96;Result;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-640,1184;Inherit;False;Metallic;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;656,1200;Inherit;False;Smoothness;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-608,0;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;560,-272;Inherit;False;AlbedoFinal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;560,-112;Inherit;False;EmissionFinal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StickyNoteNode;30;-2000,-1072;Inherit;False;1686.571;742.6754;;Albedo;1,1,1,1;;0;0
Node;AmplifyShaderEditor.StickyNoteNode;31;-1501.4,-176;Inherit;False;1132.522;478.5807;;Normal;1,1,1,1;;0;0
Node;AmplifyShaderEditor.StickyNoteNode;32;-1616,400;Inherit;False;2066.07;514.4899;;Emission;1,1,1,1;;0;0
Node;AmplifyShaderEditor.StickyNoteNode;33;-2832,-176;Inherit;False;1038.091;425.6679;;Tiling;1,1,1,1;;0;0
Node;AmplifyShaderEditor.StickyNoteNode;37;-160,-400;Inherit;False;969.7568;476.0136;;Color Overlay;1,1,1,1;;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;816,416;Inherit;False;104;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;816,336;Inherit;False;100;AlbedoFinal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;784,496;Inherit;False;101;EmissionFinal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;816,576;Inherit;False;92;Metallic;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;816,672;Inherit;False;95;Smoothness;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1104,336;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Hurtable/Hurtable;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;50;0,0,0,1;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;46;1;45;0
WireConnection;46;2;44;0
WireConnection;46;3;43;0
WireConnection;21;0;19;0
WireConnection;21;1;22;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;47;0;46;0
WireConnection;15;0;21;0
WireConnection;15;1;25;0
WireConnection;82;0;15;0
WireConnection;57;0;56;0
WireConnection;57;1;52;0
WireConnection;54;1;57;0
WireConnection;54;2;55;0
WireConnection;58;0;54;0
WireConnection;27;0;26;0
WireConnection;27;1;85;0
WireConnection;2;0;17;0
WireConnection;2;1;87;0
WireConnection;28;0;29;0
WireConnection;28;1;27;0
WireConnection;38;0;2;0
WireConnection;38;1;39;0
WireConnection;41;0;42;0
WireConnection;41;1;28;0
WireConnection;41;2;29;4
WireConnection;61;1;60;0
WireConnection;61;2;59;0
WireConnection;64;0;54;0
WireConnection;64;1;38;0
WireConnection;63;0;41;0
WireConnection;63;1;61;0
WireConnection;88;0;64;0
WireConnection;98;0;63;0
WireConnection;66;0;65;0
WireConnection;66;1;83;0
WireConnection;70;0;69;0
WireConnection;70;1;84;0
WireConnection;9;0;18;0
WireConnection;9;1;86;0
WireConnection;9;5;12;0
WireConnection;68;0;66;0
WireConnection;68;1;6;0
WireConnection;72;0;70;0
WireConnection;72;1;7;0
WireConnection;4;0;89;0
WireConnection;4;1;3;0
WireConnection;4;2;5;0
WireConnection;36;0;99;0
WireConnection;36;1;3;0
WireConnection;36;2;5;0
WireConnection;92;0;68;0
WireConnection;95;0;72;0
WireConnection;104;0;9;0
WireConnection;100;0;4;0
WireConnection;101;0;36;0
WireConnection;0;0;102;0
WireConnection;0;1;105;0
WireConnection;0;2;103;0
WireConnection;0;3;93;0
WireConnection;0;4;96;0
ASEEND*/
//CHKSM=893A9C52DC4CDFF1C5B5E29A904CA83F4E51CEB8