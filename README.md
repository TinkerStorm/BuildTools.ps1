# BuildTools.ps1

A bulk compile script to build all specified revisions of spigot / craftbukkit for multi-version plugin development.

Originally created by Mackan, and modified to work on Slabbo.

`$runtimes` contains configuration presets for compiling each revision on their respective java binary. These binaries are assumed to be placed in `JAVA_{v}_HOME`, but can be provided as strings in the script as needed.

## Arguments

- `-cmd` = `"compile"`
  - `(c)ompile / (b)uild` - Build all specified revisions
  - `(d)eploy / (i)nstall` - Install all specified revisions to maven
- `-versions` = `"*"` (CSV)
  - filter to specific revisions, use `*` for all (default)
  - i.e. `1.10,1.18.1,1.20.2,1.21`
- `-pipeline` = `"craftbukkit"`

## Examples

```ps1
.\BuildTools.ps1 -cmd compile -pipeline craftbukkit -versions '1.8'
```

