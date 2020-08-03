#include "miniWaveTankJonswap.h"
const int max_num_fs = 100;
double miniWaveTankJonswap::period = 0;
double miniWaveTankJonswap::df = 0;
double miniWaveTankJonswap::f_low = 0;
double miniWaveTankJonswap::f_high = 0;
int miniWaveTankJonswap::num_fs = 0;
double miniWaveTankJonswap::f[max_num_fs];
double miniWaveTankJonswap::amp[max_num_fs];
double miniWaveTankJonswap::phase[max_num_fs];
double miniWaveTankJonswap::S[max_num_fs];

miniWaveTankJonswap::miniWaveTankJonswap(double _period, double _low, double _high)
{ //constructor
  df = 1 / _period;
  f_low = df * floor(_low / df); //round to the nearest multiple of df
  f_high = df * floor(_high / df);
  num_fs = (int)((f_high - f_low) / df);
  if(num_fs > max_num_fs)
  {
	  Serial.print("Error: num_fs greater than max elements: ");
	  Serial.println(max_num_fs);
	  return;
  }

  // f and phase are assigned upon construction
  randomSeed(123); //uses a defined seed, so the sequence is the same between runs. !Note: The same seed will produce different results on Atmel and ARM processors.
  for (int i = 0; i < num_fs; i++)
  { //f increments by df
    f[i] = f_low + i * df;
    phase[i] = random(0,1000)/ 1000.0 * 2 * M_PI;
  }
}
void miniWaveTankJonswap::update(double sigH, double peakF, double gamma)
{ 
  //updates amp with new values. Called on button press
  double Hm0 = sigH / 100; //cm to meters
  double Tp = 1 / peakF;
  //gamma is the same;
  ///////////////////////////////////////////////start jonswap
  double g = 9.81;
  double siga = 0.07;
  double sigb = 0.09;
  double fp = 1 / Tp;
  double S_temp[max_num_fs];
  double Gf[max_num_fs];
  double Sf[max_num_fs];
  double alpha_JS = 0;
  double trapz = 0;
  int i;

  for (i = 0; i < num_fs; i++)
  {
    if (f[i] <= fp)
    {
      Gf[i] = pow(gamma, exp(-pow((f[i] - fp), 2) / (2 * (siga, 2) * pow(fp, 2))));
    }
    else
    {
      Gf[i] = pow(gamma, exp(-pow((f[i] - fp), 2) / (2 * pow(sigb, 2) * pow(fp, 2))));
    }
    S_temp[i] = pow(g, 2) * pow((2 * M_PI), -4) * pow(f[i], -5) * exp(-(5 / 4) * pow(f[i] / fp, -4));
  }

  //trapezoidal rule

  for (i = 0; i < num_fs - 1; i++)
  {
    trapz += (S_temp[i] * Gf[i] + S_temp[i + 1] * Gf[i + 1]) * (f[i + 1] - f[i]) / 2;
  }
  alpha_JS = (Hm0 * Hm0) / 16 / trapz;
  for (i = 0; i < num_fs; i++)
  {
    Sf[i] = alpha_JS * S_temp[i] * Gf[i];
  }
  for (i = 0; i < num_fs; i++)
  {
	  S[i] = Sf[i];
  }
  
  /////////////////////////////////////////////end jonswap
  for (int i = 0; i < num_fs; i++)
  { //reassign amplitude.
    //System.out.println(""+S.S[i]+"  "+S.f[i]+"  "+f[i]);    //this proves that f and S.f are the same
    amp[i] = sqrt(2 * S[i] * 2 * M_PI * df) * 100; //meters to cm
  }
}

int miniWaveTankJonswap::getNum()
{
  return num_fs;
}

float* miniWaveTankJonswap::getAmp()
{
  return copyArraydf(amp);
}

float* miniWaveTankJonswap::getPhase()
{
  return copyArraydf(phase);
}

float* miniWaveTankJonswap::getF()
{
  return copyArraydf(f);
}

float* miniWaveTankJonswap::copyArraydf(double d[])
{ //copies a double array to a float array
  float f[num_fs];
  for (int i = 0; i < num_fs; i++)
  {
    f[i] = (float)d[i];
  }
  return f;
}
