include <modules.scad>

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



module exploded_view(){
	color("Aqua",1.0)			{translate([0,0, plate_thickness/2+2.5]) 	punch();}
								translate([0,0, plate_thickness/2+1.5]) 	punch(cbore = false);
	color("DarkSlateGray",1.0)	{translate([0,0,-plate_thickness/2]) 		base();}
	color("Aquamarine",1.0)		{translate([0,0, plate_thickness/2+4]) 		die();}
								translate([0,0, plate_thickness/2+5]) 		die(cbore = false);
}
module assembly(){
	color("Aqua",1.0)			{translate([0,0, 3*plate_thickness/2]) 	punch();} 	
								translate([0,0, plate_thickness/2]) 	punch(cbore = false);
	color("DarkSlateGray",1.0)	{translate([0,0,-plate_thickness/2]) 	base();}
	color("Aquamarine",1.0)		{translate([0,0, plate_thickness/2+1]) 	die();}
								translate([0,0, plate_thickness/2+1.5]) die(cbore = false);

}

/**********************/
/*** PART INSTANCES ***/
/**********************/

assembly();
//exploded_view();
//color("OrangeRed",1.0)		{translate([0,0,.6])					specimen();}