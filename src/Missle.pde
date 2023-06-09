import java.util.ArrayList;
import java.util.*;
final static float TIMEBEFORETRACK = 150;

public class Missle
{
  PImage img;
  float centerX, centerY;
  float speed;
  float angle;
  float angleChange = 0;
  float w, h;
  public Queue<Cell> q = new LinkedList<Cell>();
  Maze maze;
  Tank targetTank;
  int lifeTime = 0;
  ParticleSystem smoke;
  PImage smokeImg;
  int targetX=-1;
  int targetY=-1;
  int lastTarget = 2;
  int missleW = 30;
  int missleH = 15;
  AudioPlayer fireSound;
  AudioPlayer trackSound;
  Tank firedTank;
  
  public Missle(float x, float y, float firedAngle, Maze maze2, AudioPlayer fireSound2, AudioPlayer trackSound2, Tank firedTank2)
  {
    firedTank = firedTank2;
    img = loadImage("Missle Shot.png");
    w = (img.width);
    h = (img.height);

    speed = BULLETSPEED*1;//*.8;
    angle = firedAngle;

    float radAngle = angle/360*TWO_PI;
    centerX = x+cos(radAngle)*(w/1);
    centerY = y+sin(radAngle)*(w/1);

    imageMode(CENTER);
    maze = maze2;


    smokeImg = loadImage("Smoke.png");
    smoke = new ParticleSystem(0, new PVector(width/2, height-60), smokeImg);
    fireSound = fireSound2;
    trackSound = trackSound2;
  }


  public void display()
  {
    float rad_angle = angle/360*TWO_PI;
    smoke.origin = new PVector(centerX-cos(rad_angle)*(missleW/1.8), centerY-sin(rad_angle)*(missleW/1.8));
    PVector wind;

    wind = new PVector(-0.07*cos(rad_angle), -0.07*sin(rad_angle));




    smoke.applyForce(wind);
    smoke.run();
    for (int i = 0; i < 2; i++) {
      smoke.addParticle();
    }

    if (lifeTime > TIMEBEFORETRACK)
    {
      getAngle();
      speed = .8*BULLETSPEED;
      playTrackSound();
    }
    pushMatrix();

    translate(centerX, centerY);
    rotate(rad_angle);
    float r = sqrt(OFFSETX*OFFSETX+OFFSETY*OFFSETY);
    float theta = atan(OFFSETY/OFFSETX)-rad_angle;
    translate(r*cos(theta), r*sin(theta));
    image(img, 0, 0, w, h);
    popMatrix();
    angle += angleChange;
    rad_angle = angle/360*TWO_PI;

    centerX += speed*cos(rad_angle);
    centerY += speed*sin(rad_angle);
    lifeTime+=1;
  }

  public void getAngle()
  {
    Cell p = getPathBFS(getColumn(), getRow());
        int mouseAngle=0;
    if (p != null)
    {
    targetX = p.x;
    targetY = p.y;

    if (targetTank != null)
    {
      //println(targetTank.team);
      if (targetTank.team.equals("Green"))
      {
        smoke.img = loadImage("Green Smoke.png");
      } else if (targetTank.team.equals("Red"))
      {
        smoke.img = loadImage("Red Smoke.png");
      } else if (targetTank.team.equals("Blue"))
      {
        smoke.img = loadImage("Blue Smoke.png");
      }
      else if (targetTank.team.equals("Orange"))
      {
        smoke.img = loadImage("Orange Smoke.png");
      }
    }
    }

    if (p == null || p.getParent() == null)
    {
      if (targetTank != null)
      {
        mouseAngle = (int)(atan2(centerY - targetTank.centerY, centerX- targetTank.centerX)* 180/ PI);
        if (missleTankCollision())
        {
          targetTank.kill(firedTank);
          explosions.add(new Explosion(targetTank.centerX, targetTank.centerY));
          stopSound();
          lifeTime = 5000;
          
        }
      }
    } else
    {
      while (p.getParent().getParent() != null) {
        if (DEBUG)
        {

          p.display();
        }
        if (p.target == -1)
        {
          if (lastTarget == 2)
          {
            p.target = 3;
            lastTarget = 3;
          } else
          {
            p.target=2;
            lastTarget=2;
          }
        }
        p = p.getParent();
      }

      //println(p.target);
      if (p.target== -1)
      {
        p.target = (int)random(0, 4);
      }


      int px = p.y;
      int py = p.x;

      float yOffset=0;
      float xOffset=0;
      mouseAngle = (int)(atan2(centerY - (py*CELL_SIZE+CELL_SIZE/2), centerX- (px*CELL_SIZE+CELL_SIZE/2))* 180/ PI);

      if (p.target == 0)
      {
        yOffset = CELL_SIZE/3;
        xOffset = CELL_SIZE/3;
        ;
      } else if (p.target == 1)
      {
        yOffset = -CELL_SIZE/3;
        xOffset = -CELL_SIZE/3;
        ;
      } else if (p.target == 2)
      {
        yOffset = -CELL_SIZE/3;
        ;
        xOffset = CELL_SIZE/3;
      } else
      {
        yOffset = CELL_SIZE/3;
        ;
        xOffset = -CELL_SIZE/3;
      }


      mouseAngle = (int)(atan2(centerY - (py*CELL_SIZE+CELL_SIZE/2+yOffset), centerX- (px*CELL_SIZE+CELL_SIZE/2+xOffset))* 180/ PI);
    }
    if (mouseAngle < 0)
    {
      mouseAngle += 360;
    }
    mouseAngle += 180;
    mouseAngle = mouseAngle%360;
    if (angle < 0)
    {
      angle += 360;
    }
    angle = angle %360;



    float a = (mouseAngle - angle);
    float b = (mouseAngle - angle + 360);
    float c = (mouseAngle - angle-360);
    float d;
    if (abs(a) < abs(b) && abs(a) < abs(c))
    {
      d = a;
    } else if (abs(b) < abs(a) && abs(b) < abs(c))
    {
      d=b;
    } else
    {
      d=c;
    }
    if (false)
    {
      println(mouseAngle);
      println(angle);
      println("---");
    }

    if (d < 0)
    {
      angleChange = -ANGLESPEED;
    } else
    {
      angleChange = ANGLESPEED;
    }
  }


  public  Cell getPathBFS(int x, int y)

  {
    q.clear();
    maze.clearVisited();
    maze.clearParents();
    q.add(maze.grid[y][x]);
    while (!q.isEmpty()) {
      Cell p = q.remove();


      boolean top = false;
      boolean bottom = false;
      boolean right = false;
      boolean left = false;

      int px = p.y;
      int py = p.x;
      //px and py are actual x/y place
      //p.x is row (y)
      //p.y is column (x)

      if (maze.grid[py][px].walls[0].isOpen && maze.grid[py-1][px].walls[1].isOpen)
        top = true;
      if (maze.grid[py][px].walls[1].isOpen && maze.grid[py+1][px].walls[0].isOpen)
        bottom = true;
      if (maze.grid[py][px].walls[3].isOpen && maze.grid[py][px+1].walls[2].isOpen)
        right = true;
      if (maze.grid[py][px].walls[2].isOpen && maze.grid[py][px-1].walls[3].isOpen)
        left = true;


      for (Tank tank : tankList) {
        if (tank.alive)
        {
          if (tank.getRow() == py && tank.getColumn() == px)
          {
            return p;
          }
        }
      }

      if (right && isFree(px+1, py)) { //can go right
        maze.grid[py][px].visited = true;
        Cell nextP = maze.grid[py][px+1];
        nextP.parent = p;
        q.add(nextP);
      }
      if (left && isFree(px-1, py)) { //can go left
        maze.grid[py][px].visited = true;
        Cell nextP = maze.grid[py][px-1];

        nextP.parent = p;
        q.add(nextP);
      }
      if (top && isFree(px, py-1)) { //can go up
        maze.grid[py][px].visited = true;
        Cell nextP = maze.grid[py-1][px];
        nextP.parent = p;
        q.add(nextP);
      }
      if (bottom && isFree(px, py+1)) { //can go dpwm
        maze.grid[py][px].visited = true;
        Cell nextP = maze.grid[py+1][px];
        nextP.parent = p;
        q.add(nextP);
      }
    }
    return null;
  }



  public  boolean isFree(int x, int y) {
    if ((x >= 0 && x < WIDTH/CELL_SIZE) && (y >= 0 && y < HEIGHT/CELL_SIZE) && (maze.grid[y][x].visited == false))
    {
      return true;
    }
    return false;
  }



  public ArrayList<Line> getLines()
  {
    ArrayList <Line> lines = new ArrayList<Line>();
    lines.add(getBottomLine());
    //lines.add(getLeftLine()); //prevent tank from running into its own missile
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

  boolean missleTankCollision()
  {
    for (Line line : getLines())
    {
      if (lineRect(line, targetTank.getTopLine(), targetTank.getBottomLine(), targetTank.getLeftLine(), targetTank.getRightLine()))
        return true;
    }
    return false;
  }

  // LINE/RECTANGLE
  boolean lineRect(Line wall, Line line1, Line line2, Line line3, Line line4) {

    // check if the line has hit any of the rectangle's sides
    // uses the Line/Line function below
    boolean left =   lineLine(wall, line1);
    boolean right =  lineLine(wall, line2);
    boolean top =    lineLine(wall, line3);
    boolean bottom = lineLine(wall, line4);

    // if ANY of the above are true, the line
    // has hit the rectangle
    if (left || right || top || bottom) {
      return true;
    }
    return false;
  }
  
   void playFireSound()
  {
    fireSound.play();
  }
  
  void playTrackSound()
  {
    trackSound.play();
  }
  
   void stopSound()
  {
    trackSound.mute();
    fireSound.mute();
  }
}
