// Circulos deformados para crear slime
const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;
const float EPSILON = 0.0005;
const float PI = 3.14159265359;
const vec3 COLOR_BACKGROUND = vec3(.0);
const vec3 COLOR_AMBIENT = vec3(0., 1., 0.);

mat2 rotate2d(float theta) {
  float s = sin(theta), c = cos(theta);
  return mat2(c, -s, s, c);
}

float sdSphere(vec3 p, float r, vec3 offset) {
  return length(p - offset) - r;
}

float opRep(vec3 p, float r, vec3 o, vec3 c) {
  vec3 q = mod(p+0.5*c,c)-0.5*c;
  return sdSphere(q, r, o);
}

float opDisplace(vec3 p, float r, vec3 o, float time) {
  float d1 = sdSphere(p, r, o);
  float d2 = sin(p.x)*sin(p.y)*sin(p.z) * cos(time);
  return d1 + d2;
}

float opSmoothUnion( float d1, float d2, float k ) {
  float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
  return mix( d2, d1, h ) - k*h*(1.0-h);
}

float scene(vec3 p) {
  float f0 = opRep(p, .1, vec3(0), vec3(8));
  float f1 = opDisplace(p, 1.5, vec3(0,1,0), iTime+1.);
  float f2 = opDisplace(p, 1.0, vec3(1,0,0), iTime+2.);
  float f3 = opDisplace(p, 1.2, vec3(0,0,1), iTime);

  float r1 = opSmoothUnion(f1,f2,0.5);
  float r2 = opSmoothUnion(r1,f3,0.5);
  return min(f0,r2);
}

float rayMarch(vec3 ro, vec3 rd) {
  float depth = MIN_DIST;
  float d;
  for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
    vec3 p = ro + depth * rd;
    d = scene(p);
    depth += d;
    if (d < PRECISION || depth > MAX_DIST) break;
  }
  d = depth;
  return d;
}

vec3 calcNormal(in vec3 p) {
    vec2 e = vec2(1, -1) * EPSILON;
    return normalize(
      e.xyy * scene(p + e.xyy) +
      e.yyx * scene(p + e.yyx) +
      e.yxy * scene(p + e.yxy) +
      e.xxx * scene(p + e.xxx) );
}

mat3 camera(vec3 cameraPos, vec3 lookAtPoint) {
    vec3 cd = normalize(lookAtPoint - cameraPos);
    vec3 cr = normalize(cross(vec3(0, 1, 0), cd));
    vec3 cu = normalize(cross(cd, cr));
    return mat3(-cr, cu, -cd);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
  vec2 mouseUV = iMouse.xy/iResolution.xy;

  if (mouseUV == vec2(0.0)) mouseUV = vec2(0.5);

  vec3 col = vec3(0);
  vec3 lp = vec3(0);
  vec3 ro = vec3(0, 0, 4); 

  float cameraRadius = 2.;
  ro.yz = ro.yz * cameraRadius * rotate2d(mix(-PI/2., PI/2., mouseUV.y));
  ro.xz = ro.xz * rotate2d(mix(-PI, PI, mouseUV.x)) + vec2(lp.x, lp.z);

  vec3 rd = camera(ro, lp) * normalize(vec3(uv, -1));
  float d = rayMarch(ro, rd); 

  if (d > MAX_DIST) {
    col = COLOR_BACKGROUND; 
  } else {
    vec3 p = ro + rd * d; 
    vec3 normal = calcNormal(p); 

    vec3 lightPosition = vec3(0, 3, 2);
    vec3 lightDirection = normalize(lightPosition - p) * .7; 

    float dif = clamp(dot(normal, lightDirection), 0., 1.) * 0.5 + 0.5;  
    col = vec3(dif) + COLOR_AMBIENT;
  }

  fragColor = vec4(col, 1.0);
}


