Function ReloadEnv
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User");
}

Function InstallChocolatey
{
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
    ReloadEnv;
}

Function CheckAndInstallChoco
{
    $OldState = $ErrorActionPreference;
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command "choco") {
            "Chocolatey already installed. Nothing to do"
        }
    }
    catch {
        "Chocolatey is not installed!"
        InstallChocolatey;
    }
    finally {
        $ErrorActionPreference = $OldState;
    }
}

Function RunOpenVSCode
{
    # Install some packages
    "Installing packages. This will take some time...";
    choco install -y --no-progress nodejs --version=14.18.1;
    choco install -y --no-progress git visualstudio2019-workload-vctools python;
    ReloadEnv;

    # Set up the source code
    $DocumentsPath=[Environment]::GetFolderPath('MyDocuments');
    cd $DocumentsPath;
    if (Test-Path $DocumentsPath\openvscode-server) {
        "Source code already exists. Will skip cloning step..."
    }
    else {
        $env:GIT_REDIRECT_STDERR="2>&1";
        git clone https://github.com/daniel-wachira/openvscode-server.git;
    }
    
    # Prepare the product
    $env:CHILD_CONCURRENCY='1';
    cd openvscode-server;
    npm -g install yarn;
    yarn;
    yarn server:init;
    yarn gulp server-min;
    
    # Launch
    node out/server.js;
}

CheckAndInstallChoco;
RunOpenVSCode;
