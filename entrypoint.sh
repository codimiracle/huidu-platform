#!/bin/bash
set -e

WORKDIR=`pwd`

service mysql start

cd ./frontend && exec npm start &
cd $WORKDIR && cd ./backend && exec java -jar "./target/$HUIDU_BACKEND_PKG.jar"

