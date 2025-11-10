FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

ARG VITE_API_BASE_URL=http://localhost:8089/api
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}

RUN npm run build

FROM nginx:1.27-alpine

RUN apk add --no-cache gettext && \
    mkdir -p /etc/nginx/templates

COPY docker/default.conf.template /etc/nginx/templates/default.conf.template
COPY docker/runtime-config.template.js /etc/nginx/templates/runtime-config.template.js
COPY docker/entrypoint.sh /entrypoint.sh
COPY --from=builder /app/dist /usr/share/nginx/html

RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
