class BandPass {
  float[] gains = new float[]{0.387508570552039854906212212881655432284, 0.387508570552039854906212212881655432284}; 
  float[][] numerator = new float[][]{ {1, 0, -1}, {1, 0, -1} };
  float [][] denominator = new float[][]{ {1, -1.970406888471329054368652577977627515793, 0.970854770517962095688346835231641307473}, {1, -0.643377170931628050709605304291471838951, 0.253626930077802126284325368033023551106} };
  LinkedList<Float> wOut1, yOut, wOut2;
  int BPBufferSize = 3;
  public BandPass() {
    wOut1 = new LinkedList<Float>();
    yOut = new LinkedList<Float>();
    wOut2 = new LinkedList<Float>();
    for (int i = 0; i < BPBufferSize; i++) {
      wOut1.add(0f);
      yOut.add(0f);
      wOut2.add(0f);
    }
  }
  public float update(float val) {
    //incrementBuff(val,xIn);
    float temp = gains[0]*val - denominator[0][1]*wOut1.get(wOut1.size()-1) - denominator[0][2]*wOut1.get(wOut1.size()-2);
    incrementBuff(temp, wOut1);
    temp = numerator[0][0]*wOut1.get(wOut1.size()-1) + numerator[0][1]*wOut1.get(wOut1.size()-2) + numerator[0][2]*wOut1.get(wOut1.size()-3);
    incrementBuff(temp, yOut);
    temp = gains[1]*yOut.peekLast() - denominator[1][1]*wOut2.get(wOut1.size()-1) - denominator[1][2]*wOut2.get(wOut1.size()-2);
    incrementBuff(temp, wOut2);
    float yOut2 = numerator[1][0]*wOut2.get(wOut1.size()-1) + numerator[1][1]*wOut2.get(wOut1.size()-2) + numerator[1][2]*wOut2.get(wOut1.size()-3);
    return yOut2;
  }
  void incrementBuff(float val, LinkedList<Float> l) {
    l.add(val);
    l.remove();
  }
}
