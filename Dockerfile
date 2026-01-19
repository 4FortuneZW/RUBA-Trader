FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY src ./src
COPY scripts ./scripts

# Create logs directory
RUN mkdir -p logs

# Expose port (if needed for health checks)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "console.log('Health check OK')" || exit 1

# Start the bot
CMD ["node", "src/bot/index.js"]
