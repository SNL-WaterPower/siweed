# SIWEED
The Sandia Interactive Wave Energy Education Display (SIWEED) is a small portable wave tank to be used for outreach and engagement on wave energy converters (WECs) and, in particular, WEC control.

## System layout
SIWEED uses a PC to control two Arduinos: (1) an Arduino Mega to run the wave maker and (2) an Arduino Due to run the WEC.
A detailed illustration of the system layout is shown in the diagram below.

![system layout](documentation/diagrams/systemLayoutPNG.png)

## System specifications
 - Tank
 	- 3/4 inch acrylic tank
 	- Inner dimension: 1.5m x 0.3m x 0.5m (filled to ~0.3m deep)
 	- Mass of water: 135 kg (~300lbs)
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
## Requirements
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


## Contributing
Except for very minor changes, we aim to follow a [gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) workflow.
