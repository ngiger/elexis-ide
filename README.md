# Using OOMPH via console

This is a test for https://github.com/a-langer/eclipse-oomph-console to see, whether we can generate
a fully automated setup via the console analog to https://github.com/elexis/elexis-3-core/blob/master/ch.elexis.sdk/Elexis.setup

# Differences to the Elexis.setup from elexis-3-core 

* The following features were added
  * RCPTT: https://www.eclipse.org/rcptt/
  * egit (I got once an error that it is needed. Not sure about it)
  * liclipsetext: https://www.liclipse.com/text/
* The URL for the git clone must be inserted manually
* nix uses easily many GB of HD under /nix. If your root partition is small,
  replace /nix by logical link to another directory
  
# Howto develop using devenv.sh

I migrated this small project to [devenv](https://devenv.sh/) to get a reliable environment
under NixOS and Debian (bullseye). To use it.

* Install [direnv](https://direnv.net/) for your OS
* `git clone git@github.com:ngiger/elexis-ide.git`
* `cd elexis-ide`
* `direnv allow` # see .envrc for details
* `devenv shell` # Downloads over 2 GB of code as instructed via devenv.nix and devenv.yaml
* Have look at `setup_elexis.sh` to override the paths you do not like

Nota bene: The existing [Elexis.setup](https://github.com/elexis/elexis-3-core/blob/master/ch.elexis.sdk/Elexis.setup)
was split into the two files [products.setup](./blob/main/elexis/products.setup) and
[projects.setup](./blob/main/elexis/projects.setup).

# Now the real task should be easy

* call `./setup_elexis.sh`. The first time it takes some time to download,
  the second time it is quite fast (approx. 30 seconds in my case).
* This will build an Eclipse ID
  At the end it will say something like `run it via: /opt/ide/elexis-2022-12/eclipse/eclipse -data /opt/workspaces/elexis-2022-12 -clean`
* call this script
* Select menu File..Import, select Oomph..Project from Catalog, then press Next.
  Select the projects under "Elexis Projekte" you want to install.
  Add manully the paths to the project git@github.com:elexis/elexis-3-core.git
  (I found no way howto pass this via system properties to oomph)
* Nota bene: The values are stored under rm `~/.eclipse/org.eclipse.oomph.setup/setups/user.setup`

Tested under Debian bullseye and NixOS 22.11
* The generate eclipse `/opt/ide/elexis-2022-12/eclipse` is small (32M), as most code is stored under $HOME/.eclipse

