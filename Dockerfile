
# --- Steg 1: Bygg-miljö ---
FROM node:20-alpine AS builder

WORKDIR /app

# Installera pnpm globalt
RUN npm install -g pnpm

# Kopiera package.json och pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

# Installera produktionsberoenden
RUN pnpm install --prod

# Kopiera resten av koden
COPY . .

# Bygg Next.js-appen med build-argument
ARG NEXT_PUBLIC_SUPABASE_URL
ARG NEXT_PUBLIC_SUPABASE_ANON_KEY
ENV NEXT_PUBLIC_SUPABASE_URL=${NEXT_PUBLIC_SUPABASE_URL}
ENV NEXT_PUBLIC_SUPABASE_ANON_KEY=${NEXT_PUBLIC_SUPABASE_ANON_KEY}
RUN pnpm build

# --- Steg 2: Produktions-miljö ---
FROM node:20-alpine AS runner

WORKDIR /app

# Kopiera byggda filer och nödvändiga paket från "builder"
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

EXPOSE 3000

# Starta appen med pnpm
CMD ["pnpm", "start"]

