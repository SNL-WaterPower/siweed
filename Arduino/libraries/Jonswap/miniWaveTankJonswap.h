//#pragma once
#ifndef miniWaveTankJonswap_h
#define miniWaveTankJonswap_h

#define _USE_MATH_DEFINES
#include <StandardCplusplus.h>
#include <vector>
#include <iostream>
#include <cmath>

class miniWaveTankJonswap
{
  public:
  static double period;
  static double df;
  static double f_low; //round to the nearest multiple of df
  static double f_high;

  static int num_fs;
  static std::vector<double> f;
  static std::vector<double> amp;
  static std::vector<double> phase; // = {3.152416,3.037871,5.045899,3.415424,1.167684,3.443497,3.721319,4.670000,3.773063,5.373082,6.113500,1.607072,5.608919,0.956348,6.036062,1.037471,5.557559,4.663542,1.105112,3.408563,4.351425,4.267931,0.195947,0.738568,3.467186,2.080551,1.471086,0.333220,2.303043,5.546058,5.556698,1.180501,6.169116,4.755245,2.835494,5.268132,5.952006,1.173083,4.801221,2.111487,2.028668,4.333523,0.226176,2.636901,5.026371,2.955182,4.031354,4.803817,4.847541,6.223209,0.417596,5.151822,1.939631,5.052632,1.916994,2.979530,3.140566,5.817336,4.445193,5.076769};

  miniWaveTankJonswap(double period, double low, double high);
  static void update(double sigH, double peakF, double gamma);


  private:
  class Jonswap
  {
public:
	std::vector<double> f;
	std::vector<double> S;

	void update(std::vector<double>& f, double Tp, double Hm0, double gamma);
  };
Jonswap J;
  public:
  virtual int getNum();
  virtual std::vector<float> getAmp();
  virtual std::vector<float> getPhase();
  virtual std::vector<float> getF();
  virtual std::vector<float> copyArraydf(std::vector<double> &d);
};
#endif