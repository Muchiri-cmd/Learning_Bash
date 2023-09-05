#!/bin/bash

if [ "$1" = "hello" ]; then
    echo "hello yourself"
elif [ "$1" = "goodbye" ];then
    echo "nice to have met you"
    echo "I hope to see you again"
else
    echo "I didn't understand that"
fi