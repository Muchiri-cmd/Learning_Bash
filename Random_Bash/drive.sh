#!/bin/bash

echo "Please enter your age"
read age
if test $age -lt 16; then
	echo "You are not old enough to drive"
else
	echo "You can drive"
fi
