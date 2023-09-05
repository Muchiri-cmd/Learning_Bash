#!/bin/bash

ls
for num in `seq 1 12`; do
	touch test$num
done
ls 
