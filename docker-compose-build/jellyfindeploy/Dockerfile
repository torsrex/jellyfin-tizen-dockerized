FROM ubuntu:mantic-20231011

ARG TIZEN_STUDIO_URL=https://download.tizen.org/sdk/Installer/tizen-studio_5.5/web-cli_Tizen_Studio_5.5_ubuntu-64.bin

# Add build dependencies
RUN apt-get update \
  && apt-get install -y curl git expect
# Create jellyfin user as tizen cannot be installed as root
RUN useradd -m jellyfin
USER jellyfin
WORKDIR /app

# Download and install tizen studio
WORKDIR /app/tizen
RUN curl -O $TIZEN_STUDIO_URL \
    && chmod a+x web-cli_Tizen_Studio_*.bin \
    && ./web-cli_Tizen_Studio_*.bin <<EOF
n
y
y
EOF
WORKDIR /app

# Add Tizen tools to path
ENV PATH="$PATH:/home/jellyfin/tizen-studio/tools/ide/bin"
ENV PATH="$PATH:/home/jellyfin/tizen-studio/tools"

# Copy in certificates
COPY --chown=jellyfin certificates/author /home/jellyfin/tizen-studio-data/keystore/author
COPY --chown=jellyfin certificates/profile /home/jellyfin/tizen-studio-data/profile
COPY --chown=jellyfin certificates/distributor /home/jellyfin/tizen-studio/tools/certificate-generator/certificates/distributor

# Do jellyfin stuff after copying certificates to use
# cached certificates on subsequent builds
ARG NODE_MAJOR=20
ARG JELLYFIN_VERSION=release-10.8.z

# Install node from nodeseource
USER root
RUN set -uex; \
    apt-get update; \
    apt-get install -y ca-certificates curl gnupg; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
     | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
     > /etc/apt/sources.list.d/nodesource.list; \
    apt-get -qy update; \
    apt-get -qy install nodejs;
USER jellyfin

# Clone jellyfin-web and build
# Verbose loglevel to show log in docker build output
RUN git clone -b $JELLYFIN_VERSION https://github.com/jellyfin/jellyfin-web.git
WORKDIR /app/jellyfin-web
RUN npm ci --no-audit --loglevel verbose
RUN npm run build:production --loglevel verbose
WORKDIR /app

# Clone jellyfin-tizen and build
RUN git clone https://github.com/jellyfin/jellyfin-tizen.git
WORKDIR /app/jellyfin-tizen
ENV JELLYFIN_WEB_DIR=/app/jellyfin-web/dist
RUN npm ci --no-audit --loglevel verbose
RUN tizen build-web -e ".*" -e gulpfile.js -e README.md -e "node_modules/*" -e "package*.json" -e "yarn.lock" 

# Emulate interactive input and build the package
COPY --chown=jellyfin ./tizen-package.sh .
RUN chmod a+x tizen-package.sh \
    && ./tizen-package.sh

# Add entrypoint to allow the installation step
# to be done runtime through docker-compose
USER root
COPY ./deploy.sh .
RUN chmod +x deploy.sh
ENTRYPOINT "/app/jellyfin-tizen/deploy.sh"