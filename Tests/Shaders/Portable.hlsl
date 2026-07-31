struct VertexOutput {
    float4 position : SV_Position;
    float4 color : COLOR0;
};

VertexOutput vertex_main(uint id : SV_VertexID) {
    const float2 positions[3] = {
        float2(0.0, -0.5),
        float2(0.5, 0.5),
        float2(-0.5, 0.5)
    };
    VertexOutput output;
    output.position = float4(positions[id], 0.0, 1.0);
    output.color = float4(0.2, 0.6, 1.0, 1.0);
    return output;
}

float4 fragment_main(VertexOutput input) : SV_Target0 {
    return input.color;
}

[numthreads(1, 1, 1)]
void compute_main(uint3 id : SV_DispatchThreadID) {
}
