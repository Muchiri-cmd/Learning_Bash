#!/bin/bash                                                                     

echo "Enter group name:"                                                        
read groupname                                                                  
                                                              
if grep -q "$groupname" /etc/group ;then                                        
        echo "Error.Please try another group name."                             
else                                                                            
        sudo groupadd $groupname                                                
fi      

echo "Enter username:"                                                          
read username     
                                                                                
if grep -q $username /etc/passwd ;then                                          
        echo "Error.Try another username."                                      
else                                                                            
        sudo useradd -m -d /"$username" -G "$groupname" $username               
        sudo passwd $username                                                   
        sudo chown "$username":"$groupname" /"$username"                        
        sudo chmod u+rwx,g+rwx,o-rwx,o+t /"$username"                           
fi                                                                              
~                                                                               
~                                                                               
~                                                                               
~          