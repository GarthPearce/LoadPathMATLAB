# User Guide

## Matlab Load Path Plotting Algorithm Version 1

### January 2019

### Plotting Load Paths for mesh and stress files using the Hex8 3D finite
#### D. Kelly, G. Pearce and K. Schroder-Turner

This User Guide describes features of the MatLab program prepared for release at the AIAA SciCom 2019 Conference, San Diego 7-11 January 2019 [1]. The program reads mesh data and stresses from text files created by a finite element solution that is run independently by the user. It then defines the vector field and plots the load paths using the Runge-Kutta algorithm described in the paper.

The MatLab application can be downloaded from the GitHub website https://GitHub/GarthPearce/LoadPathMATLAB

The site contains the source of the program, and a number of example sets of data.

Contents

Installation        2

Example Run        4

Program Features        5

Format of Input Files        6

References        8

Example 1  Pin Loaded Hole        9

Example 5 Simple Cube        11

Example 9 Step – static solution        13

Example 9 Step Transient solution        15



## Installation

Download the files in the director &quot;Load-Path-Plotter – AIAA – V1&quot; to your chosen MatLab run directory.

To launch the program nagivate to your chosen directory and select the LoadPathGui file and press &quot;Run&quot;. The graphical user interface show below will appear.