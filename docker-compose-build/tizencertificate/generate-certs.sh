#!/bin/bash
echo "Generating certificates ..."
# Create dev certificate and signing profile
tizen certificate -a jellyfin -p 1234 -c SG -ct SG -n jellyfin -f jellyfin \
    && tizen security-profiles add -n jellyfin -a /home/jellyfin/tizen-studio-data/keystore/author/jellyfin.p12 -p 1234
# Replace passwords
sed -i "s|password=\"/home/jellyfin/tizen-studio-data/keystore/author/jellyfin.pwd\"|password=\"1234\"|g" /home/jellyfin/tizen-studio-data/profile/profiles.xml \
    && sed -i "s|password=\"/home/jellyfin/tizen-studio-data/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.pwd\"|password=\"tizenpkcs12passfordsigner\"|g" /home/jellyfin/tizen-studio-data/profile/profiles.xml
# Copy generated certificates to local directories
cp /home/jellyfin/tizen-studio-data/keystore/author/jellyfin.p12 /tmp/tizen-output/author/jellyfin.p12
cp /home/jellyfin/tizen-studio-data/profile/profiles.xml /tmp/tizen-output/profile
cp /home/jellyfin/tizen-studio/tools/certificate-generator/certificates/distributor/tizen-distributor-ca.cer /tmp/tizen-output/distributor
cp /home/jellyfin/tizen-studio/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.p12 /tmp/tizen-output/distributor
echo "Done generating certificates"
