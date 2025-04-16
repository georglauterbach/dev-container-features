
# Development Container Feature - Python (python)

Work efficiently and effortlessly with Python

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/python:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| uv.install | - | boolean | false |
| uv.install.version | Which [version of `uv`](https://github.com/astral-sh/uv/releases) to install (use 'latest' to install the latest version) | string | latest |
| uv.install.method | Defines the [method with which `uv` should be install](https://docs.astral.sh/uv/getting-started/installation/) | string | curl |
| uv.install.uri | Custom URI to download the `uv` installation script from (takes precedence over `uv.install.version`) | string | - |
| proxy.http.http.address | A URI for an HTTP proxy | string | - |
| proxy.http.https.address | A URI for an HTTPS proxy | string | - |
| proxy.http.no-proxy.address | A list of URIs to not proxy | string | localhost,127.0.0.1 |

## Customizations

### VS Code Extensions

- `charliermarsh.ruff`
- `ms-python.isort`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/python/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
