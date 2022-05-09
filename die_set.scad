/**********************/
/*** RENDER SETTINGS***/
/**********************/
$fn = 100;					// # faces for curves
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
dowel_clearance = 0;


// 1/4-20 screws, measure values
screw_dia = .25;
tap_drill = 13/64;
cbore_dia = .5;
cbore_depth = .25;

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
module die(A = A, R = R, t = plate_thickness, offset = 0){
	radius = R + offset/2;
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
}

// bottom tool, .006" clearance on cutout section
module punch(cbore = true){
	difference(){
		// same shape as specimen with die clearance and plate thickness
		specimen(t = plate_thickness, offset = clearance);
		union(){
			// dowel holes
			dowel_hole();
			translate([  blank_length/2 - 1,  0, 0])	dowel_hole();
			translate([-(blank_length/2 - 1), 0, 0])	dowel_hole();
			// screw holes (clearance)
			translate([ (blank_length/2 - 1),  blank_width/3, 0])	screw_hole(threaded = false);
			translate([ (blank_length/2 - 1), -blank_width/3, 0])	screw_hole(threaded = false);
			translate([-(blank_length/2 - 1),  blank_width/3, 0])	screw_hole(threaded = false);
			translate([-(blank_length/2 - 1), -blank_width/3, 0])	screw_hole(threaded = false);
			// counterbores
			if(cbore){
				translate([ (blank_length/2 - 1),  blank_width/3, 0.1])	counterbore();
				translate([ (blank_length/2 - 1), -blank_width/3, 0.1])	counterbore();
				translate([-(blank_length/2 - 1),  blank_width/3, 0.1])	counterbore();
				translate([-(blank_length/2 - 1), -blank_width/3, 0.1])	counterbore();
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
			translate([ (blank_length/2 - 1), 0, 0])	dowel_hole();
			translate([-(blank_length/2 - 1), 0, 0])	dowel_hole();
			// punch screw holes, threaded (copied+modified)
			translate([ (blank_length/2 - 1),  blank_width/3, 0])	screw_hole();
			translate([ (blank_length/2 - 1), -blank_width/3, 0])	screw_hole();
			translate([-(blank_length/2 - 1),  blank_width/3, 0])	screw_hole();
			translate([-(blank_length/2 - 1), -blank_width/3, 0])	screw_hole();
		}	
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

module dowel_pin(){
	cylinder(h = depth, r = dowel_radius, center = true);
}

/**********************/
/*** PART INSTANCES ***/
/**********************/

color("Aqua",1.0)			{translate([0,0,plate_thickness/2]) 	punch();}
color("DarkSlateGray",1.0)	{translate([0,0,-plate_thickness/2]) 	base();}
color("Aquamarine",1.0)		{translate([0,0,1]) 					die();}
//color("OrangeRed",1.0)		{translate([0,0,.6])					specimen();}