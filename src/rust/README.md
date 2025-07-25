
# Development Container Feature - Rust (rust)

Work efficiently and effortlessly with the Rust programming language

## Example Usage

```json
"features": {
    "ghcr.io/georglauterbach/dev-container-features/rust:7": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| rust.install | In environments where Rust is already installed, set this to false to not install Rust (again) | boolean | true |
| rust.install-base-packages | Install packages Rust required to work properly (like 'build-essential') | boolean | true |
| rust.rustup.default-toolchain | Defines the [toolchain](https://rust-lang.github.io/rustup/concepts/toolchains.html) that will be installed via `rustup` | string | none |
| rust.rustup.default-toolchain-file | Defines the [toolchain file](https://rust-lang.github.io/rustup/overrides.html#the-toolchain-file) that contains extra information about the toolchain. This path **must be absolute** and include the file name. This is useful to set a default (global) toolchain when 'rust.rustup.default-toolchain' is not used, but a 'rust-toolchain.toml' exists. | string | - |
| rust.rustup.update-default-toolchain | Whether or not to update the default toolchain | boolean | false |
| rust.rustup.profile | Defines the [profile](https://rust-lang.github.io/rustup/concepts/profiles.html) that will be used by `rustup` during the installation | string | minimal |
| rust.rustup.additional-targets | A list of [additional targets](https://rust-lang.github.io/rustup/cross-compilation.html) that will be installed by `rustup` | string | - |
| rust.rustup.additional-components | A list of [additional components](https://rust-lang.github.io/rustup/concepts/components.html) that ill be installed by `rustup` (ref: [release-component-target-matrix](https://rust-lang.github.io/rustup-components-history/)) | string | - |
| rust.rustup.dist-server | The URI for downloading static resources related to Rust ([ref](https://rust-lang.github.io/rustup/environment-variables.html)) | string | https://static.rust-lang.org |
| rust.rustup.update-root | The URI for downloading self-update ([ref](https://rust-lang.github.io/rustup/environment-variables.html)) | string | https://static.rust-lang.org/rustup |
| rust.rustup.rustup-init.host-triple | The [host triple](https://wiki.osdev.org/Target_Triplet) (including the architecture) of the system that you want to bootstrap Rust on | string | - |
| system.packages.additional-packages | A list of additional packages to install via the system's package manager. These packages are installed **prior** to Rust. | string | - |
| system.packages.package-manager.set-proxies | Whether to add the proxy to the package manager configuration, if proxies were supplied | boolean | false |
| linker.mold.install | Whether to install the linker [`mold`](https://github.com/rui314/mold) | boolean | false |
| linker.mold.version | The version of the [`mold`](https://github.com/rui314/mold) linker to install | string | 2.39.1 |
| download-acquire-insecure | Whether to download files without checking certificates | boolean | true |
| proxy.http.http.address | A URI for an HTTP proxy | string | - |
| proxy.http.https.address | A URI for an HTTPS proxy | string | - |
| proxy.http.no-proxy.address | A list of URIs to not proxy | string | localhost,127.0.0.1 |

## Customizations

### VS Code Extensions

- `rust-lang.rust-analyzer`
- `tamasfe.even-better-toml`
- `vadimcn.vscode-lldb@1.11.5`

## About

This Development Container Feature installs [Rust](https://www.rust-lang.org/) via [rustup](https://www.rust-lang.org/tools/install) and additional extensions required to work efficiently with Rust.

### Environment Variables Set by This Feature

| Name               | Description                                                   | Value                                                                            | Needs Overwrite |
| :----------------- | :------------------------------------------------------------ | :------------------------------------------------------------------------------- | :-------------- |
| `RUSTUP_HOME`      | Directory path that `rustup` uses as its "home" directory     | `/opt/devcontainer/features/ghcr_io/georglauterbach/rust/rustup/home`            | Yes             |
| `CARGO_HOME`       | Directory path that `Cargo` uses as its "home" directory      | `/opt/devcontainer/features/ghcr_io/georglauterbach/rust/cargo/home`             | Yes             |
| `CARGO_TARGET_DIR` | Directory that Cargo uses to place binaries & build artifacts | `${containerWorkspaceFolder}/target`                                             | No              |
| `PATH`             | Extend `PATH` to include `rustup`, `cargo`, `rustc`, etc.     | `/opt/devcontainer/features/ghcr_io/georglauterbach/rust/cargo/home/bin:${PATH}` | No              |
| `RUST_PRETTIFIER_FOR_LLDB_FILE` | Path to a LLDB prettifier file                   | `/opt/devcontainer/features/ghcr_io/georglauterbach/rust/prettifier_for_lldb.py` | No              |

> [!IMPORTANT]
>
> You **SHOULD** overwrite the predefined environment variables marked with  `Yes` in the "Needs Overwrite" column above. The new values should be locations that are persisted across container restarts.
>
> You should define these variables in `containerEnv` in your `devcontainer.json` file, e.g. like this:
>
> ```jsonc
>   "containerEnv": {
>     // you could mount a volume to `${containerWorkspaceFolder}/.rust`
>     "RUSTUP_HOME": "${containerWorkspaceFolder}/.rust/rustup/home",
>     "CARGO_HOME": "${containerWorkspaceFolder}/.rust/cargo/home"
>   }
> ```
>
> If you want to extend `PATH` to the new `CARGO_HOME`, do it like this:
>
> ```jsonc
>   "remoteEnv": {
>     "PATH": "${containerEnv:CARGO_HOME}/bin:${containerEnv:PATH}"
>   }
> ```

### Supported Base / OS

Currently, this feature works on recent versions of Debian- and Ubuntu-based distributions. It may be extended to other Linux distributions too, requiring only to add the new distribution to a matcher and extending the package management steps. Bash is required in all cases.

### Debugger Support

#### rust-analyzer & CodeLLDB

This feature installs the excellent extensions [`rust-lang.rust-analyzer`](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer) (language server) and [`vadimcn.vscode-lldb`](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) (native LLDB debugger). [rust-analyzer](https://github.com/rust-lang/rust-analyzer) is, by default, configured to use [CodeLLDB](https://github.com/vadimcn/codelldb) as its debugger of choice.

##### Proper Symbols

To enable proper symbols in the debugger, add the setting

```jsonc
"lldb.launch.preRunCommands": [
  "command script import ${containerEnv:RUST_PRETTIFIER_FOR_LLDB_FILE}"
]
```

to the `devcontainer.json`'s IDE-specific settings (example shown is for VS Code). The symbol definitions are copied from [`cmrschwarz/rust-prettifier-for-lldb`](https://github.com/cmrschwarz/rust-prettifier-for-lldb).

##### Using a Subdirectory

If your code lives in a separate directory that is not the repository root, set

```jsonc
"lldb.launch.cwd": "${containerWorkspaceFolder}/<SUBDIRECTORY OF YOUR CODE>",
"lldb.launch.relativePathBase": "${containerWorkspaceFolder}/<SUBDIRECTORY OF YOUR CODE>"
```

You should also create a symbolic link for a potential `rust-toolchain.toml` file via

```bash
ln -s "<SUBDIRECTORY OF YOUR CODE>/rust-toolchain.toml" 'rust-toolchain.toml'
```

This is currently required for the [`rust-lang.rust-analyzer`](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer) extension to work properly.

#### Niche Scenarios

In case

1. you do not set a default toolchain (the default with this feature is `none`), and
2. your Rust's root directory (e.g., the directory that contains `Cargo.toml`) is not the root directory that you open with VS Code,

you may want to create a symbolic link to [`rust-toolchain.toml`](https://rust-lang.github.io/rustup/overrides.html#the-toolchain-file), if you are using such a file (which is advised). [Such a configuration is classified as a niche scenario by CodeLLDB](https://github.com/vadimcn/codelldb/issues/1156), and you may experience unformatted variables in the debugger.

### Additional Adjustments

1. Inside the container, `securityOpt` is set to `seccomp=unconfined`.
2. A new capability is added: `SYS_PTRACE` for proper debugging.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/georglauterbach/dev-container-features/blob/main/src/rust/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
