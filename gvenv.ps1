param(
    [Parameter(Position=0)]
    [ValidateSet("cr", "act", "ls", "updn")]
    [string]$Command,
	
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$RemainingArgs
)


if (($Command -eq "cr") -or ($Command -eq "act") -or ($Command -eq "updn")){
	if ($RemainingArgs.Count -eq 0) {
        $Host.UI.WriteErrorLine("Please provide the environment name.`nUsage: gvenv.ps1 $Command <env_name>")
        exit 1
    } elseif ($RemainingArgs.Count -gt 1){
		$Host.UI.WriteErrorLine("$Command only takes a single argument (environt name).`nUsage: gvenv.ps1 $Command <env_name>")
		exit 1
	}
	else {
		$EnvName = $RemainingArgs[0]
	}
}


# Resolve GVENV_DIR
$GVENV_DIR = $Env:GVENV_DIR
if (-not $GVENV_DIR) {
    $GVENV_DIR = Join-Path $HOME ".gvenv"
}
if (-not (Test-Path $GVENV_DIR)) {
    Write-Host "Creating virtual environment directory at $GVENV_DIR"
    New-Item -ItemType Directory -Path $GVENV_DIR | Out-Null
}


# function to check if uv exists
function Ensure-uv {
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        $Host.UI.WriteErrorLine("'uv' is not installed or not in PATH. Please install uv first.")
        exit 1
    }
}


function Activate-Env {
	$envPath = Join-Path $GVENV_DIR $EnvName
        if (-not (Test-Path $envPath)) {
            $Host.UI.WriteErrorLine("Environment '$EnvName' does not exist at $envPath.`nRun 'gvenv.ps1 ls' to list available environments.")
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
		Ensure-uv
		
		$envPath = Join-Path $GVENV_DIR $EnvName
        if (Test-Path $envPath) {
			$Host.UI.WriteErrorLine("Environment '$EnvName' already exists at $envPath.`nUse 'gvenv.ps1 act $EnvName' to activate it.`nIf you want to overwrite, delete the existing environment first (proceed with caution).")
            exit 1
        }

        Write-Host "Creating uv venv '$EnvName' at $GVENV_DIR"
        uv venv $EnvName --directory $GVENV_DIR
    }


    "act" {
        Activate-Env
    }


    "ls" {
        Write-Host "Available environments in ${GVENV_DIR}:"
        Get-ChildItem $GVENV_DIR -Directory | ForEach-Object {
            Write-Host $_.Name
        }
    }


	"updn" {
		Ensure-uv
		Activate-Env
		
		$reqpath = Join-Path $GVENV_DIR ("." + $EnvName + "_newest.txt")
		uv pip freeze > $reqpath
		(Get-Content $reqpath) -replace '(==.*)','' | Set-Content $reqpath
		uv pip install -U -r $reqpath

		deactivate
	}


    Default {
        Write-Host @"
gvenv.ps1 - Manage uv virtual environments

Usage:
    gvenv.ps1 cr <env_name>          Create a uv venv
    gvenv.ps1 act <env_name>         Activate a uv venv
    gvenv.ps1 updn <env_name>        Upgrade all packages in the venv to their latest versions
    gvenv.ps1 ls                     List all venvs created with gvenv

Environment variable:
    GVENV_DIR - Directory to store environments (defaults to ~\.gvenv)

"@
        Ensure-uv
    }
}
