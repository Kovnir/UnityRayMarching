float add(float a, float b)
{
    return min(a, b);
}
float add(float a, float b, float c)
{
    return add(a, add(b, c));
}
float add(float a, float b, float c, float d)
{
    return add(a, add(b, c, d));
}
float add(float a, float b, float c, float d, float e)
{
    return add(a, add(b, c, d, e));
}
float add(float a, float b, float c, float d, float e, float f)
{
    return add(a, add(b, c, d, e, f));
}

float substruct(float a, float b)
{
    return max(-a, b);
}

float intersect(float a, float b)
{
    return max(a, b);
}

float merge(float a, float b, float k) {
    float h = clamp(0.5+0.5*(b-a)/k, 0., 1.);
    return lerp(b, a, h) - k*h*(1.0-h);
}
