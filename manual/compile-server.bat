@echo off
cd ../backend && mvn install && mvn package -Dmaven.test.skip=true
copy target/huidu-web-backend-0.5.1-SNAPSHOT.jar ../manual/
copy src\main\resources\application-production.properties ../manual/
