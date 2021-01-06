#!/bin/bash

echo "Hello there"

TEST_ARG=$1
if [[ $TEST_ARG == "Awesome" || $TEST_ARG == *"awesome"* ]]
then
  OTHER_VAR=awesome
else
  OTHER_VAR=unknown
fi

ls -lth

echo $OTHER_VAR

echo "Finished"