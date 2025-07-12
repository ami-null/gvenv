param(
    [Parameter(Position=0)]
    [ValidateSet("cr", "act", "ls", "upd")]
    [string]$Command,

    [Parameter(Position=1)]
    [string]$EnvName
)

# Resolve UVENV_DIR
$UVENV_DIR = $Env:UVENV_DIR
if (-not $UVENV_DIR) {
    $UVENV_DIR = Join-Path $HOME ".uvenv"
}
if (-not (Test-Path $UVENV_DIR)) {
    Write-Host "Creating virtual environment directory at $UVENV_DIR"
    New-Item -ItemType Directory -Path $UVENV_DIR | Out-Null
}

# Check uv exists for cr command
function Ensure-uv {
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        $Host.UI.WriteErrorLine("'uv' is not installed or not in PATH. Please install uv first.")
        exit 1
    }
}

function Activate-Env {
	if (-not $EnvName) {
            $Host.UI.WriteErrorLine("Please provide an environment name. Usage: uvenv.ps1 act <env_name>")
            exit 1
        }

        $envPath = Join-Path $UVENV_DIR $EnvName
        if (-not (Test-Path $envPath)) {
            $Host.UI.WriteErrorLine("Environment '$EnvName' does not exist at $envPath.`nRun 'uvenv.ps1 ls' to list available environments.")
            exit 1
        }

        $activateScript = Join-Path $envPath "Scripts\Activate.ps1"
        if (-not (Test-Path $activateScript)) {
            $Host.UI.WriteErrorLine("Activation script not found at $activateScript")
            exit 1
        }

        Write-Host "Activating environment '$EnvName'"
        & $activateScript
}


# Handle commands
switch ($Command) {
    "cr" {
        if (-not $EnvName) {
			$Host.UI.WriteErrorLine("Please provide an environment name. Usage: uvenv.ps1 cr <env_name>")
            exit 1
        }

        $envPath = Join-Path $UVENV_DIR $EnvName
        if (Test-Path $envPath) {
			$Host.UI.WriteErrorLine("Environment '$EnvName' already exists at $envPath.`nUse 'uvenv.ps1 act $EnvName' to activate it.`nIf you want to overwrite, delete the existing environment first (proceed with caution).")
            exit 1
        }
		
		Ensure-uv

        Write-Host "Creating uv venv '$EnvName' at $UVENV_DIR"
        uv venv $EnvName --directory $UVENV_DIR
    }

    "act" {
        Activate-Env
    }

    "ls" {
        Write-Host "Available environments in ${UVENV_DIR}:"
        Get-ChildItem $UVENV_DIR -Directory | ForEach-Object {
            Write-Host $_.Name
        }
    }
	
	"upd" {
		Ensure-uv
		Activate-Env
		$reqpath = Join-Path $UVENV_DIR ("." + $EnvName + ".txt")
		uv pip freeze > $reqpath
		(Get-Content $reqpath) -replace '(==.*)','' | Set-Content $reqpath
		uv pip install -U -r $reqpath
		deactivate
	}

    Default {
        Write-Host @"
uvenv.ps1 - Manage uv virtual environments

Usage:
    uvenv.ps1 cr <env_name>   Create a uv venv
    uvenv.ps1 act <env_name>  Activate a uv venv
    uvenv.ps1 upd <env_name>  Upgrade packages in the ven to their latest versions
    uvenv.ps1 ls              List all uv venvs

Environment variable:
    UVENV_DIR - Directory to store environments (defaults to ~\.uvenv)

"@
        Ensure-uv
    }
}
