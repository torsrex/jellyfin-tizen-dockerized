# jellyfin-tizen-dockerized

This repository contains dockerized build steps for installing Jellyfin on a Tizen (Samsung) TV.

## Prerequisites

- Download and install [https://docs.docker.com/get-docker/](Docker) # TODO: Test windows
- Samsung TV in development mode
  1. Turn on TV
  2. Open the 'apps' app
  3. Press the '123'/'quick settings' button on your remote. Press the 'down arrow' until a numerical keypad is displayed
  4. Enter the digits '12345' and press done
  5. Set developer mode to 'on' and enter the IP of the host/computer you're running the docker container on
     - Windows: Click on the "wifi" symbol in your system tray. Click "properties" on your connected network". Scroll to the end of the list and find "IPv4 address" under "Properties". Enter this address.
     - Linux: Open a terminal and run `ifconfig`. Enter the address next to "inet". You can use `iwconfig` to help identify your wifi adapter.
  6. Turn off and on your TV again
  7. Press the '123'/'quick settings' button on your remote. Use the 'up arrow' to get to the quick settings menu. Navigate to 'all settings' and go to connection -> network. Open 'network status' and click on 'IP settings'.
  8. Write down the entry next to the 'IP address' entry (it may be greyed out).
  9. After installing Jellyfin you can repeat the above steps to turn off developer mode.

## Build and Install Jellyfin

## Option 1: Run entire process in single docker container

This will run the entire build and installation procedure inside a single docker container. It uses the Docker cache to cache the generation of the certificates. This means that on subsequent runs e.g. when upgrading Jellyfin it will use the Docker cache to re-use the certificates. However, deleting the Docker cache or moving the script to a different computer will generate a new development certificate which will require the Jellyfin app on the TV to be uninstalled before the script can be run. Otherwise, the final installation step will fail.

1. Enter the dockerized-build directory using `cd dockerized-build`
2. Run `docker build . --build-arg="TV_IP=<ip address you wrote down from step 8 in setting the tv to development mode>"` e.g. `docker build . --build-arg="TV_IP=192.168.1.191"`
3. If the build succeeds the Jellyfin app should be installed on your tv. If not, see [Troubleshooting](#troubleshooting).

## Option 2: Use intermediate container to export development certificates

1. Enter the docker-compose-build directory using `cd docker-compose-build`
2. Run `docker-compose --profile certificate up --build` to generate the certificates
3. Do one of the following
   - Build through docker-compose:
     1. Modify docker-compose.yml file and set the TV_IP variable e.g. TV_IP=192.168.1.191 which is the ip address you wrote down from step 8 in setting the tv to development mode
     2. Run `docker-compose --profile deploy build`
   - Build through docker:
     1. Enter the jellyfindeploy directory using `cd jellyfindeploy`
     2. Run `docker build . --build-arg="TV_IP=<ip address you wrote down from step 8 in setting the tv to development mode>"` e.g. `docker build . --build-arg="TV_IP=192.168.1.191"`
4. If the build succeeds the Jellyfin app should be installed on your tv. If not, see [Troubleshooting](#troubleshooting).

## Additional parameters

- TIZEN_STUDIO_URL: Link to download tizen studio from. You can get the latest link from https://developer.tizen.org/development/tizen-studio/download, but you probably don't have to change this
- NODE_MAJOR: The major Node version. Can be changed to upgrade the Node version used to build Jellyfin
- JELLYFIN_VERSION: Branch name of the Jellyfin version to install
- TV_IP: The ip address of your Samsung tv

## Troubleshooting

- The build crashes when installing Jellyfin on the tv with the error `reason: Author certificate not match` -> The generated certificate is incompatible with the current Jellyfin install. Uninstall Jellyfin on the TV and run the script again.
- The build crashes with the error `Error: TV_IP is not set.` -> You forgot to set the TV_IP when running the docker build command.
- The build crashes when installing jellyfin-web dependencies or building jellyfin-web --> Too little memory allocated to docker. In my testing I tried with 3.8GB initially which would occasionally crash. Increasing the limit to 10GB solved this.
  1. Open Docker Desktop
  2. Press the cogwheel in the top right
  3. Go to "Resources"
  4. Adjust the "Memory limit" slider
