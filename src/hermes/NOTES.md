## Enabling _hermes_ Inside Your Container

Add

```bash
[[ -f ${HOME}/.config/bash/90-hermes.sh ]] && source "${HOME}/.config/bash/90-hermes.sh"
```

to your Bash setup (e.g., `${HOME}/.bashrc`) to enable _hermes_. This could be archived by adding a `postCreateCommand` to your Development Container definition.
