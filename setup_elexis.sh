#!/usr/bin/env bash
#set -o verbose
set -o pipefail
set -e
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
ELEXIS_INSTALLER=$SCRIPTPATH/eclipse-installer/eclipse-inst
if  test -f $ELEXIS_INSTALLER; then
  echo ELEXIS_INSTALLER found as $ELEXIS_INSTALLER
else
  echo NO ELEXIS_INSTALLER found as $ELEXIS_INSTALLER, fetching it
  mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:unpack \
  -Dartifact=com.github.a-langer:org.eclipse.oomph.console.product:1.0.2:tar.gz:linux.gtk.x86_64  \
  -DoutputDirectory=./ -Dproject.basedir=./
fi

SETUPS=$SCRIPTPATH/elexis/
INST_ROOT=/tmp/elexis_ide2
rm -rf $INST_ROOT; mkdir -p $INST_ROOT
INST_ROOT=/tmp/elexis-ide
rm -rf $INST_ROOT
$ELEXIS_INSTALLER -nosplash -application org.eclipse.oomph.console.application -vmargs \
  -Doomph.redirection.setups="index:/->$SETUPS/" \
  -Doomph.installation.location="$INST_ROOT/ide" \
  -Doomph.product.id="eclipse.ide4elexis" \
  -Doomph.project.id="elexis.ide" \
  -Doomph.workspace.location="$INST_ROOT/workspace" \
  -Doomph.installation.id="elexis.ide2" \
  -Dsetup.p2.agent="$HOME/.p2" \
  -Doomph.setup.offline=false \
  -Declipse.train=2022-09 \
  -Dcore.git.clone.location=git@github.com:elexis/elexis-3-core.git \
  -Dgithub.remoteURIs=git@github.com:elexis/ \
  -Dgit.container.root="$INST_ROOT/git" \
  -Doomph.installer.verbose=true 2>&1 | tee $SCRIPTPATH/$0.log
IDE=`find $INST_ROOT -name eclipse`
echo SETUPS were in $SETUPS IDE is $IDE
echo run it via: $IDE -data $INST_ROOT/workspace -clean | tee --append $SCRIPTPATH/$0.log
