#!/usr/bin/env bash

# Exit if command fails
set -e 
# Return status of a pipeline.
# In case of a failure the value of the last (rightmost) command to exit with a non-zero status.
set -o pipefail
#set -o errexit -o pipefail -o noclobber -o nounset
# Set script directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Get the commit which modified Dockerfile last
CONTAINER_COMMIT=$(git log -n 1 --pretty=format:%H -- ./.devcontainer/Dockerfile)
# Create container image name
CONTAINER_IMAGE_NAME="dev-docker-${CONTAINER_COMMIT}"
# Create container name
CONTAINER_NAME="dev-container"

#TODO: Add cleanup functionality: Delete all images related to repo
HelpPromptPrint() {
cat << EOF
----------------------------------------
########## Container Manager ##########
----------------------------------------
-h   | --help   : Display this help prompt
-b   | --build  : Build container image
-r   | --run    : Run container image
----------------------------------------
########################################
----------------------------------------
EOF
}

BuildContainerImage () {
  echo "Attempting to build container image..."

  # Check if the container image already exists
  result=$(sudo docker images -q "${CONTAINER_IMAGE_NAME}")
  if [[ -n "$result" ]]; then
    echo 'Container image already exist...'
    exit 1
  else
    # Build container image
    cd ${SCRIPT_DIR}/.devcontainer/
    docker build -t ${CONTAINER_IMAGE_NAME}:1.0 .
  fi
  echo 'Container image built sucessfully...'
  exit 0
}

ContainerExitStatusHandler () {
  # Check if container status is 'exited'
  echo 'exit status container check...'
  if [ $( sudo docker ps -f status=exited -f name=${CONTAINER_NAME} | grep ${CONTAINER_NAME} | wc -l ) -gt 0 ]; then
    echo 'Removing container...'
    sudo docker rm ${CONTAINER_NAME}
  fi
}

# TODO: Exec into repo folder
RunContainer () {
  echo "Attempting to run container..."
  # Invoke exit status handler
  ContainerExitStatusHandler
  # Check if image exists:
  result=$(sudo docker images -q "${CONTAINER_IMAGE_NAME}")
  if [[ -n "$result" ]]; then
    # Container image exists, check if it is already running
    if [ $( docker ps | grep ${CONTAINER_NAME} | wc -l ) -gt 0 ]; then
      # Container exists
      echo "Container already exists, connecting to the instance..."
      sudo docker exec -i ${CONTAINER_NAME} /bin/bash
    else 
      # Container does not exist
      echo "Creating container..."
      sudo docker container run -it --name ${CONTAINER_NAME} -v ${SCRIPT_DIR}:${SCRIPT_DIR} ${CONTAINER_IMAGE_NAME}:1.0
      sudo docker exec -i ${CONTAINER_NAME} /bin/bash
    fi 
  else
    echo 'Container image does not exist...'
    exit 1
  fi
  # Run container shutdown
  ContainerExitStatusHandler
  exit 0
}

# Parse script arguments
POSITIONAL_ARGS=()
# Until no arguments left to process:
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      HelpPromptPrint
      exit 0
      ;;
    -r|--run)
      RunContainer
      shift # argument
      exit 0
      ;;
    -b|--build)
      BuildContainerImage
      shift # argument
      exit 0
      ;;
    -*)
      echo "Unknown script argument $1"
      exit 1
      ;;
    *)
    # save positional arg
    POSITIONAL_ARGS+=("$1") 
    shift # past argument
    ;;
  esac
done
