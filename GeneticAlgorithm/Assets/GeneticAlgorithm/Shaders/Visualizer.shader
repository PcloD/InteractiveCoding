// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Sketch/Visualizer"
{
	Properties
	{
		_Lines ("Lines", 2D) = "" {}
		_Nematodes ("Nematodes", 2DArray) = "" {}
		_Depth ("Depth", Float) = 1.0
		_Strokes ("Strokes", Vector) = (0, 0, 0, -1)
		_Gradient ("Gradient", 2D) = "" {}
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM

			#pragma target 4.0
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2g {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			struct g2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float lifetime : TEXCOORD1;
			};

			sampler2D _Lines;

			UNITY_DECLARE_TEX2DARRAY(_Nematodes);

			float _Depth;
			float4 _Strokes; // x = count, y = 1 / count, z = (1 / count) * 0.5
			sampler2D _Gradient;

			float3 spline(float t, float3 p0, float3 p1, float3 p2, float3 p3)
		    {
		        float tm1 = t - 1.0;
		        float tm2 = tm1 * tm1;
		        float t2 = t * t;

		        float3 m1 = 0.5 * (p2 - p0);
		        float3 m2 = 0.5 * (p3 - p1);

		        return (1 + 2 * t) * tm2 * p1 + t * tm2 * m1 + t2 * (3 - 2 * t) * p2 + t2 * tm1 * m2;
		    }

		    void fetch(int idx, float depth, out float3 p0, out float3 p1, out float3 p2, out float3 p3) {
		    	p0 = UNITY_SAMPLE_TEX2DARRAY_LOD(_Nematodes, float3(_Strokes.z + _Strokes.y * (idx - 1), 0.5, depth), 0).xyz;
				p1 = UNITY_SAMPLE_TEX2DARRAY_LOD(_Nematodes, float3(_Strokes.z + _Strokes.y * idx, 0.5, depth), 0).xyz;
				p2 = UNITY_SAMPLE_TEX2DARRAY_LOD(_Nematodes, float3(_Strokes.z + _Strokes.y * (idx + 1), 0.5, depth), 0).xyz;
				p3 = UNITY_SAMPLE_TEX2DARRAY_LOD(_Nematodes, float3(_Strokes.z + _Strokes.y * (idx + 2), 0.5, depth), 0).xyz;
		    }
			
			void append (inout LineStream<g2f> stream, float lifetime, float2 uv, float start, float last, float3 p0, float3 p1, float3 p2, float3 p3) {
				g2f pIn;
				pIn.lifetime = lifetime;

				float t;
				float3 p;

				float d = (last - start) * 0.1;
				// for(t = start; t < last; t += 0.1) {
				for(t = start; t < last; t += d) {
					float3 p = spline(t, p0, p1, p2, p3);
					p.xy -= 0.5;

					pIn.pos = UnityObjectToClipPos(float4(p, 1));
					pIn.uv = float2(uv.x, uv.y + t * _Strokes.y);
					stream.Append(pIn);
				}

				p = spline(last, p0, p1, p2, p3);
				p.xy -= 0.5;

				pIn.pos = UnityObjectToClipPos(float4(p, 1));
				pIn.uv = float2(uv.x, uv.y + t * _Strokes.y);
				stream.Append(pIn);
			}

			v2g vert (appdata v)
			{
				v2g OUT;
				OUT.pos = float4(0, 0, 0, 1);
				OUT.uv = v.uv;
				return OUT;
			}

			[maxvertexcount(128)]
			void geom(point v2g IN[1], inout LineStream<g2f> stream) {
				float3 pos = IN[0].pos.xyz;
				float t = IN[0].uv.y;

				float4 ln = tex2Dlod(_Lines, float4(t, 0, 0, 0));

				g2f pIn;

				float depth = t * _Depth;

				float lifetime = saturate(ln.x);
				float len = 0.2 * (smoothstep(0.0, 0.2, lifetime) * smoothstep(0.0, 0.2, 1.0 - lifetime));

				float interval = (_Strokes.x - 2);

				float last = 1 + interval * lifetime;
				float start = last - interval * len;
				start = max(1, start);

				int from = floor(start);
				float sfr = frac(start);

				int lfl = floor(last);
				float lfr = frac(last);

				int i = from;

				float3 p0, p1, p2, p3;

				// first segment
				if(lfl > 1) {
					fetch(i, depth, p0, p1, p2, p3);
					append(stream, lifetime, float2(t, i * _Strokes.y), sfr, 1, p0, p1, p2, p3); 
					if(from == lfl) {
						// first segment only
						return;
					}
				}

				for(i = from + 1; i < lfl; i++) {
					fetch(i, depth, p0, p1, p2, p3);
					append(stream, lifetime, float2(t, i * _Strokes.y), 0, 1, p0, p1, p2, p3);
				}

				// last segment
				fetch(lfl, depth, p0, p1, p2, p3);
				append(stream, lifetime, float2(t, lfl * _Strokes.y), 0, lfr, p0, p1, p2, p3);
			}
			
			fixed4 frag (g2f IN) : SV_Target
			{
				float lm = smoothstep(0.0, 0.1, IN.lifetime) * smoothstep(1.0, 0.9, IN.lifetime);
				float4 grad = tex2D(_Gradient, float2(IN.uv.x, 0.5));
				return fixed4(1, 1, 1, lm) * grad;
			}

			ENDCG
		}
	}
}
