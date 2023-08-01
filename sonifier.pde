import beads.*;

//Global variables
boolean songOn;
boolean positionCheck;
boolean checkingTrack;
boolean checkingPlay;
double trackTimer;
WavePlayer positionUsedMelody;
Glide positionUsedGlide;
Gain positionUsedGain;
Glide positionUsedGainGlide;
Gain masterGain;
Glide masterGainGlide;
double waveTimer;
boolean setEnvelope;
SamplePlayer track;
double trackLength;
Gain trackGain;
Glide trackGainGlide;
Bead trackEndListener;
Glide trackRateGlide;
BiquadFilter lowPassFilter;
Glide lowPassGlide;
BiquadFilter highPassFilter;
Glide highPassGlide;
Envelope envelope;
Panner panner;
Glide pannerGlide;


void setupAudio() {
  setupMasterGain();
  setupUgens();
  setupSamplePlayers();
  setupWavePlayers();
  setupInputs();
  ac.out.addInput(masterGain);
}

void setupMasterGain() {
  masterGainGlide = new Glide(ac, 1.0, 1.0);  
  masterGain = new Gain(ac, 2, masterGainGlide);
  
}

void setupUgens() {
  // filters
  highPassGlide = new Glide(ac, 10.0, 500);
  highPassFilter = new BiquadFilter(ac, BiquadFilter.HP, highPassGlide, .5);
  
  
  
  lowPassGlide = new Glide(ac, 10.0, 500);
  lowPassFilter = new BiquadFilter(ac, BiquadFilter.LP, lowPassGlide, .5);
  
  
  // envelopes
  envelope = new Envelope(ac);
  
  // panner
  pannerGlide = new Glide(ac, 2, 5);
  panner = new Panner(ac, pannerGlide);
}

void setupSamplePlayers() {
  
  track = getSamplePlayer("MySong.wav");
  
  trackLength = track.getSample().getLength();
  
  trackRateGlide = new Glide(ac, 0, 500);
  
  track.setRate(trackRateGlide);
  
  trackGainGlide = new Glide(ac, .3 , 1.0);
  trackGain = new Gain(ac, 1 , trackGainGlide);
  
   trackEndListener = new Bead() {
   public void messageReceived(Bead message) {
      SamplePlayer sp = (SamplePlayer) message;
      sp.setEndListener(null);
      //setPlaybackRate(0,true);
    }
   };
  
  
}

void setupWavePlayers() {
  positionUsedGlide = new Glide(ac, 200.0, 0);
  positionUsedMelody = new WavePlayer(ac, positionUsedGlide, Buffer.SINE);
  
  positionUsedGain = new Gain(ac, 2, 0);
  
  
  
}

public void waveCheck() {
  if(positionCheck == true && waveTimer <= 30) {
    if(positionUsedGain.getGain() == 0) {
      envelope.addSegment(.3, 1, 1);
      envelope.addSegment(0, 100, 1);
      positionUsedGain.setGain(envelope);
    }
    waveTimer += 1;

  } else if (waveTimer >= 30) {
    positionCheck = false;
    waveTimer = 0;
    envelope.clear();
    positionUsedGain.setGain(0.0);
  }
}

public void checkingTrack() {
  if(checkingTrack == true && trackTimer <= 75) {
    trackGainGlide.setValue(.1);
    trackTimer +=1;
  } else if (trackTimer >= 75) {
    checkingTrack = false;
    trackGainGlide.setValue(.3);
    trackTimer = 0;
  }
}
  
public void addEndListener() {
  if (track.getEndListener() == null) {
    track.setEndListener(trackEndListener);
  }
}

public void setPlaybackRate(float rate, boolean immediately) {
  if (track.getPosition() < 0) {
    track.reset();
  }
  if (immediately) {
    trackRateGlide.setValueImmediately(rate);
  }
  else {
    trackRateGlide.setValue(rate);
  }
}
public void Play(int val) {
  if (track.getPosition() <= 0) {
    if(trackRateGlide.getValue() == 0) {
       setPlaybackRate(1, false);
    }
    
    if(demoPicked <= 3) {
     demoSelector.hide();
     if(demoPicked == 0) {
       notificationServer.loadEventStream(eventDataJSON1);
      } else if (demoPicked == 1) {
      notificationServer.loadEventStream(eventDataJSON2);
      } else if (demoPicked == 2) {
      notificationServer.loadEventStream(eventDataJSON3);
      }
    }
    checkingPlay = true;
    addEndListener();
    track.start();
    track.setToLoopStart();
  } else {
    resetData();
    if(demoPicked <= 3) {
     demoSelector.hide();
     if(demoPicked == 0) {
       notificationServer.loadEventStream(eventDataJSON1);
      } else if (demoPicked == 1) {
      notificationServer.loadEventStream(eventDataJSON2);
      } else if (demoPicked == 2) {
        notificationServer.loadEventStream(eventDataJSON3);
      }
    }
    timer = 0;
    track.reTrigger();
  }
}

void playPosition(int positionSelected) {
  if(waveTimer == 0) {
    totalAlerts = checkingPlay == true ? totalAlerts + 1 : totalAlerts;
    checkingTrack = true;
    if(positionSelected == 0) {
          positionCheck = true;
          positionUsedGlide.setValue(200);
    } else if (positionSelected == 1) {     
          positionCheck = true;
          positionUsedGlide.setValue(300);        
    } else if (positionSelected == 2) {
          positionCheck = true;
          positionUsedGlide.setValue(400);      
    } else if (positionSelected == 3) {
          positionCheck = true;
          positionUsedGlide.setValue(500);       
    } else if (positionSelected == 4) {     
          positionCheck = true;
          positionUsedGlide.setValue(600);       
    } else if (positionSelected == 5) {       
          positionCheck = true;
          positionUsedGlide.setValue(700);
    }
  }
}

void setupInputs() {
  trackGain.addInput(track);
  highPassFilter.addInput(trackGain);
  lowPassFilter.addInput(trackGain);
  panner.addInput(lowPassFilter);
  panner.addInput(highPassFilter);
  positionUsedGain.addInput(positionUsedMelody);
  panner.addInput(positionUsedGain);
  masterGain.addInput(panner);
}
