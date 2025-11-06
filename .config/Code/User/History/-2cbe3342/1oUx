# Stage 1: Build stage
FROM node:18-alpine AS builder

# Set working directory inside container
WORKDIR /app

# Copy dependency file first (better layer caching )
COPY package*.json ./

# Install only production dependencies 
RUN npm ci --only=production

# Copy the rest of the application code
COPY . .

# Stage 2: Runtime stage (Hardened Image)
FROM node:18-alpine

# Remove default package manager cache and unused files
RUN rm -rf /var/cache/apk/* /tmp/*

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -s appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy built files from builder stage
COPY --from=builder /app /app

# Drop root privilages
USER appuser

# Expose the app port
EXPOSE 3000

# Run the application
CMD ["node", "index.js"]