
# Development Container Feature - Rust (rust)

A Development Container Feature to work efficiently and effortlessly with the Rust programming language

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/rust:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| rustup-default-toolchain | The default toolchain to install | string | none |
| rustup-update-default-toolchain | Whether to update the default toolchain | string | false |
| rustup-profile | Which profile `rustup` should use for the installation | string | minimal |
| rustup-dist-server | Root URI for downloading static resources related to Rust | string | https://static.rust-lang.org |
| rustup-update-root | Root URL for downloading self-update | string | https://static.rust-lang.org/rustup |
| rustup-init-target-triple | The target triple (without the architecture) | string | unknown-linux-gnu |
| additional-targets | List of additional targets to install | string | - |
| additional-components | List of additional `rustup` components | string | - |
| additional-packages | List of additional packages to install via APT | string | - |
| install-mold | Whether to install the mold linker | string | false |
| mold-version | The version of the mold linker to install | string | 2.33.0 |
| http_proxy | A URI for an HTTP proxy | string | - |
| https_proxy | A URI for an HTTPS proxy | string | - |
| no_proxy | List of URIs to not proxy | string | localhost,127.0.0.1 |

## Customizations

### VS Code Extensions

- `bierner.docs-view@0.1.0`
- `editorconfig.editorconfig@0.16.4`
- `fill-labs.dependi@0.7.10`
- `rust-lang.rust-analyzer@0.4.2135`
- `tamasfe.even-better-toml@0.19.2`
- `usernamehw.errorlens@3.20.0`
- `vadimcn.vscode-lldb@1.11.0`


## About

This Development Container Feature installs [Rust](https://www.rust-lang.org/) via [rustup](https://www.rust-lang.org/tools/install) and additional extensions required to work efficiently in Rust. This feature is installed after `ghcr.io/devcontainers/features/common-utils`.

> [!TIP]
>
> #### Works Well With [`georglauterbach/dev-container-base`](https://github.com/georglauterbach/dev-container-base)
>
> This Development Container Feature works well with base images that focus on recent versions of Ubuntu, like [`ghcr.io/georglauterbach/dev-container-base:edge`](https://github.com/georglauterbach/dev-container-base/pkgs/container/dev-container-base).

### Supported Base / OS

This feature should work on recent versions of Debian- and Ubuntu-based distributions. This feature depends on the APT package manager. Bash is required. The package `build-essential` has to be installable.

### Environment Variables Set by This Feature

> [!TIP]
>
> The following variables can be overwritten in the `containerEnv` section in your `devcontainer.json` file.
>
> You should use a volume or a bind-mount to cache the files contained in the directories denoted by the environment variables.

| Name                    | Description                                                                         | Value                                             |
| :---------------------- | :---------------------------------------------------------------------------------- | :------------------------------------------------ |
| `RUSTUP_HOME`           | Directory path that `rustup` uses as its "home" directory                           | `${containerWorkspaceFolder}/target/rustup_home`  |
| `CARGO_HOME`            | Directory path that `Cargo` uses as its "home" directory                            | `${containerWorkspaceFolder}/target/cargo_home`   |
| `CARGO_TARGET_DIR`      | Changes the `target/` directory that Cargo uses to place binaries & build artifacts | `${containerWorkspaceFolder}/target/cargo_target` |

### Additional Adjustments

1. Inside the container, `securityOpt` is set to `seccomp=unconfined`.
2. A new capability is added: `SYS_PTRACE` for proper debugging.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/rust/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
