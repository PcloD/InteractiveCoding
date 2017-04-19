
#define FIRE_OCTIVES 3
#define ITERATIONS 10

sampler2D _FireTex;
fixed4 _Scale;
float _Lacunarity, _Gain, _Magnitude;
float _Epsilon;

float turbulence(float3 pos) {
    float sum = 0.0;
    float freq = 1.0;
    float amp = 1.0;

    for(int i = 0; i < FIRE_OCTIVES; i++) {
        sum += abs(FIRE_NOISE(pos * freq)) * amp;
        freq *= _Lacunarity;	
        amp *= _Gain;
    }
    return sum;
}

float sample_fire (float3 loc, float4 scale) {
    float2 st = float2(sqrt(dot(loc.xz, loc.xz)), loc.y);

    loc.y -= _Time.y * scale.w;
    loc *= scale.xyz;

    st.y += sqrt(st.y) * _Magnitude * turbulence(loc);
    // st.y -= 0.1;

    if(st.y <= 0.0 || st.y >= 1.0) {
    	return 0;
    }

    return tex2D(_FireTex, st).r;
}


float sample(float3 rayPos) {
	float3 rayDir = -UNITY_MATRIX_V[2].xyz;

	float rayLen = 0.1;

	float output = 0;
	for(int i = 0; i < ITERATIONS; i++) {
		rayPos += rayDir * rayLen;

		float3 lp = (mul(unity_WorldToObject, float4(rayPos, 1.0))).xyz;
		lp.y += 0.5;
		lp.xz *= 2.0;
		output += sample_fire(lp, _Scale);
    }

    return output;
}

float3 sample_normal(float3 world) {
	float3 rayDir = -normalize(UNITY_MATRIX_V[2].xyz);
	float3 rayUp = normalize(UNITY_MATRIX_V[1].xyz);
	float3 rayRight = normalize(UNITY_MATRIX_V[0].xyz);

	float right = sample(world.xyz + rayRight * _Epsilon);
	float left = sample(world.xyz - rayRight * _Epsilon);

	float up = sample(world.xyz + rayUp * _Epsilon);
	float down = sample(world.xyz - rayUp * _Epsilon);

	float forward = sample(world.xyz + rayDir * _Epsilon);
	float back = sample(world.xyz - rayDir * _Epsilon);

	float dx = right - left;
	float dy = up - down;
	float dz = forward - back;

	return normalize(float3(dx, dy, dz));
}
