
# Setup the varables
# --------------------
. ./apt-cacher-ng/_set-vars.sh
# --------------------

#	-e http_proxy=http://${APT_CACHER_CONTAINER_NAME}:3142 \
#	--network=${APT_CACHER_NETWORK} \

docker run \
	--privileged --rm \
	-it xixer \
	--hostname=xixer \
	--password=xixer \
	--usb-device=disk3${1}
