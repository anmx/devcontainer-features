# Devcontainer Features

This repository contains a collection of Devcontainer Features.

## Features

### astro

Astro is a modern static site generator for building fast, content-driven websites.

#### Options

| Option                | Description                                                                                                                   | Default         |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `version`             | Version of astro to install from GitHub releases.                                                                             | `latest`        |
| `skipProjectCreation` | Skip automatic project creation (only install Astro CLI globally)                                                             | `true`          |
| `installGlobally`     | Install Astro CLI globally in addition to project creation                                                                    | `true`          |
| `project`             | The name of the Astro project folder to create. This is only used if project creation is not skipped.                           | `astro-project` |
| `template`            | The Astro project template to use. See https://github.com/withastro/astro/tree/main/examples for available templates.           | `basics`        |
| `integrations`        | A space separated list of Astro integrations to add to the project. See https://docs.astro.build/en/guides/integrations-guide/ | `""`            |

#### Usage

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/typescript-node:latest",
    "features": {
        "ghcr.io/anmx/devcontainer-features/astro:1": {}
    }
}
```

### just

`just` is a handy way to save and run project-specific commands.

#### Options

| Option               | Description                                                  | Default  |
| -------------------- | ------------------------------------------------------------ | -------- |
| `version`            | Version of just to install from GitHub releases. (E.g. 1.45.0) | `latest` |
| `installCompletions` | Install shell completions and man pages.                     | `false`  |

#### Usage

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/anmx/devcontainer-features/just:1": {}
    }
}
```
