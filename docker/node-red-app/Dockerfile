FROM ubuntu:16.10

RUN apt-get -y update \
    && apt-get install -y \
                        git \
                        npm \
                        nodejs \
    && apt-get clean

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN npm install -g pm2@latest
RUN npm install -g --unsafe-perm node-red node-red-admin

ARG GIT_CLONE_URL=''
ARG PORT_TO_EXPOSE=''
ARG USER_NAME=apprunner

ENV USER_DIR=/home/$USER_NAME
ENV APP_STARTUP_YML=app_startup.yml
ENV CONTAINER_STARTUP_SH=container_startup.sh
ENV GIT_CLONE_LOCATION=$USER_DIR/.git/node-red-app

RUN adduser --disabled-password --gecos "" $USER_NAME

ADD $APP_STARTUP_YML $USER_DIR/
ADD $CONTAINER_STARTUP_SH $USER_DIR/
RUN chmod +x $USER_DIR/$CONTAINER_STARTUP_SH

USER $USER_NAME
RUN case ${PORT_TO_EXPOSE-} in '') \
        echo "$0: Kindly specify port to expose using --build-arg PORT_TO_EXPOSE=PORT_NUMBER." >&2; \
        exit 1;; \
    esac

RUN mkdir -p $GIT_CLONE_LOCATION

VOLUME $GIT_CLONE_LOCATION

EXPOSE $PORT_TO_EXPOSE

CMD $USER_DIR/$CONTAINER_STARTUP_SH