const float flash, fade, overlay_alpha;
const float2 noffs, nscale;
const float noise_amt;
const float dist_amt, dist_freq, dist_time;
const float2 viewport;

texture color_tex;
sampler color_samp = sampler_state {
	Texture = (color_tex);
	MipFilter = NONE;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	sRGBTexture = FALSE;
};

texture spectrum_tex;
sampler spectrum_samp = sampler_state {
	Texture = (spectrum_tex);
	MipFilter = NONE;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	sRGBTexture = FALSE;
};

texture noise_tex;
sampler noise_samp = sampler_state {
	Texture = (noise_tex);
	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
	AddressU = WRAP;
	AddressV = WRAP;
	sRGBTexture = FALSE;
};

texture overlay_tex;
sampler overlay_samp = sampler_state {
	Texture = (overlay_tex);
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	sRGBTexture = TRUE;
};

struct VS_OUTPUT {
	float4 pos : POSITION;
	float2 uv  : TEXCOORD0;
};

VS_OUTPUT vertex(float4 ipos : POSITION, float2 uv : TEXCOORD0)
{
	VS_OUTPUT Out;
	Out.pos = ipos;
	Out.uv = uv;
	return Out;
}

float4 pixel(VS_OUTPUT In) : COLOR
{
	const float sep = 0.03;
	float dist = pow(2 * distance(In.uv, float2(0.5, 0.5)), 2);
	float2 pos = In.uv;
	pos += float2(
			(sin(pos.y * dist_freq + dist_time) * 2 - 1) * dist_amt,
			(sin(pos.x * dist_freq + dist_time) * 2 - 1) * dist_amt);
	float2 end = (pos - 0.5) * (1 - dist * sep * 2) + 0.5;
	float3 sum = 0, filter_sum = 0;


	int samples = max(3, int(length(viewport * (end - pos) / 2)));
	float2 delta = (end - pos) / samples;
	for (int i = 0; i < samples; ++i) {
#if 1
		float3 sample = tex2Dlod(color_samp, float4(pos, 0, 0)).rgb;
#else
		float3 sample = tex3Dlod(grade_samp, float4(pow(sample, 1.0 / 2.2) * (15.0 / 16) + 0.5 / 16, 0));
#endif
		float t = (i + 0.5) / (samples + 1);
		float3 filter = tex2Dlod(spectrum_samp, float4(t, 0, 0, 0));
		sum += sample * filter;
		filter_sum += filter;
		pos += delta;
	}
	sum /= filter_sum;

#if 0
	float3 col = tex3Dlod(grade_samp, float4(pow(sum, 1.0 / 2.2) * (15.0 / 16) + 0.5 / 16, 0));
#else
	float3 col = sum;
#endif

	float4 o = tex2D(overlay_samp, In.uv);
	o.a *= overlay_alpha;
	col *= 1 - o.a;
	col += o.rgb * o.a;

	col = col * fade + flash;

	col += (tex2D(noise_samp, In.uv * nscale + noffs) - 0.5) * (1.0 / 8);

	return float4(col, 1);
}

technique postprocess {
	pass P0 {
		VertexShader = compile vs_3_0 vertex();
		PixelShader  = compile ps_3_0 pixel();
	}
}
