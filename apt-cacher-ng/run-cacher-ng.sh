
# Setup the varables
# --------------------
. _set-vars.sh
# --------------------

echo
echo "Setting up apt-cacher-ng at:"
echo "---------------------------------------------------------"

docker network ls | grep ${APT_CACHER_NETWORK} >/dev/null
if [ $? -gt 0 ] ; then

	echo "Creating Network: ${APT_CACHER_NETWORK}"
	docker network create ${APT_CACHER_NETWORK}
else
	echo "Using Network:"
	docker network ls | grep ${APT_CACHER_NETWORK}
fi

echo
docker run --rm -d --network=${APT_CACHER_NETWORK} -p 3142:3142 --name ${APT_CACHER_CONTAINER_NAME} ${APT_IMAGE_NAME}

echo
