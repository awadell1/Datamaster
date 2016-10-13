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
6. Type the following command into MATLAB: `dm = Datamaster; ds = dm.getDatasource; ds(1:100).Histogram2('Engine_RPM', 'Manifold_Pres',[0, 10000; 70 170])`
7. Congrats! You now have Datamaster up and running, now go check out the ~~wiki~~ and get started analyzing data

## Don't know Git? Not a problem ##
Git is a Distributed Version Control System, (Autodesk Vault is a Centralized Version Control System) created to handle source code for large open source projects. At it's basis Git strives to do the following:

* Speed: Most operations in git are local
* Simple Design: Once you get pasted the terminology, git is dead simple to use
* Fully Distributed: You don't need to connect to a special server to get work done

Why should you be using git?

* Easily saves every version of your code with a commented commit history to document your progress
* Quickly revert to any version of any file
* Once a file is committed it is virtually impossible to lose

So how do you get started? Here's a few resources:

* For a quick explaination of what git is and how to use it: [Git Basics](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository)
* For an in depth explination of all things git: [Pro Git](https://git-scm.com/book/en/v2)
* For a run down of using git with Sourcetree: [Sourcetree Tutorial](https://confluence.atlassian.com/bitbucket/tutorial-learn-sourcetree-with-bitbucket-cloud-760120235.html?_ga=1.17903230.693814136.1476383528)

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