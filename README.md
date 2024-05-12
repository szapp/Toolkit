# Ninja-specific scripts

This repository ties together [Ninja](https://github.com/szapp/Ninja)-specific versions of [LeGo](https://github.com/Lehona/LeGo) and [Ikarus](https://github.com/Lehona/Ikarus) to create the necessary file for Ninja.

## Instructions

### GitHub workflow

Use the GitHub workflow to create the ready to use file.
The file can then be downloaded from the artifacts of the workflow run.

### Local

Alternatively, for local creation, follow these steps.

1. Create a file in the root directory of the repository name `outpath.txt`.
This file is by default listed in the .gitignore.
In this file write the absolute or relative path to the sub-directory `\src\inc\` of the local clone of the Ninja repository.

2. Enable execution of Powershell scripts (ps1) -- one time only

3. Add the GothicVDFS to the PATH environment variable -- one time only

3. Execute `build.ps1` and mind the working directory and find the file `IKLG.DATA` with correct VDFS timestamp in the directory specified in `outpath.txt`.
