# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Enable corepack for yarn
RUN npm install -g corepack && corepack enable

# Copy dependency files first (cached layer)
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/

# Install dependencies (cached unless lockfile changes)
RUN yarn install --immutable

# Copy source files
COPY . .

# Build the application
RUN yarn build

# Production stage
FROM nginx:alpine

# Copy built files from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
