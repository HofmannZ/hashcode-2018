#!/bin/sh

echo Running 5 tests...

dart dart/src/main.dart --input inputs/a_example.in --output outputs/a_example.out &
dart dart/src/main_b.dart --input inputs/b_short_walk.in --output outputs/b_short_walk.out &
dart dart/src/main_c.dart --input inputs/c_going_green.in --output outputs/c_going_green.out &
dart dart/src/main_d.dart --input inputs/d_wide_selection.in --output outputs/d_wide_selection.out &
dart dart/src/main_e.dart --input inputs/e_precise_fit.in --output outputs/e_precise_fit.out &
dart dart/src/main_f.dart --input inputs/f_different_footprints.in --output outputs/f_different_footprints.out &

wait
echo All tests finished.
exit