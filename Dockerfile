# huidu platform
# version 1.0

FROM mysql:5.7.17

ENV VERSION huidu-platform-nightly-202003232200
ENV HUIDU_BACKEND_PKG huidu-web-backend-0.0.1-SNAPSHOT

COPY . /app
WORKDIR /app

VOLUME ["/var/log", "/var/lib/mysql"]

# use china mirror for apt
RUN cp ./config/apt/sources.list /etc/apt/sources.list \
\
# requirements
# fix openjdk issue
&& mkdir -p /usr/share/man/man1 \
&& apt update && apt-get install -y curl \
&& curl -sL https://deb.nodesource.com/setup_10.x | bash -  \
\
# install system package
&& apt-get install -y nodejs maven \
\
# use china mirror for npm maven
&& cp ./config/maven/settings.xml /etc/maven/settings.xml \
&& npm install -g cnpm --registry=https://registry.npm.taobao.org \
\
# install dependences packages
&& cd frontend && cnpm install && cnpm run build && cd .. \
&& cd backend && rm -rf src/test && mvn install && mvn package && cd .. \
# frontend application config
&& cp ./config/host-config.ts ./frontend/configs/ \
# backend application config
&& cp ./config/application.properties ./backend/ \
\
# setup env
&&  echo "default-character-set=utf8mb4" >> /etc/conf.d/mysql.cnf >> && echo "character-set-server=utf8mb4" >> /etc/mysql.conf.d/mysqld.cnf \
&& service mysql start \
&& echo "CREATE database huidu_online_reading;" | mysql -u root && mysql -u root huidu_online_reading < ./config/huidu_online_reading.sql \
\
# generate version file
&& RUN echo -e "huidu plaform version \"$VERSION\"\nnodejs version \"`nodejs -v`\"\nnpm version \"`npm -v`\"" > ./backend/version && java -version 2>> ./backend/version

EXPOSE 3000 4000

CMD ["./entrypoint.sh"]
