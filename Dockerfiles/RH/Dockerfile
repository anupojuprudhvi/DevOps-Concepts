###STAGE 1: Build ###
FROM node:14.17.3 as build 
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY package.json /usr/src/app
RUN npm install --force
COPY . /usr/src/app
RUN npm run build --prod

### STAGE 2: Run ###
FROM nginx:1.17.1-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /usr/src/app/dist/patientconsentportal /usr/share/nginx/html/pcc
