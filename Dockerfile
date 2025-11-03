FROM node:18-alpine

WORKDIR /app

# Copy package files from the node app directory
COPY node-express-server-rest-api/package*.json ./
RUN npm install

# Copy the rest of the application
COPY node-express-server-rest-api/ ./

EXPOSE 3000
CMD ["npm", "start"]
