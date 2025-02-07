
# Development Container Feature - Rust (rust)

A Development Container Feature to work efficiently and effortlessly with the Rust programming language

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/rust:5": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| rust.install | In environments where Rust is already installed, set this to false to not install Rust (again) | boolean | true |
| rust.rustup.default-toolchain | Defines the [toolchain](https://rust-lang.github.io/rustup/concepts/toolchains.html) that will be installed via `rustup` | string | none |
| rust.rustup.default-toolchain-file | Defines the [toolchain file](https://rust-lang.github.io/rustup/overrides.html#the-toolchain-file) that contains extra information about the toolchain. This path **must** be relative to the base of the repository. This is useful to set a default (global) toolchain when 'rust.rustup.default-toolchain' is not used, but a 'rust-toolchain.toml' exists. | string | - |
| rust.rustup.update-default-toolchain | Whether or not to update the default toolchain | boolean | false |
| rust.rustup.profile | Defines the [profile](https://rust-lang.github.io/rustup/concepts/profiles.html) that will be used by `rustup` during the installation | string | minimal |
| rust.rustup.additional-targets | A list of [additional targets](https://rust-lang.github.io/rustup/cross-compilation.html) that will be installed by `rustup` | string | - |
| rust.rustup.additional-components | A list of [additional components](https://rust-lang.github.io/rustup/concepts/components.html) that ill be installed by `rustup` (ref: [release-component-target-matrix](https://rust-lang.github.io/rustup-components-history/)) | string | - |
| rust.rustup.dist-server | The URI for downloading static resources related to Rust ([ref](https://rust-lang.github.io/rustup/environment-variables.html)) | string | https://static.rust-lang.org |
| rust.rustup.update-root | The URI for downloading self-update ([ref](https://rust-lang.github.io/rustup/environment-variables.html)) | string | https://static.rust-lang.org/rustup |
| rust.rustup.rustup-init.host-triple | The [host triple](https://wiki.osdev.org/Target_Triplet) (including the architecture) of the system that you want to bootstrap Rust on | string | - |
| system.packages.additional-packages | A list of additional packages to install via the system's package manager | string | - |
| linker.mold.install | Whether to install the linker [`mold`](https://github.com/rui314/mold) | boolean | false |
| linker.mold.version | The version of the [`mold`](https://github.com/rui314/mold) linker to install | string | 2.36.0 |
| proxy.http.http.address | A URI for an HTTP proxy | string | - |
| proxy.http.https.address | A URI for an HTTPS proxy | string | - |
| proxy.http.no-proxy.address | A list of URIs to not proxy | string | localhost,127.0.0.1 |

## Customizations

### VS Code Extensions

- `editorconfig.editorconfig@0.16.7`
- `rust-lang.rust-analyzer`
- `tamasfe.even-better-toml@0.21.2`
- `usernamehw.errorlens@3.23.0`
- `vadimcn.vscode-lldb@1.11.3`

## About

This Development Container Feature installs [Rust](https://www.rust-lang.org/) via [rustup](https://www.rust-lang.org/tools/install) and additional extensions required to work efficiently with Rust.

> [!TIP]
>
> #### Works Well With [`georglauterbach/dev-container-base`](https://github.com/georglauterbach/dev-container-base)
>
> This Development Container Feature works well with base images that focus on recent versions of Ubuntu, like [`ghcr.io/georglauterbach/dev-container-base:edge`](https://github.com/georglauterbach/dev-container-base/pkgs/container/dev-container-base).

### Environment Variables Set by This Feature

| Name                    | Description                                                   | Value                                | Needs Overwrite |
| :---------------------- | :------------------------------------------------------------ | :----------------------------------- | :-------------- |
| `RUSTUP_HOME`           | Directory path that `rustup` uses as its "home" directory     | `/usr/rust/rustup`                   | Yes             |
| `CARGO_HOME`            | Directory path that `Cargo` uses as its "home" directory      | `/usr/rust/cargo/home`               | Yes             |
| `CARGO_TARGET_DIR`      | Directory that Cargo uses to place binaries & build artifacts | `${containerWorkspaceFolder}/target` | No              |
| `PATH`                  | Extend `PATH` to include `rustup`, `cargo`, `rustc`, etc.     | `/usr/rust/cargo/home/bin:${PATH}`   | No              |

> [!IMPORTANT]
>
> You may want to overwrite or extend the set of predefined environment variables above. Those marked with  `Yes` in the "Needs Overwrite" column should definitely be overwritten in `containerEnv`. The new values should be locations that are persisted across container restarts. You most likely want to overwrite these variables when you work with different toolchains at the same time and having them side-by-side is desired.
>
> You should define these variables in `containerEnv` in your `devcontainer.json` file. Good defaults are: `RUSTUP_HOME: "${containerWorkspaceFolder}/.rust/rustup_home"` and `"CARGO_HOME": "${containerWorkspaceFolder}/.rust/cargo_home"`.
>
> If you want to extend `PATH` to the new `CARGO_HOME`, add `"PATH": "${containerEnv:CARGO_HOME}/bin:${containerEnv:PATH}"` to `remoteEnv`.

> [!NOTE]
>
> You will not see the `.rust/` directory in your explorer in VS Code as this feature provides default settings that hide this directory.

### Additional Adjustments

1. Inside the container, `securityOpt` is set to `seccomp=unconfined`.
2. A new capability is added: `SYS_PTRACE` for proper debugging.

### Supported Base / OS

Currently, this feature works on recent versions of Debian- and Ubuntu-based distributions. It may be extended to other Linux distributions too, requiring only to add the new distribution to a matcher and extending the package management steps. Bash is required in all cases.

### Debugger Support

#### rust-analyzer & CodeLLDB

This feature installs the excellent extensions [`rust-lang.rust-analyzer`](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer) (language server) and [`vadimcn.vscode-lldb`](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) (native LLDB debugger). [Rust-analyzer](https://github.com/rust-lang/rust-analyzer) is, by default, configured to use [CodeLLDB](https://github.com/vadimcn/codelldb) as its debugger of choice.

#### Niche Scenarios

In case

1. you do not set a default toolchain (the default with this feature is `none`), and
2. your Rust's root directory (e.g., the directory that contains `Cargo.toml`) is not the root directory that you open with VS Code,

you may want to create a symbolic link to [`rust-toolchain.toml`](https://rust-lang.github.io/rustup/overrides.html#the-toolchain-file), if you are using such a file (which is advised). [Such a configuration is classified as a niche scenario by CodeLLDB](https://github.com/vadimcn/codelldb/issues/1156), and you may experience unformatted variables in the debugger.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/rust/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
