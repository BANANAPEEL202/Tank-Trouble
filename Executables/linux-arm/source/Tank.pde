import java.util.ArrayList;
 import ddf.minim.*;

public class Tank
{
  PImage img;
  PImage machineImg;
  PImage shotImg;
  PImage missleImg;
  PImage missleFiredImg;
  PImage laserImg;
  PImage beamImg, beamImg1, beamImg2, beamImg3;
  PImage fragBombImg;
  PImage recoilImg;
  PImage fragRecoilImg;
  float centerX, centerY;
  float speed;
  float angle;
  float angleChange;
  float w, h;
  String team;
  boolean alive = true;
  int score = 0;
  float powerTimer = -1;
  float recoilTimer = -1;
  PowerUp power;
  boolean machineFire = false;
  Laser laser;
  Beam beam;
  Missle missle = null;
  Maze maze;
  boolean pause = false;
  boolean onWall;
  Bullet fragBomb = null;
 

  AudioPlayer missileFireSound = minim.loadFile("Sounds/Missle Launch.mp3");
  AudioPlayer trackSound = minim.loadFile("Sounds/Missle Track.mp3");
  AudioPlayer laserFireSound = minim.loadFile("Sounds/Laser.mp3");
    AudioPlayer shotgunFireSound = minim.loadFile("Sounds/Shotgun.mp3");
      AudioPlayer machinegunFireSound = minim.loadFile("Sounds/Machine Gun.mp3");
      AudioPlayer fragBombFireSound = minim.loadFile("Sounds/Frag Bomb Explosion.mp3");
  ArrayList<Bullet> bulletList = new ArrayList<Bullet>();
    ArrayList<Smoke> smokeList = new ArrayList<Smoke>();

  
  int redKills = 0;
  int blueKills = 0;
  int greenKills = 0;
  int orangeKills = 0;
  int suicides = 0;
  int powerUpsCollected = 0;
  int deaths = 0;
  int bulletsFired=0;
  int fumbles = 0;
  int secondPlace = 0;
  int thirdPlace =0;
  int fourthPlace = 0;
  

  public Tank(String filename, float x, float y, float angle2, int score2, String team2, Maze maze2)
  {
    
    img = loadImage(filename);
    w = (img.width);
    h = (img.height);
    centerX = x;
    centerY=y;
    speed = 0;
    angle = angle2;
    imageMode(CENTER);
    score = score2;
    team = team2;
    machineImg = loadImage("Machine Gun/"+team + " Tank.png");
    shotImg = loadImage("Shotgun/"+team + " Tank.png");
    missleImg = loadImage("Missle/"+team + " Tank.png");
    missleFiredImg = loadImage("Missle/" + team + " Tank Fired.png");
    laserImg = loadImage("Laser/" + team + " Tank.png");
    beamImg = loadImage("Beam/" + team + " Tank.png");
    beamImg1 = loadImage("Beam/" + team + " Tank (1).png");
    beamImg2 = loadImage("Beam/" + team + " Tank (2).png");
    beamImg3 = loadImage("Beam/" + team + " Tank (3).png");
    fragBombImg = loadImage("Frag Bomb/" + team + " Tank.png");
    recoilImg = loadImage("Recoil/" + team + " Tank.png");
    fragRecoilImg = loadImage("Frag Bomb/" + team + " Tank Recoil.png");
    maze = maze2;
    onWall = false;
    

    
  }


  public void reset(float x, float  y, float angle2, Maze maze2)
  {
    this.alive = true;
     centerX = x;
    centerY=y;
     speed = 0;
    angle = angle2;
    maze = maze2;
     onWall = false;
     
       powerTimer = -1;
   recoilTimer = -1;
   power = null;
   machineFire = false;
   missle = null;

   pause = false;
 fragBomb = null;
 bulletList.clear();
 smokeList.clear();
    missileFireSound = minim.loadFile("Sounds/Missle Launch.mp3");
   trackSound = minim.loadFile("Sounds/Missle Track.mp3");
   laserFireSound = minim.loadFile("Sounds/Laser.mp3");
     shotgunFireSound = minim.loadFile("Sounds/Shotgun.mp3");
       machinegunFireSound = minim.loadFile("Sounds/Machine Gun.mp3");
       fragBombFireSound = minim.loadFile("Sounds/Frag Bomb Explosion.mp3");
  }

  public void display()
  {
    if (alive)
    {
      if (pause)
      {
        speed = 0;
        angleChange= 0;
      }


      if (machineFire)
      {
        if (powerTimer % 5 == 0)
        {
          Bullet bullet = new Bullet(angle+random(-4, 4), centerX, centerY, w, h, 3, 5, 0);
          bulletList.add(bullet);
        }
        if (powerTimer == -1)
        {
          powerTimer = 3*30;
        } else if (powerTimer == 0)
        {
          power = null;
          powerTimer = -1;
          machineFire = false;
        } else
        {
          powerTimer -=1;
        }
      }
      if (power != null && power.type == "Laser")
      {

        if (powerTimer == -1) //not fired
        {
          if (!onWall)
          {
          laser = new Laser(centerX, centerY, angle, w, h, laserFireSound, this);
          laser.display(team);
          }
        } else if (powerTimer == 0) //fire ended
        {
          power = null;
          powerTimer = -1;
          laser = null;
        } else //firing
        {
          powerTimer -=1;
          laser.displayFire(team);
        }
      }
      if (power != null && power.type == "Beam")
      {

        if (powerTimer == -1) //not fired
        {
        } else if (powerTimer == 0) //fire ended
        {
          power = null;
          powerTimer = -1;
          pause = false;
          beam = null;
        } else //firing
        {
          powerTimer -=1;
          beam.display(powerTimer);
        }
      }
       for (int i = 0; i < smokeList.size(); i++)
    {
      Smoke smoke = smokeList.get(i);
      smoke.display();
    
      if (smoke.opacity < 10)
      {
        smokeList.remove(i);
      }
    }
      
      pushMatrix();
      float rad_angle = angle/360*TWO_PI;
      translate(centerX, centerY);
      rotate(rad_angle);
      float r = sqrt(OFFSETX*OFFSETX+OFFSETY*OFFSETY);
      float theta = atan(OFFSETY/OFFSETX)-rad_angle;
      translate(r*cos(theta), r*sin(theta));
      image(getImage(), 0, 0, w, h);
      popMatrix();


      angle += angleChange;
      rad_angle = angle/360*TWO_PI;

      centerX += speed*cos(rad_angle);
      centerY += speed*sin(rad_angle);
    }
    for (int i = 0; i < bulletList.size(); i++)
    {
      Bullet aBullet = bulletList.get(i);
      if (aBullet.lifeTime <= 0)
      {
        if (aBullet == fragBomb)
        {
          fragBombExplode();
        }
        bulletList.remove(i);
      }
      aBullet.display();
    }

    if (missle != null)
    {
      missle.display();

      if (missle.lifeTime > 700)
      {
        missle.stopSound();
        missle = null;
        power = null;
        
      }
    }
    
    if (!shotgunFireSound.isPlaying() && shotgunFireSound.position() != 0)
    {
      shotgunFireSound.rewind();
    }
    if (!machinegunFireSound.isPlaying() && machinegunFireSound.position() != 0)
    {
      machinegunFireSound.rewind();
    }
     if (!fragBombFireSound.isPlaying() && fragBombFireSound.position() != 0)
    {
      fragBombFireSound.rewind();
    }
   
  }

  public PImage getImage()
  {
    if (power == null)
    {
        if (recoilTimer == -1)
      {
        return img;
      } else
      {
        recoilTimer-=1;
        return recoilImg;
      }

    } else if (power.type == "Machine Gun")
    {
      return machineImg;
    } else if (power.type == "Shotgun")
    {
      return shotImg;
    } else if (power.type == "Missle")
    {
      if (missle == null)
      {
        return missleImg;
      }
    } else if (power.type == "Laser")
    {
      return laserImg;
    }
    else if (power.type == "Frag Bomb")
    {
      if (recoilTimer == -1)
      {
      return fragBombImg;
      }
      recoilTimer -=1;
      return fragRecoilImg;
    }
    if (power != null && power.type == "Beam")
    {

      if (powerTimer == -1) //not fired
      {
        return beamImg;
      } else //firing
      {
        float time = 3.5*30-powerTimer;
        if (time < 15)
        {
          return beamImg1;
        } else if (time < 30)
        {
          return beamImg2;
        } else
        {
          return beamImg3;
        }
      }
    }
    return missleFiredImg;
  }
  /*
  public void undoMove()
   {
   
   
   
   float rad_angle = angle/360*TWO_PI;
   
   centerX -= speed*cos(rad_angle);
   centerY -= speed*sin(rad_angle);
   }
   */

  void fire()
  {
    if (alive)
    {
      if (bulletList.size() < 5)
      {
      bulletsFired++;
      }
 
    if (!onWall|| (power != null &&power.type == "Beam"))
    {
      if (power == null )
      {
        if (bulletList.size() < 5 && alive)
        {
          Bullet bullet = new Bullet(angle, centerX, centerY, w, h, 10, 8); //
          bulletList.add(bullet);
            recoilTimer = 5;
            drawGunSmoke();

        }
      } else
      {
        if (power.type == "Machine Gun")
        {

          machineFire = true;
          machinegunFireSound.play();
        } else if (power.type == "Shotgun")
        {
          int numShells = 6;
          for (int i = 0; i < 5; i++)
          {
            Bullet bullet = new Bullet(angle+(-18+36/numShells*i), centerX, centerY, w, h, 3, 6, 0);
            shotgunFireSound.play();
            bulletList.add(bullet);
          }
          power = null;
        } else if (power.type == "Laser")
        {
          //Bullet bullet = new Bullet(angle, centerX, centerY, w, h, 15, 8);
          //bulletList.add(bullet
          laser.fire(team);
          powerTimer = .5*30;
        } else if (power.type == "Missle")
        {
          if (missle == null)
          {
            missle = new Missle(centerX, centerY, angle, maze, minim.loadFile("Sounds/Missle Launch.mp3"), minim.loadFile("Sounds/Missle Track.mp3"), this);
            missle.playFireSound();
          }
        } else if (power.type == "Beam")
        {
          if (beam == null)
          {
            beam = new Beam (centerX, centerY, w, h, angle, this);
            powerTimer = 3.5*30;
            pause = true;
            beam.playFireSound();
          }
        }
         else if (power.type == "Frag Bomb")
        {
          if (powerTimer == -1) // not fired yet
          {
          Bullet bullet = new Bullet(angle, centerX, centerY, w, h, 15, 10);
          fragBomb = bullet;
          bulletList.add(bullet);
          recoilTimer = 10;
           drawGunSmoke();
          powerTimer = 1;
          }
          else // fired, so now explode
          {
            fragBombExplode();
            fragBombFireSound.play();
          }
        }
      }
    } else //on wall
    {
      if (power == null)
      {
        if (bulletList.size() < 5 && alive)
        {
          Bullet bullet = new Bullet(angle, centerX, centerY, 0, 0, 10, 8); // spawn bullet inside tank to instantly kill it
          bulletList.add(bullet);
        }
      } else
      {
        if (power.type == "Frag Bomb")
        {
          if (fragBomb != null)
          {
          fragBombExplode();
          }
          else
          {
            Bullet bullet = new Bullet(angle, centerX, centerY, 0, 0, 15, 8);
        bulletList.add(bullet);
          }
        }
        else
        {
        Bullet bullet = new Bullet(angle, centerX, centerY, 0, 0, 15, 8);
        bulletList.add(bullet);
        }
      }
    }
    }
  }


public void fragBombExplode()
{
  int numFrags = 50;
   for (int i = 0; i < numFrags; i++)
          {
            Bullet bullet;
            if (i%2==0)
            {
             bullet = new Bullet(random(0,360), fragBomb.x, fragBomb.y, 0, 0, 5, 3, minim.loadFile("Sounds/Frag.mp3"));
            }
            else
            {
               bullet = new Bullet(random(0,360), fragBomb.x, fragBomb.y, 0, 0, 5, 3, null);
            }
            
            bulletList.add(bullet);
          }
          fragBomb.lifeTime = -1;
            powerTimer = -1;
            power = null;
            fragBomb = null;
            
          
}




  public ArrayList<Line> getLines()
  {
    ArrayList <Line> lines = new ArrayList<Line>();
    lines.add(getBottomLine());
    lines.add(getLeftLine());
    lines.add(getRightLine());
    lines.add(getTopLine());

    if (DEBUG)
    {
      for (Line line : lines)
      {
        line.display();
      }
    }
    return lines;
  }
  public Line getBottomLine()
  {
    float x1, y1;
    float x2, y2;
    float rad_angle = angle/360*TWO_PI;
    float centerX2 = centerX-1/6*w;
    x1 = centerX2 + w*2/3/2*cos(rad_angle) -h/2*sin(rad_angle);
    y1 = centerY + w*2/3/2*sin(rad_angle) +h/2*cos(rad_angle);
    x2 = centerX2 - w/2*cos(rad_angle) -h/2*sin(rad_angle);
    y2 = centerY - w/2*sin(rad_angle) +h/2*cos(rad_angle);
    if (false)
    {
      ellipse(x1, y1, 4, 4);
      ellipse(x2, y2, 4, 4);
    }
    return new Line(x1, y1, x2, y2);
  }

  public Line getLeftLine()
  {
    float x1, y1;
    float x2, y2;
    float rad_angle = angle/360*TWO_PI;
    float centerX2 = centerX-1/6*w;
    x1 = centerX2 - w/2*cos(rad_angle) -h/2*sin(rad_angle);
    y1 = centerY - w/2*sin(rad_angle) +h/2*cos(rad_angle);
    x2 = centerX2 - w/2*cos(rad_angle) +h/2*sin(rad_angle);
    y2 = centerY - w/2*sin(rad_angle) -h/2*cos(rad_angle);
    if (false)
    {
      ellipse(x1, y1, 4, 4);
      ellipse(x2, y2, 4, 4);
    }
    return new Line(x1, y1, x2, y2);
  }

  public Line getRightLine()
  {
    float x1, y1;
    float x2, y2;
    float rad_angle = angle/360*TWO_PI;
    float centerX2 = centerX-1/6*w;
    x1 = centerX2 + w*2/3/2*cos(rad_angle) -h/2*sin(rad_angle);
    y1 = centerY + w*2/3/2*sin(rad_angle) +h/2*cos(rad_angle);
    x2 = centerX2 + w*2/3/2*cos(rad_angle) +h/2*sin(rad_angle);
    y2 = centerY + w*2/3/2*sin(rad_angle) -h/2*cos(rad_angle);

    if (false)
    {
      ellipse(x1, y1, 4, 4);
      ellipse(x2, y2, 4, 4);
    }
    return new Line(x1, y1, x2, y2);
  }

  public Line getBarrel(boolean missle)
  {
    float x1, y1;
    float x2, y2;
    float x3, y3;
    float x4, y4;
    float rad_angle = angle/360*TWO_PI;
    float centerX2 = centerX-1/6*w;
    x1 = centerX2 + w*2/3/2*cos(rad_angle) -h/2*sin(rad_angle);
    y1 = centerY + w*2/3/2*sin(rad_angle) +h/2*cos(rad_angle);
    x2 = centerX2 + w*2/3/2*cos(rad_angle) +h/2*sin(rad_angle);
    y2 = centerY + w*2/3/2*sin(rad_angle) -h/2*cos(rad_angle);

    x3 = (x1+x2)/2;
    y3 = (y1+y2)/2;
    if (!missle)
    {
    x1 = centerX2 + w/1.8*cos(rad_angle) -h/2*sin(rad_angle);
    y1 = centerY + w/1.8*sin(rad_angle) +h/2*cos(rad_angle);
    x2 = centerX2 + w/1.8*cos(rad_angle) +h/2*sin(rad_angle);
    y2 = centerY + w/1.8*sin(rad_angle) -h/2*cos(rad_angle);

    }
    else
    {
    x1 = centerX2 + w/1*cos(rad_angle) -h/2*sin(rad_angle);
    y1 = centerY + w/1*sin(rad_angle) +h/2*cos(rad_angle);
    x2 = centerX2 + w/1*cos(rad_angle) +h/2*sin(rad_angle);
    y2 = centerY + w/1*sin(rad_angle) -h/2*cos(rad_angle);
    }
  
    x4 = (x1+x2)/2;
    y4 = (y1+y2)/2;
    if (DEBUG)
    {
      ellipse(x3+OFFSETX, y3+OFFSETY, 4, 4);
      ellipse(x4+OFFSETX, y4+OFFSETY, 4, 4);
    }

    return new Line(x3, y3, x4, y4);
  }



  public Line getTopLine()
  {
    float x1, y1;
    float x2, y2;
    float rad_angle = angle/360*TWO_PI;
    float centerX2 = centerX-1/6*w;
    x1 = centerX2 - w/2*cos(rad_angle) +h/2*sin(rad_angle);
    y1 = centerY - w/2*sin(rad_angle) -h/2*cos(rad_angle);
    x2 = centerX2 + w*2/3/2*cos(rad_angle) +h/2*sin(rad_angle);
    y2 = centerY + w*2/3/2*sin(rad_angle) -h/2*cos(rad_angle);
    if (false)
    {
      ellipse(x1, y1, 4, 4);
      ellipse(x2, y2, 4, 4);
    }
    return new Line(x1, y1, x2, y2);
  }

  void setLeft(float left) {
    centerX = left + w/2;
  }

  float getLeft() {
    float rad_angle = angle/360*TWO_PI;
    float centerX2 = centerX-1/6*w;
    float x1 = centerX2 + w*2/3/2*cos(rad_angle) -h/2*sin(rad_angle);
    float x2 = centerX2 - w/2*cos(rad_angle) -h/2*sin(rad_angle);
    float x3 = centerX2 + w*2/3/2*cos(rad_angle) +h/2*sin(rad_angle);
    float x4 = centerX2 - w/2*cos(rad_angle) +h/2*sin(rad_angle);
    return min(min(x1, x2), min(x3, x4));
  }
  void setRight(float right) {
    centerX = right - w/2;
  }
  float getRight() {
    float rad_angle = angle/360*TWO_PI;
    float centerX2 = centerX-1/6*w;
    float x1 = centerX2 + w*2/3/2*cos(rad_angle) -h/2*sin(rad_angle);
    float x2 = centerX2 - w/2*cos(rad_angle) -h/2*sin(rad_angle);
    float x3 = centerX2 + w*2/3/2*cos(rad_angle) +h/2*sin(rad_angle);
    float x4 = centerX2 - w/2*cos(rad_angle) +h/2*sin(rad_angle);
    return max(max(x1, x2), max(x3, x4));
  }
  void setTop(float top) {
    centerY = top + h/2;
  }
  float getTop() {
    float rad_angle = angle/360*TWO_PI;
    float y1 = centerY - w/2*sin(rad_angle) +h/2*cos(rad_angle);
    float y2 = centerY - w/2*sin(rad_angle) -h/2*cos(rad_angle);
    float y3 = centerY + w*2/3/2*sin(rad_angle) +h/2*cos(rad_angle);
    float y4 = centerY + w*2/3/2*sin(rad_angle) -h/2*cos(rad_angle);
    return min(min(y1, y2), min(y3, y4));
  }
  void setBottom(float bottom) {
    centerY = bottom - h/2;
  }
  float getBottom() {
    float rad_angle = angle/360*TWO_PI;
    float y1 = centerY - w/2*sin(rad_angle) +h/2*cos(rad_angle);
    float y2 = centerY - w/2*sin(rad_angle) -h/2*cos(rad_angle);
    float y3 = centerY + w*2/3/2*sin(rad_angle) +h/2*cos(rad_angle);
    float y4 = centerY + w*2/3/2*sin(rad_angle) -h/2*cos(rad_angle);
    return max(max(y1, y2), max(y3, y4));
  }

  int getColumn()
  {
    return (int)(centerX/CELL_SIZE);
  }

  int getRow()
  {
    return (int)(centerY/CELL_SIZE);
  }
  
  public void kill(Tank killer)
  {
    int tanksAlive = 0;
    for (Tank tank: tankList)
    {
      if (tank.alive)
      {
        tanksAlive++;
      }
    }
    if (tanksAlive == 1)
    {
      this.fumbles++;
    }
    else if (tanksAlive == 2)
    {
      secondPlace++;
    }
     else if (tanksAlive == 3)
    {
      thirdPlace++;
    }
      else if (tanksAlive == 4)
    {
      fourthPlace++;
    }
    
    this.alive = false;
    this.deaths++;
if (this.team == "Red")
    {
     killer.redKills++;
    }
    else if (this.team == "Green")
    {
      killer.greenKills++;
    }
     else if (this.team == "Blue")
    {
      killer.blueKills++;
    }
     else if (this.team == "Orange")
    {
       killer.orangeKills++;
    }
    
    
  }
  
  public int getKills(Tank killer)
  {

    if (killer.team == "Red")
    {
      return redKills;
    }
    else if (killer.team == "Green")
    {
      return greenKills;
    }
     else if (killer.team == "Blue")
    {
      return blueKills;
    }
     else if (killer.team == "Orange")
    {
      return orangeKills;
    }
    return -1;
  }
  
  public float getTotalKills()
  {
    return redKills+greenKills+blueKills+orangeKills-getKills(this);
  }
  
  public String getKD()
  {
    if (this.deaths == 0)
    {
       return String.format("%.2f",getTotalKills());
    }
    return String.format("%.2f",getTotalKills()/this.deaths);
  }
  
    public String getAccuracy()
  {
    if (bulletsFired == 0)
    {
       return String.format("%.1f",0.0)+ "  ";
    }
    else if (bulletsFired == getTotalKills())
    {
      return "100";
    }
    return String.format("%.1f",getTotalKills()/this.bulletsFired*100).substring(0,2)+ "  ";
  }
  
  public float getMaxPlace()
  {
    return max(score, max(secondPlace, max(thirdPlace, fourthPlace)));
  }
  
  void drawGunSmoke()
  {
         float x1, y1;
    float x2, y2;
    float x4, y4;
    float rad_angle = angle/360*TWO_PI;
    float centerX2 = centerX-1/6*w;
    x1 = centerX2 + w/1.8*cos(rad_angle) -h/2*sin(rad_angle);
    y1 = centerY + w/1.8*sin(rad_angle) +h/2*cos(rad_angle);
    x2 = centerX2 + w/1.8*cos(rad_angle) +h/2*sin(rad_angle);
    y2 = centerY + w/1.8*sin(rad_angle) -h/2*cos(rad_angle);
    
  
    x4 = (x1+x2)/2;
    y4 = (y1+y2)/2;
    if (speed == 0)
    {
      smokeList.add(new Smoke(x4, y4, random(2,6), random(90,110),rad_angle, random(.5,.7)));
      smokeList.add(new Smoke(x4, y4, random(2,6),  random(90,110),rad_angle+0.25, random(.5,.7)));
      smokeList.add(new Smoke(x4, y4, random(2,6),  random(90,110),rad_angle-0.25, random(.5,.7)));
    }
    else
    {
      smokeList.add(new Smoke(x4, y4, random(2,6), random(90,110),rad_angle, max(0,speed)+random(.5,.7)));
      smokeList.add(new Smoke(x4, y4, random(2,6),  random(90,110),rad_angle+0.25/speed, max(0,speed)+random(.5,.7)));
      smokeList.add(new Smoke(x4, y4, random(2,6),  random(90,110),rad_angle-0.25/speed, max(0,speed)+random(.5,.7)));
    }
  }
  

}
