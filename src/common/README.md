
# Development Container Feature - Common Setup (common)

Common setup for system packages, user configuration or user programs

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/common:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| system.packages.update | Whether package signatures should be updated | boolean | true |
| system.packages.upgrade | Whether existing packages should be upgraded | boolean | true |
| system.packages.additional-packages | A comma-separated list of additional packages to install | string | - |
| system.packages.clean | Whether to run cleanup steps (like `apt-get clean`) | boolean | true |
| system.setup.doas | Whether to set up [`doas`](https://wiki.archlinux.org/title/Doas). Make sure it is installed. | boolean | false |
| system.time.zone | The time zone to use (for configuration packages like `tzdata` non-interactively) | string | - |
| user.config.prompt | Whether to provide a prompt setup. Setting this to `true` does not enable anything yet, it simply places the configuration files. | boolean | true |
| user.packages.install | Install additional packages to `${HOME}/.local/bin/` | boolean | true |
| proxy.http.http.address | A URI for an HTTP proxy | string | - |
| proxy.http.https.address | A URI for an HTTPS proxy | string | - |
| proxy.http.no-proxy.address | A list of URIs to not proxy | string | localhost,127.0.0.1 |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/common/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
