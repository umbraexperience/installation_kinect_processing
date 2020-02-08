// umbra 2019-2020
// Adrià Crehuet, Santi Cros amb la col·laboració de Pol Valverde

import org.openkinect.freenect.*;
import org.openkinect.processing.*;


import oscP5.*;
import netP5.*;

OscP5 oscP5;                    // Creem un objecte OSC
NetAddress video;    // Creem un objecte per enviar OSC (on definirem Port i IP)
NetAddress audio;    // Creem un objecte per enviar OSC (on definirem Port i IP)
NetAddress leds;

Kinect kinect;

// Depth image
PImage depthImg;

// Which pixels do we care about?
int minDepth =  60;
int maxDepth = 1000;

int x1 = 30;
int y1 = 160;

int x2 = 243;
int y2 = 160;

int x3 = 456;
int y3 = 160;

int wr = 153;

int c1, c2, c3;


boolean inter1 = false;
boolean inter2 = false;
boolean inter3 = false;


// What is the kinect's angle
float angle;

int thres = 2800;

void setup() {
  size(640, 480);

  kinect = new Kinect(this);
  kinect.initDepth();
  //kinect.initVideo();

  angle = kinect.getTilt();

  // Blank image
  depthImg = new PImage(kinect.width, kinect.height);

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  video = new NetAddress("127.0.0.1", 33334);
  audio = new NetAddress("127.0.0.1", 2390);
  leds = new NetAddress("192.168.24.62", 2390);
}

void draw() {

  c1 = 0;
  c2 = 0;
  c3 = 0;

  // background(0);

  PImage pre = kinect.getVideoImage();

  // Threshold the depth image
  int[] rawDepth = kinect.getRawDepth();
  for (int i=0; i < rawDepth.length; i++) {
    int y = i / 640;
    int x = i - y * 640;
    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      if ( y >= 160 && y <= 320) {
        depthImg.pixels[i] = color(255);
        if (x >= x1 && x < x1 + wr) {
          c1++;
        } else if (x >= x2 && x < x2 + wr) {
          c2++;
        } else if (x >= x3 && x <= x3 + wr) {
          c3++;
        }
      }
    } else {
      depthImg.pixels[i] = color(pre.get(x, y+20));
    }
  }

  // Draw the thresholded image
  depthImg.updatePixels();

  //image(kinect.getVideoImage(), 0 , 0);
  image(depthImg, 0, 0);

  stroke(255);
  fill(255, 0, 0, 0);
  rect(x1, y1, wr, 160);
  rect(x2, y2, wr, 160);
  rect(x3, y3, wr, 160);

  fill(255, 0, 0, 100);
  if (c1 > thres) {
    rect(x1, y1, wr, 160);

    if (!inter1) {
      inter1=true;
      background(255, 0, 0);

      OscMessage myMessage = new OscMessage("1");
      /* send the message */
      oscP5.send(myMessage, video);
    }
  } else if (c1 < thres) {

    if (inter1) {
      inter1=false;
      background(0, 0, 255);
      OscMessage myMessage = new OscMessage("0");
      /* send the message */
      oscP5.send(myMessage, video);
    }
  }

  if (c2 > thres) {
    rect(x2, y2, wr, 160);
    if (!inter2) {
      inter2=true;
      background(255, 0, 0);
      OscMessage myMessage = new OscMessage("1");
      /* send the message */
      oscP5.send(myMessage, audio);
    }
  } else if (c2 < thres) {

    if (inter2) {
      inter2=false;
      background(0, 0, 255);
      OscMessage myMessage = new OscMessage("0");
      /* send the message */
      oscP5.send(myMessage, audio);
    }
  }

  if (c3 > thres) {
    rect(x3, y3, wr, 160);
    if (!inter3) {
      inter3=true;
      background(255, 0, 0);
      
            OscMessage myMessage = new OscMessage("1");
      /* send the message */
      oscP5.send(myMessage, leds);
    }
  } else if (c3 < thres) {

    if (inter3) {
      inter3=false;
      background(0, 0, 255);
      
                  OscMessage myMessage = new OscMessage("0");
      /* send the message */
      oscP5.send(myMessage, leds);
    }
  }

  fill(255);
  text("TILT: " + angle, 10, 20);
  text("THRESHOLD: [" + minDepth + ", " + maxDepth + "]", 10, 36);
  text("C1: " + c1 + " " + inter1, 10, 52);
  text("C2: " + c2 + " " + inter2, 10, 68);
  text("C3: " + c3 + " " + inter3, 10, 83);
}

// Adjust the angle and the depth threshold min and max
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angle++;
    } else if (keyCode == DOWN) {
      angle--;
    }
    angle = constrain(angle, 0, 30);
    kinect.setTilt(angle);
  } else if (key == 'a') {
    minDepth = constrain(minDepth+10, 0, maxDepth);
  } else if (key == 's') {
    minDepth = constrain(minDepth-10, 0, maxDepth);
  } else if (key == 'z') {
    maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } else if (key =='x') {
    maxDepth = constrain(maxDepth-10, minDepth, 2047);
  }
}
