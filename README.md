# Opendigitalradio/mmbtools

The **Opendigitalradio/mmbtools** docker image aims at providing a sandboxed environment for the Multi Media Broadcasting tools from [Opendigitalradio](https://www.opendigitalradio.org/mmbtools).

## Content of the image
| Component | Description |
| --------- | ----------- |
| [jgoerzen/debian-base-minimal](https://hub.docker.com/r/jgoerzen/debian-base-minimal) | base debian image with systemd |
| [odr-audioenc](https://github.com/opendigitalradio/odr-audioenc) | audio encoder |
| [odr-padenc](https://github.com/opendigitalradio/odr-padenc) | program-associated-data encoder |
| [odr-dabmux](https://github.com/opendigitalradio/odr-dabmux) | dab multiplexer |
| [odr-dabmod](https://github.com/opendigitalradio/odr-dabmod) | dab modulator |
| [odr-EncoderManager](https://github.com/opendigitalradio/odr-encodermanager) | encoder manager |
| [configuration files](https://github.com/Opendigitalradio/dab-scripts/tree/master/config) | sample configuration files |

## Usage

### Start the docker container
```
docker run \
	--name mmbtools \
	--tty \
	--detach \
	--publish 8001-8003:8001-8003 \
	--publish 9201:9201 \
	--volume /sys/fs/cgroup:/sys/fs/cgroup:rw \
	--volume /etc/localtime:/etc/localtime:ro \
	--stop-signal=SIGRTMIN+3 \
	--tmpfs /run:size=100M \
	--tmpfs /run/lock:size=100M \
	--cgroupns=host \
opendigitalradio/mmbtools
```

If you have a USB transceiver and if you intend to broadcast, then you should:
- Plug your USB transceiver
- Run the command `lsusb` and identify the bus number and device number of your transceiver
- Add the argument `--device /dev/bus/usb/xxx/yyy` to the above `docker run` command where **xxx** is the bus number and **yyy** if the device number

### Access the components
| Component | Action | URL | Authentication |
| --------- | ------ | --- | -------------- |
| Supervisor | n/a | localhost:8001 | user: `odr` <br /> password: `odr` |
| Encoder Manager | Start 10-EncoderManager | localhost:8003 | user: `odr` <br /> password: `odr` |
| Multiplex Manager | Start 20-Mulitplex <br /> Start 21-Multiplex-Manager | localhost:8002 | n/a |

### Test-1: check the encoders
- Access the supervisor (http://localhost:8001)
- Start `10-EncoderManager`
- Log into the Encoder Manager (http://localhost:8003)
- Open the `status` tab
- Check the audio levels and the DLS text

### Test-2: check the multiplex
- Install `dablin` on a GUI host
- Access the supervisor (http://localhost:8001)
- Start the audio and PAD encoders
- Start `20-Multiplex`
- Run the following command to view the multiplex information and hear the radio streams (by default the first one):
  ```
  nc localhost 9201 | dablin_gtk -f edi -I -1
  ```

### Test-3: check the modulator
If you have a USB transceiver card and wish to broadcast on a channel other than **5A**, or if you have a USB transceiver card othen than the HackRF, then
- Get a command line inside the running container:
	```
	docker exec \
		--interactive \
		--tty \
		mmbtools \
		bash
	```
- Follow these [instructions](https://github.com/opendigitalradio/dab-scripts#configuration)
- Access the supervisor (http://localhost:8001)
- Start the audio and PAD encoders
- Start `20-Multiplex`
- Start `30-Modulator`
## Sources
[github](https://github.com/colisee/docker-mmbtools)
