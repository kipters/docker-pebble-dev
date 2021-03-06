FROM ubuntu:16.04
MAINTAINER André Dumas

# Instructions as per https://developer.pebble.com/sdk/install/linux/

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    python2.7-dev \
    python-pip \
    libfreetype6

# Install Pebble Tool
ENV PEBBLE_TOOL_VERSION pebble-sdk-4.5-linux64
ENV PEBBLE_PATH /root/pebble-dev
ENV PEBBLE_HOME $PEBBLE_PATH/$PEBBLE_TOOL_VERSION
ENV PATH $PEBBLE_HOME/bin:$PATH

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - && apt-get install -y nodejs

RUN mkdir -p $PEBBLE_PATH
RUN curl -sSL https://s3.amazonaws.com/assets.getpebble.com/pebble-tool/$PEBBLE_TOOL_VERSION.tar.bz2 \
		| tar -v -C $PEBBLE_PATH -xj

WORKDIR $PEBBLE_HOME

RUN /bin/bash -c " \
    pip install virtualenv \
    && virtualenv --no-site-packages .env \
    && source .env/bin/activate \
    && pip uninstall six -y \
    && pip install -I 'six==1.9.0' \
    && pip install -r requirements.txt \
    && deactivate \
    "

RUN /bin/bash -c " \
    mkdir -p /root/.pebble-sdk \
    && touch /root/.pebble-sdk/NO_TRACKING \
    "

# Install Pebble SDK
ENV PEBBLE_SDK_VERSION 4.3
RUN yes | pebble sdk install $PEBBLE_SDK_VERSION

VOLUME /pebble
WORKDIR /pebble

ENTRYPOINT ["pebble"]
