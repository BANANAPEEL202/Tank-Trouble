


public class PowerUp
{
  String type = "";
  float x;
  float y;
  PImage img;
  float lifeTime = 0;
  ArrayList<Smoke> smokeList = new ArrayList<Smoke>();
  float radAngle=0;

  AudioPlayer spawnSound;
  AudioPlayer collectSound;
  public PowerUp(float x2, float y2, int typeNum)
  {
    x = x2;
    y = y2;
    if (typeNum == 0)
    {
      type = "Machine Gun";
    } else if (typeNum == 1)
    {
      type = "Shotgun";
    } else if (typeNum == 2)
    {
      type = "Laser";
    } else if (typeNum == 3)
    {
      type = "Missle";
    } else if (typeNum == 4)
    {
      type = "Beam";
    } else if (typeNum == 5)
    {
      type = "Frag Bomb";
    }
    img = loadImage("Power Ups/"+type+".png");
    spawnSound = minim.loadFile("Sounds/Powerup Spawn.mp3");
    collectSound = minim.loadFile("Sounds/Powerup Collect.mp3");
    radAngle = random(-.4, .4)*PI/2;
  }

  public void display()
  {
    float size = 1;
    if (6 <= lifeTime && lifeTime <= 8)
    {
      drawSmoke(x, y, 10);
    }
    if (lifeTime < 4)
    {
      size = 0.7/4*lifeTime+.5;
    } else if (lifeTime < 6)
    {
      size = -0.2/2*(lifeTime-4)+1.2;
    }

    lifeTime+=0.2;
    updateSmokeList();
    pushMatrix();
    translate(x+OFFSETX, y+OFFSETY);
    rotate(radAngle);
    scale(size);
    image(img, 0, 0);
    popMatrix();
  }

  void drawSmoke(float centerX, float centerY, float R)
  {
    float r = R * sqrt(random(0, 1));
    float theta = random(0, 1) * 2 * PI;
    float x = centerX + r * cos(theta);
    float y = centerY + r * sin(theta);
    float opacity = random(120, 180);
    float smokeRadius = random(10, 20);

    if (smokeList.size()< 10 && frameCount%2==0)
    {
      smokeList.add(new Smoke(x, y, smokeRadius, opacity, theta));
    }
  }

  void updateSmokeList()
  {
    for (int i = 0; i < smokeList.size(); i++) //update tank class to same double loop smoke removal system
    {
      Smoke smoke = smokeList.get(i);
      smoke.displaySmoke();
    }
    for (int i = 0; i < smokeList.size(); i++)
    {
      Smoke smoke = smokeList.get(i);
      if (smoke.opacity < 10)
      {
        smokeList.remove(i);
      }
    }
  }

  void playSpawnSound()
  {
    spawnSound.play();
  }

  void playCollectSound()
  {
    collectSound.play();
  }
}
