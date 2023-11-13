# jellyfin-tizen-dockerized

This repository contains dockerized build steps for installing Jellyfin on a Tizen (Samsung) TV.

## Prerequisites

- Download and install [https://docs.docker.com/get-docker/](Docker)
  - Use WSL2 for Windows
- Samsung TV in development mode
  1. Turn on TV
  2. Open the "apps" app
  3. Press the "123/quick settings" button on your remote. Press the "down arrow" button on your remote until a numerical keypad is displayed
  4. Enter the digits "12345" and press done
  5. Set developer mode to "on" and enter the IP of the host/computer you're running the docker container on (use the 123 menu and press done on each text box)
     - Windows: Click on the "wifi" symbol in your system tray. Click "properties" on your connected network. Scroll to the end of the list and find "IPv4 address" under "Properties". Enter this address
     - Linux: Open a terminal and run `ifconfig`. Enter the address next to "inet". You can use `iwconfig` to help identify your wifi adapter.
  6. Turn off and on your TV again
  7. Press the "123/quick settings" button on your remote. Use the "up arrow" button to get to the quick settings menu. Navigate to "all settings" and go to connection -> network. Open "network status" and click on "IP settings"
  8. Write down the entry next to the "IP address" entry (it may be greyed out)
  9. After installing Jellyfin you can repeat the above steps to turn off developer mode

## Build and Install Jellyfin

### Option 1: Run entire process in single docker container

This will run the entire build and installation procedure inside a single docker container. It uses the Docker cache to cache the generation of the certificates. This means that on subsequent runs e.g. when upgrading Jellyfin it will use the Docker cache to re-use the certificates. However, deleting the Docker cache or moving the script to a different computer will generate a new development certificate which will require the Jellyfin app on the TV to be uninstalled before the script can be run. Otherwise, the final installation step will fail.

1. Enter the dockerized-build directory using `cd dockerized-build`
2. Run `docker build . --build-arg="TV_IP=<ip address you wrote down from step 8 in setting the tv to development mode>"` e.g. `docker build . --build-arg="TV_IP=192.168.1.191"`
3. If the build succeeds the Jellyfin app should be installed on your tv. If not, see [Troubleshooting](#troubleshooting)

### Option 2: Use intermediate container to export development certificates

This will first generate the certificates and store them for later use so that if the Docker cache is cleared or the script is run on a different computer the certificates can still be reused.

1. Enter the docker-compose-build directory using `cd docker-compose-build`
2. Run `docker-compose --profile certificate up --build` to generate the certificates
3. Modify the docker-compose.yml file and set the TV_IP variable e.g. TV_IP=192.168.1.191 which is the ip address you wrote down from step 8 in setting the tv to development mode
4. Run `docker-compose --profile deploy up --build` to deploy Jellyfin to the tv
5. If the build succeeds the Jellyfin app should be installed on your tv. If not, see [Troubleshooting](#troubleshooting)

## Additional Parameters

- TIZEN_STUDIO_URL: Link to download tizen studio from. You can get the latest link from https://developer.tizen.org/development/tizen-studio/download, but you probably don't have to change this
- NODE_MAJOR: The major Node version. Can be changed to upgrade the Node version used to build Jellyfin
- JELLYFIN_VERSION: Branch name or tag name of the Jellyfin version to install
- TV_IP: The ip address of your Samsung tv
- NONCE: (Only for option 1) can be used to trigger a re-install of the same build to the same tv by setting this to a random string

## Troubleshooting

- The build crashes when installing Jellyfin on the tv with the error `reason: Author certificate not match` -> The generated certificate is incompatible with the current Jellyfin install. Uninstall Jellyfin on the TV and run the script again
- The build crashes with the error `Error: TV_IP is not set.` -> You forgot to set the TV_IP when running the docker build command
- The build crashes with an error similar to `failed to connect to 192.168.1.191:26101` -> You likely whitelisted the wrong ip on the tv
- You used option 1 and installed Jellyfin successfully, uninstalled it, and wanted to install it again, but nothing happens -> For simplicity sake, option 1 does everything during the docker build phase with no runtime step as opposed to option 2. However, this means that the install step is also cached if it succeeds. The script is set up so that if any of the parameters listed under [Additional parameters](#additional-parameters) changes then it will re-run the install. However, if you want to install the same version to the same TV, you can set the `NONCE` parameter to a random string (replace loremipsum) like so: `docker build . --build-arg="TV_IP=192.168.1.191" --build-arg="NONCE=loremipsum"`. Alternatively, use `docker build . --build-arg="TV_IP=192.168.1.191" --no-cache`, however, this will also run the build steps again so this will take longer
- (Linux) The build crashes when installing jellyfin-web dependencies or building jellyfin-web --> Too little memory allocated to docker. In my testing I tried with 3.8GB initially which would occasionally crash. Increasing the limit to 10GB solved this
  1. Open Docker Desktop
  2. Press the cogwheel in the top right
  3. Go to "Resources"
  4. Adjust the "Memory limit" slider
- (Windows) The build fails with something like `/bin/sh: 1: /app/generate-certs.sh: not found` -> Git replaced LF with CRLF on Windows. Run the following commands and try again:
  ```bash
  git config --local core.autocrlf false
  git checkout .
  ```

## Additional Notes

- Tested on Linux Mint 21.2 with Docker version 24.0.7
- Tested on Windows 10.0.19045.3636 with Docker version 24.0.6
- Not affiliated with Jellyfin or any of the referenced projects. I just wanted an easy, reliable way to install and keep Jellyfin updated on my tv without resorting to prebuilds
