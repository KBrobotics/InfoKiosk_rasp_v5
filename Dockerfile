# =========================
# ETAP 1 — BUILD (Vite)
# =========================
FROM node:20-alpine AS build
WORKDIR /app

# Narzędzia do budowania zależności natywnych (częsty brak na alpine)
RUN apk add --no-cache python3 make g++ libc6-compat

ARG API_KEY
ENV VITE_API_KEY=PoTJPuT1fKV-I7rvclv6HwlWFjnXZuhC5dK-q69du8TXoVOA9nLPw23yNTTyc3YunLWNYfY_11KP-zU4_DZ8JQ==

# Kopiujemy manifesty i ewentualne locki
COPY package.json ./
COPY package-lock.json* ./
COPY npm-shrinkwrap.json* ./

# Instalacja:
# 1) jeśli jest lock → spróbuj npm ci
# 2) jeśli npm ci padnie (niespójny lock) → npm install
# 3) jeśli nie ma lock → npm install
RUN if [ -f package-lock.json ] || [ -f npm-shrinkwrap.json ]; then \
      npm ci --no-audit --no-fund || npm install --no-audit --no-fund; \
    else \
      npm install --no-audit --no-fund; \
    fi

# Kod aplikacji
COPY . .

# Build produkcyjny
RUN npm run build


# =========================
# ETAP 2 — PRODUCTION (Nginx)
# =========================
FROM nginx:alpine

# Konfiguracja pod SPA (odświeżanie tras bez 404)
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
