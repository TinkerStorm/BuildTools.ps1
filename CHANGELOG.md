# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# [0.0.2] - 2024-08-09

# Fixed

- Check for revisions after filter with `-cmd install`, exit if none found.
- Use `Test-Path` to ensure requested files exist before attempting to install them with maven.

# [0.0.1] - 2024-08-09

Initial Release

# Added

- Build /compile with `./BuildTools.ps1 -cmd build ...`
- Deploy / install with `./BuildTools.ps1 -cmd deploy ...`
