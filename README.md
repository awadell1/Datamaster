# Datamaster#

## What is Datamaster ##
Datamaster is a set of MATLAB objects that enable multi-MoTeC Log file analysis, devloped for Cornell Racing to enable designers to validate load cases or quantify system by quickly analyzing thousands of log files.

* Quickly filter datasources to examine only relevant data
* Leverage the power of MATLAB for advanced signal filtering, plotting and more
* Baked in analysis tools for analyzing car performance (ie. gg-circles, torque curves, etc)

## Getting Started with Datamaster ##
Ready to get started with Datamaster? Here's how:

1. Install a Git client (For example [Sourcetree ](https://www.sourcetreeapp.com/))
2. Clone Datamaster to your local machine
3. Checkout the `master` branch
4. Fire up MATLAB
5. Add Datamaster to the MATLAB Path
    * Click: HOME > ENVIRONMENT > SetPath
    * Click Add Folder...
    * Navigate to the Datamaster folder
    * Click Okay and approve the change
6. Type the following command into MATLAB: `dm = Datamater; dm.getDatasource.Histogram2('Engine_RPM', 'Manifold_Pres',[0, 10000; 70 170])`
7. Congrats! You now have Datamaster up and running, now go check out the ~~wiki~~ and get started analyzing data

## Bug Reporting ##
Datamaster is still very much in it's infancy, and as such bugs are to be expected. If you do by chance happen to find a bug:

1. Submit a Bug Report [here](https://bitbucket.org/cornellracingsimulation/datamaster/issues/new)
2. Try to fix the bug your self if at all possible
3. If you do manage to fix the bug, please submit a pull request [here](https://bitbucket.org/cornellracingsimulation/datamaster/pull-requests/)

## Feature Request ##
Datamaster is a new tool and likely is missing some of the features that you might want. If there's a feature that you'd like to see in a future release:

1. Submit a feature request [here](https://bitbucket.org/cornellracingsimulation/datamaster/issues/new)
2. Try to implement the feature yourself
3. If you do manage to implement the feature, please submit a pull request [here](https://bitbucket.org/cornellracingsimulation/datamaster/pull-requests/)