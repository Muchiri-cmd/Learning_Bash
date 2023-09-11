#!/bin/bash

echo -n "Enter username for new user:"
read username

getent passwd $username > /dev/null

while [ $? -eq 0 ]
do
    echo "User $username already exists. Please try another username."
    read username
    getent passwd $username > /dev/null
done

echo -n "Enter group name for new user:"
read groupname

getent group $groupname > /dev/null

while [ $? -eq 0 ]
    do
        echo "Group $groupname already exists. Please try another group name."
        read groupname
        getent group $groupname > /dev/null
    done

groupadd $groupname
useradd -m -d /"$username" -G "$groupname" $username
passwd $username

mkdir /"$username"
chown "$username":"$groupname" /"$username"
chmod u+rwx,g+rwx,o-rwx,o+t /"$username"