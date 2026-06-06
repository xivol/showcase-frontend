FROM node:22-alpine AS base
RUN npm install -g pnpm
WORKDIR /app

# Create a non‑root user (node user already exists in node:alpine)
USER node

COPY package.json pnpm-lock.yaml* ./
COPY vendor ./vendor

FROM base AS deps
# Now running as node, not root – scripts are allowed
RUN pnpm install --no-frozen-lockfile

FROM deps AS build
COPY --chown=node:node . .
RUN pnpm run build

FROM node:22-alpine
RUN npm install -g serve
WORKDIR /app
COPY --from=build --chown=node:node /app/dist ./dist
USER node
EXPOSE 5173
CMD [ "serve", "-s", "dist", "-l", "5173" ]
