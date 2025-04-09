
# Development Container Feature - hermes (hermes)

Delivers setup and configuration for your container using [`hermes`](https://github.com/georglauterbach/hermes)

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/hermes:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| hermes.version | The released version of hermes to use | string | 7.1.0 |
| hermes.acquire-insecure | Whether to download `hermes` without checking certificates | boolean | false |
| hermes.run | Whether to actually run `hermes` | boolean | true |
| hermes.arguments | Additional arguments to supply to `hermes` after `hermes --verbose --non-interactive run` | string | --install-packages |
| proxy.http.http.address | A URI for an HTTP proxy | string | - |
| proxy.http.https.address | A URI for an HTTPS proxy | string | - |
| proxy.http.no-proxy.address | A list of URIs to not proxy | string | localhost,127.0.0.1 |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/hermes/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
