// hqcmount.scad - two piece mount to mate Pi Zero with HQ Camera
// Andrew Ho (andrew@zeuscat.com)

pi_length = 65;
pi_width = 30;
cam_length = 38;
cam_width = 38;
thickness = 3;

include <bubble.scad>

e = 0.1;
e2 = e * 2;
$fn = 120;

module rounded_flat_corners(length, width, height, radius) {
  module corner() {
    cylinder(r = radius, h = height);
  }
  union() {
    translate([radius, radius]) corner();
    translate([radius, width - radius]) corner();
    translate([length - radius, width - radius]) corner();
    translate([length - radius, radius]) corner();
  }
}

module rounded_flat_cube(length, width, height, radius) {
  hull() rounded_flat_corners(length, width, height, radius);
}

// https://www.raspberrypi.org/documentation/hardware/raspberrypi/mechanical/rpi_MECH_Zero_1p3.pdf
module pi_plate() {
  length = pi_length;
  width = pi_width;
  height = thickness;
  corner_radius = 3;
  hole_offset = 3.5;
  hole_diameter = 2.5;
  post_width = 1.5;
  post_height = 1.5;  // 1mm for bottom, 5mm for top

  module four_corners() {
    module y_corners() {
      children();
      translate([0, width, height]) rotate(180, v = [1, 0, 0]) children();
    }
    y_corners() children();
    translate([length, 0, height]) rotate(180, v = [0, 1, 0]) y_corners() children();
  }

  module backplate() {
    module corner() {
      translate([corner_radius, corner_radius, 0]) cylinder(r = corner_radius, h = height);
      translate([hole_offset, hole_offset, 0]) cylinder(r = hole_offset, h = height);
    }
    module hole() {
      translate([0, 0, -e]) cylinder(d = hole_diameter, h = height + e2);
    }

    module x_cutout() {
      translate([0, 0, -e]) {
        hull() {
          x = 16.52;
          y = -16;
          translate([x, y, 0]) cylinder(r = 20, h = height + e2);
          translate([length - x, y, 0]) cylinder(r = 20, h = height + e2);
        }
      }
    }

    module y_cutout() {
      module half_cutout() {
        translate([0, 0, -e]) {
          x = -16;
          y = 16.52;
          difference() {
            translate([x, y, 0]) cylinder(r = 20, h = height + e2);
            // TODO: fix little side divot (or don't)
            translate([-e, width / 2 + e, -e]) cube([20, (width / 2), height + (2 * e2)]);
          }
        }
      }
      half_cutout();
      translate([0, width, height]) rotate(180, v = [1, 0, 0]) half_cutout();
    }

    difference() {
      union() {
        //translate([0, 0, -2]) cube([length, width, e]);  // Pi Zero overall size check

        // Basic backplate shape that overall mirrors Pi Zero size
        four_corners() corner();
        difference() {
          // Rectangle that doesn't quite go to the edges of the corners
          indent = 0.8;
          translate([indent, indent, 0])
            cube([length - (indent * 2), width - (indent * 2), height]);
          // Cutouts for each corner, since the corners are rounded
          translate([0, 0, -e]) {
            cube([hole_offset, hole_offset, height + e2]);
            translate([length - hole_offset, 0, 0])
              cube([hole_offset, hole_offset, height + e2]);
            translate([length - hole_offset, width - hole_offset, 0])
              cube([hole_offset, hole_offset, height + e2]);
            translate([0, width - hole_offset, 0])
              cube([hole_offset, hole_offset, height + e2]);
          }
        }
      }

      // Cutouts along sides
      x_cutout();
      translate([0, width, height]) rotate(180, v = [1, 0, 0]) x_cutout();
      y_cutout();
      translate([length, 0, height]) rotate(180, v = [0, 1, 0]) y_cutout();

      // Cutouts for holes
      translate([hole_offset, hole_offset, 0]) hole();
      translate([length - hole_offset, hole_offset, 0]) hole();
      translate([length - hole_offset, width - hole_offset, 0]) hole();
      translate([hole_offset, width - hole_offset, 0]) hole();
    }
  }

  module post() {
    difference() {
      cylinder(d = hole_diameter + (post_width * 2), h = post_height);
      translate([0, 0, -e]) cylinder(d = hole_diameter, h = post_height + e2);
    }
  }

  union() {
    backplate();
    translate([hole_offset, hole_offset, height]) post();
    translate([length - hole_offset, hole_offset, height]) post();
    translate([length - hole_offset, width - hole_offset, height]) post();
    translate([hole_offset, width - hole_offset, height]) post();
  }
}

// https://static.raspberrypi.org/files/product-mechanical-drawings/20200428_HQ_Camera_Technical_drawing.pdf
module cam_plate() {
  length = cam_length;
  width = cam_width;
  height = thickness;
  corner_radius = 2;  // guessed
  hole_offset = 4;
  hole_diameter = 2.5;
  post_width = 1.5;
  post_height = 4;

  module backplate() {
    module hole() {
      translate([0, 0, -e]) cylinder(d = hole_diameter, h = height + e2);
    }
    difference() {
      rounded_flat_cube(length, width, height, corner_radius);
      translate([hole_offset, hole_offset, 0]) hole();
      translate([length - hole_offset, hole_offset, 0]) hole();
      translate([length - hole_offset, width - hole_offset, 0]) hole();
      translate([hole_offset, width - hole_offset, 0]) hole();
    }
  }

  module post() {
    difference() {
      cylinder(d = hole_diameter + (post_width * 2), h = post_height);
      translate([0, 0, -e]) cylinder(d = hole_diameter, h = post_height + e2);
    }
  }

  union() {
    backplate();
    translate([hole_offset, hole_offset, height]) post();
    translate([length - hole_offset, hole_offset, height]) post();
    translate([length - hole_offset, width - hole_offset, height]) post();
    translate([hole_offset, width - hole_offset, height]) post();
  }
}

// The plate that mounts to the Pi Zero
difference() {
  pi_plate();
  translate([0, 0, thickness * (3/2)]) mirror([0, 0, 1])
    translate([(pi_length - cam_length) / 2, (pi_width - cam_width) / 2, 0]) cam_plate();
}

// The plate that mounts to the camera
translate([(pi_length - cam_length) / 2, pi_width, 0]) {
  difference() {
    cam_plate();
    translate([0, 0, thickness * (3/2)]) mirror([0, 0, 1])
      translate([-(pi_length - cam_length) / 2, -(pi_width - cam_width) / 2, 0]) pi_plate();
  }
  translate([(cam_length - (bl_length + (2 * bl_thickness))) / 4, cam_width, 0])
    mirror([0, 0, 1])
    rotate(-90, [1, 0, 0])
    bubble_level();
}
