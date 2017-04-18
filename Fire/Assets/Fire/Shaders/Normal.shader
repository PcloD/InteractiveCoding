Shader "Custom/Normal" {

    Properties {
        _FireTex ("Fire Texture", 2D) = "white" {}
		_Scale ("Fire Scale", Vector) = (1, 3, 1, 0.5)
		_Lacunarity ("_Lacunarity", float) = 2.0
		_Gain ("_Gain", float) = 0.5
		_Magnitude ("_Magnitude", float) = 1.3
		_Epsilon ("Epsilon", Range(0.0001, 0.1)) = 0.01
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

		struct v2f {
		    float4 pos: POSITION;
		    float3 world: NORMAL;
		};

		v2f vert (appdata_full v) {
		    v2f OUT;
		    OUT.pos = UnityObjectToClipPos(v.vertex);
		    OUT.world = (mul(unity_ObjectToWorld, v.vertex)).xyz;
		    return OUT;
		}

        float4 frag (v2f IN) : COLOR {
        	float3 norm = sample_normal(IN.world.xyz);
        	norm = (norm + 1) * 0.5;
        	return float4(norm, 1);
        }

        ENDCG

        Pass {
            Cull Off
            Blend One One

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

    } 

}

