FROM node:24.0.2-alpine

WORKDIR /app
COPY . .

RUN npm install --production

EXPOSE 3001

CMD ["npm", "start"]
