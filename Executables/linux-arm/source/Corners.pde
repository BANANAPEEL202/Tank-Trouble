public class Corner
{
  float x, y;
  float w,h;
  public boolean bottom, top, left, right;
  
  public Corner(float x1, float y1)
  {
    x=x1;
    y=y1;
    w=5;
    h=5;
    bottom = false;
    top = false;
    left = false;
    right = false;
  }
  
  public void display()
  {
    rect(x-w/2+OFFSETY, y-w/2+OFFSETY, 5,5);
  }
  
  public boolean isRightCorner()
  {
    if (top && right && !bottom && !left || !top && !right && bottom && left ||  !top && right && bottom && !left | top && !right && !bottom && left)
    {
      return true;
    }
    return false;
  }
  
  public boolean isStraight()
  {
    if ((top && bottom && !left && !right) || (left && right && !top && !bottom))
    {
      return true;
    }
    return false;
  }
}
