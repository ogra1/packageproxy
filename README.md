[![Snap Status](https://build.snapcraft.io/badge/ogra1/packageproxy.svg)](https://build.snapcraft.io/user/ogra1/packageproxy)

## packageproxy

[![Snap Status](https://build.snapcraft.io/badge/ogra1/packageproxy.svg)](https://build.snapcraft.io/user/ogra1/packageproxy)

The packageproxy snap ships a pre-confgured Approx install.
In the default configuration you can point your sources.list to:

        http://localhost:9999/ubuntu

.. or replace "localhost" with the actual IP when accessing it from
another host. If you use any of the Ubuntu Ports architectures,
replace "/ubuntu" with "ubuntu-ports".

Approx is an HTTP-based proxy server for Debian-style package archives.
It fetches files from remote repositories on demand,
and caches them for local use.

Approx saves time and network bandwidth if you need to install or
upgrade .deb packages for a number of machines on a local network.
Each package is downloaded from a remote site only once,
regardless of how many local clients install it.
The approx cache typically requires a few gigabytes of disk space.

Approx also simplifies the administration of client machines:
repository locations need only be changed in approx's configuration file,
not in every client's /etc/apt/sources.list file.

# building

Just call snapcraft in the toplevel of this tree.

# configuration

After installing the snap you can edit the config like:

	sudo vi /var/snap/packageproxy/current/config.yaml
and then restart the service with:

	sudo systemctl restart snap.packageproxy.approx.service
