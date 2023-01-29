#!/usr/bin/env bash
# Copyright (c) 2023 by Niklaus Giger <niklaus.giger@member.fsf.org>
set -o errexit
set -o pipefail
set -o verbose
set -e

SCRIPT=$(readlink -f $0)i
SCRIPTPATH=`dirname $SCRIPT`

# Adapt the following variables to your needs
# Each of them can be overridden by the environment variable of the same name
export ECLIPSE_TRAIN="${ECLIPSE_TRAIN:-2022-09}"
export INST_ROOT="${INST_ROOT:-/opt/ide/elexis-$ECLIPSE_TRAIN}"
export USER_HOME="${USER_HOME:-$HOME/}"
export WORKSPACE="${WORKSPACE:-/opt/workspaces/elexis-$ECLIPSE_TRAIN}"
export P2_POOL="${P2_POOL:-$HOME/.eclipse}"
export SETUPS="${SETUPS:-${SCRIPTPATH}/elexis/}"
export ELEXIS_INSTALLER="${ELEXIS_INSTALLER:-${SCRIPTPATH}/eclipse-installer/eclipse-inst}"

echo "Setup into ${ELEXIS_INSTALLER}. Workspace will be ${WORKSPACE} using setups from ${SETUPS}"
echo "Eclipse will be found under ${INST_ROOT}/elexis/eclipse"
echo run it via: ${INST_ROOT}/eclipse/eclipse -data $WORKSPACE -clean

# cache for downloaded jar is usually under ~/.eclipse. Changed to "$INST_ROOT/p2_pool" as suggested by default https://www.eclipse.org/forums/index.php/t/681941/
#   -Doomph.installation.id="elexis" \

# Thanks for adapting the variables to you needs!

if  test -f $ELEXIS_INSTALLER; then
  echo ELEXIS_INSTALLER found as $ELEXIS_INSTALLER
else
  echo NO ELEXIS_INSTALLER found as $ELEXIS_INSTALLER, fetching it
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
  -Dworkspace.location="$WORKSPACE_nooomph" \
  -Dworkspace.location="$WORKSPACE" \
  -Dgithub.remoteURIs="git@github.com:elexis" \
  -Doomph.github.remoteURIs="git@github.com:elexisoomph" \
  -Dsetup.p2.agent="$P2_POOL" \
  -Duser.home="$USER_HOME" \
  -Doomph.setup.offline=false \
  -Declipse.train=$ECLIPSE_TRAIN \
  -Dcore.git.clone.location=git@github.com:elexis/elexis-3-core.git \
  -Dgithub.remoteURIs=git@github.com:elexis/ \
  -Dgit.container.root="$INST_ROOT/git" \
  -Doomph.git.container.root="$INST_ROOT/git_oomph" \
  -Doomph.installer.verbose=true 2>&1 | tee $0.log
IDE=`find $INST_ROOT -type f -name eclipse`
if -f /etc/NIXOS; then
  echo "NixOS needs a special treating"
fi
echo SETUPS were in $SETUPS IDE is $IDE
echo run it via: $IDE -data $WORKSPACE -clean | tee --append $0.log
