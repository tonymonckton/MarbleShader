Shader "Custom/MarbleSurfaceShader"
{
    Properties
    {
       // _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _Contrast ("Contrast", range(0,5)) = 1.0
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Scale ("Scale", Range(0,100))   = 1.0
        _Period("Period", Range(0,10))  = 1.0
        _Distortion("Distortion", Range(0,10)) = 1.0
        _Octaves("Octaves", Range(1,50) ) = 8
        _Color ("Main Color", Color)    = (1,1,1,1)
        _Offset ("Noise offset", Vector) = (1.0, 1.0, 1.0)
        _Alpha("Alpha", Range(0, 1.0))  = 1.0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        float _Contrast;
        float _Scale;
        float _Period;
        float _Distortion;
        float _Octaves;
        float4 _Color;
        float _Offset;
        float _Alpha;

        struct Input
        {
        //    float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 localPos;
            float3 worldNormal; INTERNAL_DATA
        };

        //sampler2D _MainTex;
        sampler2D _BumpMap;


        half _Glossiness;
        half _Metallic;

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            o.localPos = v.vertex.xyz;
        }

        float hash( float n )
        {
            return frac(sin(n)*43758.5453);
        }

        float noise( float3 x )
        {
            // The noise function returns a value in the range -1.0f -> 1.0f
            float3 p = floor(x);
            float3 f = frac(x);

            f       = f*f*(3.0-2.0*f);
            float n = p.x + p.y*57.0 + 113.0*p.z;

            return  lerp(lerp(lerp( hash(n+0.0), hash(n+1.0),f.x),
                    lerp( hash(n+57.0), hash(n+58.0),f.x),f.y),
                    lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
                    lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
        }

        float fractal3(float3 v, float o) {
            float n = 0.0f;
            float oct = 1.0f;
            v *= _Scale;
            for (float octave=0.0; octave<o; octave++) {
                n += noise(v*oct)/oct;
                oct *= 2.0f;
            }
            return n;
        }

        float constast(float x, float gain) 
        {
            const float a = 0.5*pow(2.0*((x<0.5)?x:1.0-x), gain);
            return (x<0.5)?a:1.0-a;
        }


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float3 localPos = IN.localPos; 

            float fracVal = fractal3(localPos, _Octaves);
            float noise = abs( sin( 180.0f * ( _Period ) + _Distortion * fracVal));
            float red    = constast(_Color.x * noise, _Contrast);
            float green  = constast(_Color.y * noise, _Contrast);
            float blue   = constast(_Color.z * noise, _Contrast);

            fixed4 nc = fixed4(red,green,blue,1.0f);
            float3 normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));

            o.Normal = normalize(normal);
            o.Albedo = nc.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = _Alpha;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
