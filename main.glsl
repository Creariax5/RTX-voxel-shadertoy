float fastnoise(vec2 p) {
    return (sin(p.x)-cos(p.y))*.5+.5;
}


// Value noise - https://www.shadertoy.com/view/lsf3WH
float hash(vec2 p) {
    p  = 50.0*fract( p*0.3183099 + vec2(0.71,0.113));
    return fract( p.x*p.y*(p.x+p.y) );
}

float noise( in vec2 p ) {
    vec2 i = floor( p );
    vec2 f = fract( p );
	vec2 u = f*f*(3.0-2.0*f);
    return mix( mix( hash( i + vec2(0.0,0.0) ), 
                     hash( i + vec2(1.0,0.0) ), u.x),
                mix( hash( i + vec2(0.0,1.0) ), 
                     hash( i + vec2(1.0,1.0) ), u.x), u.y);
}

float myNoise(in vec2 uv) {
    float f = 0.0;
    uv *= 8.0;
    mat2 m = mat2(1.6, 1.2, -1.2, 1.6);
    
    int iterations = 0;
    f = 0.5000 * noise(uv);
    uv = m * uv;
    
    // Track subsequent iterations with counter
    float amplitude = 0.2500;
    for (int i = 0; i < MAX_NOISE_ITER; i++) {
        f += amplitude * noise(uv);
        uv = m * uv;
        amplitude *= 0.5;  // Reduces from 0.2500 to 0.1250 to 0.0625
        iterations++;
    }    
    return f;
}

float noiseStep(vec2 p, float prec) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    // Combine smoothstep and precision reduction in one step
    // Store 1/prec to avoid multiple divisions
    float invPrec = 1.0/prec;
    vec2 u = floor((f * f * (3.0 - 2.0 * f)) * prec) * invPrec;
    
    // Compute the mix factor for x once instead of twice
    float mixX = mix(
        hash(i),                    // (0,0)
        hash(i + vec2(1.0, 0.0)),  // (1,0)
        u.x
    );
    
    float mixY = mix(
        hash(i + vec2(0.0, 1.0)),  // (0,1)
        hash(i + vec2(1.0, 1.0)),  // (1,1)
        u.x
    );
    
    // Final mix and quantization in one step
    return floor(mix(mixX, mixY, u.y) * prec) * invPrec;
}

vec3 generateRay(vec2 uv, vec3 cam_vec) {
    // Create view matrix from camera vector
    vec3 forward = normalize(cam_vec);
    vec3 right = normalize(cross(forward, vec3(0.0, 1.0, 0.0)));
    vec3 up = cross(right, forward);
    
    // Generate ray direction
    return normalize(forward + right * uv.x * FOV + up * uv.y * FOV);
}

bool getVoxel(ivec3 rayPos) {
    float noise_pos = myNoise(vec2(rayPos.xz)/(MAP_HEIGHT*8.0))*MAP_HEIGHT - MAP_HEIGHT;
    
    return float(rayPos.y) < noise_pos;
}

vec3 getCubeDDA(vec3 rayPos, vec3 rayDir) {
    int i;
    ivec3 mapPos = ivec3(floor(rayPos));
	vec3 deltaDist = abs(1.0 / rayDir);
	ivec3 rayStep = ivec3(sign(rayDir));
	vec3 sideDist = (sign(rayDir) * (vec3(mapPos) - rayPos) + (sign(rayDir) * 0.5) + 0.5) * deltaDist; 
	bvec3 mask = bvec3(false);
    
	for (i = 0; i < MAX_RAY_STEPS; i++) {
		if (getVoxel(mapPos)) break;
        mask = lessThanEqual(sideDist.xyz, min(sideDist.yzx, sideDist.zxy));

		sideDist += vec3(mask) * deltaDist;
		mapPos += ivec3(vec3(mask)) * rayStep;
	}
	
	vec3 color = vec3(0.45);
    color = mask.y ? vec3(1.0) : color;
    color = mask.z ? vec3(0.65) : color;
    color = (i >= MAX_RAY_STEPS-1) ? rayDir : color;
	return abs(color);
}

vec3 image(vec2 fragCoord) {
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y*1.0;
    
    vec2 iM = fetchData(iChannel0, PIX_CLICKED_ADDR).rg;
    vec3 cam_vec = fetchData(iChannel0, VEC_CAM_ADDR).rgb;
    vec3 ray = generateRay(uv, cam_vec);
    vec3 pos_cam = fetchData(iChannel0, POS_CAM_ADDR).rgb;
    
    return getCubeDDA(pos_cam, ray);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 color = vec3(0.0);
    
    
    if (IMG == 0) {
        color = image(fragCoord);
        
    } else if (IMG == 1) {
        ivec2 texCoord = ivec2(fragCoord/50.0);
        color = fetchData(iChannel0, texCoord).rgb;
        
    } else {
        vec2 uv = vec2(fragCoord.xy * 0.004) + iTime*0.0;
        
        float timeBasedPrec = pow(2.0, mod((iTime/2.0), 6.0)+0.0);
    
        // Use the time-based precision in the noise function
        color = vec3(noiseStep(uv*1.0, timeBasedPrec));
    }
    
    fragColor = vec4(color.x, color.y, color.z, 1.0);
}
