#!/usr/bin/env bash
set -o verbose
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
echo SCRIPTPATH ist $SCRIPTPATH
ELEXIS_INSTALLER=$SCRIPTPATH/eclipse-installer/eclipse-inst
if  test -f $ELEXIS_INSTALLER; then
echo ELEXIS_INSTALLER found as $ELEXIS_INSTALLER
else
echo NO ELEXIS_INSTALLER found as $ELEXIS_INSTALLER, fetching it
mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:unpack \
-Dartifact=com.github.a-langer:org.eclipse.oomph.console.product:1.0.2:tar.gz:linux.gtk.x86_64  \
-DoutputDirectory=./ -Dproject.basedir=./
ls -l $ELEXIS_INSTALLER
fi

SETUPS=$SCRIPTPATH/elexis/
echo PWD ist $PWD
INST_ROOT=/tmp/elexis_ide2
rm -rf $INST_ROOT; mkdir -p $INST_ROOT
echo PWD ist $PWD
ls -l $ELEXIS_INSTALLER $SETUPS
cd $SCRIPTPATH/eclipse-installer
INST_ROOT=/tmp/elexis-ide
rm -rf $INST_ROOT
echo PWD ist $PWD
# INST=$SCRIPTPATH/./eclipse-inst
# INST=$SCRIPTPATH/org.eclipse.oomph.console.product/target/products/org.eclipse.oomph.console.product/linux/gtk/x86_64/eclipse-installer/eclipse-inst
time $ELEXIS_INSTALLER -nosplash -application org.eclipse.oomph.console.application -vmargs \
  -Doomph.redirection.setups="index:/->$SETUPS/" \
  -Doomph.redirection.setupsDir="index:/->$SETUPS/" \
  -Doomph.installation.location="$INST_ROOT/ide" \
  -Doomph.product.id="eclipse.ide4elexis" \
  -Doomph.project.id="elexis.ide" \
  -Doomph.workspace.location="$INST_ROOT/workspace" \
  -Doomph.installation.id="elexis.ide2" \
  -Dsetup.p2.agent="$HOME/.p2" \
  -Doomph.setup.offline=false \
  -Doomph.installer.verbose=true 2>&1 | tee  $0.log
du -shx $INST_ROOT
IDE=`find $INST_ROOT -name eclipse`
echo SETUPS were in $SETUPS IDE is $IDE
export START=" $IDE -data $INST_ROOT/workspace -clean"
echo $START
$START
exit
