struct VertexInput {
    float3 position : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float2 uv : TEXCOORD2;
    float4 color : TEXCOORD3;
};

cbuffer ShadowDrawUniforms : register(b0, space1) {
    float4x4 model;
    float4x4 viewProjection;
};

struct VertexOutput {
    float4 position : SV_Position;
};

VertexOutput vertex_main(VertexInput input) {
    VertexOutput output;
    output.position = mul(viewProjection, mul(model, float4(input.position, 1.0)));
    return output;
}

void fragment_main() {
}
