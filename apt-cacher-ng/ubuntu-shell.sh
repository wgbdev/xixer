
# Setup the varables
# --------------------
. _set-vars.sh
# --------------------


#mkdir -p /var/cache/apt-cacher-ng
# make it work on a mac
mkdir -p ${CACHE_WORKING_DIRECTORY}

echo
echo "Running Ubuntu Shell at: ${CONTAINER_BASE_DIRECTORY}"
echo "---------------------------------------------------------"

#echo "Mapping -v [${CACHE_WORKING_DIRECTORY} : ${CONTAINER_BASE_DIRECTORY}]"
echo "Mapping -v [${CACHE_WORKING_DIRECTORY} : /wgb]"
echo
echo "NOTE: All apt-get calls should be cached to persistant Volume [${CACHE_WORKING_DIRECTORY}]"
echo "      You can view the cache at: [/wgb/var/cache/apt-cacher-ng/]"
echo

docker run -it --network=${APT_CACHER_NETWORK}  --rm -e http_proxy=http://${CONTAINER_NAME}:3142 -v ${CACHE_WORKING_DIRECTORY}:/wgb/${CONTAINER_BASE_DIRECTORY} --name ${SHELL_CONTAINER} ubuntu bash
