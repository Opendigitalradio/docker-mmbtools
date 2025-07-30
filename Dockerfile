FROM debian:bookworm-backports

# Set image labels
LABEL org.opencontainers.image.vendor="Open Digital Radio"
LABEL org.opencontainers.image.authors="colisee@hotmail.com"

## Expose ports
EXPOSE 8001
EXPOSE 9201

## Set the entrypoint
ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon"]

# Create user odr
RUN useradd \
      --create-home \
      --groups dialout,audio \
      odr ;\
      mkdir -p /home/odr/log ;\
      chown odr:odr /home/odr/log

# Copy files
COPY --chown=odr:odr --chmod=744 config /home/odr/config/
COPY --chown=odr:odr --chmod=744 mot /home/odr/mot/

# Add non-free repository, upgrade system and install required packages
ARG DEBIAN_FRONTEND=noninteractive
RUN sed \
      -i /etc/apt/sources.list.d/backports.list \
      -e 's/ main/ main non-free/' ;\
    apt-get update ;\
    apt-get upgrade --yes ;\
    apt-get \
      install --yes \
      odr-audioenc \
      odr-padenc \
      odr-dabmux \
      odr-dabmod \
      supervisor ;\
    apt-get clean

# Customize supervisor
RUN if [ ! $(grep inet_http_server /etc/supervisor/supervisord.conf) ]; then \
      echo ''                   >> /etc/supervisor/supervisord.conf ;\
      echo '[inet_http_server]' >> /etc/supervisor/supervisord.conf ;\
      echo 'port = 8001'        >> /etc/supervisor/supervisord.conf ;\
      echo 'username = odr'     >> /etc/supervisor/supervisord.conf ;\
      echo 'password = odr'     >> /etc/supervisor/supervisord.conf ;\
    fi; \
    if [ ! $(grep /home/odr /etc/supervisor/supervisord.conf) ]; then \
      sed \
        -i /etc/supervisor/supervisord.conf \
        -e "s:\(^files =.*$\):\1 /home/odr/config/supervisor/*.conf:" ;\
    fi
