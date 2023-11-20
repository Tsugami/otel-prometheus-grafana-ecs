FROM node:18-bullseye-slim

WORKDIR /app

COPY package*.json ./

ENV NODE_ENV=production
ENV PORT=3000

RUN --mount=type=cache,target=/app/.npm \
    npm set cache /app/.npm && \
    npm ci --omit=dev

USER node

COPY --chown=node:node ./src/ .

EXPOSE 3000

CMD ["node", "index.js"]