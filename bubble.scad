bl_length = 29.0 + 0.1;
bl_height = 9.9 + 0.1;
bl_thickness = 1.5;

module bubble_level() {
  length = bl_length;
  height = bl_height;
  thickess = bl_thickness;

  dimple_diameter = 7.4 - 0.1;
  dimple_depth = 0.4;

  outer_length = length + (2 * thickness);
  outer_height = height + (2 * thickness);

  e = 0.1;
  e2 = e * 2;

  module level() {
    difference() {
      cube([length, height, height]);
      translate([0, height / 2, height / 2])
        resize(newsize=[dimple_depth * 2, dimple_diameter, dimple_diameter]) sphere(r = 1);
      translate([length, height / 2, height / 2])
        resize(newsize=[dimple_depth * 2, dimple_diameter, dimple_diameter]) sphere(r = 1);
    }
  }

  module base() {
    difference() {
      cube([outer_length, outer_height, thickness * 2]);
      translate([thickness, thickness, thickness])
        cube([length, height, thickness + e]);
    }
  }

  module sidewall() {
    translate([0, 0, thickness]) {
      cube([thickness, outer_height, (height / 2) - thickness]);
      difference() {
        translate([0, outer_height / 2, (height / 2) - thickness])
          rotate(90, [0, 1, 0])
          cylinder(d = outer_height, h = thickness);
        translate([-e, -e, -(thickness + thickness + e)])
          cube([thickness + e2, outer_height + e2, outer_height / 2]);
      }
      translate([thickness, outer_height / 2, height / 2])
        resize(newsize=[dimple_depth * 2, dimple_diameter, dimple_diameter]) sphere(r = 1);
    }
  }

  base();
  sidewall();
  translate([outer_length, 0, 0]) mirror([1, 0, 0]) sidewall();
}
