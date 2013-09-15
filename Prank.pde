// The next line is needed if running in JavaScript Mode with Processing.js
/* @pjs preload="moonwalk.jpg"; */

import ddf.minim.*;

class Prank {

  Minim minim;
  AudioPlayer yogaSong, prankSong;

  int startTime;
  int state;
  boolean started;

  PImage pot, lid, handle, spout, steam, tea, punkd;

  Prank(PApplet app) {
    pot = loadImage("teapot-body.png");
    lid = loadImage("teapot-top.png");
    handle = loadImage("teapot-handle.png");
    spout = loadImage("teapot-spout.png");
    steam = loadImage("Steam.png");
    tea = loadImage("Tea.png");
    punkd = loadImage("punkd.png");

    minim = new Minim(app);
    
    // load song from the data folder
    prankSong = minim.loadFile("teapot.mp3");
    yogaSong = minim.loadFile("YogaMusic.mp3");

    started = false;
  }

  void intro() {
    yogaSong.play();
  }
  
  void start() {
    started = true;

    yogaSong.pause();
    prankSong.play();
    
    startTime =  millis();
    state = 1;
  }

  void run(ArrayList<PImage> images, ArrayList<Skeleton> skeletons) {
    PImage capture;
    Skeleton skeleton;
    int duration;

    background(0);
    
    print("Prank: drawing state:");
    println(state);
    
    switch(state) {
    case 1:
      capture = images.get(1);
      skeleton = skeletons.get(1);
      duration = im_a_little_teapot(capture, skeleton);
      if ( millis() - startTime > duration)
      {
        state = 2;
        startTime =  millis();
      } 
      return;

    case 2:
      capture = images.get(2);
      skeleton = skeletons.get(2);
      duration = short_and_stout(capture, skeleton);
      if ( millis() - startTime > duration)
      {
        state = 3;
        startTime =  millis();
      } 
      return;

    case 3:
      capture = images.get(4);
      skeleton = skeletons.get(4);
      duration = here_is_my_handle(capture, skeleton);
      if ( millis() - startTime > duration)
      {
        state = 4;
        startTime =  millis();
      } 
      return;

    case 4:
      capture = images.get(5);
      skeleton = skeletons.get(5);
      duration = here_is_my_spout(capture, skeleton);
      if ( millis() - startTime > duration)
      {
        state = 5;
        startTime =  millis();
      } 
      return;  

    case 5:
      capture = images.get(5);
      skeleton = skeletons.get(5);
      duration = when_i_get_all_steamed_up(capture, skeleton);
      if ( millis() - startTime > duration)
      {
        state = 6;
        startTime =  millis();
      } 
      return;  

    case 6:
      capture = images.get(5);
      skeleton = skeletons.get(5);
      duration = hear_me_shout(capture, skeleton);
      if ( millis() - startTime > duration)
      {
        state = 7;
        startTime =  millis();
      } 
      return;  

    case 7:
      capture = images.get(6);
      skeleton = skeletons.get(6);
      duration = tip_me_over_and_pour_me_out(capture, skeleton);
      if ( millis() - startTime > duration)
      {
        state = 8;
        startTime =  millis();
      } 
      return;  

    case 8:
      duration = punkd();
      if ( millis() - startTime > duration)
      {
        state = 9;
        startTime =  millis();
      } 
      return;

    case 9:
      stop();
      return;
    }
  }

  int im_a_little_teapot(PImage img, Skeleton skeleton)
  {
    int delay = 2000; 
    image(img, 0, 0, width, height);
    return delay;
  }

  int short_and_stout(PImage img, Skeleton skeleton)
  {
    int delay = 2000; 
    
    im_a_little_teapot(img, skeleton);
    
    // put center of teapot at center of hips
    image(pot, skeleton.hips.x - pot.width/ 2.0, skeleton.hips.y - pot.height/ 2.0);

    // put bottom of lid at top of head
    image(lid, skeleton.head.x - lid.width/ 2.0, skeleton.head.y - 150);
    return delay;
  }

  int here_is_my_handle (PImage img, Skeleton skeleton)
  {
    int delay = 2000;
    
    short_and_stout(img, skeleton);
    
    //attach top left of handle to right shoulder
    image(handle, skeleton.right_shoulder.x + 100, skeleton.right_shoulder.y);

    return delay;
  }

  int here_is_my_spout (PImage img, Skeleton skeleton)
  {
    int delay = 2000; 
    
    here_is_my_handle(img, skeleton);
    
    //attach top right of spout to left shoulder
    image(spout, skeleton.left_shoulder.x - spout.width -100, skeleton.left_shoulder.y);
    return delay;
  }

  int when_i_get_all_steamed_up (PImage img, Skeleton skeleton)
  {
    int delay = 2000; 
    
    here_is_my_spout(img, skeleton);
    
    //attach bottom of steam to top center of head
    
    return delay;
  }

  int hear_me_shout (PImage img, Skeleton skeleton)
  {
    int delay = 2000; 

    when_i_get_all_steamed_up(img, skeleton);
    
    //put tea at the end of left hand
    image(steam, skeleton.head.x - steam.width/ 2.0, skeleton.head.y - steam.height);

    return delay;
  }

  int tip_me_over_and_pour_me_out (PImage img, Skeleton skeleton)
  {
    int delay = 4000; 
    
    image(img, 0, 0, width, height);
    image(tea, skeleton.left_hand.x - tea.width + 100, skeleton.left_hand.y);

    return delay;
  }

  int punkd()
  {
    int delay = 4000; 
    image(punkd, 0, 0, width, height);
    return delay;  
  }

  void stop()
  {
    yogaSong.close();
    prankSong.close();
    minim.stop();
    noLoop();
  }
}

