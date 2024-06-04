FROM node:8 AS base

# Set the working directory
WORKDIR /app

# Copy package.json, package-lock.json, bower.json, and Gruntfile.js
COPY .bowerrc ./
COPY package*.json ./
COPY bower.json ./
COPY Gruntfile.js ./

# Install dependencies
RUN npm install -g bower@1.3.2 grunt-cli@1.2.0 --force
RUN npm install grunt-contrib-copy@1.0.0 grunt@1.0.1 grunt-bower@0.21.2 grunt-bowercopy@1.2.4 --force
RUN bower install --allow-root

# Copy the rest of the application files
COPY . .

# Run Grunt tasks
RUN grunt --force

# Nginx stage
FROM nginx:stable-bookworm AS nginx

# Copy the application files from the base stage
COPY --from=base /app /usr/share/nginx/html

# Copy the Nginx configuration file
COPY default.conf /etc/nginx/conf.d/default.conf

# Remove the files in /docker-entrypoint.d
RUN rm -rf /docker-entrypoint.d

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
