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
}
