#!/bin/bash

# Check parameters
if [[ "$#" -ne 3 ]]; then
    echo "3 parameters required"
    exit 0
fi

# Translate lesson name into correct name for Workshopper projects
if [ $2 == "beep_boop" ]; then
    STR="BEEP BOOP"
elif [ $2 == "meet_pipe" ]; then
    STR="MEET PIPE"
elif [ $2 == "input_output" ]; then
    STR="INPUT OUTPUT"
elif [ $2 == "transform" ]; then
    STR="TRANSFORM"
elif [ $2 == "lines" ]; then
    STR="LINES"
elif [ $2 == "concat" ]; then
    STR="CONCAT"
elif [ $2 == "http_server" ]; then
    STR="HTTP SERVER"
elif [ $2 == "http_client" ]; then
    STR="HTTP CLIENT"
elif [ $2 == "websockets" ]; then
    STR="WEBSOCKETS"
elif [ $2 == "html_stream" ]; then
    STR="HTML STREAM"
elif [ $2 == "crypt" ]; then
    STR="CRYPT"
elif [ $2 == "secretz" ]; then
    STR="SECRETZ"

else
    echo UNKNOWN: Make sure you have your code file selected before running/verifying
    exit 0
fi
echo SELECTED FILE IS : $STR

#Select the workshopper lesson
stream-adventure select $STR > /dev/null

# Run or Verify?
if [ $1 == "run" ]; then
    stream-adventure run $3/$2.js
elif [ $1 == "verify" ]; then
    stream-adventure verify $3/$2.js
else 
    echo "BAD COMMAND"
fi

