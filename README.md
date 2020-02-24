# Unity Ray Marching

Note: This is just a test, I'm not a graphics programmer and it's the result of the first day of my acquaintance with Ray Marching.
If you want to learn Ray Marching - I recommend you next youtube videos, that helped me deal with it:
- [Writing a ray marcher in Unity](https://www.youtube.com/watch?v=S8AWd66hoCo)
- [RayMarching: Basic Operators](https://www.youtube.com/watch?v=AfKGMUDWfuE)
- [Ray Marching for Dummies!](https://www.youtube.com/watch?v=PGtv-dBi2wE)

## Raymarching Examples

There are several simple tests, that helped me recognize how Ray Marching works.

To use this, you need to apply the material with shader `RayMarchingTest` to any mesh. This mesh will we used as a canvas to render Ray Marching image.

<img src="/Images/test_material.png" width=500></img>


### Light

You can setup two light sources: one `Directional` and one `Point`.

Each light has two parameters:
- Vector4 for `Direction` in case of Directional light and `Position` for point light. The fourth value is light `Intensity`.
- `Color` for light color;

Point lint also contains the float field for the `Range`.

You can set up these values manually or use `RayMarchingCanvas` class to take values from the scene.

Also, you can enable or disable `Shadows`, but they are looks awful.

### System

<img src="/Images/trip.gif" width=500></img>

coming soon...

### Quality

coming soon...

## Particle System

<img src="/Images/particles.gif" width=500></img>

coming soon...
