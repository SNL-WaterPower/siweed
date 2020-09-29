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
* [Contributing](#contributing)


<!-- ABOUT THE PROJECT -->
## About The Project

The Sandia Interactive Wave Energy Education Display (SIWEED) is a small portable wave tank to be used for outreach and engagement on wave energy converters (WECs) and, in particular, WEC control.


<!-- GETTING STARTED -->
## Getting Started

### Prerequisites
- SIWEED requires 
	- [Arduino IDE 1.8.13](https://www.arduino.cc/en/main/software) or higher for programming Arduinos
		- Libraries 
			- DueTimer(1.4.7)
			- Encoder (1.4.1)
			- Jonswan
	- [Processing IDE 3.5.4](https://processing.org/download/) or higher for programming the GU
		- Libraries
			- Sound
			- Console
			- Meter
			- ControlP5


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
5. Change Arduino IDE board to "Arduino Mega or Mega 2560"
```
This can be found at Tools > Board > Arduino Mega or Mega 2560
```
NOTE: When programming the Arduino DUE board, make sure to change the selected board to: Arduino DUE (Progamming Port).
Also, make sure that the microUSB is plugged into the programming port of the DUE
<!-- Running the GUI -->
### Running the GUI
1. Open processing.exe 
2. File > Open > siweedGUI.pde (Ex: Ex: C:\Users\user\Documents\GitHub\siweed\Processing\siWeedGUI\siweedGUI.pde)
3. Click "Run"
4. The GUI will open, allow some time for it to load. 

<!-- System layout -->
## System layout
SIWEED uses a PC to control two Arduinos: (1) an Arduino Mega to run the wavemaker and (2) an Arduino Due to run the WEC.
A detailed illustration of the system layout is shown in the diagram below.

![system layout](documentation/diagrams/systemLayoutPNG.png)
<!-- System Specifications -->
## System specifications
 - Tank
 	- 3/4 inch acrylic tank
 	- Inner dimension: 1.5m x 0.3m x 0.5m (filled to ~0.3m deep)
 	- Mass of water: 135 kg (~300lbs
 	- Mass of dry tank: ?
 	- Volume: 135 L (~36 gal)
 - WEC: 
 	- Diameter: 6 cm
   	- Mass: 0.04 kg list item
   	- Natural frequency: ~3.4 Hz list item
 - System update rates:
 	- Processing (GUI): 30 Hz
 	- Arduinos:
 		- Wave make (Mega)
 			- General: 100 Hz
 			- Serial communication: 30 Hz
 		- WEC (Due)
 			- General: 100 Hz
 			- Serial communication: 30 Hz


<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/SNL-WaterPower/siweed/issues) for a list of proposed features (and known issues).

<!-- CONTRIBUTING -->
## Contributing

Except for very minor changes, we aim to follow a [gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) workflow.

### Issues

Issues are very valuable to this project.

* Ideas are a valuable source of contributions others can make
* Problems show where this project is lacking
* With a question, you show where contributors can improve the user experience

Thank you for creating them.

### Pull Requests

Pull requests are, a great way to get your ideas into this repository.

When deciding to merge in a pull request, look at the following things:

#### Does it state intent

Be clear which problem is trying to be solved with your contribution.

For example:

> Add link to code of conduct in README.md

Doesn't tell anything about why you're doing that

> Add link to code of conduct in README.md because users don't always look in the CONTRIBUTING.md

Tells the problem found, and the pull request shows the action taken to solve it.


#### Is it of good quality

* There are no spelling mistakes
* It reads well
* For English language contributions: Has a good score on [Grammarly](grammarly.com) or [Hemingway App](http://www.hemingwayapp.com/)

#### Does it move this repository closer to our vision for the repository

The aim of this repository is:

* To provide a README.md and assorted documents anyone can copy and paste, into their project
* The content is usable by someone who hasn't written something like this before
* Foster a culture of respect and gratitude in the open-source community.









