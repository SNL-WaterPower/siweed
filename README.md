<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
  *	[Running the GUI](#running-the-gui)
* [System Layout](#System-layout)
* [System Specifications](#System-Specifications)
* [Roadmap](#roadmap)


<!-- ABOUT THE PROJECT -->
## About The Project

The Sandia Interactive Wave Energy Education Display (SIWEED) is a small portable wave tank to be used for outreach and engagement on wave energy converters (WECs) and, in particular, WEC control.


<!-- GETTING STARTED -->
## Getting Started

### Prerequisites
- SIWEED requires 
	- [Arduino IDE 1.8.13](https://www.arduino.cc/en/main/software) or higher for programming Arduinos
		- Libraries are included in the repo. Many are modified, so you need to use the versions in the repo.
		- Arduino SAM boards package
	- [Processing IDE 3.5.4](https://processing.org/download/) or higher for programming the GUI
		- Libraries are included in the repo. Many are modified, so you need to use the versions in the repo.


### Installation

1. Download the latest version of [Arduino IDE](https://www.arduino.cc/en/main/software) 
2. Download the latest version of [Processing IDE](https://processing.org/download/)
3. Download the [Master SIWEED Repository](https://github.com/SNL-WaterPower/siweed/tree/master)
4. Change the Sketchbook Location for the Arduino IDE to \siweed\Arduino
```
Open Arduino IDE
Change the location of your sketchbook folder to ~\siweed\Arduino at File > Preferences > Sketchbook location to 
Ex: C:\Users\user\Documents\GitHub\siweed\Arduino
```
5. Change Sketchbook Location for the Processing IDE to \siweed\Processing
```
Open Processing IDE
Change the location of your sketchbook folder to ~\siweed\Processing at File > Preferences > Sketchbook location to 
Ex: C:\Users\user\Documents\GitHub\siweed\Processing
```
5. Change Arduino IDE board to "Arduino Due Programming Port"
```
This can be found at Tools > Board > Arduino ARM(32 - bits) Boards > Arduino Due Programming Port

If you do not see the Arduino ARM(32 - bits) Boards, you need to install the SAM boards package by going to tools > board > boards manager, searching SAM, 
and installing the SAM package.
```
6. Upload the sketches to the Arduinos
```
With the Arduinos connected, select a port in tools > port, be sure to choose a port with an arduino plugged in. Go to file > sketchbook, and open WaveMaker_Controller.
Upload the sketch. 

Switch the port to the other arduino, and open WEC_Controller. Upload the sketch. That is all for the arduinos, you can close the IDE if you wish.
```
<!-- Running the GUI -->
### Running the GUI
1. Open processing.exe 
2. File > Open > siweedGUI.pde (Ex: C:\Users\user\Documents\GitHub\siweed\Processing\siWeedGUI\siweedGUI.pde)
3. (optional)Edit modifiers. These are booleans at the top of the code that will do things like enable basic mode, debugging, or data logging.
4. Click "Run"
5. The GUI will open, allow some time for it to load. 

<!-- System layout -->
## System layout
SIWEED uses a PC to control two Arduino Dues: (1) to run the wavemaker and (2) to run the WEC.
A detailed illustration of the system layout is shown in the diagram below.

![system layout](https://github.com/SNL-WaterPower/siweed/blob/master/documentation/diagrams/SystemLayout.png)
<!-- System Specifications -->
## System specifications
 - Tank
 	- 3/4 inch acrylic tank
 	- Inner dimension: 1.5m x 0.3m x 0.5m (filled to ~0.3m deep)
 	- Mass of water: 135 kg (~300lbs)
 	- Mass of dry tank: ?
 	- Volume: 135 L (~36 gal)
 - WEC: 
 	- Diameter: 12 cm
   	- Mass: 0.04 kg list item		!!needs updating
   	- Natural frequency: ~3.4 Hz list item	!!needs updating
 - System update rates:
 	- Processing (GUI): 30 Hz
 	- Arduinos:
 		- Wave maker
 			- General: 100 Hz
 			- Serial communication: 30 Hz
 		- WEC
 			- General: 100 Hz
 			- Serial communication: 30 Hz


<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/SNL-WaterPower/siweed/issues) for a list of proposed features (and known issues).

## Copyright and license
Copyright 2021 National Technology & Engineering Solutions of Sandia, LLC (NTESS).
Under the terms of Contract DE-NA0003525 with NTESS, the U.S. Government retains certain rights in this software.
The software is distributed under a [GNU General Public License](COPYING).
