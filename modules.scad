/********************/
/*** PART MODULES ***/
/********************/

// target specimen, nominal sizes
module specimen(l = blank_length, w = blank_width, t = specimen_thickness, A = sp_A, R = sp_R, offset = 0){
	difference(){
		cube([l, w, t], center = true);
		die(R = R, t = 2*t, offset = offset);
	}
}

// top tool, no offset
module die(A = sp_A, R = sp_R, t = plate_thickness, offset = 0, cbore = false, threaded = false){
	radius = R + offset/2;
	screw_spacing = die_screw_spacing;
	dowel_spacing = die_dowel_spacing;

	difference(){
		union(){			
			// flat cutout sections
			translate([-A/2, (reduced-offset)/2,-t/2])		cube([A, 2*R, t]);
			translate([-A/2,-(reduced-offset)/2,-t/2])		
										mirror([0,1,0])		cube([A, 2*R, t]);
			// 1.25 + R + rw/2 = 4" across tools
			translate([-(A+2*radius)/2, reduced/2+R,-t/2])	cube([A+2*radius, 1.25, t]);		
			translate([-(A+2*radius)/2,-reduced/2-R,-t/2])	
										mirror([0,1,0])		cube([A+2*radius, 1.25, t]);
			// radii
			union(){
				translate([ A/2, reduced/2 + R,0])	cylinder(h = t, r = radius, center = true);
				translate([-A/2, reduced/2 + R,0])	cylinder(h = t, r = radius, center = true);
				translate([ A/2,-reduced/2 - R,0])	cylinder(h = t, r = radius, center = true);
				translate([-A/2,-reduced/2 - R,0])	cylinder(h = t, r = radius, center = true);
			}
		}
		union(){
			// dowel holes ***update helper functions (won't update with dowel values yet)
			hole_array(x = dowel_spacing[0], y = dowel_spacing[1], threaded = false, type = false);
			//screw holes
			hole_array(x = screw_spacing[0], y = screw_spacing[1], threaded = threaded, type = true);
			// counterbores
			if(cbore){
				mirror([0,0,1]){
					translate([ screw_spacing[0],  screw_spacing[1], 0.1])	counterbore();
					translate([ screw_spacing[0], -screw_spacing[1], 0.1])	counterbore();
					translate([-screw_spacing[0],  screw_spacing[1], 0.1])	counterbore();
					translate([-screw_spacing[0], -screw_spacing[1], 0.1])	counterbore();
				}
			}
		}
	}
}

// bottom tool, .006" clearance on cutout section
module punch(cbore = false, threaded = false){
	screw_spacing = punch_screw_spacing;
	//dowel_spacing = punch_dowel_spacing;
	difference(){
		// same shape as specimen with die clearance and plate thickness
		specimen(t = plate_thickness, offset = clearance);
		union(){
			// dowel holes
			hole(type = false);
			translate([ screw_spacing[0], 0, 0])	hole(type = false);
			translate([-screw_spacing[0], 0, 0])	hole(type = false);
			// screw holes
			hole_array(x = screw_spacing[0], y = screw_spacing[1], z = 0, threaded = threaded, type = true);
			// counterbores
			if(cbore){
				translate([ screw_spacing[0],  screw_spacing[1], 0.1])	counterbore();
				translate([ screw_spacing[0], -screw_spacing[1], 0.1])	counterbore();
				translate([-screw_spacing[0],  screw_spacing[1], 0.1])	counterbore();
				translate([-screw_spacing[0], -screw_spacing[1], 0.1])	counterbore();
			}
		}
	}	
}

// baseplate
module base(l = base_length, w = base_width, t = plate_thickness){
	difference(){
		color("DarkRed", 1.0) cube([l,w,t], center = true);
		union(){
			// center hole
			hole(type = false);
			// short edge locator
			translate([-(blank_length/2 + dowel_radius), 0, 0])	hole(type = false);
			// long edge locators
			translate([-(blank_length/2 - blank_width/2), blank_width/2 + dowel_radius, 0])	hole(type = false);
			translate([ (blank_length/2 - blank_width/2), blank_width/2 + dowel_radius, 0])	hole(type = false);
			
			// punch alignment holes (copied from punch module)
			translate([ punch_screw_spacing[0], 0, 0])	hole(type = false);
			translate([-punch_screw_spacing[0], 0, 0])	hole(type = false);
			// punch screw holes, clearance
			hole_array(x = punch_screw_spacing[0], y = punch_screw_spacing[1], threaded = false, type = true);
			
			// die alignment holes
			hole_array(x = die_dowel_spacing[0], y = die_dowel_spacing[1], threaded = false, type = false);

		}	
	}
	if(show_dowels){
		// blank locators
		translate([-(blank_length/2 + dowel_radius), 0, 1.5])  dowel_pin(dowel_length = 3.5);
		translate([-(blank_length/2 - blank_width/2), blank_width/2 + dowel_radius, 1.5])	dowel_pin(dowel_length = 3.5);
		translate([ (blank_length/2 - blank_width/2), blank_width/2 + dowel_radius, 1.5])	dowel_pin(dowel_length = 3.5);
		// die guides
		color("Violet", 1.0) scale([1,1,3]){hole_array(x = die_dowel_spacing[0], y = die_dowel_spacing[1], z = 0.5, threaded = false, type = false);}
		// punch locators
		translate([0,0,.5])	dowel_pin(dowel_length = 1.5);
		translate([ punch_screw_spacing[0], 0, .5])	dowel_pin(dowel_length = 1.5);
		translate([-punch_screw_spacing[0], 0, .5])	dowel_pin(dowel_length = 1.5);
	}
}


/***********************/
/*** HELPER FEATURES ***/
/***********************/

// create a hole or pin, boolean threaded, type false = dowel, type true = screw
module hole(depth = 2*plate_thickness, threaded = false, type = true){
	r = !type ? dowel_radius : (threaded ? tap_drill/2 : screw_dia/2);
	cylinder(h = depth, r = r, center = true);
}

module counterbore(){
	cylinder(h = cbore_depth + .1, r = cbore_dia/2);	// +.1 to prevent z-fighting on preview
}

module dowel_pin(dowel_length){
	color("Violet") cylinder(h = dowel_length, r = dowel_radius, center = true);	
}

module hole_array(x,y,z=0,threaded,type){
	translate([ x, y, z]) hole(type = type, threaded = threaded);
	translate([-x, y, z]) hole(type = type, threaded = threaded);
	translate([ x,-y, z]) hole(type = type, threaded = threaded);
	translate([-x,-y, z]) hole(type = type, threaded = threaded);
}