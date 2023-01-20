# Using OOMPH via console

This is a test for https://github.com/a-langer/eclipse-oomph-console to see, whether we can generate
a fully automated setup via the console analog to https://github.com/elexis/elexis-3-core/blob/master/ch.elexis.sdk/Elexis.setup

# What works

* installing desired eclipse release train (e.g. 22-09) works
* Adding needed feature like targetplatform
* Setting heap size via eclipse.ini to 2048 works

# Problems

* gitClone of repos like elexis-3-core does not work. Is this a problem with oomph/setup/InducedChoices?
* The generate eclipse is small, as most code is stored under $HOME/.p2
* Some setup like cleanup.remove_trailing_whitespaces does not work. Why?
* There are 4 description containing MISSING which do not appear in the log file? Why are these preferences not set?
