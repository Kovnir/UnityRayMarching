Shader "Unlit/RayMarchingTest"
{
    Properties
    {
        [Header(Light)]
        _DirectionLight ("DirectionLight", Vector) = (0,0,0,0)
        _DirectionLightColor("DirectionaLightColor", COLOR) = (1,1,1,1)

        [Space]
        _PointLight ("PointLight", Vector) = (0,0,0,0)
        _PointLightColor("PointLightColor", COLOR) = (1,1,1,1)

        [Space]
        [Toggle(ENABLE_SHADOWS)]
        _EnableShadows ("Enable Shadows", Float) = 0
        
        [Header(System)]
        [KeywordEnum(MovingBalls, Trip, AllShapes)] _Program ("Program", Float) = 0

        [Header(Quality)]
        _GeometrySurfDist("Geometry Surface Distance", Range(0.00001,0.4)) = 0.01
        _ShadowSurfDist("Shadow Surface Distance", Range(0.00001,0.4)) = 0.01

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
            #pragma shader_feature ENABLE_SHADOWS
            #pragma multi_compile _PROGRAM_MOVINGBALLS _PROGRAM_TRIP _PROGRAM_ALLSHAPES
            #include "UnityCG.cginc"
            #include "Geometry.cginc"
            #include "Blends.cginc"

            #define MAX_STEPS 1000
            #define MAX_DIST 1000
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            }; 

            float4 _DirectionLight;
            float3 _DirectionLightColor;
            float4 _PointLight;
            float3 _PointLightColor;
            float _GeometrySurfDist;
            float _ShadowSurfDist;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1)); //from worlds space to object space
                o.hitPos = v.vertex; //already in object space
                return o;
            }

            float GetDist_AllShapes(float3 p)
            {
                float plane = p.y + 0.5f;
                float sphere = Sphere(p, float4(-1,0,0,.3));
                float capsule = Capsule(p, float3(0,-0.075,0), float3(0,0.15,0), 0.1);
                return min(plane, sphere, capsule);
            }
                        
            float GetDist_MovingBalls(float3 p)
            {
                float distance = 1000;
                for(int i =-3; i < 3; i++)
                {
                    for(int j =-3; j < 3; j++)
                    {
                        float f1 = sin(_Time * 30 + i)/3;
                        float f2 = sin(_Time * 30 + j)/4;
                        distance = min(distance, Sphere(p, float4(i + f1,-0.3,j + f2,.3)));
                    }
                }
                float planeDist = p.y + 0.5f;
                return min(distance, planeDist);
            }

            float GetDist_Trip(float3 p)
            {
                float distance = 1000;
                
                for(int i =-3; i < 3; i++)
                    for(int j =-3; j < 3; j++)
                    {
                        float f1 = sin(_Time * 30 + i)/3;
                        float f2 = sin(_Time * 30 + j)/4;
                        distance = min(distance, Sphere(p, float4(i + f1,0.2,j + f2,.3)));
                    }
               
                float planeDist = p.y;
                return min(distance, planeDist) + planeDist + distance;
            }
                        
            float GetDist(float3 p)
            {
#ifdef _PROGRAM_MOVINGBALLS 
                return GetDist_MovingBalls(p);
#endif
#ifdef _PROGRAM_TRIP
                return GetDist_Trip(p);
#endif
#ifdef _PROGRAM_ALLSHAPES
                return GetDist_AllShapes(p);
#endif
            }
            
            float Raymarch(float3 ro, float3 rd)
            {
                //distance from origin
                float dO = 0;
                //distance from the surface
                float dS; 
                
                for(int i =0; i < MAX_STEPS; i++)
                {
                    float3 p = ro + dO*rd;
                    dS = GetDist(p);
                    dO += dS;
                    if (dS < _GeometrySurfDist || dO > MAX_DIST)
                    {
                        //hit!
                        break;
                    }
                }
                return dO;
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

            float3 GetLight(float3 p)
            {
                float3 n = GetNormal(p);

                float3 directionLightDir = _DirectionLight.xyz;
                float3 directionLight = saturate(dot(n, directionLightDir) * _DirectionLight.w) * _DirectionLightColor;

                float3 pointLightPos = _PointLight.xyz;
                float l = normalize(pointLightPos-p);
                float3 pointLight = saturate(dot(n, l) * _PointLight.w) * _PointLightColor;

#ifdef ENABLE_SHADOWS
                float shadow = Raymarch(p + n * _ShadowSurfDist, pointLightPos);
                if (shadow < length(pointLightPos - p))
                {
                    pointLight *= 0.1;
                }
#endif
                
                return directionLight + pointLight;
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
                if (d<MAX_DIST)
                {
                    float3 p = ro + rd * d;
                    float3 dif = GetLight(p);
//                    float3 n = GetNormal(p);
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
