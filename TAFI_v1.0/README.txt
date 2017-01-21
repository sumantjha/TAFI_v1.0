Toolbox for Analysis of Flexural Isostasy - TAFI

Introduction

TAFI allows a user to compute the flexural response to loading for
various plate types. The parameters can be adjusted using sliders or
input boxes. The responses are displayed in form of 2-D plots. The
gravity responses for such flexural basin shapes are also displayed. This
program allows a user to import their own data to compare it with the
flexure and gravity profile. The data so imported can be shifted up and
down to aid modeling.
 
Installation and running TAFI

Download and unzip TAFI.zip file at a preferred location. 
From Matlab’s workspace, cd to the unzipped TAFI directory.
Enter TAFI at the command line.

Alternatively
	Add path of the TAFI directory and subdirectories in Matlab. 
	On Unix and Mac, this can be done as:

	setenv MATLABPATH ‘<path of unzipped TAFI main directory>

	On windows or any other operating system, its best to use a Use a 	
	startup.m File.

	See here for adding path in Matlab:
	http://www.mathworks.com/help/matlab/matlab_env/add-folders-to-	
	search-path-upon-startup-on-unix-or-macintosh.html

Alternatively
	Use Matlab’s install app tool and install TAFI app using 	“TAFI.mlappinstall” file in Matlab’s App ribbon bar. 


Bugs: Send all bugs, with error messages to sumant.jha@colostate.edu.

Known bugs:
1. As of now, Matlab does not enables clearing all the data imported into GUI, after shutting down the GUI. Closing TAFI and restarting will use the previously imported data constraint
and load files. Functions are provided to clear the constraints and loadfile.

Another way to do it is to close the Matlab completely and restart it.
