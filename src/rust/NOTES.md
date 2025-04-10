## About

This Development Container Feature installs [Rust](https://www.rust-lang.org/) via [rustup](https://www.rust-lang.org/tools/install) and additional extensions required to work efficiently with Rust.

### Environment Variables Set by This Feature

| Name                    | Description                                                   | Value                                | Needs Overwrite |
| :---------------------- | :------------------------------------------------------------ | :----------------------------------- | :-------------- |
| `RUSTUP_HOME`           | Directory path that `rustup` uses as its "home" directory     | `/usr/rust/rustup`                   | Yes             |
| `CARGO_HOME`            | Directory path that `Cargo` uses as its "home" directory      | `/usr/rust/cargo/home`               | Yes             |
| `CARGO_TARGET_DIR`      | Directory that Cargo uses to place binaries & build artifacts | `${containerWorkspaceFolder}/target` | No              |
| `PATH`                  | Extend `PATH` to include `rustup`, `cargo`, `rustc`, etc.     | `/usr/rust/cargo/home/bin:${PATH}`   | No              |

> [!IMPORTANT]
>
> You **SHOULD** overwrite or extend the set of predefined environment variables above, especially those marked with  `Yes` in the "Needs Overwrite" column. The new values should be locations that are persisted across container restarts. You most likely want to overwrite these variables when you work with different toolchains at the same time and having them side-by-side is desired.
>
> ---
>
> You should define these variables in `containerEnv` in your `devcontainer.json` file. Good defaults are:
>
> - `RUSTUP_HOME: "${containerWorkspaceFolder}/.rust/rustup_home"`
> - `"CARGO_HOME": "${containerWorkspaceFolder}/.rust/cargo_home"`.
>
> You will not see the `.rust/` directory in your VS Code explorer as this feature provides default settings that hide this directory.
>
> ---
>
> If you want to extend `PATH` to the new `CARGO_HOME`, add
>
> - `"PATH": "${containerEnv:CARGO_HOME}/bin:${containerEnv:PATH}"`
>
> to `remoteEnv`.

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
