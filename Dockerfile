# huidu platform
# version 1.0

FROM ubuntu:18.04

ENV VERSION huidu-platform-nightly-202003232200
ENV HUIDU_BACKEND_PKG huidu-web-backend-0.0.1-SNAPSHOT
ENV MYSQL_ROOT_PASSWORD 12345678

COPY . /app
WORKDIR /app

VOLUME ["/var/log", "/var/lib/mysql"]

# install system package
RUN apt update && apt-get install -y nodejs npm openjdk-8-jdk-headless maven mariadb-server \
\
# use china mirror for npm and maven
&& npm install -g cnpm --registry=https://registry.npm.taobao.org \
&& cp ./config/apt/sources.list /etc/apt/sources.list \
&& cp ./config/maven/settings.xml /etc/maven/settings.xml \
\
# install dependences packages
&& cd frontend && cnpm install && cd .. \
&& cd backend && rm -rf src/test && maven install && maven package && cd .. \
&& cp ./config/application-production.properties ./backend/ \
\
# setup env
&& echo "" > msi_ops.txt && echo "y" >> msi_ops.txt && echo "$MYSQL_ROOT_PASSWORD" >> msi_ops.txt && echo "$MYSQL_ROOT_PASSWORD" >> msi_ops.txt && echo "y" >>  msi_ops.txt && echo "y" >> msi_ops.txt && echo "y" >>  msi_ops.txt && echo "y" >> msi_ops.txt \
&& service mysql start && mysql_secure_installation < msi_ops.txt \
&& echo "CREATE database huidu_online_reading;" | mysql -u root -p"$MYSQL_ROOT_PASSWORD" && mysql -u root -p"$MYSQL_ROOT_PASSWORD" huidu_online_reading < ./config/huidu_online_reading.sql \
\
# generate version file
&& RUN echo -e "huidu plaform version \"$VERSION\"\nnodejs version \"`nodejs -v`\"\nnpm version \"`npm -v`\"" > ./backend/version && java -version 2>> ./backend/version

EXPOSE 3000 4000

CMD ["./entrypoint.sh"]
