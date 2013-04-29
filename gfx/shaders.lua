-- This is Marcus porting and tweaking some sweet GLSL code found here: http://glsl.heroku.com/e#8258.4
space = love.graphics.newPixelEffect [[
         extern float time;
         extern vec4 bgColor;
         float N = 12;
         
         vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
         {
            vec2 v = tc;
    
            float x = v.x;
            float y = v.y;
            
            float t = time * 0.15;
            float r;
            for ( int i = 0; i < N; i++ ){
                float d = 3.14159265 / float(N) * float(i) * 3.0;
                r = length(vec2(x,y)) + 0.01;
                float xx = x;
                x = x + cos(y +cos(r) + d) + cos(t);
                y = y - sin(xx+cos(r) + d) + sin(t);
            }
            float red = cos(r*sin(time*0.01));
            red = red*.2;
            vec4 mbgColor = bgColor/255.0;
            return vec4( red, red, red, 1.0 ) + mbgColor*mbgColor.a;
         }
      ]]

rainbow = love.graphics.newPixelEffect [[ 
        extern float time;

        vec4 hsv_to_rgb(float h, float s, float v, float a)
        {
            float c = v * s;
            h = mod((h * 6.0), 6.0);
            float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));
            vec4 color;
         
            if (0.0 <= h && h < 1.0) {
                color = vec4(c, x, 0.0, a);
            } else if (1.0 <= h && h < 2.0) {
                color = vec4(x, c, 0.0, a);
            } else if (2.0 <= h && h < 3.0) {
                color = vec4(0.0, c, x, a);
            } else if (3.0 <= h && h < 4.0) {
                color = vec4(0.0, x, c, a);
            } else if (4.0 <= h && h < 5.0) {
                color = vec4(x, 0.0, c, a);
            } else if (5.0 <= h && h < 6.0) {
                color = vec4(c, 0.0, x, a);
            } else {
                color = vec4(0.0, 0.0, 0.0, a);
            }
         
            color.rgb += v - c;
         
            return color;
        }

        vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
        {
            return hsv_to_rgb(sin(pc.x*.001 + time)*cos(pc.y*.001+time), 1.0, 1.0, 1.0)*Texel(texture, tc);
        }
    ]]

announcementShader = love.graphics.newPixelEffect [[ 
        extern float time;
        extern number player;

        vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
        {
            float a = sin(time*50)/2.0 + 0.5;
            if (player == 0) {
                return vec4(1.0, a, a, 1.0)*Texel(texture, tc);
            } else {
                return vec4(a, a, 1.0, 1.0)*Texel(texture, tc);
            }
        }
    ]]

invertShader = love.graphics.newPixelEffect [[
        extern float time;

        vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
        {
            vec4 col = Texel(texture, tc);
            return vec4(1.0-col.x, 1.0-col.y, 1.0-col.z, 1.0);
        }
    ]]

