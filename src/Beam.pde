import java.util.ArrayList;
import java.util.*;

public class Beam
{
  float angle;
  Line line;
  Tank targetTank;
  Tank firedTank;
  String team = "";
  float w, h;
  PImage img;
  float time;

  Float bezierPoints[];
  Line bezier2;
  AudioPlayer fireSound;
  
  public Beam(float centerX, float centerY, float w2, float h2, float firedAngle, Tank firedTank2)
  {
    w = w2;
    h = h2;
    firedTank = firedTank2;
    angle = firedAngle;
    float radAngle = angle/360*TWO_PI;
    line = new Line(centerX+cos(radAngle)*(w/2), centerY+sin(radAngle)*(w/2), centerX+cos(radAngle)*(1400), centerY+sin(radAngle)*(1400));
    imageMode(CENTER);
    team = firedTank.team;
    img = loadImage("Beam/" + team + " Beam.png");
    fireSound = minim.loadFile("Sounds/Death Ray.mp3");
  }


  public void display(float time2)
  {
    time = time2;
    time = 3.5*30-time;
    if (time >45)
    {

      noFill();
      if (team == "Blue")
      {
        stroke(27, 30, 247);
    } else if (team == "Green")
      {
        stroke(57, 240, 57);
      } 
       else if (team == "Orange")
      {
        stroke(237,138,5);
      } 
      else
      {
        stroke(204, 0, 0);
      }
      strokeWeight(7);
      if (bezier2 != null)
      {
        bezier2.display2();
      } else
      {
        line.display2();
      }
      if (bezierPoints != null)
      {
        bezier(bezierPoints[0]+OFFSETX, bezierPoints[1]+OFFSETY, bezierPoints[2]+OFFSETX, bezierPoints[3]+OFFSETY, bezierPoints[4]+OFFSETX, bezierPoints[5]+OFFSETY, bezierPoints[6]+OFFSETX, bezierPoints[7]+OFFSETY);
      }
      for (int i = 0; i < 100; i+=7)
      {
        float t = i/100.0;
        float x, y, tx, ty, rand;
        if (bezierPoints != null)
        {
          x = bezierPoint(bezierPoints[0], bezierPoints[2], bezierPoints[4], bezierPoints[6], t);
          y = bezierPoint(bezierPoints[1], bezierPoints[3], bezierPoints[5], bezierPoints[7], t);

          tx = bezierTangent(bezierPoints[0], bezierPoints[2], bezierPoints[4], bezierPoints[6], t);
          ty = bezierTangent(bezierPoints[1], bezierPoints[3], bezierPoints[5], bezierPoints[7], t);
          rand = (int)random(0, 3);
          if (rand != 0)
          {
            pushMatrix();
            float rad_angle = atan2(ty, tx);
            rad_angle += PI;
            translate(x, y);
            rotate(rad_angle);
            float r = sqrt(OFFSETX*OFFSETX+OFFSETY*OFFSETY);
            float theta = atan(OFFSETY/OFFSETX)-rad_angle;
            translate(r*cos(theta), r*sin(theta));
            image(img, 0, 0);
            popMatrix();
          }
        }
      }
      for (int i = 0; i < 100; i+=2)
      {
        float t = i/100.0;
        float x, y, tx, ty, rand;
        if (bezier2 != null)
        {
          x = bezier2.lerpX(t);
          y = bezier2.lerpY(t);
          rand = (int)random(0, 3);
          if (rand == 0)
          {
            pushMatrix();
            float rad_angle = bezier2.radAngle();
            translate(x, y);
            rotate(rad_angle);
            float r = sqrt(OFFSETX*OFFSETX+OFFSETY*OFFSETY);
            float theta = atan(OFFSETY/OFFSETX)-rad_angle;
            translate(r*cos(theta), r*sin(theta));
            image(img, 0, 0);
            popMatrix();
          }
        } else
        {
          x = line.lerpX(t);
          y = line.lerpY(t);
          rand = (int)random(0, 3);
          if (rand == 0)
          {
            pushMatrix();
            float rad_angle = line.radAngle();
            translate(x, y);
            rotate(rad_angle);
             float r = sqrt(OFFSETX*OFFSETX+OFFSETY*OFFSETY);
            float theta = atan(OFFSETY/OFFSETX)-rad_angle;
            translate(r*cos(theta), r*sin(theta));
            image(img, 0, 0);
            popMatrix();
          }
        }
      }
    }
    strokeWeight(1);
  }
  
   void playFireSound()
  {
    fireSound.play();
  }

}
