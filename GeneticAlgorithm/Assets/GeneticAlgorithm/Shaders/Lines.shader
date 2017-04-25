Shader "Sketch/Lines"
{
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Speed ("Speed", Float) = 0.005
	}

	CGINCLUDE

	#include "UnityCG.cginc"
	#include "Assets/Common/Shaders/Random.cginc"

	#pragma vertex vert

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

	v2f vert (appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}
	
	sampler2D _MainTex;
	float _Speed;

	ENDCG

	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		Blend Off

		Pass // init
		{
			CGPROGRAM
			#pragma fragment frag
			
			float4 frag (v2f IN) : SV_Target
			{
				float r = nrand(IN.uv);
				float r2 = saturate(nrand(IN.uv.yx, 13.337));
				return float4(0, lerp(0.25, 1.0, r2), 0, 1);
			}
			ENDCG
		}

		Pass // update
		{
			CGPROGRAM
			#pragma fragment frag
			
			float4 frag (v2f IN) : SV_Target
			{
				float4 ln = tex2D(_MainTex, IN.uv);
				ln.x += ln.y * _Time.x * _Speed;
				return ln;
			}
			ENDCG
		}

		Pass // birth
		{
			CGPROGRAM
			#pragma fragment frag
			
			float4 frag (v2f IN) : SV_Target
			{
				float4 ln = tex2D(_MainTex, IN.uv);
				if(ln.x >= 1) {
					ln.x = 0;
					ln.y = lerp(0.25, 1.0, nrand(IN.uv.yx, _Time.x));
				}
				return ln;
			}
			ENDCG
		}

	}
}
