param (
  # spigot, craftbukkit
  [string] $pipeline = 'craftbukkit',
  # * or <minecraft_build_revision,...> i.e. 1.13,1.16.1,1.20.6
  [string] $versions = '*',
  # compile / install
  [string] $cmd = 'compile'
)

$splitVersions = $versions -Split ","

function Build-Revisions {
  param (
    [Parameter(Mandatory = $true)] [string] $javaHome,
    [Parameter(Mandatory = $true)] [string] $revision
  )

  Write-Host "Checking $revision in $splitVersions"
  if (($versions -ne '*') -and ($revision -notin $splitVersions)) {
    Write-Host "$revision not found in revision filter, skipping..."
    Continue
  }

  $folder = ($javaHome -Split "\\")[-1]
  Write-Host "Compiling $pipeline for $revision on '$($folder)'"
  $revision -match "\d\.(\d{1,2})(?:\.\d+)?"

  if ($Matches[0] -ge 18) {
    & "$javaHome\bin\java.exe" -jar $PSScriptRoot\BuildTools.jar --remapped --compile=$pipeline --rev $revision
  } else {
    & "$javaHome\bin\java.exe" -jar $PSScriptRoot\BuildTools.jar --compile=$pipeline --rev $revision
  }

  if ($LASTEXITCODE -ne 0) {
    Write-Host "Error occurred for $revision on $folder using $pipeline"
    exit $LASTEXITCODE
  }
}

function Deploy-Revisions {
  param (
    [Parameter(Mandatory=$true)] [string[]] $revisions
  )

  foreach ($rev in $revisions) {
    $pipelineVersion = "$pipeline-$rev.jar"

    mvn install:install-file -Dfile="$PSScriptRoot\$pipelineVersion" -DgroupId="org.spigotmc" -DartifactId="spigot" -Dversion="$rev-R0.1-SNAPSHOT" -Dpackaging="jar"
  }
}

$runtimes = @(
  [PSCustomObject] @{
    Revisions = @(
      '1.8', '1.8.3', '1.8.8', '1.9.2', '1.9.4', '1.10.2', '1.11.2', '1.12.2',
      '1.13', '1.13.2', '1.14.4', '1.15.2', '1.16.1', '1.16.3', '1.16.5'
    );
    Binary    = $env:JAVA_8_HOME
  },
  [PSCustomObject] @{
    Revisions = @('1.17');
    Binary = $env:JAVA_16_HOME
  }
  [PSCustomObject] @{
    Revisions = @('1.18.1', '1.18.2', '1.19', '1.19.3', '1.20.1', '1.20.2', '1.20.4');
    Binary    = $env:JAVA_17_HOME
  },
  [PSCustomObject] @{
    Revisions = @('1.20.6');
    Binary    = $env:JAVA_21_HOME
  }
)

function Invoke-Build {
  foreach ($runtime in $runtimes) {
    foreach ($revision in $runtime.Revisions) {
      Build-Revisions -javaHome $runtime.Binary -revision $revision
    }
  }
}

function Invoke-Deploy {
  $revisions = Foreach-Object -InputObject $runtimes -Process { $_.Revisions } |
    Where-Object { Test-Path "$PSScriptRoot/$pipeline-$_.jar" }

  if ($versions -ne '*') {
    $revisions = $revisions | Where-Object { $splitVersions -Contains $_ }
  }

  if ($revisions.Count -eq 0) {
    Write-Host "No revisions available to install/deploy."
    Exit 1
  }

  Deploy-Revisions -Revisions $revisions
}

switch ($cmd) {
  { @('c', 'compile', 'b', 'build') -contains $_ } { Invoke-Build }
  { @('i', 'install', 'd', 'deploy') -contains $_ } { Invoke-Deploy }
  default {
    Write-Host "Please use either '(c)ompile/(b)uild' or '(i)nstall/(d)eploy' as `$cmd"
    Exit 0
  }
}
