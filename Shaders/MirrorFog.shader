Shader "Hidden/Semiwork/MirrorFog"
{
	Properties
	{
		_MainTex ("Reflection", 2D) = "black" {}
	}

	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D_float _ReflectionDepthTex;
			float4x4 _ReflectionInverseViewProjection;
			float3 _ReflectionCameraPosition;
			fixed4 _MirrorFogColor;
			float4 _MirrorFogParams;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 _color = tex2D(_MainTex, i.uv).rgb;

				float _rawDepth = SAMPLE_DEPTH_TEXTURE(_ReflectionDepthTex, i.uv);

				#if defined(UNITY_REVERSED_Z)
				if(_rawDepth < 0.000001) return fixed4(_MirrorFogColor.rgb, 1);
				#else
				if(_rawDepth > 0.999999) return fixed4(_MirrorFogColor.rgb, 1);
				#endif

				#if defined(UNITY_REVERSED_Z)
				float4 _reflectionClip = float4(i.uv.x * 2.0 - 1.0, -(i.uv.y * 2.0 - 1.0), _rawDepth, 1.0);
				#else
				float4 _reflectionClip = float4(i.uv.x * 2.0 - 1.0, i.uv.y * 2.0 - 1.0, _rawDepth * 2.0 - 1.0, 1.0);
				#endif

				float4 _reflectedWorld = mul(_ReflectionInverseViewProjection, _reflectionClip);
				_reflectedWorld.xyz /= _reflectedWorld.w;

				float _viewDistance = length(_reflectedWorld.xyz - _ReflectionCameraPosition);
				float _fogAmount = saturate((_viewDistance - _MirrorFogParams.x) / max(_MirrorFogParams.y - _MirrorFogParams.x, 0.001));

				return fixed4(lerp(_color, _MirrorFogColor.rgb, _fogAmount), 1);
			}
			ENDCG
		}
	}

	Fallback Off
}
