FROM node:22-alpine AS base
RUN npm install -g pnpm
WORKDIR /app

# Copy only what's needed for installing dependencies
COPY package.json pnpm-lock.yaml ./
COPY vendor ./vendor

# Install dependencies (still blocked for security)
RUN pnpm install --frozen-lockfile --config.ignore-scripts=false

# ✅ Approve all pending builds non-interactively
RUN pnpm approve-builds --all

# Copy the rest of the source and build
COPY . .
RUN pnpm run build

# Production stage
FROM node:22-alpine
RUN npm install -g serve
WORKDIR /app
COPY --from=base /app/dist ./dist
EXPOSE 5173
CMD [ "serve", "-s", "dist", "-l", "5173" ]
