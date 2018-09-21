#!/bin/sh

echo "start test"
node -v
cd ./angular-test && npm install && ng test --no-watch --no-progress
echo "test done"