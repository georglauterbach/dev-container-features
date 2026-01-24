
# hermes (hermes)

This Feature installs [_hermes_](https://github.com/georglauterbach/hermes].

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/hermes:12": {}
}
```



## Enabling _hermes_ Inside Your Container

Add

```bash
[[ -f ${HOME}/.config/bash/90-hermes.sh ]] && source "${HOME}/.config/bash/90-hermes.sh"
```

to your Bash setup (e.g., `${HOME}/.bashrc`) to enable _hermes_. This could be archived by adding a `postCreateCommand` to your Development Container definition.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/hermes/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
