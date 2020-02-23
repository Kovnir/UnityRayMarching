float2x2 GetRotationMatrix(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return float2x2(c, -s, s, c);
}

float3 Rotate(float3 p, float3 angle)
{
    p.yz = mul(p.yz, GetRotationMatrix(angle.x));
    p.xz = mul(p.xz, GetRotationMatrix(angle.y));
    p.xy = mul(p.xy, GetRotationMatrix(angle.z));
    return p;
}

float Sphere(float3 p, float4 sphere)
{
    return length(p - sphere.xyz) - sphere.w;
}

float Capsule(float3 p, float3 a, float3 b, float r, float3 rotation)
{
    p = Rotate(p, rotation);
    
    float3 ab = b-a;
    float3 ap = p-a;
    
    float t = saturate(dot(ab, ap) / dot (ab, ab));
    
    float3 c = a + t*ab;
    return length (p-c) - r;
}

float Torus(float3 p, float3 position, float2 radius, float3 rotation)
{
    p -= position;
    p = Rotate(p, rotation);
    return length(float2(length(p.xz)-radius.x, p.y)) - radius.y;
}

float Box(float3 p, float3 position, float3 size, float3 rotation)
{
    p -= position;
    p = Rotate(p, rotation);
    
    return length(max(abs(p)-size, 0));
}

