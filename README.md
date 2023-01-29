# Using OOMPH via console

This is a test for https://github.com/a-langer/eclipse-oomph-console to see, whether we can generate
a fully automated setup via the console analog to https://github.com/elexis/elexis-3-core/blob/master/ch.elexis.sdk/Elexis.setup

# What works

* call `./setup_elexis.sh` in a checkout of the repository. This will build and eclipse which
* can be tested via `/tmp/elexis-ide/ide/elexis.ide2/eclipse -data /tmp/elexis-ide/workspace -clean`
* installing desired eclipse release train (e.g. 22-09) works
* Adding needed feature like targetplatform
* Setting heap size via eclipse.ini to 2048 works

Tested under Debian bullseye and NixOS 22.11

# Problems

* gitClone of repos like elexis-3-core does not work. Is this a problem with oomph/setup/InducedChoices?
  Installed manually by clicking File...Import..Oomph..Projects from Catalog and choose elexis.ide
  Help..Performe Setup Tasks
* The generate eclipse is small, as most code is stored under $HOME/.p2
* Some setup like cleanup.remove_trailing_whitespaces does not work. Why?
* There are 4 description containing MISSING which do not appear in the log file? Why are these preferences not set?

Now I have the following undefined variables
workspace.location
uri
github.remoteURIs
git.container.root$

Adding the following lines to /opt/ide/elexis-2022-09/elexis/eclipse.ini

-Dcore.git.clone.root.location=/opt/workspaces/elexis-2022-09/git
-Dworkspace.location=/opt/workspaces/elexis-2022-09
-Duri=uri
-Dgithub.remoteURIs=git@github.com:elexis
-Dgit.container.root=/opt/workspaces/elexis-2022-09/git/container_root

Gives me
Performing Eclipse Ini -Xmx2048
Skipping because of /opt/ide/elexis-2022-09/eclipse/eclipse.ini not found
(I started from /opt/ide/elexis-2022-09/elexis/eclipse
Settting installation.id in eclipse.ini did not work
mv /opt/ide/elexis-2022-09/elexis /opt/ide/elexis-2022-09/eclipse
and starting via 
 /opt/ide/elexis-2022-09/eclipse/eclipse -data /opt/workspaces/elexis-2022-09 -clean

LiClipseText
 https://www.liclipse.com/text/updates/
org.brainwy.liclipsetext.feature.feature.group
org.brainwy.liclipsetext.feature.source.feature.group
git clone location rule
  ${installation.location/git/}${@id.locationQualifier|trim}${@id.remoteURI|gitRepository}
   grep -r '${' Elexis.setup

          location="${jre.location-17}"/>
      <description>Set the heap space needed to work with the projects of ${scope.project.label}</description>
        value="=https://raw.githubusercontent.com/elexis/elexis-3-core/master/ch.elexis.sdk/Elexis.setup->${core.git.clone.location|uri}/ch.elexis.sdk/Elexis.setup"
        targetURL="${workspace.location|uri}/.metadata/.plugins/org.eclipse.jdt.ui/dialog_settings.xml"
        <value>${scope.project.label} Github repository</value>
        <value>${scope.project.label} Github repository</value>
        <value>${scope.project.label} Github repository</value>
    <description>Install the tools needed in the IDE to work with the source code for ${scope.project.label}</description>
      userID="${github.user.id}"
      userID="${github.user.id}"
        rootFolder="${core.git.clone.location}"
        rootFolder="${base.git.clone.location}"
        rootFolder="${server.git.clone.location}"/>
          rootFolder="${medelexis.git.clone.location}"/>
            rootFolder="${medelexis.application.git.clone.location}"/>
