public class miniWaveTankJonswap{
    public static void main(String[] args){
        int i;
        double Hm0 = Double.parseDouble(args[0]);
        double Tp = Double.parseDouble(args[1]);
        double gamma = Double.parseDouble(args[2]);
    
        double f_low = 2;
        double f_high = 4;
        double df = 1/30;

        int num_fs = (int)((f_high - f_low)/df);
        double[] f = new double[num_fs];
    
        for(i = 0; i < num_fs; i++){
            f[i] = f_low + i*df;
        }
        Jonswap S = new Jonswap(f, Tp, Hm0, gamma);
        for(i = 0; i < f.length; i++){
            System.out.println(""+S.S[i]+"  "+S.f[i]);
        }
    }

    
    private static class Jonswap{
        public double[] f;
        public double[] S;

        public Jonswap(double[] f, double Tp, double Hm0, double gamma){
            double g = 9.81;
            double siga = 0.07;
            double sigb = 0.09;
            double fp = 1/Tp;
            double[] S_temp = new double[f.length];
            double[] Gf = new double[f.length];
            double[] Sf = new double[f.length];
            double alpha_JS = 0;
            double trapz = 0;;
            int i;

            for(i = 0; i < f.length; i++){
                if(f[i] <= fp){
                    Gf[i] = Math.pow(gamma, Math.exp(-Math.pow((f[i]-fp),2)/(2*Math.pow(siga,2)*Math.pow(fp,2))));
                }
                else{
                    Gf[i] = Math.pow(gamma, Math.exp(-Math.pow((f[i]-fp),2)/(2*Math.pow(sigb,2)*Math.pow(fp,2))));
                }
                S_temp[i] = Math.pow(g,2) * Math.pow((2*Math.PI),-4) * Math.pow(f[i],-5) * Math.exp(-(5/4)*Math.pow(f[i]/fp,-4));
            }
            
            //trapezoidal rule

            for(i = 0; i < f.length - 1; i++){
                trapz += (S_temp[i]*Gf[i] + S_temp[i+1]*Gf[i+1]) * (f[i+1]-f[i])/2;
            }
            alpha_JS = (Hm0*Hm0)/16/trapz;
            for(i = 0; i < f.length; i++){
                Sf[i] = alpha_JS * S_temp[i] * Gf[i];
            }
            this.S = Sf;
            this.f = f;
        }
    }
}
