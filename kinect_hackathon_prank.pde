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

SimpleOpenNI  context;
PGraphics buffer;
PImage bufferImg;

void setup()
{
  println("Starting up...");
  
  size(1024, 768);

  print("Starting OpenNI...");
  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }
  println("OpenNI is ready!");

  // Create an off-screen buffer.
  buffer = createGraphics(640, 480, JAVA2D);

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();
  
  // enable RGB image capture
  context.enableRGB();

  background(200, 0, 0);

  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();
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
  for (int i=0;i<userList.length;i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      stroke(0, 255, 0);
      drawSkeleton(buffer, userList[i]);
    }
  }

  bufferImg = buffer.get(0, 0, buffer.width, buffer.height);
  image(bufferImg, 0, 0, width, height);
}

// draw the skeleton with the selected joints
void drawSkeleton(PGraphics buffer, int userId)
{
  // Get the 3d joint data
  PVector headPos3 = new PVector();
  PVector headPos2 = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, headPos3);
  context.convertRealWorldToProjective(headPos3, headPos2);

  float headSize = max(10, 150 - headPos3.z / 50);
  
  buffer.beginDraw();
  buffer.clear();
  buffer.ellipse(headPos2.x, headPos2.y, headSize, headSize);
  buffer.endDraw();
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

