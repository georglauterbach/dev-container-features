
# hermes (hermes)

https://github.com/georglauterbach/hermes in a Development Container

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/hermes:11": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| init.bashrc | Whether to add _hermes_ to the default Bash setup in `$[HOME}/.bashrc` | boolean | true |
| init.bashrc-overwrite | When `hermes.init.bashrc` is `true`, whether to completely overwrite the file `${HOME}/.bashrc` to only run _hermes_ | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/hermes/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
