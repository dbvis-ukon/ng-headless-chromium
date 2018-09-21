#The image is based on https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker

ARG NODE_VERSION=10-slim
ARG ANGULAR_CLI_VERSION="^6"
ARG PUPPETEER_VERSION="^1.4"

FROM node:$NODE_VERSION

LABEL author="Wolfgang Jentner <wolfgang.jentner@uni.kn>"

# See https://crbug.com/795759
RUN apt-get update && apt-get install -yq libgconf-2-4

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update && apt-get install -yq wget --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -yq google-chrome-unstable \
		fonts-ipafont-gothic \
		fonts-wqy-zenhei \
		fonts-thai-tlwg \
		fonts-kacst \
		ttf-freefont \
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
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean autoclean \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /src/*.deb

# RUN apt-get update && \
#     apt-get install -y \
#     gconf-service \
#     libasound2 \
#     libatk1.0-0 \
#     libc6 \
#     libcairo2 \
#     libcups2 \
#     libdbus-1-3 \
#     libexpat1 \
#     libfontconfig1 \
#     libgcc1 \
#     libgconf-2-4 \
#     libgdk-pixbuf2.0-0 \
#     libglib2.0-0 \
#     libgtk-3-0 \
#     libnspr4 \
#     libpango-1.0-0 \
#     libpangocairo-1.0-0 \
#     libstdc++6 \
#     libx11-6 \
#     libx11-xcb1 \
#     libxcb1 \
#     libxcomposite1 \
#     libxcursor1 \
#     libxdamage1 \
#     libxext6 \
#     libxfixes3 \
#     libxi6 \
#     libxrandr2 \
#     libxrender1 \
#     libxss1 \
#     libxtst6 \
#     ca-certificates \
#     fonts-liberation \
#     libappindicator1 \
#     libnss3 \
#     lsb-release \
#     xdg-utils \
#     wget && \
#     apt-get clean autoclean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# It's a good idea to use dumb-init to help prevent zombie chrome processes.
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# INSTALL @angular/cli
RUN npm install -g @angular/cli@${ANGULAR_CLI_VERSION} && \
    # Install puppeteer so it's available in the container.
    npm i puppeteer@${PUPPETEER_VERSION} && \
    rm -rf /tmp/* /var/cache/apk/* *.tar.gz ~/.npm && \
    npm cache clear --force && \
    yarn cache clean
    #sed -i -e "s/bin\/ash/bin\/sh/" /etc/passwd

# Add user so we don't need --no-sandbox.
RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /node_modules

# install gosu: https://github.com/tianon/gosu/blob/master/INSTALL.md#from-debian
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	fetchDeps=' \
		ca-certificates \
		wget \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
	chmod +s /usr/local/bin/gosu; \
# verify that the binary works
	gosu nobody true; \
	\
	apt-get purge -y --auto-remove $fetchDeps

ADD ./tests /tmp/tests
RUN chmod +x /tmp/tests/run-test.sh
RUN chown -R pptruser /tmp/tests

# Run everything after as non-privileged user.
USER pptruser

# check that gosu can be executed from pptruser
RUN gosu root true;


ENTRYPOINT ["dumb-init", "--"]
CMD ["google-chrome-unstable"]
