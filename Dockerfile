FROM public.ecr.aws/amazonlinux/amazonlinux:2027.0.20261026.1
EXPOSE 8080

WORKDIR /usr/src/app

COPY . .

# hadolint ignore=DL3041,DL3016
RUN rm -f package-lock.json; \
    curl -fsSL https://rpm.nodesource.com/setup_24.x | bash -; \
    dnf install nodejs -y; \
    npm install -g npm; \
    npm install --legacy-peer-deps; \
    dnf upgrade -y; \
    dnf clean all

RUN npm run build

CMD ["npm", "run", "start"]