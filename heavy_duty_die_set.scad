// parameters from datasheet (FL-0504)
A = 5;      // top square width
B = 4;      // space clear of pins
C = 5;      // hole to bottom edge
D = 4;      // between pins
E = 2.44;   // hole to slot
J = 1.38;   // bottom thickness
K = 1.25;   // top thickness
PL = 6;     // pin length
M = 8;      // overall width
N = 4;      // top edge to slot
PD = 1;     // pin diameter
R = 6.25;   // between slots
T = 6.75;   // overall height

gap = .19;

sq = T-2*gap;
pin_location = [D/2, T/2 - (N-E)];
top_radius = (N-E)-gap;


module heavy_set(){
    translate([0,0,6]) heavy_top();
    heavy_bottom();
    color("coral") translate([0,0,(PL-J)/2]) pins();
}

module pins(){
    array_two(2*pin_location[0], y = pin_location[1]) cylinder(h = PL, r = PD/2, center = true);
}

module heavy_top(){
    difference(){
        union(){       
            cube([D,sq,K], center = true); // long square
            translate([0, -(sq-C)/2, 0]) cube([A,C,K], center = true); // wide square
            array_two(2*pin_location[0], y = pin_location[1]) cylinder(h = K, r = top_radius, center = true);
        }
        // pin holes
        array_two(2*pin_location[0], y = pin_location[1])cylinder(h = 2*K, r = PD/2, center = true);
    }
}

module heavy_bottom(){
    difference(){
        union(){
            cube([A,sq,J], center = true);  // long sqaure
            cube([M, sq - (M-A),J], center = true); // wide
            // corner radii
            array_four(x_spacing = A, y_spacing = sq - (M-A)) cylinder(h = J, r = (M-A)/2, center = true);
        }
        union(){
            // pin holes
            array_two(2*pin_location[0], y = pin_location[1]) cylinder(h = 2*J, r = PD/2, center = true);
            // slot holes
            array_two(R, y = T/2-N) cylinder(h = 2*J, r = .78/2, center = true);
            // slots
            translate([ R/2+.5, T/2-N,0]) cube([1,.78,2*J], center = true);
            mirror([1,0,0]) translate([ R/2+.5, T/2-N,0]) cube([1,.78,2*J], center = true);
        }
    }
}