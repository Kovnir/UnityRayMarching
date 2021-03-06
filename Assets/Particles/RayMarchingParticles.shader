﻿Shader "Unlit/RayMarchingParticles"
{
    Properties
    {
        _MergeFactor("Merge Factor", Range(0,10)) = 2
        _FresnelFactor("Fresnel Factor", float) = 1
        _LightFactor("Light Factor", float) = 1
        _FresnelColor("Fresnel Color", Color) = (1,1,1,1)
        _Color("Color", Color) = (1,1,1,1)
        _Shininess("Shininess", Range(0,100)) = 1

        [Header(Direction Light)]
        _LightDirection ("Direction", vector) = (0,-1,0)
        _LightIntensity ("Intensity", float) = 1
        _LightColor("Color", COLOR) = (1,1,1,1)

        [Header(System)]    
        _GeometrySurfDist("Geometry Surface Distance", Range(0.00001,0.4)) = 0.01
        _MaxSteps("Max Steps", Range(100,1000)) = 1000
        _MaxDist("Max Distance", Range(10,1000)) = 1000
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "Assets/ShadersBase/Geometry.cginc"
            #include "Assets/ShadersBase/Blends.cginc"

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            };

            float _GeometrySurfDist;
            float4 particles[100];
            float _MaxDist;
            float _MaxSteps;
            
            float _MergeFactor;
            float _LightFactor;
            float _FresnelFactor;
            float3 _FresnelColor;
            float3 _Color;
            float _Shininess;
            
            float3 _LightDirection;
            float _LightIntensity;
            float3 _LightColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.ro = _WorldSpaceCameraPos;
                o.hitPos =mul(unity_ObjectToWorld, v.vertex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float GetDist(float3 p)
            {
                float distance = _MaxDist;
                for(int i = 0; i < 100; i++)
                {
                    float4 particle = particles[i];
                    if (particle.w > 0)
                    {
                        float sphere = Sphere(p, particle);
                        distance = merge(distance, sphere, _MergeFactor);
                    }
                }
                return distance;
            }
            
            float3 GetNormal(float3 p)
            {
                float2 eps = float2(1e-2,0);
                float3 n = GetDist(p) - float3(
                    GetDist(p-eps.xyy),
                    GetDist(p-eps.yxy),
                    GetDist(p-eps.yyx)
                    );
                return normalize(n);
            }

            float3 GetLight(float3 p, float3 rd)
            {
                float3 n = GetNormal(p);

                float3 directionLight = saturate(dot(n, -_LightDirection)) * _LightIntensity * _LightColor;
                float3 fresnel = 1-dot(n, -rd);
                
                float3 specLight = max(0.0, dot(reflect(-_LightDirection, n), rd));
                
                return (directionLight * _LightFactor + fresnel * _FresnelFactor * _FresnelColor) * _Color + pow(specLight, _Shininess);
            }
            
            float Raymarch(float3 ro, float3 rd)
            {
                //distance from origin
                float dO = 0;
                //distance from the surface
                float dS; 
                
                for(int i =0; i < _MaxSteps; i++)
                {
                    float3 p = ro + dO*rd;
                    dS = GetDist(p);
                    dO += dS;
                    if (dS < _GeometrySurfDist || dO > _MaxDist)
                    {
                        //hit!
                        break;
                    }
                }
                return dO;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                //make uv from center
                float2 uv = i.uv - 0.5;
                //ray origin = camera position
                float3 ro = i.ro;
                //ray direction
                float3 rd = normalize(i.hitPos - ro);
            
                float d = Raymarch(ro, rd);
                
                fixed4 col = 0;
                if (d < _MaxDist)
                {
                    float3 p = ro + rd * d;
                    float3 dif = GetLight(p, rd);
                    col.rgb = dif;
                }
                else
                {
                    discard;
                }
                return col;
            }
            ENDCG
        }
    }
}
