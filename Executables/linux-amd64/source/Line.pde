public class Line
{
  float x1, x2, y1, y2;
  boolean isHorizental = false;
  boolean isVertical = false;
  public Line(float x11, float y11, float x22, float y22)
  {
    x1=x11;
    y1=y11;
    x2=x22;
    y2=y22;
    if (x1 == x2)
    {
        isVertical = true;
    }
    if (y1 == y2)
    {
      isHorizental = true;
    }
  }
  
  public void display()
  {
    stroke(#FF0000);
    strokeWeight(2);
    line(x1+OFFSETX,y1+OFFSETY,x2+OFFSETX,y2+OFFSETY);
    stroke(#000000);
  }
  
  public void display(int color2)
  {
    stroke(color2);
    strokeWeight(2);
    line(x1+OFFSETX,y1+OFFSETY,x2+OFFSETX,y2+OFFSETY);
    stroke(#000000);
  }
  
  public void displayLaser(String team)
  {
    strokeWeight(2); 
       if (team == "Red")
      {
        stroke(#FF0000);
      }
      else if (team == "Green")
      {
        stroke(#00FF00);
      }
      else if (team == "Orange")
      {
        stroke(#ED8A05);
      }
      else
      {
        stroke(#0000FF);
      }
    line(x1+OFFSETX,y1+OFFSETY,x2+OFFSETX,y2+OFFSETY);
    stroke(#000000);
  }
  
  public float midX()
  {
    return (x1+x2)/2;
  }
  
  public float midY()
  {
    return (y1+y2)/2;
  }
  
  public void display2()
  {
  line(x1+OFFSETX,y1+OFFSETY,x2+OFFSETX,y2+OFFSETY);
  }
  
  public float lerpY(float t)
  {
    return (1-t)*y1 + t*y2;
  }
  
  public float lerpX(float t)
  {
    return (1-t)*x1 + t*x2;
  }
  
  public float slope()
  {
    return (y2-y1)/(x2-x1);
  }
  
  public float radAngle()
  {
    float rad_angle = atan2((y2-y1), (x2-x1));
     rad_angle += PI;
     return rad_angle;
  }
  
  public boolean equals(Line otherLine)
  {
    if (otherLine.x1 == this.x1 && otherLine.x2 == this.x2 && otherLine.y1 == this.y1 && otherLine.y2 == this.y2)
    {
      return true;
    }
    return false;
  }
}
