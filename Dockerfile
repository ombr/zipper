FROM node:alpine
MAINTAINER Luc Boissaye <luc@boissaye.fr>

COPY . /var/app
WORKDIR /var/app
RUN npm install

CMD npm run start
