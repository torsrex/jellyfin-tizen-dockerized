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
    && chmod +x web-cli_Tizen_Studio_*.bin \
    && ./web-cli_Tizen_Studio_*.bin <<EOF
n
y
y
EOF
WORKDIR /app

# Add Tizen tools to path
ENV PATH="$PATH:/home/jellyfin/tizen-studio/tools/ide/bin"
ENV PATH="$PATH:/home/jellyfin/tizen-studio/tools"

# Create dev certificate and signing profile
RUN tizen certificate -a jellyfin -p 1234 -c SG -ct SG -n jellyfin -f jellyfin \
    && tizen security-profiles add -n jellyfin -a /home/jellyfin/tizen-studio-data/keystore/author/jellyfin.p12 -p 1234
# Replace passwords
RUN sed -i "s|password=\"/home/jellyfin/tizen-studio-data/keystore/author/jellyfin.pwd\"|password=\"1234\"|g" /home/jellyfin/tizen-studio-data/profile/profiles.xml \
    && sed -i "s|password=\"/home/jellyfin/tizen-studio-data/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.pwd\"|password=\"tizenpkcs12passfordsigner\"|g" /home/jellyfin/tizen-studio-data/profile/profiles.xml

# Do jellyfin stuff after creating certificates to use
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
RUN chmod +x tizen-package.sh \
    && ./tizen-package.sh

# Set TV_IP at the end to cache previous work
ARG NONCE=""
ARG TV_IP
RUN if [ -z "$TV_IP" ]; then echo "Error: TV_IP is not set."; exit 1; fi

# Extract TV name from provided IP
# and install Jellyfin
RUN sdb connect $TV_IP \ 
    && TV_NAME=$(sdb devices | awk '/device/{if(NR==2) print $NF}') \
    && tizen install -n Jellyfin.wgt -t $TV_NAME
