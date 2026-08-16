struct VertexInput {
    float3 position : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float2 uv : TEXCOORD2;
    float4 color : TEXCOORD3;
};

cbuffer PointShadowUniforms : register(b0, space1) {
    float4x4 modelViewProjection;
    float4x4 model;
    float4 vertexLightPositionRange;
};

cbuffer PointShadowFragmentUniforms : register(b0, space3) {
    float4x4 fragmentModelViewProjection;
    float4x4 fragmentModel;
    float4 lightPositionRange;
};

struct VertexOutput {
    float3 worldPosition : TEXCOORD0;
    float4 position : SV_Position;
};

VertexOutput vertex_main(VertexInput input) {
    const float4 localPosition = float4(input.position, 1.0);
    VertexOutput output;
    output.position = mul(modelViewProjection, localPosition);
    output.worldPosition = mul(model, localPosition).xyz;
    return output;
}

struct FragmentOutput {
    float depth : SV_Depth;
};

FragmentOutput fragment_main(VertexOutput input) {
    const float range = max(lightPositionRange.w, 0.0001);
    const float depth = saturate(length(input.worldPosition - lightPositionRange.xyz) / range - 0.00008);
    FragmentOutput output;
    output.depth = depth;
    return output;
}
