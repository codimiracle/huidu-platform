#!/bin/bash
set -e

PWD="${pwd}"

cd ./frontend && exec npm start &
cd $PWD && cd ./backend && exec java -jar "./target/$HUIDU_BACKEND_PKG.jar"

