vec3 rotate(vec3 v, vec2 angle) {
    vec3 result = v;
    
    // Create rotation axes
    vec3 right = normalize(cross(v, vec3(0.0, 1.0, 0.0)));
    vec3 up = normalize(cross(right, v));
    
    // Rotate around right vector for up/down (negated angle.y)
    float cosX = cos(-angle.y);  // Negated here
    float sinX = sin(-angle.y);  // Negated here
    result = normalize(v * cosX + up * sinX);
    
    // Rotate around world up for left/right
    float cosY = cos(angle.x);
    float sinY = sin(angle.x);
    return vec3(
        result.x * cosY - result.z * sinY,
        result.y,
        result.x * sinY + result.z * cosY
    );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Store raw mouse coordinates for simplicity
    vec2 iM = iMouse.xy;
    
    if (storeData(fragCoord, SCREEN_COLOR_ADDR)) {
        fragColor = vec4(0.0, 0.0, 1.0, 0.0);
    }
    if (storeData(fragCoord, PIX_CLICKED_ADDR)) {
        fragColor = vec4(iM, iMouse.zw);
    }
    if (storeData(fragCoord, LAST_PIX_CLICKED_ADDR)) {
        fragColor = vec4(iM, iMouse.zw);
    }
    vec3 cam_vec = normalize(vec3(1.0, 0.0, 1.0));
    if (storeData(fragCoord, VEC_CAM_ADDR)) {
        fragColor = vec4(cam_vec, 1.0);
    }
    vec3 cam_pos = normalize(vec3(0.0, 0.0, 0.0));
    if (storeData(fragCoord, POS_CAM_ADDR)) {
        fragColor = vec4(cam_pos, 1.0);
    }
    
    if (iFrame > 0) {
        if (storeData(fragCoord, SCREEN_COLOR_ADDR)) {
            fragColor = fetchData(iChannel0, SCREEN_COLOR_ADDR);
            fragColor.r += 0.01;
        }
        if (storeData(fragCoord, PIX_CLICKED_ADDR)) {
            fragColor = vec4(iM, iMouse.zw);
        }
        if (storeData(fragCoord, LAST_PIX_CLICKED_ADDR)) {
            fragColor = fetchData(iChannel0, PIX_CLICKED_ADDR);
        }
        if (storeData(fragCoord, VEC_CAM_ADDR)) {
            fragColor = fetchData(iChannel0, VEC_CAM_ADDR);
            
            if (fetchData(iChannel0, LAST_PIX_CLICKED_ADDR).b == fetchData(iChannel0, PIX_CLICKED_ADDR).b) {
                vec2 mousePos = iMouse.xy / iResolution.xy;  // Normalize to [0,1]
                vec2 lastMousePos = fetchData(iChannel0, LAST_PIX_CLICKED_ADDR).xy / iResolution.xy;
                
                vec2 delta = mousePos - lastMousePos;
                delta *= vec2(3.0, -3.0);
                
                
                cam_vec = fragColor.xyz;
                cam_vec = rotate(cam_vec, delta);
                
                fragColor = vec4(normalize(cam_vec), 1.0);
            }
        }
        if (storeData(fragCoord, POS_CAM_ADDR)) {
            fragColor = fetchData(iChannel0, POS_CAM_ADDR);
            
            cam_vec = fetchData(iChannel0, VEC_CAM_ADDR).rgb;
            
            vec2 forward = normalize(cam_vec.xz) * SPEED;
            fragColor.xz += forward * iTimeDelta * (
                texelFetch(iChannel1, ivec2(KEY_Z, 0), 0).r -  // Forward
                texelFetch(iChannel1, ivec2(KEY_S, 0), 0).r    // Backward
            );

            // Strafe left/right (perpendicular to camera direction)
            vec2 right = normalize(vec2(-forward.y, forward.x)) * SPEED;  // 90-degree rotation
            fragColor.xz += right * iTimeDelta * (
                texelFetch(iChannel1, ivec2(KEY_D, 0), 0).r -  // Right
                texelFetch(iChannel1, ivec2(KEY_Q, 0), 0).r    // Left
            );
            fragColor.g += (iTimeDelta * SPEED) * texelFetch(iChannel1, ivec2(KEY_SPACE, 0), 0).r -
        		(iTimeDelta * SPEED) * texelFetch(iChannel1, ivec2(KEY_E, 0), 0).r;
        }
    }
}
