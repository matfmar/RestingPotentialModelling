PLEASE READ THE CONTENT OF THIS FILE THOROUGHLY BEFORE EXECUTING OR OPENING ANY FILE FROM THE REPOSITORY.

# RestingPotentialModelling
This repository is aimed to be a supplementary material to my research article(s) concerning modelling of cellular resting potential. It contains an application (an executable and all additional files) that was used to do the research.

## About the program
The program was written in Object Pascal and built for Windows machine on x86_64 CPU. If a user wants to run it on other platforms, they have to build it by themselves based on the source code present in the repository.

## How to use the program
In order to execute the program double-click the file project1.exe. When main windows appears, click Options to set the simulation parameters. By default they are set to meet the requirements of a model cardiomyocyte with plasma membrane impermeant to water and present impermeant ions. After setting the parameters, click START! button to run the simulation. Because of nonuniform thread support and other thread-related issues on Windows machines appearance of a program may look as if it is not responding. It is not the case, so please remain calm and wait until the simulation is over and a window with results appears. When it happens, all data is present in separate boxes named by their content chronologically (from the start till the end of the simulation). In order to get a graph or perform other types of data proccessing results can be copied from the boxes directly or from the textfiles (with corresponding filenames located inside the working directory) to be an input to a separate application (i.e. MATLAB, MS Excel, R environment and so on).

## Safety issues
The program was successfully tested on several (different) machines with Windows OS. The program is not presumed to make any changes to the machine apart from files in the working directory. However, possible (but extremely unlikely) negative impact on a computer cannot be excluded. Therefore, using any content of the repository is on the user's own responsibility. I am not responsible for consequences of using the content of the repository (particularly the program). It is possible to view how the program is running remotely on my machine, but solely after individual contact with me.

## Contact and copyright issues
The repository is distributed under GNU GPL v3 licence. To contact me please write to: marzec-mateusz[at]wp.pl
