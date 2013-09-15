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

PoseSeries poses;

ArrayList<Skeleton> skeletons;
ArrayList<PImage> images;

GameState state;

PImage splash_screen, check_results;
Prank prank;

int finishTime = 0;
int setup = 0;

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

  setup = millis();
  
  // enable depthMap generation (required for skeleton generation)
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  // enable RGB image capture
  context.enableRGB();

  // Setup series of poses with a delay in between each one
  poses = new PoseSeries(2000);
  Marker ignore = new Marker();
  
  poses.add(new Pose("Line up your head and hands with the red circles",
      new Marker("HEAD", 0, 450, 1500), 
      new Marker("L", -600, 300, 1500), 
      new Marker("R", 600, 300, 1500)
  ));
  poses.add(new Pose("Place your arms at your sides",
      new Marker("HEAD", 0, 450, 1500), 
      new Marker("L", -100, -250, 1500), 
      new Marker("R", 100, -250, 1500)
  ));
  poses.add(new Pose("Bend your knees and your elbows",
      new Marker("HEAD", 0, 100, 1500), 
      ignore, 
      ignore
  ));
  poses.add(new Pose("Stand up straight again",
      new Marker("HEAD", 0, 450, 1500), 
      new Marker("L", -100, -250, 1500), 
      new Marker("R", 100, -250, 1500)
  ));
  poses.add(new Pose("Bend your right elbow and place your hand on your hip",
      new Marker("HEAD", 0, 450, 1500), 
      ignore,
      new Marker("R", 180, 0, 1500)
  ));
  poses.add(new Pose("Extend your left arm",
      new Marker("HEAD", 0, 450, 1500), 
      new Marker("L", -600, 300, 1500), 
      new Marker("R", 180, 0, 1500)
  ));
  poses.add(new Pose("Tilt your body sideways from the waist",
      new Marker("HEAD", -250, 250, 1500), 
      new Marker("L", -700, 0, 1500), 
      new Marker("R", 180, 0, 1500)
  ));
  
  skeletons = new ArrayList<Skeleton>();
  images = new ArrayList<PImage>();
  
  state = GameState.SPLASH_SCREEN;
  
  splash_screen = loadImage("splash.png");
  check_results = loadImage("CheckResults.png");

  prank = new Prank(this);
  prank.intro();
}

void draw() {
 
 switch(state) {
  case SPLASH_SCREEN:
    drawSplashScreen();
    
    // update the cam
    context.update();
    break;
    
  case CAPTURE_POSES:
    drawPoseCapture();
    break;
    
  case CHECK_RESULTS:
    drawCheckResultsScreen();
    break;
    
  case PRANK:
    prank.run(images, skeletons);
    break;
 } 
}

void drawSplashScreen() {
  image(splash_screen, 0, 0, width, height);
}

void drawCheckResultsScreen() {
  image(check_results, 0, 0, width, height);
  
  if(millis() - finishTime > 4000) {
    state = GameState.PRANK;
          
    // This should only be run once
    prank.start();

  }
}

void drawPoseCapture()
{
  // update the cam
  context.update();

  image(context.rgbImage(), 0, 0, width, height);

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  if(userList.length == 0) {
    // Wait until player enters the scene
    poses.update();
    return;
  }
  int userId = userList[0];
  if(!context.isTrackingSkeleton(userId)) {
    poses.update();
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

  if(poses.update(true, head, lhand, rhand)) {
    println("Advanced to next pose...");
    
    // Take snapshot of current image and player skeleton
    PImage snapshot = createImage(width, height, RGB);
    PImage rgb = context.rgbImage();
    snapshot.copy(rgb, 0, 0, 640, 480, 0, 0, width, height);
    images.add(snapshot);
    
    skeletons.add(new Skeleton(context, userId));
    
    if(poses.complete()) {
      // Game over!!!!
      println("Player is done! Now we take a picture.");
      println("We have " + images.size() + " images and " + skeletons.size() + " skeletons to process.");
      
      state = GameState.CHECK_RESULTS;
      finishTime = millis();
    }
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
  println("New user: " + userId);

  if((millis() - setup) > 5000) {
    if(state == GameState.SPLASH_SCREEN) {
      state = GameState.CAPTURE_POSES;
    }
  }
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("Lost user: " + userId);
}

