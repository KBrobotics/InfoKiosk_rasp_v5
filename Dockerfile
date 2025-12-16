# =========================
# ETAP 1 — BUILD (Vite)
# =========================
FROM node:20-alpine AS build
WORKDIR /app

# build-arg z docker-compose
ARG API_KEY
ENV VITE_API_KEY=$API_KEY

# Kopiujemy package.json (+ ewentualne locki jeśli istnieją)
COPY package.json ./
COPY package-lock.json* ./
COPY npm-shrinkwrap.json* ./

# Instalujemy zależności:
# - jeśli jest lock -> npm ci
# - jeśli nie ma -> npm install
RUN if [ -f package-lock.json ] || [ -f npm-shrinkwrap.json ]; then \
      npm ci; \
    else \
      npm install; \
    fi

# Reszta kodu
COPY . .

# Build produkcyjny
RUN npm run build


# =========================
# ETAP 2 — PRODUCTION (Nginx)
# =========================
FROM nginx:alpine

# Konfiguracja pod SPA (żeby odświeżanie tras nie dawało 404)
RUN rm -f /etc/nginx/conf.d/default.conf && \
    printf "server {\n\
  listen 80;\n\
  server_name _;\n\
  root /usr/share/nginx/html;\n\
  index index.html;\n\
  location / {\n\
    try_files \$uri \$uri/ /index.html;\n\
  }\n\
}\n" > /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
