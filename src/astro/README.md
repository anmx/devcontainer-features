
# astro (astro)

Astro is a modern static site generator for building fast, content-driven websites.

## Example Usage

```json
"features": {
    "ghcr.io/anmx/devcontainer-features/astro:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of astro to install from GitHub releases. | string | latest |
| skipProjectCreation | Skip automatic project creation (only install Astro CLI globally) | boolean | true |
| installGlobally | Install Astro CLI globally in addition to project creation | boolean | true |
| project | The name of the Astro project folder to create. This is only used if project creation is not skipped. | string | astro-project |
| template | The Astro project template to use. See https://github.com/withastro/astro/tree/main/examples for available templates. This is only used if project creation is not skipped. | string | basics |
| integrations | A space separated list of Astro integrations to add to the project. See https://docs.astro.build/en/guides/integrations-guide/ for integrations. This is only used if project creation is not skipped. | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/anmx/devcontainer-features/blob/main/src/astro/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
