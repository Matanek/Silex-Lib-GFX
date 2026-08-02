struct VertexInput {
    float3 position : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float2 uv : TEXCOORD2;
    float4 color : TEXCOORD3;
};

cbuffer DrawUniforms : register(b0, space1) {
    float4x4 modelViewProjection;
    float4 materialColor;
};

struct VertexOutput {
    float4 color : COLOR0;
    float4 position : SV_Position;
};

VertexOutput vertex_main(VertexInput input) {
    VertexOutput output;
    output.position = mul(modelViewProjection, float4(input.position, 1.0));
    output.color = input.color * materialColor;
    return output;
}

float4 fragment_main(VertexOutput input) : SV_Target0 {
    return input.color;
}
