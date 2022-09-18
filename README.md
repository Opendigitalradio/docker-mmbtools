# docker-mmbtools

## Goal
This repository aims at building a docker container image with:
- the main components of the [mmbTools - MultiMedia Broadcasting Tools](https://www.opendigitalradio.org/)
- fully functional sample configuration files

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
- Point your web browser to `localhost:8001`
- Sign in as user `odr` with password `odr`

### First test: run the multiplex off-air
- Install `dablin` on your host
- Start the 2 audio encoders and the 2 PAD encoders
- Start the multiplexer
- Run the following command to view the multiplex information and hear one of the 2 radio streams (by default the first one):
	```
	# If your host doesn't have a graphical interface
	nc localhost 9201 | dablin -f edi -I -1

	# If your host has a graphical interface
	nc localhost 9201 | dablin_gtk -f edi -I -1
	```

### Second test: run the multiplex on-air
If you need to broadcast on a channel other than **5A**, or if you have a USB transceiver card othen than the HackRF, then
- Get a command line inside the running container:
	```
	docker exec \
		--interactive \
		--tty \
		mmbtools \
		bash
	```
- Follow these [instructions](https://github.com/opendigitalradio/dab-scripts#configuration)

