#!/usr/bin/env bash
# Copyright (c) 2023 by Niklaus Giger <niklaus.giger@member.fsf.org>
# run it via steam-run ./setup_elexis_ide.sh
set -o errexit
set -o pipefail
# set -o verbose
set -e

if test -f /etc/NIXOS; then
    SCRIPT=${BASH_SOURCE:-$0}
else
    SCRIPT=$(readlink -f "$0")i
fi
SCRIPTPATH=$(dirname "$SCRIPT")

# Adapt the following variables to your needs
# Each of them can be overridden by the environment variable of the same name
export INST_ROOT="${INST_ROOT:-/opt/ide/elexis-2025-03}"
export GIT_ROOT="${GIT_ROOT:-$INST_ROOT/git}"
export WORKSPACE="${WORKSPACE:-$INST_ROOT/workspace}"
export USER_HOME="${USER_HOME:-$HOME/}"
export P2_POOL="${P2_POOL:-$HOME/.eclipse}"
export SETUPS="${SETUPS:-${SCRIPTPATH}/elexis-ide/}"
export ELEXIS_INSTALLER="${ELEXIS_INSTALLER:-${SCRIPTPATH}/eclipse-installer/eclipse-inst}"

echo "Setup into ${ELEXIS_INSTALLER}. Workspace will be ${WORKSPACE} using setups from ${SETUPS}"
echo "Eclipse will be found under ${INST_ROOT}/elexis/eclipse, repos under ${GIT_ROOT}"

if [ "install" == "$1" ]; then
    echo "Passed install on the command line. (Re-)installing it"
    if test -d "$WORKSPACE"; then echo Removing workspace "$WORKSPACE"; rm -rf "$WORKSPACE"; fi
    if test -d "$INST_ROOT"; then echo Removing installed eclipse "$INST_ROOT/eclipse"; rm -rf "$INST_ROOT/eclipse"; fi
fi
if file -d "$INST_ROOT" ; then
  echo IDE not found, building it
else
    echo found "$INST_ROOT" INST_ROOT
    echo "running it via: ${INST_ROOT}/eclipse/eclipse -data $WORKSPACE -clean"
    "${INST_ROOT}/eclipse/eclipse" -data "$WORKSPACE" -clean
    exit 0
fi
# cache for downloaded jar is usually under ~/.eclipse. See https://www.eclipse.org/forums/index.php/t/681941/
#   -Doomph.installation.id="elexis" \

# Thanks for adapting the variables to you needs!

if  test -f "$ELEXIS_INSTALLER"; then
  echo "ELEXIS_INSTALLER found as $ELEXIS_INSTALLER"
else
  echo "NO ELEXIS_INSTALLER found as $ELEXIS_INSTALLER, fetching it"
  mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:unpack \
  -Dartifact=com.github.a-langer:org.eclipse.oomph.console.product:LATEST:tar.gz:linux.gtk.x86_64  \
  -DoutputDirectory=./ -Dproject.basedir=./
fi
$ELEXIS_INSTALLER -nosplash  -shared="$INST_ROOT/p2_shared"  -application org.eclipse.oomph.console.application -vmargs \
  -Doomph.redirection.setups="index:/->$SETUPS/" \
  -Doomph.installation.location="$INST_ROOT" \
  -Doomph.product.id="eclipse.ide4elexis" \
  -Doomph.project.id="elexis.ide" \
  -Doomph.workspace.location="$WORKSPACE" \
  -Dworkspace.location="$WORKSPACE" \
  -Dsetup.p2.agent="$P2_POOL" \
  -Duser.home="$USER_HOME" \
  -Doomph.setup.offline=false \
  -Dgit.container.root="$GIT_ROOT" \
  -Doomph.installer.verbose=true 2>&1 | tee "install-`date '+%Y-%m-%d-%H-%M'`.log"
IDE=$(find "$INST_ROOT" -type f -name eclipse)
echo "SETUPS were in $SETUPS IDE is $IDE"
echo "run it via: $IDE -data $WORKSPACE -clean"
"$IDE" -data "$WORKSPACE" -clean &
exit 0
