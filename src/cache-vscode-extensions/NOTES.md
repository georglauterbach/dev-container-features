> [!NOTE]
>
> This extension is based upon [microsoft/vscode-remote-release#7690 (comment)](https://github.com/microsoft/vscode-remote-release/issues/7690#issuecomment-2761197753) by [@chrmarti](https://github.com/chrmarti).

## About

This extension properly links (with symbolic links) the `${HOME}/.vscode-server/extensions` (and the insiders versions, respectively) directory to a location onto which a volume is mounted. This persists extensions across container restarts because VS Code recognizes that the extensions directory is not empty.
