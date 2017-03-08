#!/usr/bin/env bash

case ${GIT_CLONE_URL-} in '')
    echo "$0: Kindly specify Git clone url using --build-arg GIT_CLONE_URL='http://your-git-repo'" >&2;
    exit 1;;
esac

if ! git -C ${GIT_CLONE_LOCATION} rev-parse --is-inside-work-tree; then
    echo "No git repo found. Going to do a git clone..."
    rm -rf ${GIT_CLONE_LOCATION}/*

    if ! git clone --depth 1 --branch stable $GIT_CLONE_URL $GIT_CLONE_LOCATION; then
        echo "Exiting...failed to clone the git repo..."
        rm -rf ${GIT_CLONE_LOCATION}/*
        exit 1;
    fi
fi

if ! git -C ${GIT_CLONE_LOCATION} rev-parse --is-inside-work-tree; then
    echo "Exiting...no git repo found"
    exit 1;
fi

if "${UPDATE_APP:-false}"; then
    echo "Updating the app..."
    git -C ${GIT_CLONE_LOCATION} fetch origin "+refs/tags/stable:refs/tags/stable"
    echo "The app has been updated..."
fi

npm -C ${GIT_CLONE_LOCATION} install

sed -i "s|#{APP_LOCATION}|${GIT_CLONE_LOCATION}|g" ${USER_DIR}/${APP_STARTUP_YML}

pm2-docker start ${USER_DIR}/${APP_STARTUP_YML}