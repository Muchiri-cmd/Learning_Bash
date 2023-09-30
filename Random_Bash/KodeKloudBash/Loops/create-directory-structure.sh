#!/bin/bash
  
countries=("USA" "UK" "India")
dir="/home/bob/countries"

#create the directories and the capital.txts
for country in "${countries[@]}"; do
       mkdir -p "$dir/$country";
       touch "$dir/$country/capital.txt"

done
#add capital cities
echo "Washington, D.C" > "$dir/USA/capital.txt"
echo "London" > "$dir/UK/capital.txt"
echo "New Delhi" > "$dir/India/capital.txt"



#print sytsem uptime 
uptime