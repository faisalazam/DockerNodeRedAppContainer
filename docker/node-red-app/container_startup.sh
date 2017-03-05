#!/usr/bin/env bash

if "${UPDATE_APP:-false}"; then
    echo "Updating the app..."
    git -C ${GIT_CLONE_LOCATION} fetch origin "+refs/tags/stable:refs/tags/stable"
    npm -C ${GIT_CLONE_LOCATION} install
    echo "The app has been updated..."
fi

sed -i "s|#{APP_LOCATION}|${GIT_CLONE_LOCATION}|g" ${USER_DIR}/${APP_STARTUP_YML}

pm2-docker start ${USER_DIR}/${APP_STARTUP_YML}