ARG NODE_VERSION=latest
FROM node:$NODE_VERSION

ARG ANGULAR_CLI_VERSION="^6"

RUN apt-get update \
    apt-get install -y \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    ca-certificates \
    fonts-liberation \
    libappindicator1 \
    libnss3 \
    lsb-release \
    xdg-utils \
    wget \
    chromium && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# INSTALL @angular/cli
RUN npm install -g @angular/cli@${ANGULAR_CLI_VERSION} && \
    npm install -g puppeteer && \
    rm -rf /tmp/* /var/cache/apk/* *.tar.gz ~/.npm && \
    npm cache clear --force && \
    yarn cache clean
    #sed -i -e "s/bin\/ash/bin\/sh/" /etc/passwd

# adding a chromium user
RUN useradd -ms /bin/bash chromium

USER chromium