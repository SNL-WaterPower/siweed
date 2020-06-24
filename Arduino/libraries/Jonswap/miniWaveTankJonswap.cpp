#include "miniWaveTankJonswap.h"

//using Random = java::util::Random;
//using Math = java::lang::Math;
double miniWaveTankJonswap::period = 0;
double miniWaveTankJonswap::df = 0;
double miniWaveTankJonswap::f_low = 0;
double miniWaveTankJonswap::f_high = 0;
int miniWaveTankJonswap::num_fs = 0;
std::vector<double> miniWaveTankJonswap::f;
std::vector<double> miniWaveTankJonswap::amp;
std::vector<double> miniWaveTankJonswap::phase;

miniWaveTankJonswap::miniWaveTankJonswap(double _period, double _low, double _high)
{ //constructor
  Serial.println('i');
  df = 1 / _period;
  f_low = df * floor(_low / df); //round to the nearest multiple of df
  f_high = df * floor(_high / df);
  num_fs = static_cast<int>((f_high - f_low) / df);
  f = std::vector<double>(num_fs);
  amp = std::vector<double>(num_fs);
  phase = std::vector<double>(num_fs);

  //std::wcout << f_low << L"  " << f_high << L"  " << num_fs << L"=?" << (f_high - f_low) / df << std::endl;

  // f and phase are assigned upon construction
  srand(123);//randomSeed(123); //uses a defined seed, so the sequence is the same between runs
  for (int i = 0; i < num_fs; i++)
  { //f increments by df
    f[i] = f_low + i * df;
    phase[i] = rand() % 1000 / 1000.0 * 2 * M_PI;
  }
  Serial.println('o');
}
void miniWaveTankJonswap::update(double sigH, double peakF, double gamma)
{ //updates amp with new values. Called on button press
  Serial.println("updating");
  double Hm0 = sigH / 100; //cm to meters
  double Tp = 1 / peakF;
  //gamma is the same;

  Jonswap *S = new Jonswap(f, Tp, Hm0, gamma);
  for (int i = 0; i < f.size(); i++)
  { //reassign amplitude.
    //System.out.println(""+S.S[i]+"  "+S.f[i]+"  "+f[i]);    //this proves that f and S.f are the same
    amp[i] = sqrt(2 * S->S[i] * 2 * M_PI * df) * 100; //meters to cm
    Serial.print(S->S[i]);
    Serial.print(" ");    
    Serial.print(df);
    Serial.print(" ");
    Serial.println(amp[i]);
  }

  delete S;
  Serial.println("updated");
}

miniWaveTankJonswap::Jonswap::Jonswap(std::vector<double> &f, double Tp, double Hm0, double gamma)
{
  Serial.println('j');
  double g = 9.81;
  double siga = 0.07;
  double sigb = 0.09;
  double fp = 1 / Tp;
  std::vector<double> S_temp(f.size());
  std::vector<double> Gf(f.size());
  std::vector<double> Sf(f.size());
  double alpha_JS = 0;
  double trapz = 0;
  //;
  int i;

  for (i = 0; i < f.size(); i++)
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

  for (i = 0; i < f.size() - 1; i++)
  {
    trapz += (S_temp[i] * Gf[i] + S_temp[i + 1] * Gf[i + 1]) * (f[i + 1] - f[i]) / 2;
  }
  alpha_JS = (Hm0 * Hm0) / 16 / trapz;
  for (i = 0; i < f.size(); i++)
  {
    Sf[i] = alpha_JS * S_temp[i] * Gf[i];
    Serial.println(Sf[i]);	//??
  }
  this->S = Sf;
  this->f = f;
  Serial.println('J');
}

int miniWaveTankJonswap::getNum()
{
  return num_fs;
}

std::vector<float> miniWaveTankJonswap::getAmp()
{
  return copyArraydf(amp);
}

std::vector<float> miniWaveTankJonswap::getPhase()
{
  return copyArraydf(phase);
}

std::vector<float> miniWaveTankJonswap::getF()
{
  return copyArraydf(f);
}

std::vector<float> miniWaveTankJonswap::copyArraydf(std::vector<double> &d)
{ //copies a double array to a float array
  std::vector<float> f(d.size());
  for (int i = 0; i < d.size(); i++)
  {
    f[i] = static_cast<float>(d[i]);
  }
  return f;
}
