
# Setup the varables
# --------------------
. _set-vars.sh
# --------------------


echo
echo "Running Utilities.... type:"
echo
echo "                            /usr/lib/apt-cacher-ng/distkill.pl"
echo
echo "                             to execute the utility"
echo "---------------------------------------------------------"
echo
echo "Volume Mapping -v [${CACHE_WORKING_DIRECTORY} : ${CONTAINER_BASE_DIRECTORY}]"
echo

#docker run --rm -it -v ${CACHE_WORKING_DIRECTORY}:${CONTAINER_BASE_DIRECTORY} --volumes-from test_apt_cacher_ng wgbdev/apt-cacher-ng bash
docker run --rm -it --volumes-from ${CONTAINER_NAME} ${IMAGE_NAME} bash



