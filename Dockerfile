# Use an official Node.js runtime
FROM node:22-alpine

# Set application working directory
WORKDIR /app

# Install curl for downloading the RDS CA bundle
RUN apk add --no-cache curl

# Copy dependency files first
COPY package*.json ./

# Install production dependencies
RUN npm ci --omit=dev

# Download AWS RDS CA certificate bundle
RUN curl --fail --silent --show-error --location \
    https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
    --output /app/global-bundle.pem

# Copy application source
COPY . .

# Create a non-root application user
USER node

# Application port
EXPOSE 3000

# Start application
CMD ["npm", "start"]
