#!/usr/bin/sh

# Finds any test maps included in the dme.
find -name "*.dme" -exec awk '/maps\\test.*/ { print "Test map included in the DME!" ; exit 1 }' {} +
