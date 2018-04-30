#!/bin/sh

echo Running 5 tests...

lib ../tests/1.in ../tests/1.out &
lib ../tests/2.in ../tests/2.out &
lib ../tests/3.in ../tests/3.out &
lib ../tests/4.in ../tests/4.out &
lib ../tests/5.in ../tests/5.out &

wait
echo All tests finished.