# Docker Image for WPI SSE
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/snugfox/wpi-sse?sort=semver)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/snugfox/wpi-sse/latest)
![Docker Pulls](https://img.shields.io/docker/pulls/snugfox/wpi-sse)
![GitHub](https://img.shields.io/github/license/snugfox/wpi-sse-docker)

`wpi-sse` is an unofficial Docker image designed and customised for software
security engineering at Worcester Polytechnic Institute. This includes a simple
Debian-based environment with several common tools, such as GDB and Pwntools.


## Getting Started
The Docker image is publicly available on DockerHub as `snugfox/wpi-sse`. There
are tags for both the latest version (`snugfox/wpi-sse:latest`), as well as
images for tagged versions (e.g. `snugfox/wpi-sse:v0.1.0`). By default, the
working directory is set to `/root/workspace`, which is an empty directory
intended for mounting a host volume.

To run a container with your current working directory mounted in the default
workspace:
```console
$ docker run -it -v "$(pwd):/root/workspace" snugfox/wpi-sse
```

To specify a custom shell or command, you can supply a command to the container:
```console
$ docker run -it -v "$(pwd):/root/workspace" snugfox/wpi-sse /bin/bash
```

You can also specify runtime options (see [Container
options](#container-options)):
```console
$ docker run -it -v "$(pwd):/root/workspace" -e OPTS="corefile,no_aslr" \
    --privileged snugfox/wpi-sse
```


You may also want to supply the `--rm` flag to automatically remove the
container after it has exited.


## Container options
The `wpi-sse` image accepts several runtime options through the `OPTS`
environemtnal variable. The complete list of options include:
- `corefile`: Enable the generation of corefiles with unlimited size. By
  default, corefiles are written according to `/proc/sys/kernel/core_pattern`,
  which is inherited from the host operating system. Note that corefiles cannot
  be written to mounted directories, such as volumes defined in `docker run`.
- `no_aslr`\*: Disable address space layout randomization (ASLR) for all processes
  in the container. This option uses `setarch -R`, which has no effect on the
  host operating system.
- `no_pwndbg`: Disable the pwndbg extension from loading in GDB. pwndbg can
  still be loaded using the GDB command `source /opt/pwndbg/gdbinit.py`.

\* *Requires that container have extended privileges (`--privileged` in
Docker)*.
