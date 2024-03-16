# SyncRelay-SRV

Find me at:

* [Blog](https://blackwizard.fr)
* [GitHub](https://github.com/Chucky2401)

Syncthing relies on a network of community-contributed relay servers. Anyone can run a relay server, and it will automatically join the relay pool and be available to Syncthing users. The current list of relays can be found [here](https://relays.syncthing.net/) [^1].

[![syncthing](https://raw.githubusercontent.com/Chucky2401/syncrelay-srv/master/img/syncthing.png)](https://syncthing.net)

## Supported Architectures

Simply pulling `chucky2401/syncrelay:tagversion` should retrieve the correct image for your arch.

## Usage

To help you get started creating a container from this image you can either use docker compose or the docker cli.

### docker compose (recommended)

```yaml
services:
  syncrelay:
    image: chucky2401/syncrelay:1.0.0
    container_name: syncrelay
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - ./strelaysrv:/var/strelaysrv
    ports:
      - 22067:22067
      - 22070:22070
    restart: unless-stopped
```

### docker cli ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=syncrelay \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -p 22067:22067 \
  -p 22070:22070 \
  -v /path/to/syncthing/strelaysrv:/var/strelaysrv
  --restart unless-stopped \
  chucky2401/syncrelay:1.0.0
```

## Parameters

Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

|       Parameter        | Default | Function                                                                                                                                                     |
| :--------------------: | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
|       `-p 22067`       | `N/A`   | Relay advertising                                                                                                                                            |
|       `-p 22070`       | `N/A`   | Port to retrieve statistics                                                                                                                                  |
|     `-e PUID=1000`     | `N/A`   | for UserID - see below for explanation                                                                                                                       |
|     `-e PGID=1000`     | `N/A`   | for GroupID - see below for explanation                                                                                                                      |
|    `-e TZ=Etc/UTC`     | `N/A`   | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List).                                               |
|   `-e TOKEN=MyToken`   | `Empty` | Set a token to securing your relay. Disables joining any pools.                                                                                              |
|   `-e PRIVATE=True`    | `Empty` | Set your relay private. It will not announced itself to the pool. If not set, it will announce to the default pool (`https://relays.syncthing.net/endpoint`) |
|       `-e PORT=`       | `22067` | If you set a different port on the host side to inform the server - see below for example                                                                    |
| `-e EXTERNAL_ADDRESS=` | `Empty` | If you want to fix the address of your relay                                                                                                                 |
|  `-v /var/strelaysrv`  | `N/A`   | Configuration files.                                                                                                                                         |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```bash
-e SECRET__TOKEN=/run/secrets/mysupertoken
```

Will set the environment variable `TOKEN` based on the contents of the `/run/secrets/mysupertoken` file.

**Note**: I recommand you to use this format to pass your token to your container.

Example:

```yaml
services:
  syncrelay:
    image: chucky2401/syncrelay:1.0.0
    container_name: syncrelay
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - SECRET_TOKEN=/run/secrets/mysupertoken
    secrets:
      - mysupertoken
    volumes:
      - ./strelaysrv:/var/strelaysrv
    ports:
      - 22067:22067
      - 22070:22070
    restart: unless-stopped
secrets:
  mysupertoken:
    file: ./secrets/token_file
```

You can avoid to use the environment variable, and just set the secret.

**ATTENTION**: be advised that the container wait for the **TOKEN** variable, nothing else.

```yaml
services:
  syncrelay:
    image: chucky2401/syncrelay:1.0.0
    container_name: syncrelay
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    secrets:
      - TOKEN
    volumes:
      - ./strelaysrv:/var/strelaysrv
    ports:
      - 22067:22067
      - 22070:22070
    restart: unless-stopped
secrets:
  TOKEN:
    file: ./secrets/token_file
```

## Using the port variable

In my case, my company authorize in the firewall only ports: 80, 443 and 8080 to the outside.

I need to use the relay on one of the three ports. In my case, only the 8080 is available at home.

So I use this docker compose file:

```yaml
services:
  syncrelay:
    image: chucky2401/syncrelay:1.0.0
    container_name: syncrelay
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - SECRET_TOKEN=/run/secrets/mysupertoken
      - PORT=8080
    secrets:
      - mysupertoken
    volumes:
      - ./strelaysrv:/var/strelaysrv
    ports:
      - 22067:22067
      - 22070:22070
    restart: unless-stopped
secrets:
  mysupertoken:
    file: ./secrets/token_file
```

In this case, `strelaysrv` is started with the argument `-ext-address=:8080`[^2], because the server needs to know on which port the client will try to contact it.

**Note**: I also use NPM (NGinX Proxy Manager)[^3] to stream the port 8080 to the port 22067 of my Docker host.

If you're not using a reverse proxy, you need to map the port to yours:

```yaml
    ports:
      - 8080:22067
```

## User / Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id your_user` as below:

```bash
id your_user
```

Example output:

```text
uid=1000(your_user) gid=1000(your_user) groups=1000(your_user)
```

[^1]: Text grab from the official [documentation](https://docs.syncthing.net/users/strelaysrv.html)
[^2]: `:8080` is equivalent to `0.0.0.0:8080` for **all interfaces**
[^3]: [NGinX Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager)
