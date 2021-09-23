// ===============================
// miniWaveTankJonswap.cpp
// Created Spring 2020
// Zachary Morrell and Nicholas Ross
// Created for the SIWEED project at Sandia National Labs
// Calculates up to 100 sine waves in a jonswap spectrum that can be 
// summed to create a timeseries.
// ===============================
//#pragma once
#ifndef miniWaveTankJonswap_h
#define miniWaveTankJonswap_h
//#define _USE_MATH_DEFINES
#include "Arduino.h"

class miniWaveTankJonswap
{
  public:
  //static double period;
  static double df;
  static double f_low;
  static double f_high;

  static int num_fs;
  static double f[100];
  static double amp[100];
  static double phase[100];
  static double S[100];
  
  
  miniWaveTankJonswap(double period, double low, double high);
  static void update(double sigH, double peakF, double gamma);

  public:
  int getNum();
  float getAmp(int);
  float getPhase(int);
  float getF(int);
};

#endif