= Rust Development Container Feature
:toc: auto
:source-highlighter: highlightjs

[NOTE]
.What is a Development Container Feature?
====
According to the https://containers.dev/implementors/features/[official documentation], Development Container Features are "are self-contained, shareable units of installation code and development container configuration. The name comes from the idea that referencing one of them allows you to quickly and easily add more tooling, runtime, or library “features” into your development container for you or your collaborators to use."
====

== About

This Development Container Feature installs https://www.rust-lang.org/[Rust] via https://www.rust-lang.org/tools/install[rustup] and additional extensions required to work efficiently in Rust.

This Feature is installed after `ghcr.io/devcontainers/features/common-utils`.

[TIP]
.Works Well With https://github.com/georglauterbach/dev-container-base[`georglauterbach/dev-container-base`]
====
This Development Container Feature works well with base images that focus on recent versions of Ubuntu, like https://github.com/georglauterbach/dev-container-base/pkgs/container/dev-container-base[`ghcr.io/georglauterbach/dev-container-base:edge`].
====

== Supported Base / OS

This Feature should work on recent versions of Debian- and Ubuntu-based distributions. This Feature depends on the APT package manager. Bash is required.

== Options

The following variables are added to / used inside the container.

[cols="2,3,1,3"]
|===
| Option ID | Description | Type | Default Value

| `rustup-default-toolchain`
| The default toolchain to install (Rust version)
| `string`
| `none`

| `rustup-update-default-toolchain`
| Whether to update the default toolchain
| `bool`
| `false`

| `rustup-profile`
| Which profile `rustup` should use for the installation
| `string`
| `minimal`

| `additional-targets`
| List of additional targets to install
| `string` (comma-separated list)
| `""`

| `additional-components`
| List of additional components to install (rustfmt, clippy, etc.)
| `string` (comma-separated list)
| `""`

| `install-mold`
| Whether to install the https://github.com/rui314/mold[`mold` linker]
| `bool`
| `false`

|===

== Environment Variables Set by This Feature

[cols="2,5,3"]
|===
| Name | Description | Value

| `RUSTUP_HOME`
| Directory path that `rustup` uses as its "home" directory
| `/usr/local/.dev_container_feature_rust/rustup_home`

| `CARGO_HOME`
| Directory path that `Cargo` uses as its "home" directory
| `/usr/local/.dev_container_feature_rust/cargo_home`

| `CARGO_TARGET_DIR`
| Changes the `target/` directory that Cargo uses to place binaries and build artifacts
| `/usr/local/.dev_container_feature_rust/target`

| `__RUSTUP_HOME_INSTALL`
| Directory path that `rustup` uses as its "home" directory during installation
| `/usr/local/bin/rustup`

| `__CARGO_HOME_INSTALL`
| Directory path that `Cargo` uses as its "home" directory during installation
| `/usr/local/bin/rustup`
|===

[TIP]
====
You should use a volume or a bind-mount for `/usr/local/.dev_container_feature_rust` to to cache the contained files.
====

== Adjustments

=== https://code.visualstudio.com/[Visual Studio Code]

==== Extensions

. https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer[`rust-lang.rust-analyzer`]
. https://marketplace.visualstudio.com/items?itemName=serayuzgur.crates[`serayuzgur.crates`]
. https://marketplace.visualstudio.com/items?itemName=tamasfe.even-better-toml[`tamasfe.even-better-toml`]
. https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb[`vadimcn.vscode-lldb`]

==== Settings

This feature does currently not modify VS Code settings.

== Additonal Adjustments

. Inside the container, `securityOpt` is set to `seccomp=unconfined`
. A new capability is added: `SYS_PTRACE` for proper debugging
