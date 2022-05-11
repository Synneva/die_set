/***********************/
/*** HELPER FEATURES ***/
/***********************/

// create a hole or pin, boolean threaded, type false = dowel, type true = screw
module hole(depth = 2*plate_thickness, threaded = false, type = true){
	r = !type ? dowel_radius : (threaded ? tap_drill/2 : screw_dia/2);
	cylinder(h = depth, r = r, center = true);
}

/* module counterbore(){
	cylinder(h = cbore_depth + .1, r = cbore_dia/2);	// +.1 to prevent z-fighting on preview
} */

module dowel_pin(dowel_length){
	color("Violet") cylinder(h = dowel_length, r = dowel_radius, center = true);	
}

module array_two(spacing, y = 0, z = 0){
	for(x = [-spacing/2, spacing/2]){
		translate([x,y,z]) children();
	}
}
module array_four(x_spacing, y_spacing, z = 0){
	for(x = [-x_spacing/2, x_spacing/2]){
		for(y = [-y_spacing/2, y_spacing/2]){
			translate([x,y,z]) mirror([0,1,0]) children();
		}
	}
}