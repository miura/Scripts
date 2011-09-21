
#version 3.6;
global_settings {  assumed_gamma 1.0 }
//--------------------------------------
camera{ ultra_wide_angle
        angle 75
        right x*image_width/image_height
        location  <0.0 , 1.0 ,-3.0>
        look_at   <0.0 , 0.0 , 0.0> }
//---------------------------------------
light_source{ <1500,2500,-2500>
              color rgb<0.8,0.8,1> }
//---------------------------------------
sky_sphere{ pigment{color rgb<0,0,0>}}
//---------------------------------------
// the rotating sphere:
sphere{ <0,0,0>, 0.25
        texture { pigment{ rgb<1,0,0> }
                  finish { diffuse 0.9
                           phong 1}
                } // end of texture
        translate < 1.0, 0, 0>
        rotate < 0,360*clock 0>//  <-!!!!
       } // end of sphere ---------------
//----------------------------------- end
