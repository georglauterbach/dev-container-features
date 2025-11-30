## Notes

### Extensions

| Areas                 | Extension                                                                                                  |
| :-------------------- | :--------------------------------------------------------------------------------------------------------- |
| Rust Language Server  | [`rust-lang.rust-analyzer`](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)   |
| TOML Language Support | [`tamasfe.even-better-toml`](https://marketplace.visualstudio.com/items?itemName=tamasfe.even-better-toml) |
| Debugger              | [`vadimcn.vscode-lldb`](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)           |

### Debugger

`rust-analyzer` is configured to use `vadimcn.vscode-lldb` as its debugger.

#### Pretty Printing

To enable pretty printing in the debugger, add the setting

```jsonc
"lldb.launch.preRunCommands": [
  "command script import ${containerEnv:DEV_CONTAINER_FEATURE_GHCR_IO_GEORGLAUTERBACH_LANG_RUST_LLDB_PRETTIFIER}"
]
```

to the `devcontainer.json`'s IDE-specific settings (example shown is for VS Code). The symbol definitions are copied from [`cmrschwarz/rust-prettifier-for-lldb`](https://github.com/cmrschwarz/rust-prettifier-for-lldb).

### Using a Subdirectory for Your Rust Code

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
