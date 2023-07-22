

public class Laser
{
  
  float x;
  float y;
  float w, h;
  PVector laserEnd;
  PVector velocity;
  float size;
  int distance;
  ArrayList<Line> lineList = new ArrayList<Line>();
  int range = 500;
  Tank firedTank;
  
  AudioPlayer fireSound;
  public Laser(float centerX, float centerY, float firedAngle, float w, float h, AudioPlayer fireSound2, Tank firedTank2)
  {
    size=5;
    float radAngle = firedAngle/360*TWO_PI;
    laserEnd = new PVector(centerX+cos(radAngle)*(w/2.2), centerY+sin(radAngle)*(w/2.2));
    PVector start = new PVector(centerX+cos(radAngle)*(w/2.2), centerY+sin(radAngle)*(w/2.2));
    velocity = new PVector(cos(radAngle)*(BULLETSPEED*.5), sin(radAngle)*BULLETSPEED*.5);
    distance = 0;
    //laserEnd.add(velocity);
    fireSound = fireSound2;
    firedTank = firedTank2;
    while (distance < range)
    {
        
        while (!laserCollision(this))
        {
          
          lineList.add(new Line(start.x, start.y, laserEnd.x, laserEnd.y));
          if (laserTankCollision(this, false))
          {
            distance = range+100;
            lineList.remove(lineList.size()-1);
            break;
          }
          else
          {
            lineList.remove(lineList.size()-1);
          }
          laserEnd.add(velocity);
          
          
         

          if ((distance + dist(start.x, start.y, laserEnd.x, laserEnd.y) > range))
          {
            break;
          }
         
        }

      lineList.add(new Line(start.x, start.y, laserEnd.x, laserEnd.y));
      distance += dist(start.x, start.y, laserEnd.x, laserEnd.y);
      x=laserEnd.x;
      y=laserEnd.y;
      start.x = x;
      start.y = y;
      if (lineList.size() > 20)
        break;
      
    }
   
    
    
  }
  void displayFire(String team)
  {
      for (Line line: lineList)
    {
    line.displayLaser(team); 
    }

  }
  
  
  void fire(String team)
  {
    displayFire(team);
    playFireSound();
    laserTankCollision(this, true);
  }
  
  void display(String team)
  {
    for (Line line: lineList)
    {
      //requires Dashed Lines from tools->manage toosl->library
      strokeWeight(1.5); 
      
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
      
      dash.line(line.x1+OFFSETX, line.y1+OFFSETY, line.x2+OFFSETX, line.y2+OFFSETY);
      stroke(#000000);
  }
  }
  
  
  
  int getColumn()
  {
    return (int)(laserEnd.x/CELL_SIZE);
  }
  
  int getRow()
  {
    return (int)(laserEnd.y/CELL_SIZE);
  }
  
  
   void playFireSound()
  {
    fireSound.play();
  }

}
