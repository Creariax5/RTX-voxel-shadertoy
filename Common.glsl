const ivec2 SCREEN_COLOR_ADDR = ivec2(0, 0);
const ivec2 PIX_CLICKED_ADDR = ivec2(1, 0);
const ivec2 LAST_PIX_CLICKED_ADDR = ivec2(2, 0);
const ivec2 VEC_CAM_ADDR = ivec2(3, 0);
const ivec2 POS_CAM_ADDR = ivec2(4, 0);

const vec3 LIGHT_POS = vec3(0, 0, 0);

const int KEY_LEFT  = 37;
const int KEY_UP    = 38;
const int KEY_RIGHT = 39;
const int KEY_DOWN  = 40;
const int KEY_SPACE = 32;
const int KEY_MAJ   = 16;
const int KEY_Q     = 81;
const int KEY_D     = 68;
const int KEY_Z     = 90;
const int KEY_S     = 83;
const int KEY_E     = 69;

const float SPEED = 300.0;

const int MAX_NOISE_ITER = 4;
const int MAX_RAY_STEPS = 400;
const float FOV = 1.2;

const float MAP_HEIGHT = 150.0;

const int IMG = 0;

#define fetchData(buf, addr) texelFetch(buf, addr, 0)
#define storeData(buf_pos, addr) ivec2(buf_pos) == addr
