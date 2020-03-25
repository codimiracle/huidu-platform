@echo off
cd ..\backend && mvn install -Dmaven.test.skip=true && cd ../ && copy "%cd%\backend\target\*.jar" "%cd%\manual\server.jar" && copy "%cd%\backend\src\main\resources\application-production.properties" "%cd%\manual\"
