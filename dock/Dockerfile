FROM phusion/baseimage
MAINTAINER "dror.tirosh@gmail.com"

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN  add-apt-repository ppa:gophers/archive &&\
  add-apt-repository -y ppa:ethereum/ethereum && \
  apt-get update && \
  apt-get install -y software-properties-common git nodejs golang-1.10-go ethereum netcat && \
  apt-get install -y libusb-1.0-0 libudev-dev && \
  apt-get install -y --no-install-recommends yarn && \
  rm -rf /var/lib/apt/lists/*

ENV PS1 "\e[31min-docker\e[0m \W \$ "
RUN echo "export PS1=\"$PS1\"" >> /etc/bash.bashrc
RUN echo "export PS1=\"$PS1\"" >> /root/.bashrc
ENV PATH /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/node_modules/.bin:/usr/lib/go-1.10/bin


CMD "/bin/bash"
