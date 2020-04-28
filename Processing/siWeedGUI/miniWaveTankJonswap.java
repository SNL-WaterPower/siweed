import java.util.Random;
public class miniWaveTankJonswap {

  final static double f_low = 2;
  final static double f_high = 4;
  final static double df = 1.0/10.0;

  static int num_fs;    
  static double[] f;
  static double[] amp;
  static double[] phase;

  public miniWaveTankJonswap() {    //constructor
    num_fs = (int)((f_high - f_low)/df); 
    f = new double[num_fs];
    amp = new double[num_fs];
    phase = new double[num_fs];

    // f and phase are assigned upon construction
    for (int i = 0; i < num_fs; i++) {    //f increments by df
      f[i] = f_low + i*df;
    }
    Random rnd = new Random(123);      //uses a defined seed, so the sequence is the same between runs
    for (double d : phase) {    //assigns random numbers to phase
      d = rnd.nextDouble()*2*Math.PI;
    }
  }

  public static void update(double sigH, double peakF, double gamma) {    //updates amp with new values. Called on button press
    double Hm0 = sigH / 100;    //cm to meters
    double Tp = 1 / peakF;
    //gamma is the same;

    Jonswap S = new Jonswap(f, Tp, Hm0, gamma);
    for (int i = 0; i < f.length; i++) {    //reassign amplitude.
      //System.out.println(""+S.S[i]+"  "+S.f[i]+"  "+f[i]);    //this proves that f and S.f are the same
      amp[i] = Math.sqrt(2*S.S[i]*2*Math.PI*df) * 100;    //meters to cm
    }
  }


  private static class Jonswap {
    public double[] f;
    public double[] S;

    public Jonswap(double[] f, double Tp, double Hm0, double gamma) {
      double g = 9.81;
      double siga = 0.07;
      double sigb = 0.09;
      double fp = 1/Tp;
      double[] S_temp = new double[f.length];
      double[] Gf = new double[f.length];
      double[] Sf = new double[f.length];
      double alpha_JS = 0;
      double trapz = 0;
      ;
      int i;

      for (i = 0; i < f.length; i++) {
        if (f[i] <= fp) {
          Gf[i] = Math.pow(gamma, Math.exp(-Math.pow((f[i]-fp), 2)/(2*Math.pow(siga, 2)*Math.pow(fp, 2))));
        } else {
          Gf[i] = Math.pow(gamma, Math.exp(-Math.pow((f[i]-fp), 2)/(2*Math.pow(sigb, 2)*Math.pow(fp, 2))));
        }
        S_temp[i] = Math.pow(g, 2) * Math.pow((2*Math.PI), -4) * Math.pow(f[i], -5) * Math.exp(-(5/4)*Math.pow(f[i]/fp, -4));
      }

      //trapezoidal rule

      for (i = 0; i < f.length - 1; i++) {
        trapz += (S_temp[i]*Gf[i] + S_temp[i+1]*Gf[i+1]) * (f[i+1]-f[i])/2;
      }
      alpha_JS = (Hm0*Hm0)/16/trapz;
      for (i = 0; i < f.length; i++) {
        Sf[i] = alpha_JS * S_temp[i] * Gf[i];
      }
      this.S = Sf;
      this.f = f;
    }
  }
  public int getNum() {
    return num_fs;
  }
  public float[] getAmp() {
    return copyArraydf(amp);
  }
  public float[] getPhase() {
    return copyArraydf(phase);
  }
  public float[] getF() {
    return copyArraydf(f);
  }
  float[] copyArraydf(final double[] d) {    //copies a double array to a float array
    float[] f = new float[d.length];
    for (int i = 0; i < d.length; i++) {
      f[i] = (float)d[i];
    }
    return f;
  }
}
