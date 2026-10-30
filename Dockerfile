FROM public.ecr.aws/amazonlinux/amazonlinux:2027.0.20261026.1 AS build
WORKDIR /usr/src/app

# hadolint ignore=DL3041
RUN dnf upgrade -y; \
    curl -fsSL https://rpm.nodesource.com/setup_24.x | bash -; \
    dnf install nodejs -y; \
    dnf clean all

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM public.ecr.aws/amazonlinux/amazonlinux:2027.0.20261026.1
EXPOSE 8080
WORKDIR /usr/src/app

ENV NODE_ENV=production \
    PORT=8080 \
    HOSTNAME=0.0.0.0

# hadolint ignore=DL3041
RUN dnf upgrade -y; \
    curl -fsSL https://rpm.nodesource.com/setup_24.x | bash -; \
    dnf install nodejs -y; \
    dnf clean all; \
    rm -rf /usr/lib/node_modules/npm /usr/bin/npm /usr/bin/npx

COPY --from=build /usr/src/app/.next/standalone ./
COPY --from=build /usr/src/app/.next/static ./.next/static
COPY --from=build /usr/src/app/public ./public

CMD ["node", "server.js"]