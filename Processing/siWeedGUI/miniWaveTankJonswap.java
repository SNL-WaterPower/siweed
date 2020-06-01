import java.util.Random;
import java.lang.Math;
public class miniWaveTankJonswap {
  final static double period = 1024.0/32.0;
  final static double df = 1/period;
  final static double f_low = df*Math.floor(1/df);    //round to the nearest multiple of df
  final static double f_high = df*Math.floor(3/df);

  static int num_fs;    
  static double[] f;
  static double[] amp;
  static double[] phase;// = {3.152416,3.037871,5.045899,3.415424,1.167684,3.443497,3.721319,4.670000,3.773063,5.373082,6.113500,1.607072,5.608919,0.956348,6.036062,1.037471,5.557559,4.663542,1.105112,3.408563,4.351425,4.267931,0.195947,0.738568,3.467186,2.080551,1.471086,0.333220,2.303043,5.546058,5.556698,1.180501,6.169116,4.755245,2.835494,5.268132,5.952006,1.173083,4.801221,2.111487,2.028668,4.333523,0.226176,2.636901,5.026371,2.955182,4.031354,4.803817,4.847541,6.223209,0.417596,5.151822,1.939631,5.052632,1.916994,2.979530,3.140566,5.817336,4.445193,5.076769};

  public miniWaveTankJonswap() {    //constructor
    num_fs = (int)((f_high - f_low)/df);
    f = new double[num_fs];
    amp = new double[num_fs];
    phase = new double[num_fs];
    
    System.out.println(f_low+"  "+f_high+"  "+num_fs+"=?"+(f_high - f_low)/df);

    // f and phase are assigned upon construction
    Random rnd = new Random(123);      //uses a defined seed, so the sequence is the same between runs
    for (int i = 0; i < num_fs; i++) {    //f increments by df
      f[i] = f_low + i*df;
      phase[i] = rnd.nextDouble()*2*Math.PI;;
    }
    /*/////for testing:
    for (int i = 0; i < num_fs; i++) {
      //phase[i] = 2.0 * Math.PI * (float)i/((float)num_fs);
      System.out.println(phase[i]);
    }
    */
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
