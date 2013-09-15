class PositionGoal {
  float ERROR_MARGIN = 200.0;
  PVector position;
  PVector screen;
  float screenWidth;
  String label;
  float labelWidth;

  PositionGoal(String label, int x, int y, int z) {
    this.position = new PVector(x, y, z);
    this.screen = convertPoint(this.position);
    this.screenWidth = 100.0 - (z / 50.0);
    this.label = label;
    this.labelWidth = textWidth(label);
  }

  boolean touching(PVector limb) {
    return this.position.dist(limb) < ERROR_MARGIN;
  }

  void draw(boolean highlighted) {
    color fill;
    if (highlighted) {
      fill = color(255, 0, 0);
      stroke(fill, 150);
      strokeWeight(2);
      fill(fill, 100);
      ellipse(this.screen.x, this.screen.y, this.screenWidth+10, this.screenWidth+10);
    } 
    else {
      fill = color(0, 255, 255);
      stroke(fill, 80);
      strokeWeight(2);
      fill(fill, 50);
      ellipse(this.screen.x, this.screen.y, this.screenWidth, this.screenWidth);
      
      fill(fill, 200);
      text(this.label, this.screen.x - this.labelWidth / 2.0, this.screen.y - this.screenWidth / 2);
    }
  }
}

class Pose {
  PositionGoal headGoal, lhandGoal, rhandGoal;

  Pose(PositionGoal headGoal, PositionGoal lhandGoal, PositionGoal rhandGoal) {
    this.headGoal = headGoal;
    this.lhandGoal = lhandGoal;
    this.rhandGoal = rhandGoal;
  }

  void draw() {
    this.headGoal.draw(false);
    this.lhandGoal.draw(false);
    this.rhandGoal.draw(false);
  }

  boolean checkAndDraw(PVector head, PVector lhand, PVector rhand) {

    // Check for goals
    boolean headTouching = this.headGoal.touching(head);
    boolean lhandTouching = this.lhandGoal.touching(lhand);
    boolean rhandTouching = this.rhandGoal.touching(rhand);

    // draw goals
    this.headGoal.draw(headTouching);
    this.rhandGoal.draw(rhandTouching);
    this.lhandGoal.draw(lhandTouching);

    return headTouching && rhandTouching && lhandTouching;
  }
}

