# README

[Claude Code Router](https://github.com/musistudio/claude-code-router) is a powerful tool to route [Claude Code](https://github.com/anthropics/claude-code) requests to different models and customize any request.

The `config.json` file contains sensitive API keys and should never be committed to version control. To ensure security, we use [git-crypt](https://github.com/AGWA/git-crypt) to automatically encrypt the configuration file.

## Usage

Install `claude-code` and `claude-code-router`
```sh
npm install -g @anthropic-ai/claude-code
npm install -g @musistudio/claude-code-router
```

Setup configuration link
```sh
mkdir -p ~/.claude-code-router
cd ~/.claude-code-router
ln -sf ~/.dotfiles/.claude-code-router/config.glm-4.5.json config.json
```
