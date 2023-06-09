public class Explosion
{
  float x,y;
  float w = 120;
  float h = 120;
  float lifeTime = 0;
    ArrayList<Smoke> smokeList = new ArrayList<Smoke>();
  
  AudioPlayer explosionSound;
  public Explosion(float x1, float y1)
  {
    x=x1;
    y=y1;
   explosionSound = minim.loadFile("Sounds/Explosion.mp3");
   playExplosionSound();
  }
  
  public void display()
  {
     if (lifeTime <= 6)
     {
       String filename = "Explosion/frame_" + (int)lifeTime + "_delay-0.1s.png";
       PImage img = loadImage(filename);
       image(img,x+OFFSETX,y+OFFSETY,w,h);
         drawSmoke(x, y, 25);
       
       lifeTime+=0.2;
     
     }

     updateSmokeList();
  }
  
  void drawSmoke(float centerX, float centerY, float R)
{
float r = R * sqrt(random(0,1));
float theta = random(0,1) * 2 * PI;
  float x = centerX + r * cos(theta);
float y = centerY + r * sin(theta);
float opacity = random(120,180);
float smokeRadius = random(10,30);

if (smokeList.size()< 20 && frameCount%3==0)
{
smokeList.add(new Smoke(x, y, smokeRadius, opacity, theta));
}

}

void updateSmokeList()
{
     for (int i = 0; i < smokeList.size(); i++) //update tank class to same double loop smoke removal system
    {
      Smoke smoke = smokeList.get(i);
      smoke.display();

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


 
  public float generateOffset()
  {
    float r = 6-lifeTime;
    float offset = random(0, r*1.8);
    return offset;
  }
  
  void playExplosionSound()
  {
    explosionSound.play();
  }
}
