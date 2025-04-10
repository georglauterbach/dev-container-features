## About

This feature performs multiple tasks (in order)

1. It installs a set of predefined packages usually required for [`hermes`][link::hermes] to work properly. This is currently only supported for Debian-like distributions. If this operations does not succeed, only a warning is issued but the installation continues in the hope that we can still make Rust work.
2. If `doas` was installed in 1. and the container user is not `root`, it sets up [`doas`][link::doas] to make the `sudo` command work.
3. It checks for `curl` or `wget` to be installed. If neither are installed, and 1. failed, the installation is aborted.
4. It downloads [`hermes`][link::hermes].
5. It (optionally) runs [`hermes`][link::hermes].

> [!NOTE]
>
> Currently, only Debian-like systems are fully supported. This is not a technical limitation, the feature is written so that other distributions work too, but their support has simply not been implemented yet. If you want to see support for a different distribution, please open an issue.

[//]: # (Links)

[link::hermes]: https://github.com/georglauterbach/hermes
[link::doas]: https://wiki.archlinux.org/title/Doas
