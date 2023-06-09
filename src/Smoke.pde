public class Smoke
{
  float x, y;
  float r;
  float opacity;
  float theta = -1;
  float speed = 0.3;
  
   public Smoke(float x1, float y1, float r2, float opacity2)
  {
    x=x1;
    y=y1;
   r = r2;
   opacity = opacity2;
   theta = -1;
  }
  
  public Smoke(float x1, float y1, float r2, float opacity2, float theta2)
  {
    x=x1;
    y=y1;
   r = r2;
   opacity = opacity2;
   theta = theta2;
  }
  
   public Smoke(float x1, float y1, float r2, float opacity2, float theta2, float speed2)
  {
    x=x1;
    y=y1;
   r = r2;
   opacity = opacity2;
   speed = speed2;
   theta = theta2;
  }
  
  
  public void display()
  {
    if (theta == -1)
    {
fill(color(140, opacity));
noStroke();
circle(x+OFFSETX,y+OFFSETY,r);
r+=.5;
opacity-=3;
    }
    else
    {
      fill(color(50, opacity));
noStroke();
circle(x+OFFSETX,y+OFFSETY,r);
x += speed*cos(theta);
y += speed*sin(theta);
r+=.2;
opacity-=2.5;
    }
  }
  
    public void displaySmoke()
  {
   
      fill(color(180, opacity));
noStroke();
circle(x+OFFSETX,y+OFFSETY,r);
x += speed*cos(theta);
y += speed*sin(theta);
r+=.2;
opacity-=3;
  
  }
  
  

  
  
}
