FROM ubuntu:mantic-20231011

ENV TIZEN_STUDIO_URL=https://download.tizen.org/sdk/Installer/tizen-studio_5.5/web-cli_Tizen_Studio_5.5_ubuntu-64.bin

# Add build dependencies
RUN apt-get update \
  && apt-get install -y curl
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

# Add tizen studio tools to path
# and copy in certificate generation script
USER root
ENV PATH="$PATH:/home/jellyfin/tizen-studio/tools/ide/bin"
COPY generate-certs.sh .
RUN chmod +x generate-certs.sh
ENTRYPOINT "/app/generate-certs.sh"