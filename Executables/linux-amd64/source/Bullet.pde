
final static float BULLETSPEED = MOVE_SPEED+0.2;

public class Bullet
{
  
  float x;
  float y;
  float w, h;
  PVector bullet;
  PVector velocity;
  float size;
  int lifeTime;
  boolean isFrag = false;
  float triangleAngle=0;
  AudioPlayer bounceSound;
  AudioPlayer fireSound;
  public Bullet(float firedAngle, float centerX, float centerY, float w, float h, int lifetime2, float size2)
  {
    float radAngle = firedAngle/360*TWO_PI;
   bullet = new PVector(centerX+cos(radAngle)*(w/1.82), centerY+sin(radAngle)*(w/1.82)); 
    velocity = new PVector(cos(radAngle)*BULLETSPEED, sin(radAngle)*BULLETSPEED);
    lifeTime = lifetime2*60;
    size = size2;

    fireSound = minim.loadFile("Sounds/Fire.mp3");
    playFireSound();
    bounceSound = minim.loadFile("Sounds/Bounce.mp3");
  }
  
  public Bullet(float firedAngle, float centerX, float centerY, float w, float h, int lifetime2, float size2, int playSound)
  {
    float radAngle = firedAngle/360*TWO_PI;
   bullet = new PVector(centerX+cos(radAngle)*(w/1.8), centerY+sin(radAngle)*(w/1.8)); 
    velocity = new PVector(cos(radAngle)*BULLETSPEED, sin(radAngle)*BULLETSPEED);
    lifeTime = lifetime2*60;
    size = size2;


    bounceSound = null;
    bounceSound = minim.loadFile("Sounds/Bounce.mp3");
  }
  
public Bullet(float firedAngle, float centerX, float centerY, float w, float h, int lifetime2, float size2, AudioPlayer fragSound)
  {
    float radAngle = firedAngle/360*TWO_PI;
    bullet = new PVector(centerX+cos(radAngle)*(w/1.8), centerY+sin(radAngle)*(w/1.8));
    velocity = new PVector(cos(radAngle)*BULLETSPEED*1.2, sin(radAngle)*BULLETSPEED*1.2);
    lifeTime = lifetime2*60;
    size = size2;
    triangleAngle = random(0,2*PI);
    

   //bounceSound = minim.loadFile("Sounds/Frag.mp3", 2048); 
   bounceSound = fragSound;
    isFrag = true;//isFrag2;
  }
  
  void display()
  {
    bullet.add(velocity);
    
    fill(0);
    if (lifeTime < 30)
    {
      float opacity = lifeTime*255/30.0;
      if (opacity< .4*255)
      {
        opacity = .4*255;
      }
      fill(0,opacity);
      stroke(0,opacity);
    }
    if (!isFrag)
    {
    ellipse(bullet.x+OFFSETX, bullet.y+OFFSETY, size,size);
    }
    else
    {
      pushMatrix();
       translate(bullet.x, bullet.y);
       triangleAngle +=45*PI/180;
       float rotation = triangleAngle;
       rotate(rotation);
        float r = sqrt(OFFSETX*OFFSETX+OFFSETY*OFFSETY);
      float theta = atan(OFFSETY/OFFSETX)-rotation;
      translate(r*cos(theta), r*sin(theta));
triangle(-0.866*size, -0.5*size, 0.866*size, -0.5*size, 0, size);
 popMatrix();
    }
    //checkCollision();
    lifeTime -= 1;
    x=bullet.x;
    y=bullet.y;
    if (!isFrag)
    {
    if (bounceSound != null && !bounceSound.isPlaying() && bounceSound.position() != 0)
    {
      bounceSound.rewind();
    }
    }
    stroke(0);      
 
  }
  /*
  boolean checkCollision()
  {

    if ((bullet.x > WIDTH-size/2) || (bullet.x < 0+size/2))
    {
      if (!isFrag)
      {
      velocity.x = velocity.x * -1;
      playBounceSound();
      }
      else
      {
        lifeTime = -1;
      }
      return true;
    }
    if (bullet.y > HEIGHT-size/2 || bullet.y < 0-size/2) 
    {
       if (!isFrag)
      {
      velocity.y = velocity.y * -1; 
      playBounceSound();
      }
      else
      {
        lifeTime = -1;
      }
      return true;
    }
    

    return false;
  }
  */
  
  int getColumn()
  {
    return (int)(bullet.x/CELL_SIZE);
  }
  
  int getRow()
  {
    return (int)(bullet.y/CELL_SIZE);
  }
  
  void playFireSound()
  {
    fireSound.play();
  }
  
   void playBounceSound()
  {
    bounceSound.play();  
  }
}
