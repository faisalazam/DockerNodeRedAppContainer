#!/usr/bin/env bash

case ${GIT_CLONE_URL-} in '')
    echo "$0: Kindly specify Git clone url using --build-arg GIT_CLONE_URL='http://your-git-repo'" >&2;
    exit 1;;
esac

if ! git -C ${GIT_CLONE_LOCATION} rev-parse --is-inside-work-tree; then
    echo "No git repo found. Going to do a git clone..."
    rm -rf ${GIT_CLONE_LOCATION}/*

    if ! git clone --depth 1 --branch stable ${GIT_CLONE_URL} ${GIT_CLONE_LOCATION}; then
        echo "[ERROR] Exiting...failed to clone the git repo..."
        rm -rf ${GIT_CLONE_LOCATION}/*
        exit 1;
    fi
fi

if ! git -C ${GIT_CLONE_LOCATION} rev-parse --is-inside-work-tree; then
    echo "[ERROR] Exiting...no git repo found"
    exit 1;
fi

if "${UPDATE_APP:-false}"; then
    echo "Updating the app..."
    if ! git -C ${GIT_CLONE_LOCATION} fetch origin "+refs/tags/stable:refs/tags/stable" && git -C ${GIT_CLONE_LOCATION} checkout -f refs/tags/stable; then
        echo "[ERROR] The app has NOT been updated..."
        exit 1;
    else
        echo "The app has been updated..."
    fi
fi

if [ -f ${GIT_CLONE_LOCATION}/package.json ]; then
    echo "Installing node module dependencies..."
    if ! npm -C ${GIT_CLONE_LOCATION} install; then
        echo "[ERROR] The node module dependencies have NOT been updated..."
        exit 1;
    else
        echo "The node module dependencies have been updated..."
    fi
fi

if [ -f ${GIT_CLONE_LOCATION}/web/bower.json ]; then
    echo "Installing bower dependencies..."
    cd ${GIT_CLONE_LOCATION}/web
    if ! ../node_modules/bower/bin/bower install -F; then
        echo "[ERROR] The bower dependencies have NOT been updated..."
        exit 1;
    else
        echo "The bower dependencies have been updated..."
    fi
    cd -
fi

if [ -f ${GIT_CLONE_LOCATION}/config/database.json ] && [ -d ${GIT_CLONE_LOCATION}/migrations ]; then
    echo "Applying database migrations..."
    if ! ${GIT_CLONE_LOCATION}/node_modules/db-migrate/bin/db-migrate up --config ${GIT_CLONE_LOCATION}/config/database.json -m ${GIT_CLONE_LOCATION}/migrations; then
        echo "[ERROR] Database migration failed..."
        exit 1;
    fi
fi

sed -i "s|#{APP_LOCATION}|${GIT_CLONE_LOCATION}|g" ${USER_DIR}/${APP_STARTUP_YML}

pm2-docker start ${USER_DIR}/${APP_STARTUP_YML}