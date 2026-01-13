
# NodeJS (nodejs)

Install NodeJS

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/nodejs:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of NodeJS to install | string | 25.0.0 |
| architecture | Architecture of NodeJS to install | string | x64 |
| uri | Non-default mirror for the `tar.xz`/`tar.gz` archive that contains NodeJS files. You can specify the version directly or use the string `{{VERSION}}` which is replaced by `node.version` | string | https://nodejs.org/dist/v{{VERSION}}/node-v{{VERSION}}-linux-{{ARCHITECTURE}}.tar.xz |
| proxy.http.http.address | A URI for an HTTP proxy | string | - |
| proxy.http.https.address | A URI for an HTTPS proxy | string | - |
| proxy.http.no-proxy.address | A list of URIs to not proxy | string | localhost,127.0.0.1 |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/nodejs/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
