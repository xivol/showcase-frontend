FROM node:22-alpine AS base
RUN npm install -g pnpm
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
COPY vendor ./vendor
RUN chown -R nextjs:nodejs /app
USER nextjs

# Install dependencies (including local file: vendor/*.tgz)
FROM base AS deps
RUN pnpm install --no-frozen-lockfile

# Copy the rest of the source and build
FROM deps AS build
COPY . .
RUN pnpm run build

# Production stage
FROM node:22-alpine
RUN npm install -g serve
WORKDIR /app
COPY --from=build /app/dist ./dist
EXPOSE 5173
CMD [ "serve", "-s", "dist", "-l", "5173" ]
