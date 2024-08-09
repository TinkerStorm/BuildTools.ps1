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
    [Parameter(Mandatory = $true)] [string[]] $revisions
  )

  foreach ($rev in $revisions) {
    if ($versions -ne '*' -and $versions -notcontains $rev) {
      Write-Host "$rev not found in revision filter, skipping..."
      Continue
    }

    $folder = ($javaHome -Split "\\")[-1]
    Write-Host "Compiling $pipeline for $rev on '$($folder)'"

    & "$javaHome\bin\java.exe" -jar $PSScriptRoot/BuildTools.jar --remapped --compile=$pipeline --rev $rev

    if ($LASTEXITCODE -ne 0) {
      Write-Host "Error occurred for $revision on $folder using $pipeline"
      exit $LASTEXITCODE
    }
  }
}

function Deploy-Revisions {
  param (
    [Parameter(Mandatory=$true)] [string[]] $revisions
  )

  foreach ($rev in $revisions) {
    $pipelineVersion = "$\$pipeline-$rev.jar"

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
    Revisions = @('1.18.1', '1.18.2', '1.19', '1.19.3', '1.20.2');
    Binary    = $env:JAVA_17_HOME
  },
  [PSCustomObject] @{
    Revisions = @('1.20.6');
    Binary    = $env:JAVA_21_HOME
  }
)

function Invoke-Build {
  foreach ($runtime in $runtimes) {
    if ($runtime.Revisions.Count -eq 0) {
      Write-Host "No revisions to build on $($runtime.Label), skipping..."
      continue
    }

    foreach ($revision in $runtime.Revisions) {
      Build-Revisions -javaHome $runtime.Binary -revisions $runtime.Revisions
    }
  }
}

function Invoke-Deploy {
  $revisions = Foreach-Object -InputObject $runtimes -Process { $_.Revisions }

  if ($versions -ne '*') {
    $revisions = $revisions | Where-Object { $splitVersions -NotContains $_ }
  }

  Deploy-Revisions -Revisions $revisions
}

switch ($cmd) {
  { @('c', 'compile', 'b', 'build') } { Invoke-Build }
  { @('i', 'install', 'd', 'deploy') } { Invoke-Deploy }
  default {
    Write-Host "Please use either '(c)ompile/(b)uild' or '(i)nstall/(d)eploy' as `$cmd"
    exit 0
  }
}
