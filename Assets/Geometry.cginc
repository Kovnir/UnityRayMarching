float Sphere(float3 p, float4 sphere)
{
    return length(p - sphere.xyz) - sphere.w;
}