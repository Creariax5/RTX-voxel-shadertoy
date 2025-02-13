# Voxel Terrain Engine 🎮
A real-time procedural voxel terrain generator implemented in GLSL on ShaderToy

![Pasted image 20250213171844](https://github.com/user-attachments/assets/67052bd5-22cc-42e7-86fb-a6b73d8bf8aa)


## 🔗 Live Demo
Check out the live demo on ShaderToy: [Voxel Terrain Engine](https://www.shadertoy.com/view/MX3cRN)

## 📝 Overview
This project implements a real-time voxel terrain generator using GLSL shaders. It combines optimized ray marching techniques with procedural noise generation to create infinite, natural-looking landscapes entirely on the GPU.

## 🛠️ Technical Features
- **Ray Marching**: Implemented using Digital Differential Analyzer (DDA) algorithm for efficient voxel traversal
- **Procedural Generation**: Custom value noise implementation with:
  - Multi-octave noise layers
  - Matrix-based transformations
  - Custom hash functions for randomization
- **Performance Optimizations**:
  - GPU-accelerated computations
  - Optimized noise calculations
  - Efficient ray generation with FOV control

## 🔧 Implementation Details
The terrain generation uses several key components:

```glsl
// Multi-octave noise for natural terrain features
float myNoise(in vec2 uv) {
    float f = 0.0;
    uv *= 8.0;
    mat2 m = mat2(1.6, 1.2, -1.2, 1.6);
    f = 0.5000 * noise(uv);
    // Additional octaves...
}
```

## 🎮 Controls
- Camera movement through mouse interaction
- Dynamic terrain generation based on viewport
- Real-time rendering with automatic updates

## 📚 Resources
- [ShaderToy Documentation](https://www.shadertoy.com/howto)
- [GLSL Reference](https://www.khronos.org/opengl/wiki/Core_Language_(GLSL))
- [Ray Marching Explanation](https://computergraphics.stackexchange.com/questions/161/what-is-ray-marching-is-sphere-tracing-the-same-thing)

## 🤝 Contributing
Feel free to fork, submit PRs, or use this code as a reference for your own projects.

## 📄 License
MIT License - feel free to use and modify for your own projects.

---
*Created with ❤️ by Florian DEMARTINI*
