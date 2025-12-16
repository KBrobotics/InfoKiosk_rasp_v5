# =========================
# ETAP 1 — BUILD (Vite)
# =========================
FROM node:20-alpine AS build

# Katalog roboczy w kontenerze
WORKDIR /app

# Zmienna przekazywana z docker-compose.yml
ARG API_KEY

# Vite wymaga prefixu VITE_
ENV VITE_API_KEY=PoTJPuT1fKV-I7rvclv6HwlWFjnXZuhC5dK-q69du8TXoVOA9nLPw23yNTTyc3YunLWNYfY_11KP-zU4_DZ8JQ==

# Instalacja zależności
COPY package.json package-lock.json ./
RUN npm ci

# Kopiujemy CAŁY kod aplikacji
COPY . .

# Budujemy produkcyjne pliki statyczne
RUN npm run build


# =========================
# ETAP 2 — PRODUCTION (Nginx)
# =========================
FROM nginx:alpine

# Usuwamy domyślną konfigurację (opcjonalne, ale czyste)
RUN rm /etc/nginx/conf.d/default.conf

# Prosta konfiguracja Nginx pod SPA (React/Vue/Vite)
RUN printf "server {\n\
    listen 80;\n\
    server_name _;\n\
\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
\n\
    location / {\n\
        try_files \$uri \$uri/ /index.html;\n\
    }\n\
}\n" > /etc/nginx/conf.d/default.conf

# Kopiujemy wynik builda z poprzedniego etapu
COPY --from=build /app/dist /usr/share/nginx/html

# Port HTTP
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
