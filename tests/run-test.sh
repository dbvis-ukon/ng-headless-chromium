#!/bin/sh

echo "start test"
node -v
cd ./angular-test && ng test --no-watch --no-progress
echo "test done"