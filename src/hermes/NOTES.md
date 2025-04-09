## About

This feature performs multiple of tasks in order:

1. It sets up the system to have a set of predefined packages usually required for [`hermes`][link::hermes] to work properly.

    > [!IMPORTANT]
    >
    > This is currently only supported for Debian-like distributions.
2. If `doas` was installed in 1., it sets up [`doas`][link::doas] if the container user is not `root`
3. It checks for `curl` or `wget` to be installed
4. It downloads [`hermes`][link::hermes]
5. It (optionally) runs [`hermes`][link::hermes]

[//]: # (Links)

[link::hermes]: https://github.com/georglauterbach/hermes
[link::doas]: https://wiki.archlinux.org/title/Doas
