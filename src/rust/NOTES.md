
## About

This Development Container Feature installs [Rust](https://www.rust-lang.org/) via [rustup](https://www.rust-lang.org/tools/install) and additional extensions required to work efficiently in Rust.

> [!TIP]
>
> #### Works Well With [`georglauterbach/dev-container-base`](https://github.com/georglauterbach/dev-container-base)
>
> This Development Container Feature works well with base images that focus on recent versions of Ubuntu, like [`ghcr.io/georglauterbach/dev-container-base:edge`](https://github.com/georglauterbach/dev-container-base/pkgs/container/dev-container-base).

### Supported Base / OS

This feature works on recent versions of Debian- and Ubuntu-based distributions (as this feature currently depends on the APT package manager). Bash is required. The package `build-essential` has to be installable.

### Debugger Support

#### rust-analyzer & CodeLLDB

This feature installs the excellent extensions [`rust-lang.rust-analyzer`](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer) (language server) and [`vadimcn.vscode-lldb`](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) (native LLDB debugger). rust-analyzer is, by default, configured to use CodeLLDB as its debugger of choice.

#### Niche Scenarios

In case you do not use a default toolchain and your Rust code (e.g., `Cargo.toml`) does not live directly in the root directory, you may want to create a symbol link to `rust-toolchain.toml` if you are using such a file. The reason is a [currently existing shortcoming in acquiring `rustc`'s sysroot](https://github.com/vadimcn/codelldb/issues/1156).

### Environment Variables Set by This Feature

| Name                    | Description                                                   | Value                              |
| :---------------------- | :------------------------------------------------------------ | :--------------------------------- |
| `RUSTUP_HOME`           | Directory path that `rustup` uses as its "home" directory     | `/usr/rust/rustup/`                      |
| `CARGO_HOME`            | Directory path that `Cargo` uses as its "home" directory      | `/usr/rust/cargo/home`                   |
| `CARGO_TARGET_DIR`      | Directory that Cargo uses to place binaries & build artifacts | `${containerWorkspaceFolder}/target` |
| `PATH`                  | Extend `PATH` to include `rustup`, `cargo`, `rustc`, etc.     | `/usr/rust/cargo/home/bin:${PATH}`       |

> [!TIP]
>
> In case you do not want to use Cargo's default target directory, overwrite [the environment variable `CARGO_TARGET_DIR`](https://doc.rust-lang.org/cargo/reference/environment-variables.html).
>
> We advise using a bind-mount or volume for this directory in case it is not a subdirectory of `${containerWorkspaceFolder}`.

### Additional Adjustments

1. Inside the container, `securityOpt` is set to `seccomp=unconfined`.
2. A new capability is added: `SYS_PTRACE` for proper debugging.
