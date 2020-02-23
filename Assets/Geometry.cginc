float Sphere(float3 p, float4 sphere)
{
    return length(p - sphere.xyz) - sphere.w;
}

float Capsule(float3 p, float3 a, float3 b, float r)
{
    float3 ab = b-a;
    float3 ap = p-a;
    
    float t = saturate(dot(ab, ap) / dot (ab, ab));
    
    float3 c = a + t*ab;
    return length (p-c) - r;
}

float Torus()
{
                
                //d = length(float2(length(p.xz)-0.5, p.y)) - 0.1; //torus
}

