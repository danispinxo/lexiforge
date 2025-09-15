FROM node:22-alpine

RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    xvfb \
    dbus \
    ttf-dejavu \
    ttf-droid \
    ttf-liberation \
    gcompat

ENV CYPRESS_CACHE_FOLDER=/app/.cache/Cypress
ENV CYPRESS_BROWSER=/usr/bin/chromium-browser
ENV DISPLAY=:99

WORKDIR /app

COPY package*.json ./
RUN npm install

RUN npx cypress install --force

COPY . .

EXPOSE 3001

CMD ["npm", "run", "dev"]