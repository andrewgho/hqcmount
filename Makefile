# Makefile - create STL files from OpenSCAD source
# Andrew Ho (andrew@zeuscat.com)

ifeq ($(shell uname), Darwin)
  OPENSCAD = /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
else
  OPENSCAD = openscad
endif

TARGETS = hqcmount.stl

all: $(TARGETS)

hqcmount.stl: hqcmount.scad
	$(OPENSCAD) -o hqcmount.stl hqcmount.scad

clean:
	@rm -f $(TARGETS)
