enum RollingType { 
  legPlacement, 
  rollingOff, 
  positionOff, 
  midlineCloseness 
}

class Notification {
   
  int timestamp;
  RollingType type; 
  float intensity;
  int positionNum;
  
  public Notification(JSONObject json) {
    this.timestamp = json.getInt("timestamp");
    
    String typeString = json.getString("type");
    
    try {
      this.type = RollingType.valueOf(typeString);
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException("That type does not exist, check your JSON file!");
    }
    
    
    
    this.intensity = json.getFloat("intensity");
    
    this.positionNum = json.getInt("positionNum");      
       
  }
  
  public int getTimestamp() { return timestamp; }
  public RollingType getType() { return type; }
  public float getIntensity() { return intensity; }
  public int getPosition() { return positionNum; }
  
  public String toString() {
      String output = getType().toString() + ": ";
      output += "(Intensity: " + getIntensity() + ") ";
      output += "(Leg Position: " + getPosition() + ") ";
      return output;
    }
}
