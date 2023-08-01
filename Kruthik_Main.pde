import controlP5.*;
import beads.*;
import java.util.*; 
import java.util.Calendar;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

//Global variables
ControlP5 p5;
int totalAlerts;
float totalTimeOfWorkout;
float timer;
boolean mutedRun;
float previousMasterVal;
Toggle muteToggler;
Slider volume;
Slider legPlacement;
Slider rollingOff;
Slider midlineCloseness;
Button topLeftAlarm;
Button topRightAlarm;
Button sideRightAlarm;
Button sideLeftAlarm;
Button bottomRightAlarm;
Button bottomLeftAlarm;
Button playButton;
RadioButton demoSelector;
int demoPicked = 3;
String eventDataJSON1 = "RollStraight2.json";
String eventDataJSON2 = "RollUphill2.json";
String eventDataJSON3 = "AroundCone2.json";
NotificationServer notificationServer;
ArrayList<Notification> notifications;
MyNotificationListener myNotificationListener;


void setup() {
  size(800, 350);
  
  ac = new AudioContext();
  p5 = new ControlP5(this);
  setupAudio();
  notificationServer = new NotificationServer();
  
  myNotificationListener = new MyNotificationListener();
  notificationServer.addListener(myNotificationListener);
  
  //Setting up sliders and buttons needed
 topLeftAlarm = p5.addButton("TopLeft") 
    .setPosition(150, 125)
    .setSize(90, 20)
    .setLabel("Top Left");
  topRightAlarm = p5.addButton("TopRight") 
    .setPosition(150, 155)
    .setSize(90, 20)
    .setLabel("Top Right");
  sideRightAlarm = p5.addButton("SideRight")
    .setPosition(150, 185)
    .setSize(90, 20)
    .setLabel("Side Right");
  sideLeftAlarm = p5.addButton("SideLeft")
    .setPosition(150, 215)
    .setSize(90, 20)
    .setLabel("Side Left");
  bottomRightAlarm = p5.addButton("BottomRight")
    .setPosition(150, 245)
    .setSize(90, 20)
    .setLabel("Bottom Right");
  bottomLeftAlarm = playButton = p5.addButton("BottomLeft")
    .setPosition(150, 275)
    .setSize(90, 20)
    .setLabel("Bottom Left");
  
  
  playButton = p5.addButton("Play")
    .setPosition(300, 215)
    .setSize(190, 20)
    .setLabel("Play");
    
  midlineCloseness = p5.addSlider("MidlineCloseness")
    .setPosition(575,50)
    .setRange(-100,100)
    .setNumberOfTickMarks(6)
    .snapToTickMarks(true)
    .setLabel("Midline Closeness");
    
  rollingOff = p5.addSlider("rollingOff")
    .setPosition(325, 50)
    .setNumberOfTickMarks(6)
    .snapToTickMarks(false)
    .setRange(0.95, 1.05)
    .setValue(1)
    .setLabel("Rolling Off");
    
  legPlacement = p5.addSlider("legPlacement")
    .setPosition(75, 50)
    .setNumberOfTickMarks(6)
    .snapToTickMarks(false)
    .setRange(-1, 1)
    .setValue(0)
    .setLabel("Leg Placement");
    
 volume = p5.addSlider("volume")
    .setPosition(75,125)
    .setSize(15,170)
    .setRange(0,100)
    .setValue(50)
    .setLabel("Volume");
    
  p5.addButton("reset")
    .setPosition(300, 245)
    .setSize(190, 20)
    .setLabel("Reset");
    
  muteToggler = p5.addToggle("mute")
    .setPosition(300, 275)
    .setSize(190, 20)
    .setValue(false);

    
  demoSelector = p5.addRadioButton("demoSelection")
    .setPosition(300,125)
    .setSize(25,25)
    .setSpacingRow(20)
    .setSpacingColumn(90)
    .setItemsPerRow(2)
    .addItem("Roll Straight", 0)
    .addItem("Roll Uphill", 1)
    .addItem("Around Cone",2)
    .addItem("Try it!", 3)
    .activate(3);
  ac.start();
 
}

void demoSelection(int selection) {
  if(selection <= 2) {
    topLeftAlarm.hide();
    topRightAlarm.hide();
    sideLeftAlarm.hide();
    bottomLeftAlarm.hide();
    sideRightAlarm.hide();
    bottomRightAlarm.hide();
    rollingOff.hide();
    legPlacement.hide();
    midlineCloseness.hide();
    if (selection == 0) {
      demoPicked = 0;
    } else if (selection == 1) {
      demoPicked = 1;
    } else if (selection == 2) {
      demoPicked = 2;
    } 
  } else if (selection == 3) {
      demoPicked = 3;
      topLeftAlarm.show();
      topRightAlarm.show();
      sideRightAlarm.show();
      bottomRightAlarm.show();
      sideLeftAlarm.show();
      bottomLeftAlarm.show();
      rollingOff.show();
      legPlacement.show();
      midlineCloseness.show();
  }
}


void TopLeft() {
  playPosition(0);
}

void TopRight() {
  playPosition(1);
}

void SideRight() {
  playPosition(2);
}

void SideLeft() {
  playPosition(3);
}

void BottomRight() {
  playPosition(4);
}

void BottomLeft() {
  playPosition(5);
}
void MidlineCloseness(float val) {
  if (val < 0) {
    lowPassFilter.pause(false);
    lowPassGlide.setValue((2600.0/ (-val/60)));
    highPassFilter.pause(true);
  } else if (val > 0) {
    lowPassFilter.pause(true);
    highPassFilter.pause(false);
    highPassGlide.setValue(5 * val);
  } else if (val == 0) {
    highPassGlide.setValue(1);
    highPassFilter.pause(false);
    lowPassFilter.pause(true);
  }
}

void rollingOff(float val) {
  if(trackRateGlide.getValue() != 0) {
     trackRateGlide.setValue(val);
  }
}
  
void legPlacement(float val) {
  pannerGlide.setValue(val);
}

void volume(float val) {
  masterGainGlide.setValue(val/40);
}


void mute(boolean val) {
  if(val == true) {
    previousMasterVal = masterGainGlide.getValue();
    masterGainGlide.setValue(0);
    volume.hide();
  } else if(val == false && masterGainGlide.getValue() == 0) {
    volume.show();
    masterGainGlide.setValue(previousMasterVal);
  }
}

void reset() {
  resetData();
  checkingPlay = false;
  timer = 0;
}



class MyNotificationListener implements NotificationListener {
  
  public MyNotificationListener() {
    //setup here
  }
  
  public void notificationReceived(Notification notification) { 
    println("<Example> " + notification.getType().toString() + " notification received at " 
    + Integer.toString(notification.getTimestamp()) + " ms");
    
    String debugOutput = ">>> ";
    switch (notification.getType()) {
      case legPlacement:
        legPlacement.setValue(notification.getIntensity());
        break;
      case rollingOff:
        rollingOff.setValue(notification.getIntensity());
        break;
      case positionOff:
        playPosition(notification.getPosition());
        break;
      case midlineCloseness:
        midlineCloseness.setValue(notification.getIntensity());
        break;
    }
    debugOutput += notification.toString();
    //debugOutput += notification.getLocation() + ", " + notification.getTag();
    
    println(debugOutput);
  }
}

void resetData() {
 demoSelector.show();
 waveTimer = 0;
 trackTimer = 0;
 notificationServer.stopEventStream();
 muteToggler.setValue(false);
 muteToggler.show();
 totalAlerts = 0;
 rollingOff.setValue(1);
 midlineCloseness.setValue(0);
 legPlacement.setValue(0);
 track.reset();
 track.pause(true);
}
void draw() {
  if(checkingPlay == true) {
     timer++;
     muteToggler.hide();
  }
  
  waveCheck();
  checkingTrack();
  background(0);
  text("Muted:   " + String.format("%.02f", muteToggler.getValue()), 575, 225);
  text("Alerts:    " + String.format("%.02f", float(totalAlerts)), 575, 200);
  text("Total Time:                        " + String.format("%.02f", timer/60), 575, 175);
  
}

interface NotificationListener {
  void notificationReceived(Notification notification);
}



class NotificationServer {
  
  Boolean debugMode = true; //set this to false to turn off the println statements on each Notification below
  
  Timer timer;
  Calendar calendar;
  private ArrayList<NotificationListener> listeners;
  private ArrayList<Notification> currentNotifications;
  long startTime;
  long pauseTime;

  public NotificationServer() {
    timer = new Timer();
    listeners = new ArrayList<NotificationListener>();
    calendar = Calendar.getInstance();
  }
  
  public void loadEventStream(String eventDataJSON) {
    currentNotifications = this.getNotificationDataFromJSON(loadJSONArray(eventDataJSON));
    
    Date date = new Date();
    startTime = date.getTime();
    println("startTime = ", startTime);
    for (int i = 0; i < currentNotifications.size(); i++) {
      this.scheduleTask(currentNotifications.get(i));
    } 
  }
  
  public void stopEventStream() {
    pauseTime = 0;
    this.stopTimer();
  }
  
  public void pauseEventStream() {
    Date date = new Date();
    pauseTime = date.getTime() - startTime;
    this.stopTimer();
  }
  
  private void stopTimer() {
    if (timer != null)
      timer.cancel(); 
    timer = new Timer();  
  }
  
  public ArrayList<Notification> getCurrentNotifications() {
    return currentNotifications;
  }
  
  public ArrayList<Notification> getNotificationDataFromJSON(JSONArray values) {
    ArrayList<Notification> notifications = new ArrayList<Notification>();
    for (int i = 0; i < values.size(); i++) {
      println(values.getJSONObject(i));
      notifications.add(new Notification(values.getJSONObject(i)));
    }
    return notifications;
  }

  public void scheduleTask(Notification notification) {
    if (notification.getTimestamp() >= pauseTime) {
      timer.schedule(new NotificationTask(this, notification), notification.getTimestamp() - pauseTime);
    }
  }
  
  public void addListener(NotificationListener listenerToAdd) {
    listeners.add(listenerToAdd);
  }
  
  public void notifyListeners(Notification notification) {
    if (debugMode)
      println("<NotificationServer> " + notification.toString());
    for (int i=0; i < listeners.size(); i++) {
      listeners.get(i).notificationReceived(notification);
    }
  }
  

  class NotificationTask extends TimerTask {
    
    NotificationServer server;
    Notification notification;
    
    public NotificationTask(NotificationServer server, Notification notification) {
      super();
      this.server = server;
      this.notification = notification;
    }
    
    public void run() {
      server.notifyListeners(notification);
    }
    
  }
}
