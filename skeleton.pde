class Skeleton {

  int user;
  SimpleOpenNI context;
  
  PVector head3d, neck3d, left_shoulder3d, left_elbow3d, right_shoulder3d, right_elbow3d, torso3d, left_hip3d, left_knee3d, right_hip3d, right_knee3d, left_hand3d, right_hand3d, left_foot3d, right_foot3d;
  PVector head, neck, left_shoulder, left_elbow, right_shoulder, right_elbow, torso, left_hip, left_knee, right_hip, right_knee, left_hand, right_hand, left_foot, right_foot;
  PVector hips;

  Skeleton(SimpleOpenNI context, int user) {
    this.context = context;
    this.user = user;
    
    this.head3d = this.getJoint(SimpleOpenNI.SKEL_HEAD);
    this.neck3d = this.getJoint(SimpleOpenNI.SKEL_NECK);
    this.left_shoulder3d = this.getJoint(SimpleOpenNI.SKEL_LEFT_SHOULDER);
    this.left_elbow3d = this.getJoint(SimpleOpenNI.SKEL_LEFT_ELBOW);
    this.right_shoulder3d = this.getJoint(SimpleOpenNI.SKEL_RIGHT_SHOULDER);
    this.right_elbow3d = this.getJoint(SimpleOpenNI.SKEL_RIGHT_ELBOW);
    this.torso3d = this.getJoint(SimpleOpenNI.SKEL_TORSO);
    this.left_hip3d = this.getJoint(SimpleOpenNI.SKEL_LEFT_HIP);
    this.left_knee3d = this.getJoint(SimpleOpenNI.SKEL_LEFT_KNEE);
    this.right_hip3d = this.getJoint(SimpleOpenNI.SKEL_RIGHT_HIP);
    this.right_knee3d = this.getJoint(SimpleOpenNI.SKEL_RIGHT_KNEE);
    this.left_hand3d = this.getJoint(SimpleOpenNI.SKEL_LEFT_HAND);
    this.right_hand3d = this.getJoint(SimpleOpenNI.SKEL_RIGHT_HAND);
    this.left_foot3d = this.getJoint(SimpleOpenNI.SKEL_LEFT_FOOT);
    this.right_foot3d = this.getJoint(SimpleOpenNI.SKEL_RIGHT_FOOT);
    
    this.convert();
  }

  PVector getJoint(int joint) {
    PVector result = new PVector();
    this.context.getJointPositionSkeleton(this.user, joint, result);
    return result;
  }
  
  void convert() {
    this.head = convertPoint(this.head3d);
    this.neck = convertPoint(this.neck3d);
    this.left_shoulder = convertPoint(this.left_shoulder3d);
    this.left_elbow = convertPoint(this.left_elbow3d);
    this.right_shoulder = convertPoint(this.right_shoulder3d);
    this.right_elbow = convertPoint(this.right_elbow3d);
    this.torso = convertPoint(this.torso3d);
    this.left_hip = convertPoint(this.left_hip3d);
    this.left_knee = convertPoint(this.left_knee3d);
    this.right_hip = convertPoint(this.right_hip3d);
    this.right_knee = convertPoint(this.right_knee3d);
    this.left_hand = convertPoint(this.left_hand3d);
    this.right_hand = convertPoint(this.right_hand3d);
    this.left_foot = convertPoint(this.left_foot3d);
    this.right_foot = convertPoint(this.right_foot3d);
    
    // convenience calculations
    this.hips = PVector.lerp(this.left_hip, this.right_hip, 0.5);
  }
}

