// parameters from datasheet (FL-0504)
A = 5;
B = 4;
C = 5;
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

module heavy_top(){
    difference(){

        union(){
            cube([A,T,K], center = true);
            translate([ D/2, T/2 - (N-E)]) cylinder(h = K, r = (N-E)-.19, center = true);
            translate([-D/2, T/2 - (N-E)]) cylinder(h = K, r = (N-E)-.19, center = true);
        }
        union(){
            translate([ D/2, T/2 - (N-E)]) cylinder(h = 2*K, r = PD/2, center = true);
            translate([-D/2, T/2 - (N-E)]) cylinder(h = 2*K, r = PD/2, center = true);
            translate([0,T/2-.19,0])    linear_extrude(height = 2*K, center = true) polygon([[1.5,.191],[-1.5,.191],[-1.31,0],[1.31,0]]);
            translate([-2.5,T/2-.19,0]) linear_extrude(height = 2*K, center = true) polygon([[0,0],[0,.191],[.19,.191]]);
        }

    }
}

heavy_top();

module heavy_bottom(){

}