# --- Stage 1: Build the React Application ---
# Use Node v20 on Alpine Linux (a lightweight version of Linux)
FROM node:20-alpine as build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (caches dependencies)
COPY package*.json ./

# Install the project dependencies
RUN npm ci

# Copy all your source code into the container
COPY . .

# 1. Receive the API Key from Google Cloud Build
ARG GEMINI_API_KEY

# 2. Write the key into a .env.local file so Vite can use it
# We add 'VITE_' because Vite only reads variables starting with VITE_
RUN echo "VITE_GEMINI_API_KEY=$GEMINI_API_KEY" > .env.local

# Build the React app (this creates the 'dist' folder)
RUN npm run build

# --- Stage 2: Serve the App using Nginx ---
# Switch to Nginx (a very fast web server)
FROM nginx:alpine

# Copy the built files from Stage 1 into the Nginx folder
COPY --from=build /app/dist /usr/share/nginx/html

# Copy our custom nginx.conf file into the Nginx configuration folder
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Tell Google Cloud we are listening on port 8080
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
