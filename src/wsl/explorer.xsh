#!/usr/bin/env xonsh
"""
It is a simple alias to open the Windows Explorer from WSL.
Supports passing paths as arguments
(regardless of whether they are WSL or Windows paths as long as it is quoted so that the path is in single args).
"""

def __aliases_explorer__(argv,stdin=None):
    import subprocess
    if(len(argv) == 0):
        subprocess.run(["/mnt/c/WINDOWS/explorer.exe", $(wslpath -w $PWD).strip()])
    else:
        subprocess.run(["/mnt/c/WINDOWS/explorer.exe"]+[$(wslpath -w @(i)) if i.startswith("/") else i for i in argv])
aliases["explorer"]=__aliases_explorer__