#!/bin/bash

DO_BUILD=1
DO_RUN=1

# see if a "--net" option was passed, if so we'll connect the
# container to a private network (creating it if necessary)
NETWORK=default
DRUN_OPTS=""
for arg; do
    case $arg in
        --net)	NETWORK=launchernw
				# create a docker network for our app if it doesn't exist
				if ! docker network ls | grep -q $NETWORK; then docker network create $NETWORK; fi
				;;
        --build) DO_RUN=0
                ;;
        --run) DO_BUILD=0
                ;;
        --help) echo "Usage: docker.sh [options]"
                echo ""
                echo "Builds and runs this project's Docker image"
                echo ""
                echo "Options:"
                echo "   --build  : Only build the Docker image"
                echo "   --run    : Only run the Docker image"
                echo "   --net    : When run the Docker image will be attached to a private network"
                echo "   --help   : This help"
                echo ""
                echo "For all other available options see 'docker run --help'"
                exit
                ;;
        *)	DRUN_OPTS="$DRUN_OPTS ${arg}"
				;;
    esac
done

if [[ $DO_BUILD -eq 1 ]]; then
    # remove any pre-existing image
    docker rm -f launcher-backend >/dev/null 2>&1

    # build the image
    echo "Building image..."
    docker build -q -t fabric8/launcher-backend -f Dockerfile.deploy .
fi

if [[ $DO_RUN -eq 1 ]]; then
    # run it
    echo "Running image..."
    docker run \
        --name launcher-backend \
        --network $NETWORK \
        -t \
        -p8080:8080 \
        -eLAUNCHPAD_KEYCLOAK_URL=$LAUNCHPAD_KEYCLOAK_URL \
        -eLAUNCHPAD_KEYCLOAK_REALM=$LAUNCHPAD_KEYCLOAK_REALM \
        -eLAUNCHPAD_MISSIONCONTROL_GITHUB_USERNAME=$LAUNCHPAD_MISSIONCONTROL_GITHUB_USERNAME \
        -eLAUNCHPAD_MISSIONCONTROL_GITHUB_TOKEN=$LAUNCHPAD_MISSIONCONTROL_GITHUB_TOKEN \
        -eLAUNCHPAD_MISSIONCONTROL_OPENSHIFT_API_URL=$LAUNCHPAD_MISSIONCONTROL_OPENSHIFT_API_URL \
        -eLAUNCHPAD_MISSIONCONTROL_OPENSHIFT_CONSOLE_URL=$LAUNCHPAD_MISSIONCONTROL_OPENSHIFT_CONSOLE_URL \
        -eLAUNCHPAD_MISSIONCONTROL_OPENSHIFT_USERNAME=$LAUNCHPAD_MISSIONCONTROL_OPENSHIFT_USERNAME \
        -eLAUNCHPAD_MISSIONCONTROL_OPENSHIFT_PASSWORD=$LAUNCHPAD_MISSIONCONTROL_OPENSHIFT_PASSWORD \
        -eLAUNCHPAD_MISSIONCONTROL_OPENSHIFT_TOKEN=$LAUNCHPAD_MISSIONCONTROL_OPENSHIFT_TOKEN \
        -eLAUNCHPAD_MISSIONCONTROL_OPENSHIFT_CLUSTERS_FILE=$LAUNCHPAD_MISSIONCONTROL_OPENSHIFT_CLUSTERS_FILE \
        -eLAUNCHPAD_MISSIONCONTROL_SERVICE_HOST=$LAUNCHPAD_MISSIONCONTROL_SERVICE_HOST \
        -eLAUNCHPAD_MISSIONCONTROL_SERVICE_PORT=$LAUNCHPAD_MISSIONCONTROL_SERVICE_PORT \
        -eLAUNCHPAD_BACKEND_CATALOG_GIT_REPOSITORY=$LAUNCHPAD_BACKEND_CATALOG_GIT_REPOSITORY \
        -eLAUNCHPAD_BACKEND_CATALOG_GIT_REF=$LAUNCHPAD_BACKEND_CATALOG_GIT_REF \
        -eLAUNCHPAD_TRACKER_SEGMENT_TOKEN=$LAUNCHPAD_TRACKER_SEGMENT_TOKEN \
        $DRUN_OPTS \
        fabric8/launcher-backend
fi

