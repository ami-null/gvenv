# uvenv
Wrapper script to create global venv (like conda) using uv.

uv relies on project specific environements. However, I like to use the same environement for multiple projects. Conda/mamba etc are not as fast as uv. Which is why I created this project - the best of both worlds. However, there is one caveat in the current implementation: one has to manage the `requirements` file of an environement manually, as opposed to how `uv` manages dependencies automatically for projects managed by `uv`. This shall change in a future implementation.

You need to have python and uv installed for this script to work.

## Roadmap
- Port to bash
- Add a command `uvenv install` that wraps `uv pip install` so that the the package list and version constraints can be captured and put into a requirements file.

## Installation

Download the `.ps1` file and place it in a directory that's available in PATH.

## Usage:

```
uvenv.ps1 cr <env_name>                    Create a uv venv
uvenv.ps1 act <env_name>                   Activate a uv venv
uvenv.ps1 upd <env_name> --newest          Upgrade all packages in the venv to their latest versions
uvenv.ps1 upd <env_name> --req <req_file>  Upgrade packages in the venv based on the given requirements file
uvenv.ps1 ls                               List all uv venvs

Environment variable:
    UVENV_DIR - Directory to store environments (defaults to ~\.uvenv)
```
