Table table;  //table for data logging
//Table FFTTable;
Table TSTable;
String startTime;
//Variables to be logged:
public class UIData {        //an object for the WEC and Wavemaker portions of the UI to use
  public int mode;
  public float mag, amp, freq, sigH, peakF, gamma;
}
//data not held in the class(not in the UI):
float probe1, probe2, waveMakerPos, debugData, wecPos, tau, pow;
UIData waveMaker;
UIData wec;
void initializeDataLogging() {
  startTime = month() + "-" + day() + "-" + year() + "_" + hour() + "-" + minute() + "-" + second();
  //Table initialization:
  table = new Table();
  table.addColumn("timeStamp");
  table.addColumn("UIWaveMakerMode");
  table.addColumn("UIWaveMakerPos");
  table.addColumn("UIWaveMakerHeight");
  table.addColumn("UIWaveMakerFrequency");
  table.addColumn("UIWaveMakerSigH");
  table.addColumn("UIWaveMakerPeakF");
  table.addColumn("UIWaveMakergamma");
  table.addColumn("UIWecMode");
  table.addColumn("UIWecTorque");
  table.addColumn("UIWeckP");
  table.addColumn("UIWeckD");
  table.addColumn("UIWecHeight");
  table.addColumn("UIWecFrequency");
  table.addColumn("UIWecSigH");
  table.addColumn("UIWecPeakF");
  table.addColumn("UIWecgamma");
  table.addColumn("probe1");
  table.addColumn("probe2");
  table.addColumn("waveMakerPos");
  table.addColumn("waveMakerDebugData");
  table.addColumn("wecPos");
  table.addColumn("wecTau");
  table.addColumn("wecPower");
/*
  //isolated .csv's
  FFTTable = new Table();
  for (int i = 0; i < queueSize *2; i++) {
    FFTTable.addColumn("FFT "+Integer.toString(i));
  }
  */
  TSTable = new Table();
  TSTable.addColumn("time");
  TSTable.addColumn("height");
  
}
//Funciton to test CSV functionality
void logData() {     //will be called at the framerate
  TableRow newRow = table.addRow();
  newRow.setFloat("timeStamp", millis());
  newRow.setInt("UIWaveMakerMode", waveMaker.mode);
  newRow.setFloat("UIWaveMakerPos", waveMaker.mag);
  newRow.setFloat("UIWaveMakerHeight", waveMaker.amp);
  newRow.setFloat("UIWaveMakerFrequency", waveMaker.freq);
  newRow.setFloat("UIWaveMakerSigH", waveMaker.sigH);
  newRow.setFloat("UIWaveMakerPeakF", waveMaker.peakF);
  newRow.setFloat("UIWaveMakergamma", waveMaker.gamma);
  newRow.setFloat("UIWecMode", wec.mode);
  newRow.setFloat("UIWecTorque", wec.mag);
 // newRow.setFloat("UIWeckP", positionTorque.getValue()); //may want to change these names
 // newRow.setFloat("UIWeckS", spring.getValue()); //may want to change these names
 // newRow.setFloat("UIWeckD", damper.getValue()); //may want to change these names
  newRow.setFloat("UIWecHeight", wec.amp);
  newRow.setFloat("UIWecFrequency", wec.freq);
  newRow.setFloat("UIWecSigH", wec.sigH);
  newRow.setFloat("UIWecPeakF", wec.peakF);
  newRow.setFloat("UIWecgamma", wec.gamma);
  newRow.setFloat("probe1", probe1);
  newRow.setFloat("probe2", probe2);
  newRow.setFloat("waveMakerPos", waveMakerPos);
  newRow.setFloat("waveMakerDebugData", debugData);
  newRow.setFloat("wecPos", wecPos);
  newRow.setFloat("wecTau", tau);
  newRow.setFloat("wecPower", pow);
  saveTable(table, "data/"+startTime+".csv");

  //isolated .csvs for testing:
  /*
  if (millis() > 40000 && millis() < 41000)    //save conditions(so not all data is captured)
  {
    TableRow FFTRow = FFTTable.addRow();
    for (int i = 0; i < queueSize *2; i++) {
      FFTRow.setFloat("FFT "+Integer.toString(i), fftArr[i]);
    }
    saveTable(FFTTable, "data/vars/FFT"+startTime+".csv");
  }
  */
  TableRow TSRow = TSTable.addRow();
  TSRow.setFloat("time", (millis()/1000.0 - 2.0));
  TSRow.setFloat("height", debugData);
  saveTable(TSTable, "data/vars/TS"+startTime+".csv");
} 
