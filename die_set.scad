/**********************/
/*** RENDER SETTINGS***/
/**********************/
$fa = .01;
$fs = .01;
show_dowels = true;			// toggle dowels on/off


/************************/
/*** MODEL PARAMETERS ***/
/************************/
base_length = 10;
base_width = 6;
plate_thickness = .5;
blank_length = 8;
blank_width = 2;

specimen_thickness = .1325; // measured, check with rob
A = 2.25;					// specimen datasheet A value
R = .5;						// specimen radius R
reduced = .5;				// specimen reduced width w

clearance = .006;			// between die and punch

dowel_radius = .125;		// 1/4" dowel pins
dowel_clearance = 0;		// not used yet


// 1/4-20 screws, measure values
screw_dia = .25;
tap_drill = 13/64;
cbore_dia = .5;
cbore_depth = .25;

// hole spacings
die_screw_spacing = [A/2-.5, 1.25];
die_dowel_spacing = [A/2, 1.25];
punch_screw_spacing = [blank_length/2 - 1, blank_width/3];
//punch_dowel_spacing = ;

/********************/
/*** PART MODULES ***/
/********************/

// target specimen, nominal sizes
module specimen(l = blank_length, w = blank_width, t = specimen_thickness, A = A, R = R, offset = 0){
	difference(){
		cube([l, w, t], center = true);
		die(R = R, t = 2*t, offset = offset);
	}
}

// top tool, no offset
module die(A = A, R = R, t = plate_thickness, offset = 0, cbore = true){
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
			screw_array(x = dowel_spacing[0], y = dowel_spacing[1], threaded = false);
			//screw holes
			screw_array(x = screw_spacing[0], y = screw_spacing[1], threaded = false);
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
module punch(cbore = true){
	screw_spacing = punch_screw_spacing;
	//dowel_spacing = punch_dowel_spacing;
	difference(){
		// same shape as specimen with die clearance and plate thickness
		specimen(t = plate_thickness, offset = clearance);
		union(){
			// dowel holes
			dowel_hole();
			translate([ screw_spacing[0], 0, 0])	dowel_hole();
			translate([-screw_spacing[0], 0, 0])	dowel_hole();
			// screw holes (clearance)
			screw_array(x = screw_spacing[0], y = screw_spacing[1], z = 0, threaded = false);
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
		cube([l,w,t], center = true);
		union(){
			// center hole
			dowel_hole();
			// short edge locator
			translate([-(blank_length/2 + dowel_radius), 0, 0])	dowel_hole();
			// long edge locators
			translate([-(blank_length/2 - blank_width/2), blank_width/2 + dowel_radius, 0])	dowel_hole();
			translate([ (blank_length/2 - blank_width/2), blank_width/2 + dowel_radius, 0])	dowel_hole();
			
			// punch alignment holes (copied from punch module)
			translate([ punch_screw_spacing[0], 0, 0])	dowel_hole();
			translate([-punch_screw_spacing[0], 0, 0])	dowel_hole();
			// punch screw holes, threaded (copied+modified)
			screw_array(x = punch_screw_spacing[0], y = punch_screw_spacing[1], threaded = true);
			
			// die alignment holes
			screw_array(x = die_dowel_spacing[0], y = die_dowel_spacing[1], threaded = false);

		}	
	}
	if(show_dowels){
		// blank locators
		translate([-(blank_length/2 + dowel_radius), 0, 1.5])  dowel_pin(dowel_length = 3);
		translate([-(blank_length/2 - blank_width/2), blank_width/2 + dowel_radius, 1.5])	dowel_pin(dowel_length = 3);
		translate([ (blank_length/2 - blank_width/2), blank_width/2 + dowel_radius, 1.5])	dowel_pin(dowel_length = 3);
		// die guides
		screw_array(x = die_dowel_spacing[0], y = die_dowel_spacing[1], z = 1.5, threaded = false);
	}
}


/***********************/
/*** HELPER FEATURES ***/
/***********************/

module dowel_hole(depth = 2*plate_thickness){
	cylinder(h = depth, r = dowel_radius, center = true);
}

module screw_hole(depth = 2*plate_thickness, threaded = true){
	radius = threaded ? tap_drill/2 : screw_dia/2;
	cylinder(h = depth, r = radius, center = true);
}

module counterbore(){
	cylinder(h = cbore_depth + .1, r = cbore_dia/2);	// +.1 to prevent z-fighting on preview
}

module dowel_pin(dowel_length){
	cylinder(h = dowel_length, r = dowel_radius, center = true);
}

module screw_array(x,y,z=0,threaded){
	translate([ x, y, z]) screw_hole(threaded = threaded);
	translate([-x, y, z]) screw_hole(threaded = threaded);
	translate([ x,-y, z]) screw_hole(threaded = threaded);
	translate([-x,-y, z]) screw_hole(threaded = threaded);
}



/**********************/
/*** PART INSTANCES ***/
/**********************/

color("Aqua",1.0)			{translate([0,0, plate_thickness/2]) 	punch();}
#color("DarkSlateGray",1.0)	{translate([0,0,-plate_thickness/2]) 	base();}
color("Aquamarine",1.0)		{translate([0,0, plate_thickness/2]) 	die();}
//color("OrangeRed",1.0)		{translate([0,0,.6])					specimen();}