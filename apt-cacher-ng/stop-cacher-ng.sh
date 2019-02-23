
# Setup the varables
# --------------------
. _set-vars.sh
# --------------------

docker stop ${CONTAINER_NAME} 

docker network ls | grep ${APT_CACHER_NETWORK}
if [ $? -gt 0 ] ; then
	echo "Removing Network: ${APT_CACHER_NETWORK}"
	docker network rm ${APT_CACHER_NETWORK}
fi
