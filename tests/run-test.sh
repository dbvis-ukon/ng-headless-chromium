#!/bin/sh
set -e

echo "start test"
node -v
cd /tmp/tests/angular-test
npm install
ng version
ng test --no-watch --no-progress
echo "test done"