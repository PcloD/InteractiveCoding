Shader "InteractiveCoding/Sketch" {

	Properties
	{
		_Color ("Color", Color) = (0.5, 0.5, 0.5, 1)
		_MainTex ("Texture", 2D) = "bump" {}
		_OriginTex ("Origin", 2D) = "bump" {}
		_CubeMap ("Cubemap", Cube) = "" {}

		_Alpha ("Alpha", Range(0.1, 0.725)) = 0.5
		_Beta ("Beta", Range(0.0, 0.1)) = 0.0

		_Intensity ("Intensity", Range(0.0, 1.0)) = 0.75
		_Speed ("Speed", Float) = 0.5
		_Scale ("Scale", Float) = 16.5

		_SpecularColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.2)
		_SpecularPower ("Specular", Range(1.0, 20.0)) = 16.3
		_LightDirection ("Light Direction", Vector) = (0.51, 0.38, 0.97, -1.0)

		_Ratio ("Ratio", Float) = 1.0
	}

	CGINCLUDE

	#include "UnityCG.cginc"
	// #include "Assets/Common/Shaders/SimplexNoise3D.cginc"
	#include "Assets/Common/Shaders/ClassicNoise3D.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex, _OriginTex;
	float4 _MainTex_TexelSize;

	float _Intensity, _Speed, _Scale;

	v2f vert (appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}

	float2 noise(float2 uv, float time) {
		float t = time * _Speed;
		float2 seed = uv * _Scale;
		// float nx = snoise(float3(seed, t));
		// float ny = snoise(float3(t + 1.3, seed));
		float nx = cnoise(float3(seed, t));
		float ny = cnoise(float3(t + 1.3, seed));
		return float2(nx, ny) * _Intensity;
	}

	ENDCG

	SubShader {
		Cull Off ZWrite Off ZTest Always

		// displace
		Pass 
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment displace

			float _Alpha, _Beta;

			float4 displace (v2f i) : SV_Target
			{
				float2 uv = i.uv + noise(i.uv, _Time.y) * _MainTex_TexelSize.xy;
				float4 org = tex2D(_OriginTex, i.uv);
				float4 src = tex2D(_MainTex, i.uv);
				float4 dst = tex2D(_MainTex, uv);
				return lerp(lerp(src, dst, _Alpha), org, _Beta);
			}

			ENDCG
		}

		// visualize
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			float4 _Color, _SpecularColor;
			float _SpecularPower;
			float3 _LightDirection;
			samplerCUBE _CubeMap;

			float _Ratio;

			float4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;
				uv.x *= _Ratio;
				uv.x += (1.0 - _Ratio) * 0.5;

				float3 normal = UnpackNormal(tex2D (_MainTex, uv));
				float diff = dot(normalize(_LightDirection), normal);
				float p = pow(saturate(diff), _SpecularPower);

				float3 viewDir = float3(0, 0, -1);
				float3 refl = reflect(viewDir, normal);
				float4 col = _Color * texCUBE(_CubeMap, refl);
				col += p * _SpecularColor;

				// return float4(diff, diff, diff, 1.0);
				// return float4(p, p, p, 1.0);
				// return float4((normal + 1.0) * 0.5, 1.0);
				return col;
			}

			ENDCG
		}
	}
}
