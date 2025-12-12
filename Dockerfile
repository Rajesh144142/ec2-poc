FROM node:18-alpine

WORKDIR /app

# Install PM2 globally
RUN npm install -g pm2

COPY package*.json ./

RUN npm ci --only=production

COPY . .

# Copy PM2 ecosystem file
COPY ecosystem.config.js ./

EXPOSE 3000