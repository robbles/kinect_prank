/* --------------------------------------------------------------------------
 * Kinect Prank
 * --------------------------------------------------------------------------
 * Description...
 * 
 * --------------------------------------------------------------------------
 * by:  Rob O'Dwyer and Alim Jiwa
 * date:  2013-09-14
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;

SimpleOpenNI context;

PFont font;

// Convert between Kinect resolution and graphics display
float SCALE_FACTOR = 1024.0 / 640.0;

Pose pose1;

void setup()
{
  println("Starting up...");
  size(1024, 768);  
  background(200, 0, 0);
  smooth();
  
  font = createFont("Droid Sans", 32);
  textFont(font);

  print("Starting OpenNI...");
  
  context = new SimpleOpenNI(this);
  context.setMirror(true);
  
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }
  println("OpenNI is ready!");

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  // enable RGB image capture
  context.enableRGB();

  // Setup first pose
  pose1 = new Pose(
    // head
    new PositionGoal("HEAD", 0, 500, 1500), 
    // left hand
    new PositionGoal("LEFT HAND", -400, 300, 1500), 
    // right hand
    new PositionGoal("RIGHT HAND", 400, 300, 1500)
    );
}

void draw()
{
  // update the cam
  context.update();

  // draw depthImageMap
  //image(context.depthImage(),0,0);

  //image(context.userImage(), 0, 0, width, height);

  image(context.rgbImage(), 0, 0, width, height);

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  if(userList.length == 0) {
    // Wait until player enters the scene
    pose1.draw();
    return;
  }
  int userId = userList[0];
  if(!context.isTrackingSkeleton(userId)) {
    pose1.draw();
    return;
  }
  
  drawSkeleton(userId);
  
  // Get the 3d joint data
  PVector head = new PVector();
  PVector neck = new PVector();
  PVector lhand = new PVector();
  PVector rhand = new PVector();

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, head);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, neck);
  
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, lhand);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rhand);
  
  // Adjust head pos to halfway point between top of head and neck
  head.lerp(neck, 0.5);

  if(pose1.checkAndDraw(head, lhand, rhand)) {
    // Player is in position!!!!
    
  }
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  stroke(0, 0, 255);
  strokeWeight(3);

  drawLimb(context, userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  drawLimb(context, userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(context, userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(context, userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  drawLimb(context, userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(context, userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawLimb(context, userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  drawLimb(context, userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  drawLimb(context, userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  drawLimb(context, userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  drawLimb(context, userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawLimb(context, userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  drawLimb(context, userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawLimb(context, userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawLimb(context, userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}

PVector convertPoint(PVector position3d) {
  PVector position2d = new PVector();
  context.convertRealWorldToProjective(position3d, position2d);
  position2d.mult(SCALE_FACTOR);
  return position2d;
}

void drawLimb(SimpleOpenNI context, int userId, int joint1, int  joint2) {
  PVector joint1Pos = new PVector();
  PVector joint2Pos = new PVector();

  context.getJointPositionSkeleton(userId, joint1, joint1Pos);
  context.getJointPositionSkeleton(userId, joint2, joint2Pos);

  PVector joint1Pos2d = convertPoint(joint1Pos);
  PVector joint2Pos2d = convertPoint(joint2Pos);

  line(joint1Pos2d.x, joint1Pos2d.y, joint2Pos2d.x, joint2Pos2d.y);
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}

