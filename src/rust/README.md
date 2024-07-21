
# Development Container Feature - Rust (rust)

A Development Container Feature to work efficiently and effortlessly with the Rust programming language

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-feature-rust/rust:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| rustup-default-toolchain | The default toolchain to install | string | none |
| rustup-update-default-toolchain | Whether to update the default toolchain | string | false |
| rustup-profile | Which profile `rustup` should use for the installation | string | minimal |
| additional-targets | List of additional targets to install | string | - |
| install-mold | Whether to install the mold linker | string | false |

## Customizations

### VS Code Extensions

- `rust-lang.rust-analyzer`
- `serayuzgur.crates`
- `tamasfe.even-better-toml`
- `vadimcn.vscode-lldb`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-feature-rust/blob/main/src/rust/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
