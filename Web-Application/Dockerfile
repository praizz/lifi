FROM node:21-alpine

# Set environment variables during build
ARG RDS_HOSTNAME
ARG RDS_USERNAME
ARG RDS_PASSWORD
ARG RDS_PORT

# Bake environment variables into the image, so it can be omitted in /k8s directory
ENV RDS_HOSTNAME=${RDS_HOSTNAME}
ENV RDS_USERNAME=${RDS_USERNAME}
ENV RDS_PASSWORD=${RDS_PASSWORD}
ENV RDS_PORT=${RDS_PORT}

EXPOSE 3001

WORKDIR /app

COPY package*.json ./

RUN npm install 

COPY . .

CMD ["npm", "start"]