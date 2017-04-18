Shader "Custom/Lighting" {

    Properties {
    	_Color ("Color", Color) = (1, 1, 1, 1)
        _FireTex ("Fire Texture", 2D) = "white" {}

		_CubeMap ("Cubemap", Cube) = "" {}
		_Brightness ("Brightness", Range(0.0, 2.0)) = 1.25

		_Scale ("Fire Scale", Vector) = (1, 3, 1, 0.5)
		_Lacunarity ("_Lacunarity", float) = 2.0
		_Gain ("_Gain", float) = 0.5
		_Magnitude ("_Magnitude", float) = 1.3
		_Epsilon ("Epsilon", Range(0.0001, 0.1)) = 0.01

		_SpecularColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.2)
		_SpecularPower ("Specular", Range(1.0, 50.0)) = 16.3
		_LightDirection ("Light Direction", Vector) = (0.51, 0.38, 0.97, -1.0)
	}

	SubShader {
		Tags { "RenderType" = "Opaque" }

		LOD 200

		CGINCLUDE

		#include "UnityCG.cginc"

		#include "Assets/Common/Shaders/SimplexNoise3D.cginc"
		#define FIRE_NOISE snoise

		// #include "Assets/Common/Shaders/ClassicNoise3D.cginc"
        // #define FIRE_NOISE cnoise

        #define FIRE_OCTIVES 3
        #define ITERATIONS 8

        #include "./Fire.cginc"

        half _Brightness;
        samplerCUBE _CubeMap;

		float4 _Color, _SpecularColor;
		float _SpecularPower;
		float3 _LightDirection;

		struct v2f {
		    float4 pos: POSITION;
		    float3 world: NORMAL;
		    float3 viewDir: TEXCOORD0;
		};

		v2f vert (appdata_full v) {
		    v2f OUT;
		    OUT.pos = UnityObjectToClipPos(v.vertex);
		    OUT.world = (mul(unity_ObjectToWorld, v.vertex)).xyz;
		    OUT.viewDir = ObjSpaceViewDir(v.vertex);
		    return OUT;
		}

        float4 frag (v2f IN) : COLOR {
        	float alpha = sample(IN.world.xyz);
        	float3 norm = sample_normal(IN.world.xyz);
        	float3 viewDir = normalize(IN.viewDir);

			float diff = dot(normalize(_LightDirection + viewDir), norm);
			float p = pow(saturate(diff), _SpecularPower);

			float3 refl = normalize(reflect(viewDir, norm));
			float4 col = _Color * saturate(texCUBE(_CubeMap, refl) * _Brightness);
			col += p * _SpecularColor;

			return float4(col.rgb, alpha * 10);
        }

        ENDCG

        Pass {
            Cull Off
            Blend SrcAlpha One

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

    } 

}

