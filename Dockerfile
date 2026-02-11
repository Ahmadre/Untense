# ── Stage 1: Build Flutter Web ────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:3.38.9 AS build

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release --base-href "/"

# ── Stage 2: Serve with nginx ────────────────────────────────────────
FROM nginx:alpine

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy built Flutter web app
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx config for SPA routing + caching
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
