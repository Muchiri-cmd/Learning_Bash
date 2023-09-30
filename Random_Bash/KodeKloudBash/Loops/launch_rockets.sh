#!/bin/bash
  
for mission in $(cat /tmp/assets/mission-names.txt)
do
        bash /home/bob/create-and-launch-rocket $mission
done
