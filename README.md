# uvenv
Wrapper script to create global venv (like conda) using uv.

uv relies on project specific environements. However, I like to use the same environement for multiple projects. Conda/mamba etc are not as fast as uv. Which is why I created this project - the best of both worlds.

You need to have python and uv installed for this script to work.

## Installation

Download the `.ps1` file and place it in a directory that's available in PATH.

## Usage:

```
uvenv cr <env_name>   Create a uv venv
uvenv act <env_name>  Activate a uv venv
uvenv upd <env_name>  Upgrade packages in the ven to their latest versions
uvenv ls              List all uv venvs

Environment variable:
    UVENV_DIR - Directory to store environments (defaults to ~\.uvenv)
```
