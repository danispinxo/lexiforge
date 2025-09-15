FROM cypress/browsers:node-22.19.0-chrome-140.0.7339.127-1-ff-142.0.1-edge-140.0.3485.54-1

ENV CYPRESS_CACHE_FOLDER=/app/.cache/Cypress
ENV DISPLAY=:99
ENV ELECTRON_DISABLE_SANDBOX=1
ENV ELECTRON_NO_SANDBOX=1

WORKDIR /app

COPY package*.json ./
RUN npm install

RUN npx cypress install

COPY . .

EXPOSE 3001

CMD ["npm", "run", "dev"]