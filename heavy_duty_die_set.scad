// parameters from datasheet (FL-0504)
A = 5;      // top square width
B = 4;      // space clear of pins
C = 5;      // 
D = 4;
E = 2.44;
J = 1.38;
K = 1.25;
PL = 6;
M = 8;
N = 4;
PD = 1;
R = 6.25;
T = 6.75;
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
    translate([ pin_location[0], pin_location[1], 0]) cylinder(h = PL, r = PD/2, center = true);
    translate([-pin_location[0], pin_location[1], 0]) cylinder(h = PL, r = PD/2, center = true);
}

module heavy_top(){
    difference(){
        union(){       
            cube([D,sq,K], center = true);
            translate([0, -(sq-C)/2, 0]) cube([A,C,K], center = true);
            translate([ pin_location[0], pin_location[1], 0])  cylinder(h = K, r = top_radius, center = true);
            translate([-pin_location[0], pin_location[1], 0])  cylinder(h = K, r = top_radius, center = true);
            //translate([0,T/2-.19,0])    linear_extrude(height = 2*K, center = true) polygon([[1.5,gap+.001],[-1.5,gap+.001],[-1.31,0],[1.31,0]]);
            //translate([-2.5,T/2-.27,0]) linear_extrude(height = 2*K, center = true) polygon([[0,0],[0,1],[1,1]]);
        }
        union(){
            translate([ pin_location[0], pin_location[1], 0]) cylinder(h = 2*K, r = PD/2, center = true); 
            translate([-pin_location[0], pin_location[1], 0]) cylinder(h = 2*K, r = PD/2, center = true);
        }

    }
}

module heavy_bottom(){
    difference(){
        union(){
            cube([A,sq,J], center = true);
            cube([M, sq - (M-A),J], center = true);
            translate([ A/2, (sq - (M-A))/2, 0]) cylinder(h = J, r = (M-A)/2, center = true);
            translate([-A/2, (sq - (M-A))/2, 0]) cylinder(h = J, r = (M-A)/2, center = true);
            translate([ A/2,-(sq - (M-A))/2, 0]) cylinder(h = J, r = (M-A)/2, center = true);
            translate([-A/2,-(sq - (M-A))/2, 0]) cylinder(h = J, r = (M-A)/2, center = true);
        }
        union(){
            translate([ pin_location[0], pin_location[1], 0]) cylinder(h = 2*J, r = PD/2, center = true); 
            translate([-pin_location[0], pin_location[1], 0]) cylinder(h = 2*J, r = PD/2, center = true);
            translate([ R/2, T/2-N,0]) cylinder(h = 2*J, r = .78/2, center = true);
            translate([-R/2, T/2-N,0]) cylinder(h = 2*J, r = .78/2, center = true);

            translate([ R/2+.5, T/2-N,0]) cube([1,.78,2*J], center = true);
            mirror([1,0,0]) translate([ R/2+.5, T/2-N,0]) cube([1,.78,2*J], center = true);
        }
    }
}