
# Development Container Feature - Rust (rust)

A Development Container Feature to work efficiently and effortlessly with the Rust programming language

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/rust:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| rustup-default-toolchain | The default toolchain to install | string | none |
| rustup-update-default-toolchain | Whether to update the default toolchain | string | false |
| rustup-profile | Which profile `rustup` should use for the installation | string | minimal |
| additional-targets | List of additional targets to install | string | - |
| additional-packages | List of additional packages to install via APT | string | - |
| install-mold | Whether to install the mold linker | string | false |

## Customizations

### VS Code Extensions

- `rust-lang.rust-analyzer`
- `fill-labs.dependi`
- `tamasfe.even-better-toml`
- `vadimcn.vscode-lldb`


## About

This Development Container Feature installs [Rust](https://www.rust-lang.org/) via [rustup](https://www.rust-lang.org/tools/install) and additional extensions required to work efficiently in Rust. This feature is installed after `ghcr.io/devcontainers/features/common-utils`.

> [!TIP]
>
> #### Works Well With [`georglauterbach/dev-container-base`](https://github.com/georglauterbach/dev-container-base)
>
> This Development Container Feature works well with base images that focus on recent versions of Ubuntu, like https://github.com/georglauterbach/dev-container-base/pkgs/container/dev-container-base[`ghcr.io/georglauterbach/dev-container-base:edge`].

### Supported Base / OS

This feature should work on recent versions of Debian- and Ubuntu-based distributions. This feature depends on the APT package manager. Bash is required. The package `build-essential` has to be installable.

### Environment Variables Set by This Feature

> [!TIP]
>
> The following variables can be overwritten in the `containerEnv` section in your `devcontainer.json` file.
>
> You should use a volume or a bind-mount to cache the files contained in the directories denoted by the environment variables.

| Name                    | Description                                                                         | Value                                                 |
| :---------------------- | :---------------------------------------------------------------------------------- | :---------------------------------------------------- |
| `RUSTUP_HOME`           | Directory path that `rustup` uses as its "home" directory                           | `${containerWorkspaceFolder}/target/rustup_home` |
| `CARGO_HOME`            | Directory path that `Cargo` uses as its "home" directory                            | `${containerWorkspaceFolder}/target/cargo_home`  |
| `CARGO_TARGET_DIR`      | Changes the `target/` directory that Cargo uses to place binaries & build artifacts | `${containerWorkspaceFolder}/target/cargo_target`      |

### Additional Adjustments

1. Inside the container, `securityOpt` is set to `seccomp=unconfined`.
2. A new capability is added: `SYS_PTRACE` for proper debugging.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/rust/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
