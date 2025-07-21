#BUILD
FROM node:20-slim AS builder

WORKDIR /app

RUN npm install -g pnpm

COPY ../nocodb /app
COPY ./docker/start.sh /app/start.sh

RUN pnpm install
RUN pnpm run bootstrap
RUN chmod +x /app/start.sh

#image finale allégée, prête à exécuter l’app
FROM node:20-slim
WORKDIR /app
RUN npm install -g pnpm
COPY --from=builder /app /app
EXPOSE 8080
CMD ["./start.sh"]
