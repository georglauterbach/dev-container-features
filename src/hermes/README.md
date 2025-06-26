
# Development Container Feature - hermes (hermes)

Use [_hermes_](https://github.com/georglauterbach/hermes) in your container

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/hermes:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| hermes.version | The released version of hermes to use | string | 10.0.1 |
| hermes.acquire-insecure | Whether to download _hermes_ without checking certificates | boolean | false |
| hermes.run | Whether to actually run _hermes_ | boolean | true |
| hermes.arguments | Additional arguments to supply to _hermes_ after `hermes --verbose --non-interactive run` | string | --install-packages |
| hermes.init.bashrc | If `hermes.run` is `true`, whether to add _hermes_ to the default Bash setup in `$[HOME}/.bashrc` | boolean | true |
| hermes.init.bashrc-overwrite | When `hermes.init.bashrc` is `true`, whether to completely overwrite the file `${HOME}/.bashrc` to only run _hermes_ | boolean | true |
| proxy.http.http.address | A URI for an HTTP proxy | string | - |
| proxy.http.https.address | A URI for an HTTPS proxy | string | - |
| proxy.http.no-proxy.address | A list of URIs to not proxy | string | localhost,127.0.0.1 |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/hermes/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
