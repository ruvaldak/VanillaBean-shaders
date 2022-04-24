# TODO:
* fix shadow flickering with TAA
* implement fog in composite
    * Refer to abandoned VanillaBean2 for new style
    * Ability to entirely adjust fog in settings.
* add other gbuffers
* fix shadow bias causing disconnected shadows
    * Emin(complementary) fixed the issue by moving the shadow map after the bias, or something like that
* Change shadow filter from box kernel to spherical
    * uniform spherical sample distribution without weights
* Shader hand lights
* Implement PBR
    * POM and Normals should be fine, specular needs to be subtle, simplistic, and fit in with the vanilla look.
    * Reflections need to be as undefined as possible (not mirror like, very generic) and react to other light sources such as torches, lava, etc.
        * Might require voxels, so initially, basic specular will suffice, maybe a heavily blurred SSR.
* Add optional bloom
* Adjust SSAO according to light
    * Light emitting blocks/objects shouldn't be affected by SSAO, their shadows shouldn't be as visible if at all, etc. Cannot cast a shadow on a light emitting object.
