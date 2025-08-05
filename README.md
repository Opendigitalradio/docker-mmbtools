# Opendigitalradio/mmbtools

The **Opendigitalradio/mmbtools** image aims at providing a sandboxed
environment for the Multi Media Broadcasting tools from
[Opendigitalradio](https://www.opendigitalradio.org/mmbtools).

## Content of the image

| Component | Description |
| --------- | ----------- |
| debian bookworm | debian bookworm and the backports repository |
| [odr-audioenc](https://github.com/opendigitalradio/odr-audioenc) | audio encoder |
| [odr-padenc](https://github.com/opendigitalradio/odr-padenc) | program-associated-data encoder |
| [odr-dabmux](https://github.com/opendigitalradio/odr-dabmux) | dab multiplexer |
| [odr-dabmod](https://github.com/opendigitalradio/odr-dabmod) | dab modulator |
| [supervisor](https://supervisord.org/) | process control system |
| config | sample configuration files |

## Getting the container image

You have 2 ways of getting the mmbtools image:

### Pull the image from docker hub

```bash
docker image pull opendigitalradio/mmbtools
```

### Build the mmbtools image

```bash
git clone https://github.com/opendigitalradio/docker-mmbtools
```

```bash
docker buildx build \
  --tag opendigitalradio/mmbtools \
  --output type=docker \
  .
```

## Pre-requisites

If the host running the docker image is attached to a usb modulator (ex:
Hackrf One), then plug your USB transceiver to the host.

### Linux OS

1. Run the command `lsusb` on the host and note the bus (bbb) and device
(ddd) numbers of your USB modulator device
1. Run the command `ls -l /dev/bus/usb/bbb/ddd` and confirm that the group
owner is **plugdev**
1. If **plugdev** is not the group owner then you need to install the package
related to your USB device (it should contain a file with the appropriate udev
rules). If you cannot find such a package, then install the `Soapysdr` package

### WSL (Windows Subsystem for Linux)

- Follow this [Microsoft guide](https://learn.microsoft.com/en-us/windows/wsl/connect-usb)
- Enter the WSL session and follow the above Linux OS steps

## Usage

### Run the mmbtools container

```bash
docker run \
  --name mmbtools \
  --rm \
  --detach \
  --publish 8001:8001 \
  --publish 9201:9201 \
  --volume /etc/localtime:/etc/localtime:ro \
opendigitalradio/mmbtools
```

Add the argument `--device /dev/bus/usb/bbb/ddd` to the above
`docker run` command where **bbb** and **ddd** are the bus and
device number

### Access the dashboard

Run your internet browser and go to
<http://HOST_RUNNING_MMBTOOLS:8001>

The credentials are:

| User | Password |
| ---  | -------- |
| odr  | odr      |

From the dashboard, you can start, stop and monitor the jobs
(modulator, multiplexer, audio and program-associated-data
services)

### Check the multiplex output

- Install `dablin` on a GUI host
- Run dablin:

  ```bash
  nc HOST_RUNNING_MMBTOOLS 9201 | dablin_gtk -f edi -I -1
  ```

## Customization

### General recommendation

If you need to change the configuration files, we recommend
that you use mount host path:

1. Copy the container configuration files on your host

   ```bash
   mkdir mmbtools
   docker cp mmbtools:/home/odr/config mmbtools
   ```

1. Customize the configuration files on your host (see below)

1. Run the docker container with your host configuration files

   ```bash
   docker run \
     --name mmbtools \
     --rm \
     --detach \
     --publish 8001:8001 \
     --publish 9201:9201 \
     --volume /etc/localtime:/etc/localtime:ro \
     --volume ./mmbtools:/home/odr/config \
     opendigitalradio/mmbtools
   ```

### Job dashboard

If you want to change the default user name and/or user password
authorized to access the job dashboard, then apply the
following commands:

```bash
# Change the user name
sed \
  -e 's/^username = odr/^username = new_user/'
  -i mmbtools/supervisord.conf

# Change the user password
sed \
  -e 's/^password = odr/^password = new_password/' \
  -i mmbtools/supervisord.conf
```

Please note that *new_user* is not related to any linux profiles

### Transmission channel

If channel 5A is being used in your area, you can switch to a
[new transmission channel](http://www.wohnort.org/config/freqs.html)
by applying the following command:

```bash
sed \
  -e 's/^channel=5A/^channel=new_channel/' \
  -i mmbtools/odr-dabmod.ini
```

### USB transceiver

The modulator sample configuration file is setup for a
[HackRF One](https://greatscottgadgets.com/hackrf/one/) using the
[SoapySDR](https://github.com/pothosware/SoapySDR/wiki) interface.

If you have a different USB transceiver, then apply one of the following
commands:

```bash
# LimeSDR
sed \
  -e 's/^device=driver=hackrf/^device=driver=lime/' \
  -i mmbtools/odr-dabmod.ini

# PlutoSDR
sed \
  -e 's/^device=driver=hackrf/^device=driver=plutosdr/' \
  -i mmbtools/odr-dabmod.ini

# Blade RF
sed \
  -e 's/^device=driver=hackrf/^device=driver=bladerf/' \
  -i mmbtools/odr-dabmod.ini
```

### RF spectrum

If the host running the mmbtools container is not powerful enough,
then you should set the following 2 parameters in the
`mmbtools/odr-dabmod.ini` file to less stringent value:

- modulator rate=2048000
- firfilter enabled=0
