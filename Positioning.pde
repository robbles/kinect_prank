class Marker {
  float ERROR_MARGIN = 180.0;
  PVector position;
  PVector screen;
  float screenWidth;
  String label;
  float labelWidth;
  boolean dummy;

  Marker(String label, int x, int y, int z) {
    this.position = new PVector(x, y, z);
    this.screen = convertPoint(this.position);
    this.screenWidth = 100.0 - (z / 50.0);
    this.label = label;
    this.labelWidth = textWidth(label);
    this.dummy = false;
  }
  
  Marker() {
    this.dummy = true;
  }

  boolean touching(PVector limb) {
    if(this.dummy) { return true; }
    return this.position.dist(limb) < ERROR_MARGIN;
  }

  void draw(boolean highlighted) {
    if(this.dummy) { return; }
    color fill;
    if (highlighted) {
      fill = color(0, 255, 0);
      stroke(fill, 150);
      strokeWeight(2);
      fill(fill, 100);
      ellipse(this.screen.x, this.screen.y, this.screenWidth+10, this.screenWidth+10);
    } 
    else {
      fill = color(255, 0, 0);
      stroke(fill, 80);
      strokeWeight(2);
      fill(fill, 50);
      ellipse(this.screen.x, this.screen.y, this.screenWidth, this.screenWidth);
      
      fill(fill, 200);
      text(this.label, this.screen.x - this.labelWidth / 2.0, this.screen.y - this.screenWidth / 2 - 10.0);
    }
  }
}

class Pose {
  String instructions;
  Marker headMarker, lhandMarker, rhandMarker;

  Pose(String instructions, Marker headMarker, Marker lhandMarker, Marker rhandMarker) {
    this.instructions = instructions;
    this.headMarker = headMarker;
    this.lhandMarker = lhandMarker;
    this.rhandMarker = rhandMarker;
  }

  void draw() {
    fill(255);
    text(this.instructions, width / 2.0 - textWidth(this.instructions) / 2.0, height - 50);
    this.headMarker.draw(false);
    this.lhandMarker.draw(false);
    this.rhandMarker.draw(false);
  }

  boolean checkAndDraw(PVector head, PVector lhand, PVector rhand) {

    // Check for markers
    boolean headTouching = this.headMarker.touching(head);
    boolean lhandTouching = this.lhandMarker.touching(lhand);
    boolean rhandTouching = this.rhandMarker.touching(rhand);

    // draw markers
    this.headMarker.draw(headTouching);
    this.rhandMarker.draw(rhandTouching);
    this.lhandMarker.draw(lhandTouching);
    
    fill(255);
    text(this.instructions, width / 2.0 - textWidth(this.instructions) / 2.0, height - 50);

    return headTouching && rhandTouching && lhandTouching;
  }
}

class PoseSeries {
  ArrayList<Pose> poses;
  Pose current;
  int timeout;
  long poseHit;
  boolean complete;
 
  PoseSeries(int timeout) {
    this.poses = new ArrayList<Pose>();
    this.timeout = timeout;
    this.poseHit = 0;
    this.complete = false;
  }
  
  void add(Pose pose) {
    if(this.current == null) {
      this.current = pose;
      return;
    }
    this.poses.add(pose);
  }
  
  void update() {
    update(false, null, null, null);
  }
  
  boolean update(boolean playerVisible, PVector head, PVector lhand, PVector rhand) {
    if(!playerVisible) {
      this.current.draw();
      return false;
    }
    if(this.current.checkAndDraw(head, lhand, rhand)) {
      // Player is in position
      if(this.poseHit == 0) {
        // Player just got into position
        this.poseHit = millis();
      } else {
        // Player is remaining in position
        long waiting = millis() - this.poseHit;
        if(waiting > this.timeout) {
          this.poseHit = 0;
          advanceToNextPose();
          return true;
        } else {          
          // Show progress bar
          fill(0, 255, 0);
          rect(0, height - 20, (width * waiting) / this.timeout, 20);
        }
      }
    } else {
      // Reset counter if player is not in position
      //this.poseHit = 0;
    }
    
    
    return false;
  }
  
  void advanceToNextPose() {    
    if(this.poses.size() == 0) {
      // We're finished!
      this.complete = true;
      return;  
    }
    
    this.current = this.poses.remove(0);
  }
  
  boolean complete() {
    return this.complete;
  }
}

