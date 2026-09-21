FROM node:24-slim

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# vite.config.ts hard-codes nitro's `preset: "vercel"` (needed for the Vercel
# deploy target). That preset writes its build output to `.vercel/output`,
# not `.output/server/index.mjs`, so a container that runs `npm run build`
# as-is has nothing to start. Overriding with NITRO_PRESET wins over the
# config value and forces the standard Node server output Docker needs.
ENV NITRO_PRESET=node-server

RUN npm run build

EXPOSE 3000

ENV PORT=3000
ENV HOST=0.0.0.0

# Build artifacts (.output) are produced above and already live in this
# image layer — no multi-stage copy needed, just don't discard this stage.
CMD ["node", ".output/server/index.mjs"]
