# Using OOMPH via console

This is a test for https://github.com/a-langer/eclipse-oomph-console to see, whether we can generate
a fully automated setup via the console analog to https://github.com/elexis/elexis-3-core/blob/master/ch.elexis.sdk/Elexis.setup

# What works

* call `./setup_elexis.sh` in a checkout of the repository. This will build an Eclipse ID
  At the end it will say something like `run it via: /opt/ide/elexis-2022-12/eclipse/eclipse -data /opt/workspaces/elexis-2022-12 -clean`
* can be tested via `/opt/ide/elexis-2022-12/eclipse/eclipse -data /opt/workspaces/elexis-2022-12 -clean`

Tested under Debian bullseye and NixOS 22.11

# Problems

* The generate eclipse `/opt/ide/elexis-2022-12/eclipse` is small (32M), as most code is stored under $HOME/.eclipse
