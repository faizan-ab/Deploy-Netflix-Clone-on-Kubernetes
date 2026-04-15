FROM node:16.17.0-alpine as builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
RUN echo "VITE_APP_TMDB_V3_API_KEY=$TMDB_V3_API_KEY" > .env
RUN npm run build || true

FROM nginx:stable-alpine

WORKDIR /usr/share/nginx/html
RUN rm -rf ./*

COPY --from=builder /app/dist .

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
