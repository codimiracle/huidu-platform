# huidu platform
# version 1.0

FROM mysql:5.7.29

ENV VERSION huidu-platform-0.7.2
ENV HUIDU_BACKEND_PKG huidu-web-backend-0.7.2-SNAPSHOT

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
&& npm install -g cnpm --registry=https://registry.npm.taobao.org
# install dependences packages
RUN cp ./config/host-config.ts ./frontend/configs/ \
&& cd frontend && cnpm install && npm run build && cd .. 
RUN cd backend && mvn install -Dmaven.test.skip=true && cd .. 
# backend application config
RUN cp ./config/application.properties ./backend/
# setup env
RUN  echo "default-character-set=utf8mb4" >> /etc/mysql/conf.d/mysql.cnf && echo "character-set-server=utf8mb4" >> /etc/mysql/mysql.conf.d/mysqld.cnf \
&& service mysql start \
&& echo "CREATE database huidu_online_reading;" | mysql -u root && mysql -u root huidu_online_reading < ./config/huidu_online_reading.sql
# generate version file
RUN echo -e "huidu plaform version \"$VERSION\"\nnodejs version \"`nodejs -v`\"\nnpm version \"`npm -v`\"" > ./backend/version && java -version 2>> ./backend/version

EXPOSE 3000 4000

CMD ["./entrypoint.sh"]
