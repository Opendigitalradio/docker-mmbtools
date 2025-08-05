FROM debian:bookworm-backports

# Set image labels
LABEL org.opencontainers.image.vendor="Open Digital Radio"
LABEL org.opencontainers.image.authors="colisee@hotmail.com"

## Expose ports
EXPOSE 8001
EXPOSE 9201

## Set the entrypoint
ENTRYPOINT ["supervisord", "-n", "-c", "/home/odr/config/supervisord.conf"]

# Create user odr
RUN useradd \
      --create-home \
      --groups dialout,audio,plugdev \
      odr

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

# Fill odr home directory
USER odr
COPY --chown=odr config /home/odr/config/
COPY --chown=odr mot /home/odr/mot/
RUN  mkdir -p /home/odr/log ;\
     mkdir -p /home/odr/run
