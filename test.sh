#!/usr/bin/env bash

set -euo pipefail

APP_DIR="/opt/ci-practice"
IMAGE_REPO="ghcr.io/legac1x/ci-practice"
URL='http://127.0.0.1:8001'

if [[ ${1:-} == '' ]]; then
    echo "Error: version argument is required"
    exit 1
fi


check_version () {
    local version=$1
    if [[ $version =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

check_web_service () {
    local URL=$1
    local expected='{"status":"ok"}'
    for ((i=1; i<= 15; i++)); do
        result_curl=$(curl --fail --silent "$URL"/health || true)
        if [[ "$result_curl" == "$expected" ]]; then
            return 0
        fi
        sleep 2
    done
    return 1
}

launch_docker_compose () {
    local version=$1
    if sudo env APP_VERSION="$version" docker compose -f "$APP_DIR"/compose.yml pull api; then
        if sudo env APP_VERSION="$version" docker compose -f "$APP_DIR"/compose.yml up -d; then
            return 0
        else
            echo "Error while up docker compose"
        fi
    else
        echo "Error while pull image"
    fi
    return 1
}

version=$1

if check_version $version; then
    printf "Full name dockere image: %s:%s\n" "$IMAGE_REPO" "$version"
    if [[ -s /opt/ci-practice/current-version ]]; then
        previous_version=$(cat /opt/ci-practice/current-version)
        if check_version $previous_version; then
            if launch_docker_compose $version && check_web_service $URL; then
                echo $version > "$APP_DIR"/draft_current-version
                echo "Service is healthy"
            else
                if launch_docker_compose $previous_version && check_web_service $URL; then
                    echo "rollback to previous version"
                else
                    echo "Error while rolling back to previous version"
                fi
                exit 1
            fi
            echo "Current version: ${previous_version}"
        else
            echo "The current version is incorrect"
            exit 1
        fi
    else
        echo "There is no such file"
        exit 1
    mv "$APP_DIR"/draft_current-version "$APP_DIR"/current-version
    fi
else
    echo "Type of version is incorrect"
    exit 1
fi

draft_current-version это временный файл новой версии, в конец скрипта версии от туда переносится в чистый current-version, 