FROM node:21 AS build

WORKDIR /app
RUN git clone https://github.com/SheepChef/Abracadabra_demo .
RUN npm ci 
RUN npx vite build --outDir ./dist

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 CMD wget -q -O - http://localhost:80/health || exit 1
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
