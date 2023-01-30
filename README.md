# Using OOMPH via console

This is a test for [eclipse-oomph-console](https://github.com/a-langer/eclipse-oomph-console) to see, whether we can generate
a fully automated setup via the console analog to [Elexis.setup](https://github.com/elexis/elexis-3-core/blob/master/ch.elexis.sdk/Elexis.setup)

# Differences to the Elexis.setup from elexis-3-core 

* The following features were added
  * [RCPTT](https://www.eclipse.org/rcptt/)
  * egit (I got once an error that it is needed. Not sure about it)
  * [liclipsetext](https://www.liclipse.com/text/) for ruby scripts
* The URL for the git clone are set to https://github.com/elexis/


As long as the eclipse-oomph-console does not support a workaround for the inducedChoices (which define the
checkout for the 3 elexis-repositories, I prefer to use the normal eclipse-oomp installer. But to work
under NixOS this project is handy to be able to install RCPTT and an Eclipse RCP/RAP with all features
needed to develop for Elexis.
  
# Howto use setup_elexis.sh

* Have look at `setup_elexis.sh` to override the paths you do not like

Nota bene: The existing [Elexis.setup](https://github.com/elexis/elexis-3-core/blob/master/ch.elexis.sdk/Elexis.setup)
was split into the two files [products.setup](./blob/main/elexis/products.setup) and
[projects.setup](./blob/main/elexis/projects.setup).

## Running

* call `./setup_elexis.sh`. The first time it takes some time to download,
  the second time it is quite fast (approx. 30 seconds in my case).
* This will build an Eclipse ID
  At the end it will say something like `run it via: /opt/ide/elexis-2022-12/eclipse/eclipse -data /opt/workspaces/elexis-2022-12 -clean`
* call this script
* Select menu File..Import, select Oomph..Project from Catalog, then press Next.
  Select the projects under **Elexis Projekte** you want to install.
  I usually deactive the first Manual Taks **P2 Director** as it will try to update all (already installed) features
* Nota bene: The values for oomph are stored under `~/.eclipse/org.eclipse.oomph.setup/setups/user.setup`

Tested under Debian bullseye and NixOS 22.11
* The generate eclipse `/opt/ide/elexis-2022-12/eclipse` is small (32M), as most code is stored under `$HOME/.eclipse`

# NixOS: added flakes for RCPTT and Elexis-IDE

This project defines two derivations elexis-ide and rcppt. Install them using flake like this

* `nix profile install github:ngiger/elexis-ide --impure` # default is elexis-ide
* `nix profile install github:ngiger/elexis-ide#rcptt` # installs RCPTT
