## What is Datamaster ##
Datamaster is a set of MATLAB objects that enable multi-MoTeC Log file analysis, developed for Cornell Racing to enable designers to validate load cases or quantify system by quickly analyzing thousands of log files.

* Quickly filter datasources to examine only relevant data
* Leverage the power of MATLAB for advanced signal filtering, plotting and more
* Baked in analysis tools for analyzing car performance (ie. gg-circles, torque curves, etc)

## Getting Started with Datamaster ##
Assuming MATLAB is already installed, download and run this setup GUI: [here](https://github.com/awadell1/Datamaster/raw/master/DatamasterSetup.mlapp)

If you have not already installed MATLAB, do that now.

You can check that everything was installed correctly by running the following command in MATLAB:
```matlab
close all
dm = Datamaster; ds = dm.getDatasource;
ds(1:100).Histogram2('Engine_RPM', 'Manifold_Pres',[0, 10000; 70 170], 'unit', {'rpm', 'kPa'});
```

Once installed check out the [wiki](https://github.com/awadell1/Datamaster/wiki/Welcome-to-the-Datamaster-wiki!) for documentation, examples and troubleshooting guides.

## For Mac and Linux Users ##
Datamaster is built using cross-platform tools (MATLAB and Python) and has been tested using Linux. However, at present Datamaster is developed solely on a PC and thus other platforms, while not unsupported are largely untested. If you do run into any bug/ missing feature for your platform, please submit a bug/feature request. However given my personal lack of access to non PC platforms, any less than obvious fixes may take time.

## Bug Reporting ##
Datamaster is still very much in it's infancy, and as such bugs are to be expected. If you do by chance happen to find a bug:

1. Submit a Bug Report [here](https://github.com/awadell1/Datamaster/issues/new)
2. Try to fix the bug your self if at all possible
3. If you do manage to fix the bug, please submit a pull request [here](https://github.com/awadell1/Datamaster/compare)

## Feature Request ##
Datamaster is a new tool and likely is missing some of the features that you might want. If there's a feature that you'd like to see in a future release:

1. Submit a feature request [here](https://github.com/awadell1/Datamaster/issues/new)
2. Try to implement the feature yourself
3. If you do manage to implement the feature, please submit a pull request [here](https://github.com/awadell1/Datamaster/compare)
