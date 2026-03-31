# Use an official Node.js runtime as the base image
# node:18-slim is a lightweight version of Node.js 18
FROM node:18-slim

# 1. Install system dependencies for 'canvas' and binary builds
# These are required by the 'canvas' and '@tensorflow/tfjs-node' packages on Linux
RUN apt-get update && apt-get install -y \
    build-essential \
    libcairo2-dev \
    libjpeg-dev \
    libpango1.0-dev \
    libgif-dev \
    librsvg2-dev \
    libpixman-1-dev \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libgdk-pixbuf2.0-0 \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# 2. Set the working directory in the container
WORKDIR /app

# 3. Copy package.json and package-lock.json first
# This improves build performance by caching the 'npm install' layer
COPY package*.json ./

# 4. Install production dependencies
# This will compile 'canvas' using the system libraries installed in Step 1
RUN npm install --production

# 5. Copy the rest of the application code
# This includes server.js, routes, controllers, and models
COPY . .

# 6. Expose the port your server runs on (usually 5000)
# We use the PORT environment variable if available, but default to 5000
ENV PORT=5000
EXPOSE ${PORT}

# 7. Command to run the application
# Using 'node server.js' directly instead of 'npm start' for better signal handling
CMD ["node", "server.js"]
