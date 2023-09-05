#!/bin/bash

if grep -q root /etc/passwd; then
    echo root is in password file

else
    echo root is missing from password file

fi