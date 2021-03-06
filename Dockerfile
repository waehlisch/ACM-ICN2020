FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y ruby bundler zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Install program to configure locales
RUN apt-get update && \
    apt-get install -y locales && \
    rm -rf /var/lib/apt/lists/*

RUN dpkg-reconfigure locales && \
  locale-gen en_US.UTF-8 && \
  /usr/sbin/update-locale LANG=en_US.UTF-8

# Install needed default locale for Makefly
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
  locale-gen

# Set default locale for the environment
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

COPY Gemfile /root/

RUN (cd /root; bundle install)

RUN apt-get update && \
    apt-get install -y shadowsocks-libev tsocks lftp && \
    rm -rf /var/lib/apt/lists/*

RUN echo set ftp:ssl-force on > /root/.lftprc && \
    echo set ftp:ssl-protect-data yes >> /root/.lftprc && \
    echo set ssl:verify-certificate no >> /root/.lftprc && \
    echo set ftp:passive-mode yes >> /root/.lftprc && \
    \
    echo server = ss-local > /root/.tsocks.conf && \
    echo server_port = 1080 >> /root/.tsocks.conf && \
    echo local = 172.0.0.0/255.0.0.0 >> /root/.tsocks.conf
