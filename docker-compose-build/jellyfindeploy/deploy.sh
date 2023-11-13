if [ -z "$TV_IP" ]; then echo "Error: TV_IP is not set."; exit 1; fi
echo "Starting install ..."
sdb connect $TV_IP \
&& TV_NAME=$(sdb devices | awk '/device/{if(NR==2) print $NF}') \
&& tizen install -n Jellyfin.wgt -t $TV_NAME || exit 1
echo "Done installing"
