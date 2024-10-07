#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
#define PI 3.1415926535

uniform float time;         // Uniforme pour le temps
uniform vec2 resolution;    // Taille de la fenêtre
#define S(a,b,t) smoothstep(a,b,t)

float Rand(float i)
{
    return fract(sin(i * 23325.) * 35543.);
}

float Random21(vec2 p)
{
    p = fract(p*vec2(242.46,234.960));
    p += dot(p,p + 23.64);
    return fract(p.x*p.y);
}

vec2 Random22(vec2 p)
{
    float n = Random21(p);
    return vec2(n, Random21(p + n));
}

float DistLine(vec2 p, vec2 a, vec2 b){
    vec2 pa = p - a;
    vec2 ba = b - a;
    float t = clamp(dot(pa,ba) / dot(ba,ba), 0.,1.);
    return length(pa- ba*t);
}

float Line(vec2 p, vec2 a, vec2 b)
{
    float d = DistLine(p,a,b);
    float m = S(.03,.01,d);
    m *= S(0.9,0.2,length(a-b));
    return m;
}

vec2 GetPosition(vec2 id, vec2 offset){
    vec2 seed = id + offset;
    vec2 n = Random22(seed) * (time*0.5 + 10.);
   return offset + sin(n) * .4;
}

float DrawField(vec2 uv, float scale)
{
    uv *= scale;
    vec2 gv = fract(uv)- .5;
    vec2 id = floor(uv);
    
    float m = 0.;
    
    vec2 p[9];
    int i = 0;
    for(float y = -1.; y <= 1.; y++)
    {
        for(float x = -1.; x <= 1.; x++)
        {
            p[i] = GetPosition(id, vec2(x,y));
            i++;
        }
    }
    
    
    for(int i=0; i<9; i++)
    {
        m += Line(gv,p[4],p[i]);
       
    }
    
     m += Line(gv,p[1],p[3]);     
     m += Line(gv,p[1],p[5]);     
     m += Line(gv,p[5],p[7]);
     m += Line(gv,p[7],p[3]);
     
     return m;
}

float Grain(vec2 uv)
{
    return (fract(sin(dot(uv, vec2(12.9898,78.233)*2.0)) * 43758.5453));
}

void main() {
    // Calcul des coordonnées normalisées (0.0 à 1.0)
   // vec2 uv = gl_FragCoord.xy / resolution;
    
  
 float t = time;
    vec2 uv = ( gl_FragCoord.xy/resolution.xy);
    vec2 mouse = resolution.xy ;
    
    vec2 fieldUV = uv + vec2(t* 0.01,t* 0.01);
    float field = DrawField(fieldUV,20.);
    float fieldMask = clamp(S(3.5,0.,length(uv *vec2(1.,2.) + vec2(0.0,-0.5))),0.,1.);
    field *= fieldMask;

    vec3 backgroundColor = mix(vec3(0.6588, 0.9137, 1.),vec3(0.043,0.1689,0.3294),(uv.y*0.4 + 1.));
    vec3 color = backgroundColor + vec3(0.6588, 0.9137, 1.) * field;
    
    vec3 mountain = mix(vec3(0.),color,S(-0.82,-0.8,uv.y))- Grain(uv)*0.05;
   
    gl_FragColor = vec4(color- Grain(uv)*0.05 ,1.0);
}
