// Begin Stepper Control Program 

import processing.serial.*; //importing GUI library
import controlP5.*; //importing GUI library

Serial port1;
ControlP5 cp5; // create Control P5 object

/////////////////// THIS SETS UP THE LOOK ////////////////////////////////////

void setup(){
  
  size(300, 450);
  
  printArray(Serial.list()); //prints avliable ports
  
  port1 = new Serial(this, "COM4", 9600); // all communication with Mega
 
  // adding buttons to window
  
  cp5 = new ControlP5(this);
  
  cp5.addButton("Up")  //name of button
    .setPosition(100, 50) //x and y coordinates of upper left corner of button
    .setSize(100, 70); //size (width, height)
    
  cp5.addButton("Down")  //name of button
    .setPosition(100, 150) //x and y coordinates of upper left corner of button
    .setSize(100, 70); //size (width, height)
    
}

/////////////////// THIS IS WHERE THINGS HAPPEN ////////////////////////////////////

void draw(){
  
  background(146, 190, 212); //background color (r,g,b)
  
  //adding title
  fill(73, 75, 77); // text color (r,g,b)
  text("Change Freq \n", 100, 30); // ("text", x coordiante, y coordinate)
  
}


/////////////////// MAKES BUTTONS DO THINGS ////////////////////////////////////


void Up(){
  port1.write('+');  
}

void Down(){
  port1.write('-'); 
}
