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
			array_four(x_spacing = A, y_spacing = reduced + 2*R)
				cylinder(h = t, r = radius, center = true);			
		}
		union(){
			// dowel holes
			array_four(x_spacing = dowel_spacing[0], y_spacing = dowel_spacing[1])
				hole(type = false, threaded = false);
			//screw holes
			array_four(x_spacing = screw_spacing[0], y_spacing = screw_spacing[1])
				hole(type = true, threaded = threaded);
			// counterbores, they dont go here but keeping code in case need it later
			/* if(cbore){
				mirror([0,0,1]){
					translate([ screw_spacing[0],  screw_spacing[1], 0.1])	counterbore();
					translate([ screw_spacing[0], -screw_spacing[1], 0.1])	counterbore();
					translate([-screw_spacing[0],  screw_spacing[1], 0.1])	counterbore();
					translate([-screw_spacing[0], -screw_spacing[1], 0.1])	counterbore();
				}
			} */
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
			array_two(screw_spacing[0])	hole(type = false);
			// // screw holes
			array_four(x_spacing = screw_spacing[0], y_spacing = screw_spacing[1]) 
				hole(type = true, threaded = threaded);
			// counterbores
			/* if(cbore){
				translate([ screw_spacing[0],  screw_spacing[1], 0.1])	counterbore();
				translate([ screw_spacing[0], -screw_spacing[1], 0.1])	counterbore();
				translate([-screw_spacing[0],  screw_spacing[1], 0.1])	counterbore();
				translate([-screw_spacing[0], -screw_spacing[1], 0.1])	counterbore();
			} */
		}
	}	
}

// baseplate
module base(l = base_length, w = base_width, t = plate_thickness){

	long_edge_location = [blank_length-blank_width, blank_width/2 + dowel_radius];
	short_edge_location = -(blank_length/2 + dowel_radius);

	difference(){
		color("DarkRed", 1.0) cube([l,w,t], center = true);
		union(){
			// center hole
			hole(type = false);
			// short edge locator
			translate([short_edge_location, 0, 0])	hole(type = false);
			// long edge locators
			array_two(long_edge_location[0], y = long_edge_location[1])	
				hole(type = false);
			// punch alignment holes
			array_two(punch_screw_spacing[0])		hole(type = false);
			// punch screw holes, clearance
			array_four(x_spacing = punch_screw_spacing[0], y_spacing = punch_screw_spacing[1])	
				hole(threaded = false, type = true);
			// die alignment holes
			array_four(x_spacing = die_dowel_spacing[0], y_spacing = die_dowel_spacing[1])
				hole(threaded = false, type = false);
		}	
	}
	if(show_dowels){
		// blank locators
		translate([short_edge_location, 0, 1.5])  dowel_pin(dowel_length = 3.5);
		array_two(long_edge_location[0], y = long_edge_location[1], z = 1.5) 
			dowel_pin(dowel_length = 3.5);
		// die guides
		array_four(x_spacing = die_dowel_spacing[0], y_spacing = die_dowel_spacing[1], z = 1.5)
			dowel_pin(dowel_length = 3.5);
		// punch locators
		translate([0,0,.5])	dowel_pin(dowel_length = 1.5);
		array_two(punch_screw_spacing[0], z = .5) dowel_pin(dowel_length = 1.5);
	}
}
