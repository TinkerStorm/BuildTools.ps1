# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# [0.1.0] - 2024-08-14

# Added

- New branch for revisions before 1.18 (without `--remapped`)

# [0.0.4] - 2024-08-14

# Fixed

- Patch install target path

# [0.0.3] - 2024-08-09

# Fixed

- Use correct variable for version filter (`-notin` and `-notcontains` are the same)
- Check `$cmd` correctly on `switch`
- Patch repetitive looping on failed compile task

# [0.0.2] - 2024-08-09

# Fixed

- Check for revisions after filter with `-cmd install`, exit if none found.
- Use `Test-Path` to ensure requested files exist before attempting to install them with maven.

# [0.0.1] - 2024-08-09

Initial Release

# Added

- Build /compile with `./BuildTools.ps1 -cmd build ...`
- Deploy / install with `./BuildTools.ps1 -cmd deploy ...`
