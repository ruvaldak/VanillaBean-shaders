# TODO:
* fix shadow flickering with TAA
* implement fog in composite
* add other gbuffers
* fix shadow bias causing disconnected shadows
    * Emin(complementary) fixed the issue by moving the shadow map after the bias, or something like that
* Change shadow filter from box kernel to spherical
    * uniform spherical sample distribution without weights
* Shader hand lights
* Implement PBR
* Adjust SSAO according to light
    * Light emitting blocks/objects shouldn't be affected by SSAO, their shadows shouldn't be as visible if at all, etc. Cannot cast a shadow on a light emitting object.
