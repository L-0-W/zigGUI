@vs vs
in vec4 position;
in vec4 color0;
in int widgetID0;
flat out int widgetID;
out vec4 color;


void main() {
    color = color0;
    widgetID = widgetID0;
    
    vec4 pos = position;
    gl_Position = pos;
}
@end

@fs fs
layout(binding = 0) uniform vs_params {
    float aspect;
    vec2 resolution_f;
};

flat in int widgetID;
in vec4 color;
out vec4 frag_color;



float roundedBoxSDF(vec2 CenterPosition, vec2 Size, vec4 Radius)
{
    Radius.xy = (CenterPosition.x > 0.0) ? Radius.xy : Radius.zw;
    Radius.x  = (CenterPosition.y > 0.0) ? Radius.x  : Radius.y;
    
    vec2 q = abs(CenterPosition)-Size+Radius.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - Radius.x;
}

void main() {


    vec2 center = resolution_f.xy / 2.0; // Centro da tela em pixels
    vec2 size = vec2(150.0, 30.0);
    
    vec4  u_colorRect   = vec4(0.176, 0.243, 0.314, 1.0); // The color of rectangle
    vec4  u_colorBorder;
    
    if (widgetID == 0) {
        u_colorBorder = vec4(1.0,1.0,1.0,1.0);
    } else {
        u_colorBorder = vec4(0.500,0.345,0.314,1.0); // The color of (internal) border
    }
    
    vec4  u_cornerRadiuses = vec4(15);
    
    float edgeSoftness  = 1.0f;
    
    vec2 halfSize = (size / 2.0);
    
    float u_borderThickness = 2.0; // The border size (in pixels) 
    float u_borderSoftness  = 2.0; // How soft the (internal) border should be (in pixels)
    
    float distance = roundedBoxSDF(gl_FragCoord.xy - center, halfSize, u_cornerRadiuses);
    
    float smoothedAlpha = 1.0f - smoothstep(0.0f, edgeSoftness * 2.0f, distance);
    
    float borderAlpha   = 1.0-smoothstep(u_borderThickness - u_borderSoftness, u_borderThickness, abs(distance));
    
    vec4 color_f = mix(vec4(0.176, 0.243, 0.314, 1.0), u_colorRect, min(u_colorRect.a, smoothedAlpha));
    
    frag_color = mix(color_f, u_colorBorder, min(u_colorBorder.a, min(borderAlpha, smoothedAlpha)));
}
@end


@program quad vs fs
