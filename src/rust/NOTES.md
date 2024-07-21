
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

| Name                    | Description                                                                         | Value                                             |
| :---------------------- | :---------------------------------------------------------------------------------- | :------------------------------------------------ |
| `RUSTUP_HOME`           | Directory path that `rustup` uses as its "home" directory                           | `${containerWorkspaceFolder}/target/rustup_home`  |
| `CARGO_HOME`            | Directory path that `Cargo` uses as its "home" directory                            | `${containerWorkspaceFolder}/target/cargo_home`   |
| `CARGO_TARGET_DIR`      | Changes the `target/` directory that Cargo uses to place binaries & build artifacts | `${containerWorkspaceFolder}/target/cargo_target` |

### Additional Adjustments

1. Inside the container, `securityOpt` is set to `seccomp=unconfined`.
2. A new capability is added: `SYS_PTRACE` for proper debugging.
