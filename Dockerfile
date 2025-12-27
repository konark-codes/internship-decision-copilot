# ---------- STEP 1: Build the React app ----------
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first (for faster rebuilds)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy rest of the project
COPY . .

# Accept build-time argument
ARG GEMINI_API_KEY

# Create .env.local before building
RUN echo "VITE_GEMINI_API_KEY=${GEMINI_API_KEY}" > .env.local

# Build the Vite app
RUN npm run build


# ---------- STEP 2: Serve with Nginx ----------
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build output to nginx folder
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose Cloud Run port
EXPOSE 8080

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
