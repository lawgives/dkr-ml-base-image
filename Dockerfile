FROM python:3.6.5-alpine3.7
MAINTAINER Ho-Sheng Hsiao <hosh@legal.io>

ENV NUMPY_VER=1.14.2 \
    SCIPY_VER=1.0.1 \
    SCIKIT_LEARN_VER=0.19.1 \
    FLASK_VER=0.12.2 \
    GUNICORN_VER=19.7.1 \
    ROLLBAR_VER=0.14.0 \
    BLINKER_VER=1.4

RUN apk update && \
    apk upgrade && \
    pip install --upgrade pip && \
    apk add build-base

# Add app user 9999:9999 and su-exec
RUN apk --no-cache add su-exec \
    && /bin/busybox adduser -D -u 9999 app

# From: https://github.com/frol/docker-alpine-python-machinelearning/blob/master/Dockerfile
# Took out python3-dev dep because it is 3.6.3 on Alpine 3.7
RUN apk add --no-cache \
        --virtual=.build-dependencies \
        g++ gfortran file binutils \
        musl-dev openblas-dev && \
    \
    apk add libstdc++ openblas && \
    \
    pip install \
	rollbar==${ROLLBAR_VER} \
        blinker==${BLINKER_VER} \
 	numpy==${NUMPY_VER} \
        scipy==${SCIPY_VER} \
        scikit-learn==${SCIKIT_LEARN_VER} \
        flask==${FLASK_VER} \
        gunicorn==${GUNICORN_VER} \
        && \
    \
    rm -r /root/.cache && \
    #find /usr/lib/python3.*/ -name 'tests' -exec rm -r '{}' + && \
    #find /usr/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \
    #rm /usr/include/xlocale.h && \
    \
    apk del .build-dependencies

CMD gunicorn -w 4 -b 0.0.0.0:8000 server:app
