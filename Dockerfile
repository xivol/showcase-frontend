FROM node:22-alpine AS base
RUN npm install -g pnpm
WORKDIR /app

# Copy only what's needed for installing dependencies
COPY package.json pnpm-lock.yaml* ./
# Copy the vendor directory (contains local .tgz files)
COPY vendor ./vendor

# Install dependencies (including local file: vendor/*.tgz)
FROM base AS deps
ENV PNPM_IGNORE_SCRIPTS=false
RUN pnpm install --no-frozen-lockfile   # or just pnpm install

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
