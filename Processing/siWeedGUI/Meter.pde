import java.util.LinkedList;
import java.util.Queue;

public class Meter {
  int xmin = 1350*width/1920;      //coordinates in pixels
  int xmax = 1854*width/1920;
  int ymin = 725*height/1100;
  int ymax = ymin+270*height/1100;

  Queue<Float> q;      //queue for moving average
  int buffSize = 25;
  float averageVal;
  int originx, originy;
  float minVal, maxVal;
  int divisionCount = 5, subDivisionCount = 5;    //how many large lines and numbers, and how subdivisions per division.
  float radiansPerSubDivision;
  int arcR, labelR, markR;
  float LMarkSize = 0.2;    //amount of large mark shown relative to radius
  public Meter(float min, float max) {
    q = new LinkedList<Float>();    //initialize queue
    originx = xmin + (xmax-xmin)/2;
    originy = ymin + (ymax-ymin) - height/75;    //slightly above frame
    minVal = min;
    maxVal = max;
    if ((ymax-ymin) < 0.5*(xmax-xmin)) {      //scales by whichever axis is smaller. Meter is twice as wide as it is tall
      arcR = (int)((ymax-ymin) * 0.6); 
      labelR = (int)(arcR + height/60);    //slightly more than arc
      markR = (int)(arcR - height/100);
    } else {
      arcR = (int)((xmax-xmin) * 0.3); 
      labelR = (int)(arcR + width/105);    //slightly more than arc
      markR = (int)(arcR - width/175);
    }
    radiansPerSubDivision = PI/divisionCount/subDivisionCount;
  }
  public void update(float val) {
    strokeWeight(height/200);    //relative to frame size
    stroke(turq);    //border color
    fill(buttonblue);            //background color
    //rect(xmin, ymin, xmax - xmin, ymax - ymin, 7);      //background and border    //moved to displayUpdate()
    stroke(white);
    noFill();
    arc(originx, originy, arcR*2, arcR*2, PI, 2 * PI);    //solid arc
    strokeWeight(height/150);
    point(originx, originy);    //origin point
    //draw numbers:
    textFont(fb, 14*height/1100);
    textAlign(CENTER);
    fill(white);
    for (int i=0; i <= divisionCount; i++) {
      float labelVal = minVal + i*(float)(maxVal-minVal)/(float)divisionCount;
      labelVal = (round(labelVal*100))/100.0;    //rounds
      String label = String.valueOf(labelVal);
      float angle = PI*((float)i/(float)divisionCount);    //angle in radians
      int labelx = (int)(originx - labelR*Math.cos(angle));
      int labely = (int)(originy - labelR*Math.sin(angle));
      text(label, labelx, labely);
    }
    //draw division lines:
    //big division lines will show more percesntage of markR with bigger stroke, small will show less percent of radius
    for (int i=0; i <= divisionCount; i++) {      //draw big line
      float angle = PI*((float)i/(float)divisionCount);    //angle in radians
      float RCos = (float)markR*(float)Math.cos(angle);
      float RSin = (float)markR*(float)Math.sin(angle);
      strokeWeight(height/400);
      int markAX = (int)(originx - RCos);
      int markAY = (int)(originy - RSin);
      int markBX = (int)(originx - (1.0-LMarkSize) * RCos);
      int markBY = (int)(originy - (1.0-LMarkSize) * RSin);
      line(markAX, markAY, markBX, markBY);    //draws line from point A to B
      for (int j=0; j <= subDivisionCount && i < divisionCount; j++) {    //draw small lines between big lines   //varibales here markes S for small
        float angleS = angle + j * radiansPerSubDivision;    //angle in radians
        float RCosS = (float)markR*(float)Math.cos(angleS);
        float RSinS = (float)markR*(float)Math.sin(angleS);
        strokeWeight(height/700);
        int markAXS = (int)(originx - (1.0-LMarkSize/2.0) * RCosS);
        int markAYS = (int)(originy - (1.0-LMarkSize/2.0) * RSinS);
        int markBXS = (int)(originx - (1.0-LMarkSize) * RCosS);
        int markBYS = (int)(originy - (1.0-LMarkSize) * RSinS);
        line(markAXS, markAYS, markBXS, markBYS);    //draws line from point A to B
      }
    }
    if (!Float.isNaN(val)) {    //verify that val is float
      q.add(val);
    }
    if (q.size() > buffSize) {
      q.remove();
    }
    averageVal = 0;
    for (int i = 0; i < q.size(); i++) {      //find sum by removing and adding to queue
      float temp = q.remove();
      averageVal += temp;
      q.add(temp);
    }
    averageVal = averageVal/q.size();      //finds moving average
    if (averageVal > maxVal) {
      averageVal = maxVal;
    } else if (averageVal < minVal) {
      averageVal = minVal;
    }
    stroke(red);
    strokeWeight(height/300); 
    float angle = PI*((averageVal-minVal)/(maxVal-minVal));    //angle in radians  
    float RCos = (float)arcR*(float)Math.cos(angle);
    float RSin = (float)arcR*(float)Math.sin(angle);
    int markX = (int)(originx - RCos);
    int markY = (int)(originy - RSin);
    line(originx, originy, markX, markY);    //draws line from point A to B
  }
  public float getAverageVal() {
    return averageVal;
  }
}
