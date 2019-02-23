# Setup the varables
# --------------------
. _set-vars.sh
# --------------------

docker build -t ${APT_IMAGE_NAME} .
