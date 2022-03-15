import java.util.LinkedList;
import java.lang.Math.*;

LinkedList<Float>[] tests = new LinkedList[4];
LinkedList<Float>[] outputs = new LinkedList[4];
LinkedList<Float>[] queues = new LinkedList[4];
void setup()
{
  size(1500, 750);
  //for(LinkedList<Float> l : tests){
  //  l = new LinkedList<Float>();
  //}
  for (int i = 0; i < 4; i++) {
    tests[i] = new LinkedList<Float>();
    queues[i] = new LinkedList<Float>();
    outputs[i] = new LinkedList<Float>();
  }
  for (int i = 0; i < 300; i++) {
    tests[0].add(sin(2f * PI * (float)i * 0.05f/30f));      //sin (2pi * hz/fs)
    tests[1].add(sin(2f * PI * (float)i * 20f/30f));
    tests[2].add(sin(2f * PI * (float)i * 3f/30f)); 
    tests[3].add(cos(2f * PI * (float)i * 20f/30f)+sin(2f * PI * i * 3f/30f)+5f);
    for (int j = 0; j < 4; j++) {
      outputs[j].add(bandPass(tests[j].getLast(), queues[j]));
    }
  }
  for (int i = 0; i < 4; i++) {
    plot(i, 0, tests[i]);
    plot(i, 1, outputs[i]);
  }
}
void plot(int yIndex, int xIndex, LinkedList<Float> l) {
  float lastValue = l.get(0);
  int lastX = 10 + (xIndex) * width/2;
  //int lastY = 10 + (yIndex+1) * height/5;
  int lastY =  (yIndex+1) * height/6;
  int size = l.size();
  line(lastX, lastY, lastX+width, lastY);
  for (int i = 1; i < size; i++) {
    //to do: make this plot not work on delta values
    float temp = l.get(i);
    int newX = (int)( 1f/((float)size) * width/2 ) + lastX;
    int newY = (int)((temp)*30f) + (yIndex+1) * height/6;
    line(lastX, lastY, newX, newY);
    lastX = newX; 
    lastY = newY;
    lastValue = temp;
  }
}
void draw()
{
  //float a = 0.0;
  //float inc = TWO_PI/25.0;
  //float prev_x = 0, prev_y = 50, x, y;

  //for (int i=0; i<100; i=i+4) {
  //  x = i;
  //  y = 50 + sin(a) * 40.0;
  //  line(prev_x, prev_y, x, y);
  //  prev_x = x;
  //  prev_y = y;
  //  a = a + inc;
  //}
}
float[] gains = new float[]{0.387508570552039854906212212881655432284, 0.387508570552039854906212212881655432284}; 
float[][] numerator = new float[][]{ {1, 0, -1}, {1, 0, -1} };
float [][] denominator = new float[][]{ {1, -1.970406888471329054368652577977627515793, 0.970854770517962095688346835231641307473}, {1, -0.643377170931628050709605304291471838951, 0.253626930077802126284325368033023551106} };
float bandPass(float val, LinkedList<Float> q) {
  int bufferSize = 20;    //based on the filter
  if (!Float.isNaN(val)) {    //verify that val is float
    q.add(val);
  }
  if (q.size() > bufferSize) {
    q.remove();
    /////only filter if populated
    Float xm1, xm2, wm1, wm2;
    Float[] xin = new Float[bufferSize], yOut = new Float[bufferSize], wOut = new Float[bufferSize];
    Float[] sig = q.toArray(new Float[q.size()]);
    for (int k = 0; k < gains.length; k++) {
      if (k == 0) {
        xin = sig;
      } else {
        xin = yOut;
      }
      for (int kk = 0; kk< q.size(); kk++) {
        if (kk == 0) {
          xm2 = 0f;
          xm1 = 0f;
          wm2 = 0f;
          wm1 = 0f;
        } else if (kk == 1) {
          xm2 = 0f;
          xm1 = xin[kk-1];
          wm2 = 0f;
          wm1 = wOut[kk-1];
        } else {
          xm2 = xin[kk-2];
          xm1 = xin[kk-1];
          wm2 = wOut[kk-2];
          wm1 = wOut[kk-1];
        }
        wOut[kk] = gains[k]*xin[kk] - denominator[k][1] * wm1 - denominator[k][2]*wm2;
        yOut[kk] = numerator[k][0]*wOut[kk] + numerator[k][1]*wm1 + numerator[k][2]*wm2;
      }
    }
    return yOut[bufferSize-1];
  } else {    //if not populated, return last val
    return q.getLast();
  }
}
//float bandPass(float val, LinkedList<Float> q){
//  if (!Float.isNaN(val)) {    //verify that val is float
//      q.add(val);
//  }
//  if (q.size() > 3) {
//    q.remove();
//    /////only filter if populated
//    float xm1, xm2, wm1, wm2;
//    LinkedList<Float> xin = new LinkedList<Float>();
//    LinkedList<Float> yOut = new LinkedList<Float>();
//    LinkedList<Float> wOut = new LinkedList<Float>();

//    for(int k = 0; k < gains.length; k++) {
//      if (k == 0){
//        xin = (LinkedList<Float>) q.clone();
//      }else{
//        xin = (LinkedList<Float>) yOut.clone();
//      }

//      for(int kk = 0; kk< q.size(); kk++){
//        if (kk == 0){
//            xm2 = 0;
//            xm1 = 0;
//            wm2 = 0;
//            wm1 = 0;
//        } else if (kk == 1){
//            xm2 = 0;
//            xm1 = xin.get(xin.size() - 3);
//            wm2 = 0;
//            wm1 = wOut.get(wOut.size() - 3);
//        }else{
//            xm2 = xin.get(xin.size() - 3);
//            xm1 = xin.get(xin.size() - 2);
//            wm2 = wOut.get(wOut.size() - 3);
//            wm1 = wOut.get(wOut.size() - 2);
//        }
//        wOut.add(gains[k]*xin.getLast() - denominator[k][1] * wm1 - denominator[k][2]*wm2);
//        yOut.add(numerator[k][0]*wOut.getLast() + numerator[k][1]*wm1 + numerator[k][2]*wm2);
//      }
//    }
//    return yOut.getLast();
//  } else {    //if not populated, return last val
//    return q.getLast();
//  }
//}
