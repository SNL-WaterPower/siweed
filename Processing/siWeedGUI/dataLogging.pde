import java.io.BufferedWriter;
import java.io.FileWriter;
String startTime;
//Variables to be logged:
public class UIData {        //an object for the WEC and Wavemaker portions of the UI to use
  public int mode;
  public float mag, amp, freq, sigH, peakF, gamma;      //for wec, amp is kp and freq is kd;
}
//data not held in the class(not in the UI):
float probe1, probe2, waveMakerPos, debugData, wecPos, tau, pow, wecVel;
String path, csvData;
UIData waveMaker;
UIData wec;
void initializeDataLogging() {
  startTime = month() + "-" + day() + "-" + year() + "_" + hour() + "-" + minute() + "-" + second();
  //path = "data/"+startTime+".csv";
  path = startTime+".csv";
  csvData =       //this is the titles of the columns, written at the top of the .csv
  "timeStamp,"
  +"UIWaveMakerMode,"
  +"UIWaveMakerPos,"
  +"UIWaveMakerHeight,"
  +"UIWaveMakerFrequency,"
  +"UIWaveMakerSigH,"
  +"UIWaveMakerPeakF,"
  +"UIWaveMakergamma,"
  +"UIWecMode,"
  +"UIWecTorque,"
  +"UIWeckP,"
  +"UIWeckD,"
  +"UIWecSigH,"
  +"UIWecPeakF,"
  +"UIWecgamma,"
  +"probe1,"
  +"probe2,"
  +"waveMakerPos,"
  +"waveMakerDebugData,"
  +"wecPos,"
  +"wecTau,"
  +"wecPower,"
  +"wecVel"
  ;
  appendTextToFile(path, csvData);
}
//Funciton to test CSV functionality
void logData() {     //will be called at the framerate
  csvData = 
  String.valueOf(millis())+','+
  String.valueOf(waveMaker.mode)+','+
  String.valueOf(waveMaker.mag)+','+
  String.valueOf(waveMaker.amp)+','+
  String.valueOf(waveMaker.freq)+','+
  String.valueOf(waveMaker.sigH)+','+
  String.valueOf(waveMaker.peakF)+','+
  String.valueOf(waveMaker.gamma)+','+
  String.valueOf(wec.mode)+','+
  String.valueOf(wec.mag)+','+
  String.valueOf(wec.amp)+','+
  String.valueOf(wec.freq)+','+
  String.valueOf(wec.sigH)+','+
  String.valueOf(wec.peakF)+','+
  String.valueOf(wec.gamma)+','+
  String.valueOf(probe1)+','+
  String.valueOf(probe2)+','+
  String.valueOf(waveMakerPos)+','+
  String.valueOf(debugData)+','+
  String.valueOf(wecPos)+','+
  String.valueOf(tau)+','+
  String.valueOf(pow)+','+
  String.valueOf(wecVel)
  ;
  appendTextToFile(path, csvData);
} 
/**https://stackoverflow.com/questions/17010222/how-do-i-append-text-to-a-csv-txt-file-in-processing
 * Appends text to the end of a text file located in the data directory, 
 * creates the file if it does not exist.
 * Can be used for big files with lots of rows, 
 * existing lines will not be rewritten
 */
void appendTextToFile(String filename, String text) {    //writes a line to the given file
  File f = new File(dataPath(filename));
  if (!f.exists()) {
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

/**
 * Creates a new file including all subfolders
 */
void createFile(File f) {
  File parentDir = f.getParentFile();
  try {
    parentDir.mkdirs(); 
    f.createNewFile();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}    
