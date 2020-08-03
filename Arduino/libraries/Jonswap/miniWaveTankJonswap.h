//#pragma once
#ifndef miniWaveTankJonswap_h
#define miniWaveTankJonswap_h

#define _USE_MATH_DEFINES
#include "Arduino.h"
//#include <StandardCplusplus.h>
//#include<vector.h>
//#include<StandardVector.h>
//#include <vector>
#include <math.h>
//#include <iostream>
//#include <cmath>

//#include <ArduinoSTL.h>
//using namespace std;

class miniWaveTankJonswap
{
  public:
  static double period;
  static double df;
  static double f_low;
  static double f_high;

  static int num_fs;
  /*
  static std::vector<double> f;
  static std::vector<double> amp;
  static std::vector<double> phase;
  static std::vector<double> S;
  */
  static double f[100];
  static double amp[100];
  static double phase[100];
  static double S[100];
  
  
  miniWaveTankJonswap(double period, double low, double high);
  static void update(double sigH, double peakF, double gamma);

  public:
  virtual int getNum();
  /*
  virtual std::vector<float> getAmp();
  virtual std::vector<float> getPhase();
  virtual std::vector<float> getF();
  virtual std::vector<float> copyArraydf(std::vector<double> &d);
  */
  virtual float* getAmp();
  virtual float* getPhase();
  virtual float* getF();
  float* copyArraydf(double d[]);
};

#endif