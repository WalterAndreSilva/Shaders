// reloj con relacion de minuto-hora
float sdCircle(vec2 uv, float r, vec2 offset) {
  float x = uv.x - offset.x;
  float y = uv.y - offset.y;
  return length(vec2(x, y)) - r;
}

float opSymX(vec2 p, float r) {
  p.x = abs(p.x);
  return sdCircle(p, r, vec2(0.45, 0));
}

float opSymY(vec2 p, float r) {
  p.y = abs(p.y);
  return sdCircle(p, r, vec2(.0, 0.45));
}

float opSymXY1(vec2 p, float r) {
  p = abs(p);
  return sdCircle(p, r, vec2(.40, .25));
}

float opSymXY2(vec2 p, float r) {
  p = abs(p);
  return sdCircle(p, r, vec2(.25, .40));
}


float sdSegment( in vec2 p, in vec2 a, in vec2 b ) {
  vec2 pa = p-a, ba = b-a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h );
}

vec3 drawScene(vec2 uv) {
  vec3 col = vec3(0);
  
  float res1 = opSymX(uv, 0.02);
  float res2 = opSymY(uv, 0.02);
  float res3 = opSymXY1(uv, 0.01);
  float res4 = opSymXY2(uv, 0.01);
  float segment1 = sdSegment(uv, vec2(0.0, .0), vec2(sin(iTime*.3)*0.2, cos(iTime*.3)*0.2));    // hora
  float segment2 = sdSegment(uv, vec2(0.0, .0), vec2(sin(iTime*3.6)*0.4, cos(iTime*3.6)*0.4));  // minuto
  
  res1 = step(0., res1);
  col = mix(vec3(0,0,1), col, res1);
  
  res2 = step(0., res2);
  col = mix(vec3(0,0,1), col, res2);
  
  res3 = step(0., res3);
  col = mix(vec3(1), col, res3);
  
  res4 = step(0., res4);
  col = mix(vec3(1), col, res4);
  
  col = mix(vec3(1, .0, .0), col, step(0., segment1 - 0.02));
  col = mix(vec3(1, 1, 1), col, step(0., segment2 - 0.01));

  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
  vec2 uv = fragCoord/iResolution.xy;
  uv -= 0.5; 
  uv.x *= iResolution.x/iResolution.y; 
  vec3 col = drawScene(uv);

  fragColor = vec4(col,1.0);
}
