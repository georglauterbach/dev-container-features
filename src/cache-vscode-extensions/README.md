
# Development Container Feature - Cache VS Code Extensions (cache-vscode-extensions)

A Development Container Feature that prevents superfluous (re-)installations of VS extensions upon container restarts by caching the extensions

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/cache-vscode-extensions:0": {}
}
```



> [!NOTE]
>
> This extension is based upon <https://github.com/microsoft/vscode-remote-release/issues/7690#issuecomment-2761197753> by [@chrmarti](https://github.com/chrmarti).

## About

This extension properly links (with symbolic links) the `${HOME}/.vscode-server/extensions` (and the insiders versions, respectively) directory to a location onto which a volume is mounted. This persists extensions across container restarts because VS Code recognizes that the extensions directory is not empty.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/cache-vscode-extensions/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
