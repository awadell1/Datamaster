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
6. Type the following command into MATLAB

```
#!matlab
dm.getDatasource.Histogram2('Engine_RPM', 'Manifold_Pres',[0, 10000; 70 170])
```



