
# Setup the varables
# --------------------
. _set-vars.sh
. apt-cacher-ng/_set-vars.sh
# --------------------


echo
echo "Starting the run ..."
echo "--------------------------------"


#mkdir -p /var/cache/apt-cacher-ng
# make it work on a mac
mkdir -p ${CACHE_WORKING_DIRECTORY}

echo
echo "Running cache-run-it.sh : [${CONTAINER_BASE_DIRECTORY}"]
echo "---------------------------------------------------------"


IMAGE_DIRECTORY="wgbdev/"
STAGE_2_IMAGE_AS_BUILT="fai-image-stage2"
IMAGE_TAG=":latest"
CONTAINER_NAME="tmp-fai-container"

CMDLINE_OPTION=""
REPO_OVERRIDE=""
DEBUG_SOURCE=""

if [ $# -gt 0 ] ; then
	CMDLINE_OPTION=${1}
	echo "Command line Option = [${CMDLINE_OPTION}]"

	REPO_OVERRIDE="${CMDLINE_OPTION}"

	echo "REPO_OVERRIDE=[${REPO_OVERRIDE}]"
REPO_OVERRIDE=""


DEBUG_SOURCE="-v $(pwd)/tmp-wrk:/usr -v $(pwd)/bin:/usr/local/bin -v $(pwd)/../../myscripts/misc-scripts:/scripts"



##DEBUG_SOURCE="-v $(pwd)/bin:/usr/local/bin"

## ENV WGB_DEBUG=true
## ENV WGB_VERBOSE=true

CACHER_SUB_TEST=""


	if [ $# -gt 1 ] ; then
		CONTAINER_NAME="${CONTAINER_NAME}-${2}"
		CACHER_SUB_TEST="-${2}"
	fi


DEBUG_SOURCE="-v $(pwd)/tmp-wrk/bin:/usr/bin \
-v $(pwd)/tmp-wrk/local:/usr/local \
-v $(pwd)/tmp-wrk/sbin:/usr/sbin \
-v $(pwd)/bin:/usr/local/bin \
-v $(pwd)/../../myscripts/misc-scripts:/scripts"

fi

#
# NOTE by wgb:
# --------------
#
# On a Mac, you can't use ~ for the come directory
#
echo
echo "Execute ./what-is-next.sh for futher instructions...."
echo
#
#
# [-e REPO=pa.archive.ubuntu.com]
# BTW, no longer works....
#

echo "		-v ${CACHE_WORKING_DIRECTORY} : ${CONTAINER_BASE_DIRECTORY} "
echo "		--network=${APT_CACHER_NETWORK}"
echo "		APT_CACHER_CONTAINER_NAME=${APT_CACHER_CONTAINER_NAME}"
echo

	docker run \
		--name ${CONTAINER_NAME} \
		--network=${APT_CACHER_NETWORK}  \
		-e http_proxy=http://${APT_CACHER_CONTAINER_NAME}:3142 \
		-v ${CACHE_WORKING_DIRECTORY}:${CONTAINER_BASE_DIRECTORY} \
		-e REPO=${REPO_OVERRIDE} \
		-v $(pwd)/faiconfig:/srv/fai/config \
		${DEBUG_SOURCE} \
		--privileged \
		--rm \
		-it ${IMAGE_DIRECTORY}${STAGE_2_IMAGE_AS_BUILT}${IMAGE_TAG} /bin/bash
echo

