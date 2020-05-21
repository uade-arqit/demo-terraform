FROM node:8.16.0-alpine

ADD package.json .

RUN npm install

ADD server ./server

ADD common ./common

EXPOSE 3000

CMD node ./server/server.js

