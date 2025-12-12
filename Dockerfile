FROM node:18-alpine

WORKDIR /app

# Install PM2 globally
RUN npm install -g pm2

COPY package*.json ./

RUN npm ci --only=production

COPY . .

# Create logs directory for PM2 (before switching to node user)
RUN mkdir -p logs && chown -R node:node /app/logs

EXPOSE 3000

USER node

CMD ["pm2-runtime", "start", "ecosystem.config.js"]