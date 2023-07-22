import garciadelcastillo.dashedlines.*;
import java.util.*;
public Queue<Cell> q = new LinkedList<Cell>();
final static float MOVE_SPEED = 3;
final static float ANGLESPEED = 4.2;
final static boolean DEBUG = false;
final static float POWERSIZE = 25/2;

int POWERCOUNT = 0;
float OFFSETY = 0;
float OFFSETX = 0;
Minim minim;
boolean BLUE = false;
boolean ORANGE = false;

int startGameDelay = 15;

int WIDTH = 1200; //WIDTH OF THE WINDOW'S SCREEN
int HEIGHT = 750; //HEIGHT OF THE WINDOW'S SCREEN

int CELL_SIZE = 80;
Tank redTank;
Tank greenTank;
Tank blueTank;
Tank orangeTank;
Maze maze;
static ArrayList<Tank> tankList = new ArrayList<Tank>();
ArrayList<Explosion> explosions = new ArrayList<Explosion>();
int gameOverTimer = 3*60;
int blueTimer= -1;
boolean blueBrake = false;
DashedLines dash;

boolean skipScreen = false;

boolean INGAME = false;
boolean STARTMENU = true;
boolean CONTROLS = false;
boolean STATS = false;
boolean greenReady = false;
boolean redReady = false;
boolean blueReady = true;
boolean orangeReady = true;
PImage background;
PImage FourPlayerBtn;
PImage TwoPlayerBtn;
PImage ThreePlayerBtn;

PImage greenIcon;
PImage redIcon;
PImage blueIcon;
PImage orangeIcon;

PImage controlBg;
PImage redControl1;
PImage redControl2;
PImage redControl3;
PImage greenControl1;
PImage greenControl2;
PImage greenControl3;
PImage orangeControl1;
PImage orangeControl2;
PImage orangeControl3;
PImage blueControl1;
PImage blueControl2;
PImage blueControl3;

PImage greenStats;
PImage redStats;
PImage blueStats;
PImage orangeStats;

PImage statsTemplate;
PImage statsButton;
float statsAngle = 0;
//Missle testMissle;

PFont bold, regular, light;
boolean focused2 = true;
int totalGames = 0;
int startTime;

AudioPlayer clickSound;


void setup()
{
  size(1200, 900);
  bold = createFont("Stats/Akzidenz-grotesk-bold.ttf", 24);
  regular = createFont("Stats/Akzidenz-grotesk-roman.ttf", 24);
  light = createFont("Stats/Akzidenz-grotesk-light.ttf", 24);

  surface.setTitle("Tank Trouble  v1.1.0");
  surface.setResizable(true);
  imageMode(CENTER);
  dash = new DashedLines(this);
  // Set the dash-gap pattern in pixels
  dash.pattern(8, 10);
  minim = new Minim(this);

  greenIcon = loadImage("Green Tank Icon.png");
  redIcon=loadImage("Red Tank Icon.png");
  blueIcon=loadImage("Blue Tank Icon.png");
  orangeIcon = loadImage("Orange Tank Icon.png");
  background = loadImage("Tank Trouble Background.png");
  FourPlayerBtn = loadImage("4 Player.png");
  TwoPlayerBtn = loadImage("2 Player.png");
  ThreePlayerBtn = loadImage("3 Player.png");

  controlBg = loadImage("Controls/Controls Background.png");
  redControl1  = loadImage("Controls/Red Control 1.png");
  redControl2  = loadImage("Controls/Red Control 2.png");
  greenControl1  = loadImage("Controls/Green Control 1.png");
  greenControl2  = loadImage("Controls/Green Control 2.png");
  orangeControl1 = loadImage("Controls/Orange Control 1.png");
  orangeControl2 = loadImage("Controls/Orange Control 2.png");
  blueControl1 = loadImage("Controls/Blue Control 1.png");
  blueControl2 = loadImage("Controls/Blue Control 2.png");

  redControl3  = loadImage("Controls/Red Control 3.png");
  greenControl3  = loadImage("Controls/Green Control 3.png");
  orangeControl3 = loadImage("Controls/Orange Control 3.png");
  blueControl3 = loadImage("Controls/Blue Control 3.png");

  greenStats = loadImage("Stats/Green Stats.png");
  redStats = loadImage("Stats/Red Stats.png");
  orangeStats = loadImage("Stats/Orange Stats.png");
  blueStats = loadImage("Stats/Blue Stats.png");
  statsTemplate = loadImage("Stats/Stats Template.png");
  statsButton = loadImage("Stats/Stats Button.png");

  //testMissle = new Missle(25,25, 0, maze);
  drawStartMenu();
  if (skipScreen)
  {
    INGAME = true;
    STARTMENU = false;
    //STATS=true;
    BLUE = true;
    ORANGE = true;
    startGame();
  }
  clickSound = minim.loadFile("Sounds/Click.mp3");
}

void windowResized()
{
  int newHeight = height;
  int newWidth = round(height/900.0*1200);

  windowResize(newWidth, newHeight) ;
  //windowRatio(newWidth, newHeight);  
}


void drawGame()
{
  background(255);
   OFFSETX = (1200-WIDTH)/2;
      OFFSETY = (750-HEIGHT)/2;
 for (Explosion explosion : explosions)
      {
        explosion.display();
        OFFSETY += explosion.generateOffset();
        OFFSETX += explosion.generateOffset();
      }
      if (BLUE)
      {
        blueMovement();
      }
      displayPowerUps();
      for (Tank tank : tankList)
      {
        if (tank.beam != null)
        {
          updateBeam(tank.beam);
          beamCollision(tank.beam);
        }
        tank.display();
        if (tank.missle != null)
        {
          getTargetTank(tank.missle);
        }
      }




      bulletWallCollision();
      tankWallCollision();
      tankBulletCollision();
      bulletCornerCollision();
      missleWallCollision();
      barrelWallCollision();

      if (POWERCOUNT <= 15)
      {
        maze.generatePowerUps();
      }
      tankPowerUpCollision();

     
      if (DEBUG)
      {
        maze.viewCorners();
      }
      checkGameOver();
      displayMaze();
      drawScore();
      drawStatsButton();
}

void draw()
{
    pushMatrix();
  scale(height/900.0);

     if (focused)
     {
         background(255);
     }
  
    if (INGAME)
    {
        if (focused)
  {
     drawGame();
  }
  else
  {
    if (focused2)
    {
    fill(color(255,155));
    rect(-10,-10,1220,920);
    fill(#414141);
    rect(600-40, 450-50, 30, 100);
     rect(600+10, 450-50, 30, 100);

    }
    focused2 = false;
  }
  
    } else if (STARTMENU)
    {
      drawStartMenu();
    } else if (CONTROLS)
    {
      image(controlBg, 1200/2, 900/2, 1200, 900);
      int tanks = 2;
      if (BLUE)
      {
        tanks=3;
      }
      if (ORANGE)
      {
        tanks=4;
      }

      float inBetween = 1500.0/(tanks+1);
      int interval = 30;
      for (int i = 0; i < tanks; i++)
      {
        float x = (i+1)*inBetween-150; //-(1500-1200)/2
        if (i==0)
        {
          if (!greenReady)
          {
            if ((frameCount/interval)%2==0)
            {
              image(greenControl1, x, 450);
            } else
            {
              image(greenControl2, x, 450);
            }
          } else
          {
            image(greenControl3, x, 450);
          }
        }
        if (i==1)
        {
          if (!redReady)
          {
            if ((frameCount/interval)%2==0)
            {
              image(redControl1, x, 450);
            } else
            {
              image(redControl2, x, 450);
            }
          } else
          {
            image(redControl3, x, 450);
          }
        }
        if (BLUE && i == 2)
        {
          if (!blueReady)
          {
            if ((frameCount/interval)%2==0)
            {
              image(blueControl1, x, 450);
            } else
            {
              image(blueControl2, x, 450);
            }
          } else
          {
            image(blueControl3, x, 450);
          }
        }
        if (ORANGE && i == 3)
        {
          if (!orangeReady)
          {
            if ((frameCount/interval)%2==0)
            {
              image(orangeControl1, x, 450);
            } else
            {
              image(orangeControl2, x, 450);
            }
          } else
          {
            image(orangeControl3, x, 450);
          }
        }
      }
      if (redReady && greenReady && blueReady && orangeReady)
      {
        startGameDelay--;
        if (startGameDelay < 0)
        {
          startGame();
          INGAME = true;
          CONTROLS = false;
        }
      }
    } else if (STATS)
    {
      
      drawStats();
    }
popMatrix();
if (clickSound != null && !clickSound.isPlaying() && clickSound.position() != 0)
    {
      clickSound.rewind();
    }
    //println("X: " + mouseX + "  Y: " + mouseY);
  }



public void drawStartMenu()
{
  int scaledMouseX = mouseX*1200/width;
  int scaledMouseY = mouseY*900/height;
  image(background, 1200/2, 900/2, 1200, 900);
  if (108 < scaledMouseX && scaledMouseX < 394 && 665 < scaledMouseY && scaledMouseY < 747) {
    image(TwoPlayerBtn, 251, 734, TwoPlayerBtn.width*1.1, TwoPlayerBtn.height*1.1);
  } else
  {
    image(TwoPlayerBtn, 251, 734, TwoPlayerBtn.width, TwoPlayerBtn.height);
  }
  if (465 < scaledMouseX && scaledMouseX < 742 && 675 < scaledMouseY && scaledMouseY < 756) {
    image(ThreePlayerBtn, 599, 739, ThreePlayerBtn.width*1.1, ThreePlayerBtn.height*1.1);
  } else
  {
    image(ThreePlayerBtn, 599, 739, ThreePlayerBtn.width, ThreePlayerBtn.height);
  }
  if (808 < scaledMouseX && scaledMouseX < 1094 && 662 < scaledMouseY && scaledMouseY < 753) {
    image(FourPlayerBtn, 950, 739, FourPlayerBtn.width*1.1, FourPlayerBtn.height*1.1);
  } else
  {
    image(FourPlayerBtn, 950, 739, FourPlayerBtn.width, FourPlayerBtn.height);
  }
  fill(#000000);
  textSize(18);


  //text("FPS: " + String.format("%.01f", frameRate), 1110, 880);
}

public void blueMovement()
{
   int scaledMouseX = mouseX*1200/width;
  int scaledMouseY = mouseY*900/height;
  int mouseAngle = (int)(atan2(blueTank.centerY+OFFSETY - scaledMouseY, blueTank.centerX+OFFSETX - scaledMouseX)* 180/ PI);
  if (mouseAngle < 0)
  {
    mouseAngle += 360;
  }
  mouseAngle += 180;
  mouseAngle = mouseAngle%360;
  int tankAngle = (int)blueTank.angle%360;
  if (tankAngle < 0)
  {
    tankAngle += 360;
  }
  tankAngle = tankAngle %360;

  float a = (mouseAngle - tankAngle);
  float b = (mouseAngle - tankAngle + 360);
  float c = (mouseAngle - tankAngle-360);
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
  if (DEBUG)
  {
    println(mouseAngle);
    println(tankAngle);
    println("---");
  }
  if (abs(mouseAngle - tankAngle) < 3)
  {
    blueTank.angleChange = 0;
    float distance = dist(scaledMouseX, scaledMouseY, blueTank.centerX+OFFSETX, blueTank.centerY+OFFSETY);
    if (distance > 40 && !blueBrake)
    {
      blueTank.speed = MOVE_SPEED;
    } else
    {
      blueTank.speed = 0;
    }
  } else if (d < 0)
  {
    blueTank.angleChange = -ANGLESPEED;
  } else
  {
    blueTank.angleChange = ANGLESPEED;
  }
}

public void mousePressed()
{
  if (INGAME)
  {
    if (focused2)
    {
      int scaledMouseX = mouseX*1200/width;
  int scaledMouseY = mouseY*900/height;
      if (20 < scaledMouseX && scaledMouseX < 60 && 840 < scaledMouseY && scaledMouseY < 880) {
      STATS = true;
    }
      else if (BLUE && mouseButton == LEFT)
      {
        blueTank.fire();
      }
      else if (BLUE && mouseButton == RIGHT)
      {
        blueBrake = !blueBrake;
      }
    } else
    {
      focused2 = true;
    }
    
  } else if (STARTMENU)
  {
    int scaledMouseX = mouseX*1200/width;
  int scaledMouseY = mouseY*900/height;
    if (108 < scaledMouseX && scaledMouseX < 394 && 665 < scaledMouseY && scaledMouseY < 747) {
      CONTROLS = true;
      STARTMENU = false;
    }
    if (465 < scaledMouseX && scaledMouseX < 742 && 675 < scaledMouseY && scaledMouseY < 756) {
      BLUE = true;
      blueReady = false;
      CONTROLS = true;
      STARTMENU = false;
    }
    if (808 < scaledMouseX && scaledMouseX < 1094 && 662 < scaledMouseY && scaledMouseY < 753) {
      BLUE = true;
      ORANGE = true;
      blueReady = false;
      orangeReady = false;
      CONTROLS = true;
      STARTMENU = false;
    }
    clickSound.play();
  } else if (CONTROLS)
  {
    if (!blueReady && BLUE)
    {
       minim.loadFile("Sounds/Click.mp3").play();
       blueReady = true;
    }
    
  }
}



public void drawScore()
{
  float inBetween = 1200.0/(tankList.size()+1);
  for (int i = 0; i < tankList.size(); i++)
  {
    Tank tank = tankList.get(i);

    float x = (i+1)*inBetween+50;
    if (tank.team.equals("Green"))
    {
      image(greenIcon, x-80, 825);
    } else if (tank.team.equals("Red"))
    {
      image(redIcon, x-80, 825);
    } else if (tank.team.equals("Blue"))
    {
      image(blueIcon, x-80, 825);
    } else if (tank.team.equals("Orange"))
    {
      image(orangeIcon, x-80, 825);
    }
    textSize(50);
    fill(#000000);
    text(tank.score/121, x, 840);
  }
  fill(#000000);
  textSize(18);
  text("FPS: " + String.format("%.01f", frameRate), 1110, 880);
}

public void startGame()
{
  totalGames++;
  startTime = millis();
  WIDTH = (int)random(6, 16)*CELL_SIZE;
  HEIGHT = (int)random(6, 10)*CELL_SIZE;
  OFFSETX = (1200-WIDTH)/2;
  OFFSETY = (750-HEIGHT)/2;
  createMaze();
  tankList.clear();
  int redX, redY, blueX, blueY, greenX, greenY, orangeX, orangeY;
  redX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
  redY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
  int angle = (int)random(1, 5)*90;
  redTank = new Tank("Red Tank.png", redX, redY, angle, 0, "Red", maze);
  do
  {
    greenX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    greenY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
  }
  while (redX==greenX && redY == greenY);
  angle = (int)random(1, 5)*90;
  greenTank = new Tank("Green Tank.png", greenX, greenY, angle, 0, "Green", maze);

  tankList.add(greenTank);
  tankList.add(redTank);
  blueX=0;
  blueY=0;
  if (BLUE)
  {
    blueX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    blueY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    do
    {
      blueX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
      blueY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    }
    while ((blueX==greenX && blueY == greenY) || (blueX==redX && blueY == redY));
    angle = (int)random(1, 5)*90;
    blueTank = new Tank("Blue Tank.png", blueX, blueY, angle, 0, "Blue", maze);
    tankList.add(blueTank);
  }
  if (ORANGE)
  {
    orangeX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    orangeY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    do
    {
      orangeX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
      orangeY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    }
    while ((orangeX==greenX && orangeY == greenY) || (orangeX==redX && orangeY == redY) || (orangeX == blueX && orangeY == blueY));
    angle = (int)random(1, 5)*90;
    orangeTank = new Tank("Orange Tank.png", orangeX, orangeY, angle, 0, "Orange", maze);
    tankList.add(orangeTank);
    Collections.swap(tankList, 1, 3);
    Collections.swap(tankList, 2, 3);
  }
  gameOverTimer = 2*60;
}

public void startNewGame()
{
  totalGames++;
  minim.stop();
  minim = new Minim(this);
  WIDTH =(int)random(6, 16)*CELL_SIZE;
  HEIGHT = (int)random(6, 10)*CELL_SIZE;
  OFFSETX = (1200-WIDTH)/2;
  OFFSETY = (750-HEIGHT)/2;
  createMaze();
  POWERCOUNT=0;
  tankList.clear();
  int redX, redY, blueX, blueY, greenX, greenY, orangeX, orangeY;
  redX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
  redY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
  int angle = (int)random(1, 5)*90;
  redTank.reset(redX, redY, angle, maze);
  do
  {
    greenX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    greenY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
  }
  while (redX==greenX && redY == greenY);
  angle = (int)random(1, 5)*90;
  greenTank.reset(greenX, greenY, angle, maze);

  tankList.add(greenTank);
  tankList.add(redTank);

  if (BLUE)
  {
    blueX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    blueY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    do
    {
      blueX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
      blueY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    }
    while ((blueX==greenX && blueY == greenY) || (blueX==redX && blueY == redY));
    angle = (int)random(1, 5)*90;
    blueTank.reset(blueX, blueY, angle, maze);
    tankList.add(blueTank);
  }
  blueX=0;
  blueY=0;
  if (ORANGE)
  {
    orangeX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    orangeY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    do
    {
      orangeX = (int)random(0, WIDTH/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
      orangeY = (int)random(0, HEIGHT/CELL_SIZE)*CELL_SIZE+CELL_SIZE/2;
    }
    while ((orangeX==greenX && orangeY == greenY) || (orangeX==redX && orangeY == redY) || (orangeX == blueX && orangeY == blueY));
    angle = (int)random(1, 5)*90;
    orangeTank.reset(orangeX, orangeY, angle, maze);
    tankList.add(orangeTank);
    Collections.swap(tankList, 1, 3);
    Collections.swap(tankList, 2, 3);
  }
  gameOverTimer = 2*60;
  if (STATS)
  {
    drawGame();
    save("Data/screenshot.jpg");
    statsTemplate = loadImage("Data/screenshot.jpg");
    INGAME = false;
  }
}

public void checkGameOver()
{
  int tanksAlive = 0;
  for (Tank tank : tankList)
  {
    if (tank.alive)
    {
      tanksAlive++;
    }
  }
  if (tanksAlive <= 1)
  {
    for (Tank tank : tankList)
    {
      if (tank.alive)
      {
        tank.score +=1;
      }
    }
    if (gameOverTimer != 0)
    {
      gameOverTimer -= 1;
    } else
    {

      startNewGame();
      
    }
  }
}

void keyPressed()
{
  if (INGAME)
  {
    if (keyCode == RIGHT)
    {
      redTank.angleChange=ANGLESPEED;
      //predictiveTankCornerCollision(redTank);
    } else if (keyCode == LEFT)
    {
      redTank.angleChange=-ANGLESPEED;
      //predictiveTankCornerCollision(redTank);
    } else if (keyCode == UP)
    {
      redTank.speed = MOVE_SPEED;
    } else if (keyCode == DOWN)
    {
      redTank.speed = -MOVE_SPEED * 0.5;
    }

    if (key == 'D' || key == 'd')
    {
      greenTank.angleChange=ANGLESPEED;
    } else if  (key == 'A' || key == 'a')
    {
      greenTank.angleChange=-ANGLESPEED;
    } else if (key == 'W' || key == 'w')
    {
      greenTank.speed = MOVE_SPEED;
    } else if (key == 'S' || key == 's')
    {
      greenTank.speed = -MOVE_SPEED * 0.5;
    }

    if (key == '0' || key == 'M')
    {
      redTank.fire();
    }

    if (key == ' ')
    {
      greenTank.fire();
    }
    if (ORANGE)
    {
      if (key == 'L' || key == 'l')
      {
        orangeTank.angleChange=ANGLESPEED;
      } else if  (key == 'J' || key == 'j')
      {
        orangeTank.angleChange=-ANGLESPEED;
      } else if (key == 'I' || key == 'i')
      {
        orangeTank.speed = MOVE_SPEED;
      } else if (key == 'K' || key == 'k')
      {
        orangeTank.speed = -MOVE_SPEED * 0.5;
      }
      if (key == '/' || key == '?')
      {
        orangeTank.fire();
      }
    }
  } else if (CONTROLS)
  {
    if (key == ' ')
    {
      if (!greenReady)
      {
      greenReady = true;
      minim.loadFile("Sounds/Click.mp3").play();
      }
    }
    if (ORANGE)
    {
      if (key == '/' || key == '?')
      {
        if (!orangeReady)
        {
        orangeReady = true;
        minim.loadFile("Sounds/Click.mp3").play();
        }
      }
    }

    if (key == '0' || key == 'M')
    {
      if (!redReady)
      {
      redReady = true;
     minim.loadFile("Sounds/Click.mp3").play();
      }
    }
  }
  else if (STATS)
  {
    if (key == ESC)
    {
      key = 0; //weird hack to prevent it from quitting the entire game
      STATS  =false;
      INGAME = true;
      minim.loadFile("Sounds/Click.mp3").play();
    }
  }
}

void keyReleased()
{
  if (INGAME)
  {
    if (keyCode == UP)
    {
      redTank.speed = 0;
    } else if (keyCode == DOWN)
    {
      redTank.speed = 0;
    } else if (keyCode == LEFT)
    {
      redTank.angleChange = 0;
    } else if (keyCode == RIGHT)
    {
      redTank.angleChange = 0;
    }

    if (key == 'D' || key == 'd')
    {
      greenTank.angleChange=0;
    } else if  (key == 'A' || key == 'a')
    {
      greenTank.angleChange=0;
    } else if (key == 'W' || key == 'w')
    {
      greenTank.speed = 0;
    } else if (key == 'S' || key == 's')
    {
      greenTank.speed = 0;
    }
    if (ORANGE)
    {
      if (key == 'L' || key == 'l')
      {
        orangeTank.angleChange=0;
      } else if  (key == 'J' || key == 'j')
      {
        orangeTank.angleChange=0;
      } else if (key == 'I' || key == 'i')
      {
        orangeTank.speed = 0;
      } else if (key == 'K' || key == 'k')
      {
        orangeTank.speed = 0;
      }
    }
  }
}

public void createMaze()
{

  maze = new Maze(HEIGHT/CELL_SIZE, WIDTH/CELL_SIZE); //Adaptive maze, screen size divided by the size of the cell
}

public void displayMaze()
{
  //draw the maze
  strokeWeight(1.2);
  stroke(#000000);
  line(0+OFFSETX, 0+OFFSETY, 0+OFFSETX, HEIGHT+OFFSETY);
  line(0+OFFSETX, 0+OFFSETY, WIDTH+OFFSETX, 0+OFFSETY);
  //line(WIDTH-1, 0, WIDTH-1, HEIGHT);
  for (Cell[] cells : maze.grid) {
    for (Cell cell : cells) {
      if (!cell.walls[3].isOpen) {
        line(cell.y * CELL_SIZE + CELL_SIZE+OFFSETX, cell.x * CELL_SIZE+OFFSETY, cell.y * CELL_SIZE + CELL_SIZE+OFFSETX, cell.x * CELL_SIZE + CELL_SIZE+OFFSETY);
      }

      if (!cell.walls[1].isOpen) {
        line(cell.y * CELL_SIZE+OFFSETX, cell.x * CELL_SIZE + CELL_SIZE+OFFSETY, cell.y * CELL_SIZE + CELL_SIZE+OFFSETX, cell.x * CELL_SIZE + CELL_SIZE+OFFSETY);
      }
    }
  }
}

public void displayPowerUps()
{
  strokeWeight(1.2);
  stroke(#000000);

  //line(WIDTH-1, 0, WIDTH-1, HEIGHT);
  for (Cell[] cells : maze.grid) {
    for (Cell cell : cells) {
      if (cell.powerUp != null)
      {
        cell.powerUp.display();
      }
    }
  }
}

public void bulletWallCollision()
{
  for (Tank tank : tankList)
  {
    ArrayList<Bullet> bulletList = tank.bulletList;
    for (Bullet bullet : bulletList)
    {
      //if (!bullet.checkCollision())
      //{
        int cellColumn = bullet.getColumn();
        int cellRow = bullet.getRow();

        if (DEBUG)
        {
          fill(#FFA500, 75);
          noStroke();
          rect(cellColumn*CELL_SIZE, cellRow*CELL_SIZE, CELL_SIZE, CELL_SIZE);
        }
        try {
          Cell cell = maze.grid[cellRow][cellColumn];
          //ArrayList<Cell> cells = maze.getSurroundingCells(cellRow, cellColumn);
          //for (Cell cell: cells)
          //{
          //ArrayList<Line> lines = new ArrayList<Line>();
          float buffer = 10;
          if (!cell.walls[0].isOpen) //top
          {
            Line newLine = new Line(cell.left()-buffer, cell.top(), cell.right()+buffer, cell.top());
            if (linePoint(newLine, bullet.x, bullet.y, 1))
            {
              if (bullet.velocity.y<0)
              {
                if (bullet.isFrag)
                {
                  bullet.lifeTime = -1;
                }
                bullet.velocity.y = bullet.velocity.y * -1;
                bullet.playBounceSound();
              }
            }
          }
          if (!cell.walls[1].isOpen) //bottom
          {
            Line newLine = new Line(cell.left()-buffer, cell.bottom(), cell.right()+buffer, cell.bottom());
            if (linePoint(newLine, bullet.x, bullet.y, 1))
            {
              if (bullet.velocity.y>0)
              {
                if (bullet.isFrag)
                {
                  bullet.lifeTime = -1;
                }
                bullet.velocity.y = bullet.velocity.y * -1;
                bullet.playBounceSound();
              }
            }
          }
          /*aLine : lines)
           {
           
           if (DEBUG)
           {
           aLine.display();
           }
           }
           */

          //lines.clear();
          if (!cell.walls[3].isOpen) //right
          {
            Line newLine = new Line(cell.right(), cell.top()-buffer, cell.right(), cell.bottom()+buffer);
            if (bullet.velocity.x>0)
            {
              if (linePoint(newLine, bullet.x, bullet.y, 1))
              {
                if (bullet.isFrag)
                {
                  bullet.lifeTime = -1;
                }
                bullet.velocity.x= bullet.velocity.x * -1;
                bullet.bounceSound.play();
              }
            }
          }
          if (!cell.walls[2].isOpen) //left
          {
            Line newLine = new Line(cell.left(), cell.top()-buffer, cell.left(), cell.bottom()+buffer);
            if (bullet.velocity.x<0)
            {
              if (linePoint(newLine, bullet.x, bullet.y, 1))
              {
                if (bullet.isFrag)
                {
                  bullet.lifeTime = -1;
                }
                bullet.velocity.x= bullet.velocity.x * -1;
                bullet.bounceSound.play();
              }
            }
          }
          /*
          for (Line aLine : lines)
           {
           if (linePoint(aLine, bullet.x, bullet.y, 1))
           {
           bullet.velocity.x = bullet.velocity.x * -1;
           bullet.bounceSound.play();
           }
           if (DEBUG)
           {
           aLine.display();
           }
           
           }
           */
          //}
        }
        catch(Exception e)
        {
        }
      }
      //for collision with endpoints, the other axis vector needs to negatize
    //}
  }
}


public void tankBulletCollision()
{
  //ArrayList<Bullet> bulletList = greenTank.bulletList;
  //bulletList.addAll(redTank.bulletList);
  for (Tank tank : tankList)
  {
    if (tank.alive)
    {
      for (Tank tank2 : tankList)
      {
        ArrayList<Bullet> bulletList = tank2.bulletList;
        for (int i = 0; i < bulletList.size(); i++)
        {
          Bullet bullet = bulletList.get(i);
          float centerX2 = tank.centerX-1/6*tank.w;
          float bulletX = cos(tank.angle/360*TWO_PI) * (bullet.x - centerX2) -
            sin(tank.angle/360*TWO_PI) * (bullet.y - tank.centerY) + centerX2;
          float bulletY  = sin(tank.angle/360*TWO_PI) * (bullet.x - centerX2) +
            cos(tank.angle/360*TWO_PI) * (bullet.y - tank.centerY) + tank.centerY;

          // Closest point in the rectangle to the center of circle rotated backwards(unrotated)
          float closestX, closestY;

          // Find the unrotated closest x point from center of unrotated circle
          if (bulletX  < centerX2-tank.w*2/3/2)
            closestX = centerX2-tank.w*2/3/2;
          else if (bulletX  > centerX2 + tank.w*2/3/2)
            closestX = centerX2+tank.w*2/3/2;
          else
            closestX = bulletX;

          // Find the unrotated closest y point from center of unrotated circle
          if (bulletY < tank.centerY-tank.h/2)
            closestY = tank.centerY-tank.h/2;
          else if (bulletY > tank.centerY+tank.h/2)
            closestY = tank.centerY+tank.h/2;
          else
            closestY = bulletY;

          // Determine collision
          boolean collision = false;

          float distance = dist(bulletX, bulletY, closestX, closestY);
          if (distance < bullet.size/2)
          {
            collision = true; // Collision
            tank2.bulletList.remove(i);
            if (bullet == tank2.fragBomb)
            {
              tank2.fragBombExplode();
            }
            tank.kill(tank2);
            explosions.add(new Explosion(tank.centerX, tank.centerY));
          } else
            collision = false;
        }
      }
    }
  }
}

public void tankCornerCollision()
{

  ArrayList <Corner> corners = maze.corners;
  for (Tank tank : tankList)
  {
    if (tank.alive)
    {
      for (Corner corner : corners)
      {

        Line line;
        if (tank.speed < 0)
        {
          line = tank.getLeftLine();
        } else
        {
          line = tank.getRightLine();
        }
        float rad_angle = tank.angle/360*TWO_PI;

        if (linePoint(line, corner.x, corner.y, .8)) //.8
        {

          //if (exactlyOneTrue(corner.left, corner.right, corner.top, corner.bottom))
          //{
          if (!corner.isRightCorner())
          {
            float velocityX = tank.speed*cos(rad_angle);
            float velocityY = tank.speed*sin(rad_angle);
            if (corner.top && velocityY < 0)//top
            {
              //tank.centerX -= tank.speed*cos(rad_angle);
              tank.centerY -= tank.speed*sin(rad_angle);
              //tank.centerY += corner.y - tank.getTop();
            }
            if (corner.bottom && velocityY > 0)
            {
              //tank.centerX -= tank.speed*cos(rad_angle);
              tank.centerY -= tank.speed*sin(rad_angle);
            }
            if (corner.left && velocityX < 0)
            {
              tank.centerX -= tank.speed*cos(rad_angle);
              //tank.centerY -= tank.speed*sin(rad_angle);
            }
            if (corner.right && velocityX > 0)
            {
              tank.centerX -= tank.speed*cos(rad_angle);
              //tank.centerY -= tank.speed*sin(rad_angle);
            }
          } else if (exactlyOneTrue(corner.left, corner.right, corner.top, corner.bottom))
          {
            float velocityX = tank.speed*cos(rad_angle);
            float velocityY = tank.speed*sin(rad_angle);
            if (corner.top && velocityY < 0)// && bullet.y - bullet.velocity.y > corner.y)
            {
              tank.centerX -= tank.speed*cos(rad_angle);
              tank.centerY -= tank.speed*sin(rad_angle);
            } else if (corner.bottom && velocityY > 0)
            {
              tank.centerX -= tank.speed*cos(rad_angle);
              tank.centerY -= tank.speed*sin(rad_angle);
            } else if (corner.left && velocityX < 0)
            {
              tank.centerX -= tank.speed*cos(rad_angle);
              tank.centerY -= tank.speed*sin(rad_angle);
            } else if (corner.right && velocityX > 0)
            {
              tank.centerX -= tank.speed*cos(rad_angle);
              tank.centerY -= tank.speed*sin(rad_angle);
            }
          }
          //}
        }





        line = tank.getTopLine();
        if (linePoint(line, corner.x, corner.y, 0.5))
        {
          tank.angle -= tank.angleChange;
          //tank.angleChange = 0;
        }

        line = tank.getBottomLine();
        if (linePoint(line, corner.x, corner.y, 0.5))
        {
          tank.angle -= tank.angleChange;
          //tank.angleChange = 0;
        }
      }
    }
  }
}



public boolean predictiveTankCornerCollision(Tank tank)
{
  ArrayList <Corner> corners = maze.corners;
  boolean collision = false;

  for (Corner corner : corners)
  {
    ArrayList<Line> tankLines = tank.getLines();
    tank.angle += tank.angleChange;
    tankLines = tank.getLines();
    /*
        for (Line line : tankLines)
     {
     if (linePoint(line, corner.x, corner.y, 0.1))
     {
     tank.angle-=tank.angleChange;
     tank.angleChange = 0;
     }
     }
     */
    float centerX2 = tank.centerX-1/6*tank.w;
    float bulletX = cos(tank.angle/360*TWO_PI) * (corner.x - centerX2) -
      sin(tank.angle/360*TWO_PI) * (corner.y - tank.centerY) + centerX2;
    float bulletY  = sin(tank.angle/360*TWO_PI) * (corner.x - centerX2) +
      cos(tank.angle/360*TWO_PI) * (corner.y - tank.centerY) + tank.centerY;

    // Closest point in the rectangle to the center of circle rotated backwards(unrotated)
    float closestX, closestY;

    // Find the unrotated closest x point from center of unrotated circle
    if (bulletX  < centerX2-tank.w*2/3/2)
      closestX = centerX2-tank.w*2/3/2;
    else if (bulletX  > centerX2 + tank.w*2/3/2)
      closestX = centerX2+tank.w*2/3/2;
    else
      closestX = bulletX;

    // Find the unrotated closest y point from center of unrotated circle
    if (bulletY < tank.centerY-tank.h/2)
      closestY = tank.centerY-tank.h/2;
    else if (bulletY > tank.centerY+tank.h/2)
      closestY = tank.centerY+tank.h/2;
    else
      closestY = bulletY;

    // Determine collision


    float distance = dist(bulletX, bulletY, closestX, closestY);
    if (distance < 1)
    {
      collision = true; // Collision
      tank.angle-=tank.angleChange;
      tank.angleChange = 0;
    } else
    {
      collision = false;
      tank.angle-=tank.angleChange;
    }
  }


  return collision;
}

public void bulletCornerCollision()
{
  ArrayList <Corner> corners = maze.corners;
  for (Tank tank : tankList)
  {
    ArrayList<Bullet> bulletList = tank.bulletList;
    for (Bullet bullet : bulletList)
    {
      for (Corner corner : corners)
      {

        float dist = dist(bullet.x, bullet.y, corner.x, corner.y);
        float threshold = bullet.size/2;
        if (bullet.isFrag)
        {
          threshold = 10;
        }
        if (dist < threshold)
        {

          if (exactlyOneTrue(corner.left, corner.right, corner.top, corner.bottom))
          {
            if (!bullet.isFrag)
            {
              if (corner.top && bullet.velocity.y < 0)// && bullet.y - bullet.velocity.y > corner.y)
              {
                bullet.velocity.y = bullet.velocity.y * -1;
              } else if (corner.bottom && bullet.velocity.y > 0)
              {
                bullet.velocity.y = bullet.velocity.y * -1;
              } else if (corner.left && bullet.velocity.x < 0)
              {
                bullet.velocity.x = bullet.velocity.x * -1;
              } else if (corner.right && bullet.velocity.x > 0)
              {
                bullet.velocity.x = bullet.velocity.x * -1;
              }
              bullet.playBounceSound();
            } else
            {
              bullet.lifeTime = -1;
            }
          }
          /*
          else if (corner.isStraight())
           {
           if (corner.left && corner.right)
           {
           bullet.velocity.y = bullet.velocity.y * -1;
           }
           else
           {
           bullet.velocity.x = bullet.velocity.x * -1;
           }
           }
           */
        }
      }
    }
  }
}

private boolean exactlyOneTrue(boolean b1, boolean b2, boolean b3, boolean b4)
{
  if (b1 && !b2 && !b3 && !b4)
  {
    return true;
  }
  if (!b1 && b2 && !b3 && !b4)
  {
    return true;
  }
  if (!b1 && !b2 && b3 && !b4)
  {
    return true;
  }
  if (!b1 && !b2 && !b3 && b4)
  {
    return true;
  }
  return false;
}

public void tankPowerUpCollision()
{
  for (Tank tank : tankList)
  {
    if (tank.alive)
    {
      //ArrayList<Line> tankLines = tank.getLines();

      ArrayList<Line> lines = new ArrayList<Line>();
      int cellColumn = tank.getColumn();
      int cellRow = tank.getRow();

      if (DEBUG)
      {
        if (tank.team.equals("red"))
          fill(#FF0000, 25);
        else if (tank.team.equals("green"))
          fill(#00FF00, 25);
        noStroke();
        rect(cellColumn*CELL_SIZE, cellRow*CELL_SIZE, CELL_SIZE, CELL_SIZE);
      }
      //ArrayList<Cell> cells = maze.getSurroundingCells(cellRow, cellColumn);
      //boolean collided = false;

      Cell cell = (maze.grid[cellRow][cellColumn]);


      //Cell cell = maze.grid[cellRow][cellColumn];
      PowerUp power = cell.powerUp;
      if (power != null && tank.power == null)
      {
        Line newLine = new Line(power.x-POWERSIZE, power.y-POWERSIZE, power.x+POWERSIZE, power.y-POWERSIZE); //top
        lines.add(newLine);
        newLine = new Line(power.x-POWERSIZE, power.y-POWERSIZE, power.x-POWERSIZE, power.y+POWERSIZE); //left
        lines.add(newLine);
        newLine = new Line(power.x+POWERSIZE, power.y-POWERSIZE, power.x+POWERSIZE, power.y+POWERSIZE); //right
        lines.add(newLine);
        newLine = new Line(power.x-POWERSIZE, power.y+POWERSIZE, power.x+POWERSIZE, power.y+POWERSIZE); //bottom
        lines.add(newLine);


        for (Line aLine : lines)
        {

          if (lineRect(aLine, tank.getTopLine(), tank.getBottomLine(), tank.getLeftLine(), tank.getRightLine()))
          {
            tank.power = power;
            tank.powerUpsCollected++;
            if (power.type.equals("Laser"))
            {
              tank.laser = new Laser(tank.centerX, tank.centerY, tank.angle, tank.w, tank.h, tank.laserFireSound, tank);
            }
            cell.powerUp = null;
            power.playCollectSound();
            POWERCOUNT-=1;
          }
          if (DEBUG)
          {
            aLine.display();
          }
        }
      }
    }
  }
}

public void tankWallCollision()
{

  for (Tank tank : tankList)
  {
    if (tank.alive)
    {

      ArrayList<Line> lines = new ArrayList<Line>();
      int cellColumn = tank.getColumn();
      int cellRow = tank.getRow();

      if (DEBUG)
      {
        if (tank.team.equals("red"))
          fill(#FF0000, 25);
        else if (tank.team.equals("green"))
          fill(#00FF00, 25);
        noStroke();
        rect(cellColumn*CELL_SIZE, cellRow*CELL_SIZE, CELL_SIZE, CELL_SIZE);
      }
      ArrayList<Cell> cells = maze.getSurroundingCells(cellRow, cellColumn);


      for (Cell cell : cells)
      {

        if (!cell.walls[0].isOpen) //top
        {
          Line newLine = new Line(cell.left(), cell.top(), cell.right(), cell.top());
          lines.add(newLine);
        }
        if (!cell.walls[1].isOpen) //bottom
        {
          Line newLine = new Line(cell.left(), cell.bottom(), cell.right(), cell.bottom());
          lines.add(newLine);
        }

        if (!cell.walls[3].isOpen) //right
        {
          Line newLine = new Line(cell.right(), cell.top(), cell.right(), cell.bottom());
          lines.add(newLine);
        }
        if (!cell.walls[2].isOpen) //left
        {
          Line newLine = new Line(cell.left(), cell.top(), cell.left(), cell.bottom());
          lines.add(newLine);
        }
      }

      for (int i = 0; i < lines.size(); i++)
      {
        for (int j = i+1; j < lines.size(); j++)
        {
          if (lines.get(i).equals(lines.get(j)))
          {
            lines.remove(j);
          }
        }
      }

      boolean verticalCol = false;
      boolean horizontalCol = false;
      for (Line aLine : lines)
      {

        if (lineRect(aLine, tank.getTopLine(), tank.getBottomLine(), tank.getLeftLine(), tank.getRightLine()))

        {


          //aLine.display(#00FF00);

          float lineTop = min(aLine.y1, aLine.y2);
          float lineBottom = max(aLine.y1, aLine.y2);
          float lineRight =max(aLine.x1, aLine.x2);
          float lineLeft = min(aLine.x1, aLine.x2);

          float rad_angle = tank.angle/360*TWO_PI;
          int BUFFER= 5;
          if (aLine.isVertical && !verticalCol)
          {

            if (tank.getBottom()-BUFFER <= lineTop && tank.centerY < lineTop) //top
            {
              tank.centerY -= abs(lineTop - tank.getBottom());
              //println("TOP");
              verticalCol = true;
            } else if (tank.getTop()+BUFFER >= lineBottom)//bottom
            {
              tank.centerY += abs(lineBottom - tank.getTop());
              //println("TOP");
              verticalCol = true;
            } else if (tank.getLeft() <= lineLeft && tank.centerX > lineLeft) //left
            {
              tank.centerX += abs(lineLeft - tank.getLeft());
              tank.centerY -= tank.speed*sin(rad_angle)*0.5;
              //println("LEFT");
              verticalCol = true;
            } else if (tank.getRight() >= lineRight && tank.centerX < lineRight) //right
            {
              tank.centerX -= abs(lineRight-tank.getRight());

              tank.centerY -= tank.speed*sin(rad_angle)*0.5;
              //println("RIGHT");
              verticalCol = true;
            }
          } else if (aLine.isHorizental && !horizontalCol)
          {
            if (tank.getRight()-BUFFER <= lineLeft && tank.centerX < lineLeft) //left
            {
              tank.centerX -= abs(lineLeft - tank.getRight());
              //println("LEFT");
              horizontalCol = true;
            } else if (tank.getLeft()+BUFFER >= lineRight) //right
            {
              tank.centerX += abs(lineRight - tank.getLeft());
              //println("RIGHT");
              horizontalCol = true;
            } else if (tank.getTop() <= lineTop && tank.centerY > lineTop) //TOP
            {
              tank.centerY += abs(lineTop - tank.getTop());

              tank.centerX -= tank.speed*cos(rad_angle)*0.5;
              //println("TOP");
              horizontalCol = true;
            } else if (tank.getBottom() >= lineBottom && tank.centerY < lineBottom) //BOTTOM
            {
              tank.centerY -= abs(lineBottom-tank.getBottom());

              tank.centerX -= tank.speed*cos(rad_angle)*0.5;
              //println("BOTTOM");
              horizontalCol = true;
            }
          }
          float t = random(.4, .6);
          float x = tank.getLeftLine().lerpX(t) - cos(tank.angle/360*TWO_PI)*(tank.w/10);
          float y = tank.getLeftLine().lerpY(t) - sin(tank.angle/360*TWO_PI)*(tank.w/10);
          ;
          drawSmoke(x, y, 15, tank);
        } else
        {
          //println("NO COL");
        }
      }
      if (DEBUG)
      {
        for (Line line : lines)
        {
          line.display();
        }
      }
      /*
      if (!collided)
       {
       tankCornerCollision();
       }
       */
    }
  }
}




public boolean laserCollision(Laser bullet)
{
  /*
  if ((bullet.x > WIDTH) || (bullet.x < 0))
   {
   bullet.velocity.x = bullet.velocity.x * -1;
   
   return true;
   }
   if (bullet.y > HEIGHT || bullet.y < 0)
   {
   bullet.velocity.y = bullet.velocity.y * -1;
   return true;
   }
   */

  int cellColumn = bullet.getColumn();
  int cellRow = bullet.getRow();



  if (DEBUG)
  {
    fill(#FFA500, 75);
    noStroke();
    rect(cellColumn*CELL_SIZE, cellRow*CELL_SIZE, CELL_SIZE, CELL_SIZE);
  }

  try {
    Cell cell = maze.grid[cellRow][cellColumn];

    if (!cell.walls[0].isOpen) //top
    {
      Line newLine = new Line(cell.left(), cell.top(), cell.right(), cell.top());
      if (linePoint(newLine, bullet.laserEnd.x, bullet.laserEnd.y, 0.8))
      {
        if (bullet.velocity.y<0)
        {
          bullet.velocity.y = bullet.velocity.y * -1;
          return true;
        }
      }
    }
    if (!cell.walls[1].isOpen) //bottom
    {
      Line newLine = new Line(cell.left(), cell.bottom(), cell.right(), cell.bottom());
      if (linePoint(newLine, bullet.laserEnd.x, bullet.laserEnd.y, 0.8))
      {
        if (bullet.velocity.y>0)
        {
          bullet.velocity.y = bullet.velocity.y * -1;
          return true;
        }
      }
    }

    if (!cell.walls[3].isOpen) //right
    {
      Line newLine = new Line(cell.right(), cell.top(), cell.right(), cell.bottom());

      if (bullet.velocity.x>0)
      {
        if (linePoint(newLine, bullet.laserEnd.x, bullet.laserEnd.y, 0.8))
        {
          bullet.velocity.x= bullet.velocity.x * -1;
          return true;
        }
      }
    }

    if (!cell.walls[2].isOpen) //left
    {
      Line newLine = new Line(cell.left(), cell.top(), cell.left(), cell.bottom());
      if (bullet.velocity.x<0)
      {
        if (linePoint(newLine, bullet.laserEnd.x, bullet.laserEnd.y, 0.2))
        {
          bullet.velocity.x= bullet.velocity.x * -1;
          return true;
        }
      }
    }
  }
  catch(Exception e)
  {
    //println(e);
  }
  return laserCorner(bullet);
}

boolean laserCorner(Laser bullet)
{
  ArrayList <Corner> corners = maze.corners;

  for (Corner corner : corners)
  {
    //float yDist = abs(corner.y-bullet.y);
    //float xDist = abs(corner.x-bullet.x);
    float dist = dist(bullet.x, bullet.y, corner.x, corner.y);
    if (dist < bullet.size/2)
    {


      if (exactlyOneTrue(corner.left, corner.right, corner.top, corner.bottom))
      {

        if (corner.top && bullet.velocity.y < 0)// && bullet.y - bullet.velocity.y > corner.y)
        {
          bullet.velocity.y = bullet.velocity.y * -1;
        } else if (corner.bottom && bullet.velocity.y > 0)
        {
          bullet.velocity.y = bullet.velocity.y * -1;
        } else if (corner.left && bullet.velocity.x < 0)
        {
          bullet.velocity.x = bullet.velocity.x * -1;
        } else if (corner.right && bullet.velocity.x > 0)
        {
          bullet.velocity.x = bullet.velocity.x * -1;
        }
        return true;
      }
    }
  }
  return false;
}



boolean laserTankCollision(Laser laser, boolean fire)
{
  for (Tank tank : tankList)
  {
    if (tank.alive)
    {

      for (Line tankLine : tank.getLines())
      {
        for (Line laserLine : laser.lineList)
        {
          if (lineLine(tankLine, laserLine))
          {
            if (fire)
            {
              tank.kill(laser.firedTank);
              explosions.add(new Explosion(tank.centerX, tank.centerY));
            }
            return true;
          }
        }
      }
    }
  }
  return false;
}


// LINE/POINT
boolean linePoint(Line line, float px, float py, float buffer) {

  float x1 = line.x1;
  float y1 = line.y1;
  float x2 = line.x2;
  float y2 = line.y2;

  // get distance from the point to the two ends of the line
  float d1 = dist(px, py, x1, y1);
  float d2 = dist(px, py, x2, y2);

  // get the length of the line
  float lineLen = dist(x1, y1, x2, y2);

  // since floats are so minutely accurate, add
  // a little buffer zone that will give collision
  //float buffer = 2;    // higher # = less accurate

  // if the two distances are equal to the line's
  // length, the point is on the line!
  // note we use the buffer here to give a range,
  // rather than one #
  if (d1+d2 >= lineLen-buffer && d1+d2 <= lineLen+buffer) {
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

public void getTargetTank(Missle missle)
{
  for (Tank tank : tankList)
  {
    if (missle.targetX != -1)
    {
      if (tank.alive)
      {
        if (tank.getColumn() == missle.targetY && tank.getRow() == missle.targetX)
        {

          missle.targetTank = tank;
        }
      }
    }
  }
}

// LINE/LINE
boolean lineLine(Line line1, Line line2) {
  float x1, x2, x3, x4, y1, y2, y3, y4;
  x1 = line1.x1;
  y1 = line1.y1;
  x2 = line1.x2;
  y2 = line1.y2;
  x3 = line2.x1;
  y3 = line2.y1;
  x4 = line2.x2;
  y4 = line2.y2;

  // calculate the direction of the lines
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // if uA and uB are between 0-1, lines are colliding
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {

    // optionally, draw a circle where the lines meet
    //float intersectionX = x1 + (uA * (x2-x1));
    //float intersectionY = y1 + (uA * (y2-y1));
    //fill(255, 0, 0);
    //noStroke();
    //ellipse(intersectionX, intersectionY, 20, 20);

    return true;
  }
  return false;
}


public  Cell getPathBFS(int x, int y)

{
  q.clear();
  maze.clearVisited();
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
          System.out.println("Exit is reached!");
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

public void missleWallCollision()
{

  //Missle missle = testMissle;
  //ArrayList<Line> tankLines = tank.getLines();
  for (Tank tank : tankList)
  {
    if (tank.missle != null)
    {

      Missle missle = tank.missle;

      Line frontLine = missle.getRightLine();
      float midX = (frontLine.x1+frontLine.x2)/2;
      float midY = (frontLine.y1+frontLine.y2)/2;




      if (15 < missle.lifeTime && missle.lifeTime < TIMEBEFORETRACK)
      {
        missleTankCollision(missle);
      }
      float rad_angle = missle.angle/360*TWO_PI;
      float xVelocity = cos(rad_angle);
      float yVelocity =  sin(rad_angle);

      




      ArrayList<Line> lines = new ArrayList<Line>();
      ArrayList<Line> lines2 = new ArrayList<Line>();
      int cellColumn = missle.getColumn();
      int cellRow = missle.getRow();


      Cell cell2 = (maze.grid[cellRow][cellColumn]);
      ArrayList<Cell> cells = maze.getSurroundingCells(cellRow, cellColumn);

      for (Cell cell : cells)
      {

        float buffer = 5;
        if (!cell.walls[0].isOpen) //top
        {
          Line newLine = new Line(cell.left()-buffer, cell.top(), cell.right()+buffer, cell.top());
          lines.add(newLine);
          lines2.add(newLine);
          //newLine.display();
        }
        if (!cell.walls[1].isOpen) //bottom
        {
          Line newLine = new Line(cell.left()-buffer, cell.bottom(), cell.right()+buffer, cell.bottom());
          lines.add(newLine);
          lines2.add(newLine);
          //newLine.display();
        }

        if (!cell.walls[3].isOpen) //right
        {
          Line newLine = new Line(cell.right(), cell.top()-buffer, cell.right(), cell.bottom()+buffer);
          lines.add(newLine);
          lines2.add(newLine);
          //newLine.display();
        }
        if (!cell.walls[2].isOpen) //left
        {
          Line newLine = new Line(cell.left(), cell.top()-buffer, cell.left(), cell.bottom()+buffer);
          lines.add(newLine);
          lines2.add(newLine);
          //newLine.display();
        }
      }
      for (int i = 0; i < lines.size(); i++)
      {
        for (int j = i+1; j < lines.size(); j++)
        {
          if (lines.get(i).equals(lines.get(j)))
          {
            lines.remove(j);
          }
        }
      }

      for (Line aLine : lines)
      {

        //0 - right
        //90 - down
        //180 - left
        //270 - up
        
        if (lineLine(aLine, frontLine) || linePoint(aLine, midX, midY, 0.1))
        {
    
          //if ((midX > cell2.right()-4) || (midX < cell2.left()+4))
          if (aLine.isVertical)
          {
            xVelocity = -1*xVelocity;
            missle.angle = atan2(yVelocity, xVelocity)*180/PI;
            // missle.display();
          } //else if (midY > cell2.top()+4 || midY < cell2.bottom()-4)
          else if (aLine.isHorizental)
          {

            yVelocity = -1*yVelocity;
            missle.angle = atan2(yVelocity, xVelocity)*180/PI;
            if (missle.angle < 0)
            {
              missle.angle = missle.angle +360;
            }
            //missle.display();
          } 
          break;
            
        }

        if (DEBUG)
        {
          aLine.display();
        }
        // }
      }
    }
  }
}



void missleTankCollision(Missle missle)
{
  for (Tank tank : tankList)
  {
    if (tank.alive)
    {
      for (Line line : missle.getLines()) 
      {
        if (lineRect(line, tank.getTopLine(), tank.getBottomLine(), tank.getLeftLine(), tank.getRightLine()))
        {
          tank.kill(missle.firedTank);
          explosions.add(new Explosion(tank.centerX, tank.centerY));
          missle.lifeTime = 5000;
        }
      }
    }
  }
}

void barrelWallCollision()
{
  for (Tank tank : tankList)
  {
    if (tank.alive)
    {
      Line barrel;
      if (tank.power!= null && tank.power.type == "Missle")
      {
        barrel = tank.getBarrel(true);
      } else
      {
        barrel = tank.getBarrel(false);
      }

      ArrayList<Line> lines = new ArrayList<Line>();
      int cellColumn = tank.getColumn();
      int cellRow = tank.getRow();

      if (DEBUG)
      {
        if (tank.team.equals("red"))
          fill(#FF0000, 25);
        else if (tank.team.equals("green"))
          fill(#00FF00, 25);
        noStroke();
        rect(cellColumn*CELL_SIZE, cellRow*CELL_SIZE, CELL_SIZE, CELL_SIZE);
      }

      Cell cell = (maze.grid[cellRow][cellColumn]);


      //Cell cell = maze.grid[cellRow][cellColumn];
      if (!cell.walls[0].isOpen) //top
      {
        Line newLine = new Line(cell.left(), cell.top(), cell.right(), cell.top());
        lines.add(newLine);
      }
      if (!cell.walls[1].isOpen) //bottom
      {
        Line newLine = new Line(cell.left(), cell.bottom(), cell.right(), cell.bottom());
        lines.add(newLine);
      }

      if (!cell.walls[3].isOpen) //right
      {
        Line newLine = new Line(cell.right(), cell.top(), cell.right(), cell.bottom());
        lines.add(newLine);
      }
      if (!cell.walls[2].isOpen) //left
      {
        Line newLine = new Line(cell.left(), cell.top(), cell.left(), cell.bottom());
        lines.add(newLine);
      }

      for (Line aLine : lines)
      {
        if (lineLine(aLine, barrel))
        {
          tank.onWall = true;
          break;
        } else
        {
          tank.onWall = false;
        }
      }
    }
  }
}

public void updateBeam(Beam beam)
{
  //https://stackoverflow.com/a/6853926
  if (beam.time == 0)
  {
    float MAXANGLE = .12; //7 degrees
    float minDist = 20000;
    float minXX=0;
    float minYY = 0;
    Tank targetTank = null;
    for (Tank tank : tankList)
    {
      if (tank.team != beam.firedTank.team && tank.alive)
      {

        float A = tank.centerX - beam.line.x1;
        float B = tank.centerY - beam.line.y1;
        float C = beam.line.x2 - beam.line.x1;
        float D = beam.line.y2 - beam.line.y1;

        float dot = A * C + B * D;
        float len_sq = C * C + D * D;
        float param = -1;
        if (len_sq != 0) //in case of 0 length line
          param = dot/len_sq;

        float xx, yy;
        xx = -1;
        yy = -1;
        if (param < 0) {
          //xx = beam.line.x1;
          //yy = beam.line.y1;
        } else if (param > 1) {
          //xx = beam.line.x2;
          //yy = beam.line.y1;
        } else {
          xx = beam.line.x1 + param * C;
          yy = beam.line.y1 + param * D;
        }

        float dx = tank.centerX - xx;
        float dy = tank.centerY - yy;
        if (Math.sqrt(dx * dx + dy * dy) < minDist)
        {
          minDist = sqrt(dx * dx + dy * dy);
          targetTank = tank;
          minXX = xx;
          minYY = yy;
        }
        float angle = atan(dist(minXX, minYY, targetTank.centerX, targetTank.centerY)/dist(beam.firedTank.centerX, beam.firedTank.centerY, minXX, minYY));
        if (angle < MAXANGLE) //3 degrees
        {
          float controlPointX = beam.firedTank.centerX;
          float controlPointY = beam.firedTank.centerY;
          float controlPointX2 = (beam.firedTank.centerX+minXX)/2;
          float controlPointY2 = (beam.firedTank.centerY+minYY)/2;
          //Line line = new Line(minXX, minYY, targetTank.centerX, targetTank.centerY);
          ellipse(controlPointX, controlPointY, 5, 5);
          noFill();
          Float bezierPoints[] = {beam.firedTank.centerX+cos(beam.angle/360*TWO_PI)*(beam.w/2), beam.firedTank.centerY+sin(beam.angle/360*TWO_PI)*(beam.w/2), controlPointX, controlPointY, controlPointX2, controlPointY2, targetTank.centerX, targetTank.centerY};
          //bezier(bezierPoints[0],bezierPoints[1],bezierPoints[2],bezierPoints[3],bezierPoints[4],bezierPoints[5],bezierPoints[6],bezierPoints[7]);
          //line.display();
          //beam.line.display();

          float tx = bezierTangent(beam.firedTank.centerX, controlPointX, controlPointX2, targetTank.centerX, 1);
          float ty = bezierTangent(beam.firedTank.centerY, controlPointY, controlPointY2, targetTank.centerY, 1);


          float a = atan2(ty, tx);
          a += PI;
          Line line2 = new Line(targetTank.centerX, targetTank.centerY, cos(a)*-1400+targetTank.centerX, sin(a)*-1400+targetTank.centerY);
          //line2.display();
          beam.bezierPoints = bezierPoints;
          beam.bezier2 = line2;
        } else if (angle < .25)
        {
          float targetDist = sqrt((minXX-beam.firedTank.centerX)*(minXX-beam.firedTank.centerX)+(minYY-beam.firedTank.centerY)*(minYY-beam.firedTank.centerY))*tan(MAXANGLE);

          dx = targetTank.centerX-minXX;
          dy = targetTank.centerY-minYY;
          float dist = sqrt(dx*dx+dy*dy);
          float ratio = targetDist/dist;

          float controlPointX = beam.firedTank.centerX;
          float controlPointY = beam.firedTank.centerY;
          float controlPointX2 = (beam.firedTank.centerX+minXX)/2;
          float controlPointY2 = (beam.firedTank.centerY+minYY)/2;
          Float bezierPoints[] = {beam.firedTank.centerX+cos(beam.angle/360*TWO_PI)*(beam.w/2), beam.firedTank.centerY+sin(beam.angle/360*TWO_PI)*(beam.w/2), controlPointX, controlPointY, controlPointX2, controlPointY2, minXX+dx*ratio, minYY+dy*ratio};

          float tx = bezierTangent(beam.firedTank.centerX, controlPointX, controlPointX2, minXX+dx*ratio, 1);
          float ty = bezierTangent(beam.firedTank.centerY, controlPointY, controlPointY2, minYY+dy*ratio, 1);


          float a = atan2(ty, tx);
          a += PI;
          Line line2 = new Line(minXX+dx*ratio, minYY+dy*ratio, cos(a)*-1400+minXX+dx*ratio, sin(a)*-1400+ minYY+dy*ratio);
          beam.bezierPoints = bezierPoints;
          beam.bezier2 = line2;
        }
      }
    }
  }
}

public void beamCollision(Beam beam)
{
  if (beam.time > 45)
  {
    for (int i = 0; i < 100; i+=2)
    {
      float t = i/100.0;
      float x, y;
      if (beam.bezier2 != null)
      {
        for (Tank tank : tankList)
        {
          if (tank.alive && beam.firedTank != tank)
          {
            x = beam.bezier2.lerpX(t);
            y = beam.bezier2.lerpY(t);
            float centerX2 = tank.centerX-1/6*tank.w;
            float bulletX = cos(tank.angle/360*TWO_PI) * (x - centerX2) -
              sin(tank.angle/360*TWO_PI) * (y - tank.centerY) + centerX2;
            float bulletY  = sin(tank.angle/360*TWO_PI) * (x - centerX2) +
              cos(tank.angle/360*TWO_PI) * (y - tank.centerY) + tank.centerY;

            // Closest point in the rectangle to the center of circle rotated backwards(unrotated)
            float closestX, closestY;

            // Find the unrotated closest x point from center of unrotated circle
            if (bulletX  < centerX2-tank.w*2/3/2)
              closestX = centerX2-tank.w*2/3/2;
            else if (bulletX  > centerX2 + tank.w*2/3/2)
              closestX = centerX2+tank.w*2/3/2;
            else
              closestX = bulletX;

            // Find the unrotated closest y point from center of unrotated circle
            if (bulletY < tank.centerY-tank.h/2)
              closestY = tank.centerY-tank.h/2;
            else if (bulletY > tank.centerY+tank.h/2)
              closestY = tank.centerY+tank.h/2;
            else
              closestY = bulletY;

            // Determine collision
            boolean collision = false;

            float distance = dist(bulletX, bulletY, closestX, closestY);
            if (distance < 7/2)
            {
              collision = true; // Collision
              tank.kill(beam.firedTank);
              explosions.add(new Explosion(tank.centerX, tank.centerY));
              break;
            } else
              collision = false;
          }
        }
      }

      if (beam.bezierPoints != null)
      {
        for (Tank tank : tankList)
        {
          if (tank.alive && beam.firedTank != tank)
          {
            x = bezierPoint(beam.bezierPoints[0], beam. bezierPoints[2], beam.bezierPoints[4], beam.bezierPoints[6], t);
            y = bezierPoint(beam.bezierPoints[1], beam.bezierPoints[3], beam.bezierPoints[5], beam.bezierPoints[7], t);

            float centerX2 = tank.centerX-1/6*tank.w;
            float bulletX = cos(tank.angle/360*TWO_PI) * (x - centerX2) -
              sin(tank.angle/360*TWO_PI) * (y - tank.centerY) + centerX2;
            float bulletY  = sin(tank.angle/360*TWO_PI) * (x - centerX2) +
              cos(tank.angle/360*TWO_PI) * (y - tank.centerY) + tank.centerY;

            // Closest point in the rectangle to the center of circle rotated backwards(unrotated)
            float closestX, closestY;

            // Find the unrotated closest x point from center of unrotated circle
            if (bulletX  < centerX2-tank.w*2/3/2)
              closestX = centerX2-tank.w*2/3/2;
            else if (bulletX  > centerX2 + tank.w*2/3/2)
              closestX = centerX2+tank.w*2/3/2;
            else
              closestX = bulletX;

            // Find the unrotated closest y point from center of unrotated circle
            if (bulletY < tank.centerY-tank.h/2)
              closestY = tank.centerY-tank.h/2;
            else if (bulletY > tank.centerY+tank.h/2)
              closestY = tank.centerY+tank.h/2;
            else
              closestY = bulletY;

            // Determine collision
            boolean collision = false;

            float distance = dist(bulletX, bulletY, closestX, closestY);
            if (distance < 7/2)
            {
              collision = true; // Collision
              tank.kill(beam.firedTank);
              explosions.add(new Explosion(tank.centerX, tank.centerY));
              break;
            } else
              collision = false;
          }
        }
      } else
      {
        x = beam.line.lerpX(t);
        y = beam.line.lerpY(t);
        for (Tank tank : tankList)
        {
          if (tank.alive && beam.firedTank != tank)
          {
            x = beam.line.lerpX(t);
            y = beam.line.lerpY(t);

            float centerX2 = tank.centerX-1/6*tank.w;
            float bulletX = cos(tank.angle/360*TWO_PI) * (x - centerX2) -
              sin(tank.angle/360*TWO_PI) * (y - tank.centerY) + centerX2;
            float bulletY  = sin(tank.angle/360*TWO_PI) * (x - centerX2) +
              cos(tank.angle/360*TWO_PI) * (y - tank.centerY) + tank.centerY;

            // Closest point in the rectangle to the center of circle rotated backwards(unrotated)
            float closestX, closestY;

            // Find the unrotated closest x point from center of unrotated circle
            if (bulletX  < centerX2-tank.w*2/3/2)
              closestX = centerX2-tank.w*2/3/2;
            else if (bulletX  > centerX2 + tank.w*2/3/2)
              closestX = centerX2+tank.w*2/3/2;
            else
              closestX = bulletX;

            // Find the unrotated closest y point from center of unrotated circle
            if (bulletY < tank.centerY-tank.h/2)
              closestY = tank.centerY-tank.h/2;
            else if (bulletY > tank.centerY+tank.h/2)
              closestY = tank.centerY+tank.h/2;
            else
              closestY = bulletY;

            // Determine collision
            boolean collision = false;

            float distance = dist(bulletX, bulletY, closestX, closestY);
            if (distance < 7/2)
            {
              collision = true; // Collision
              tank.kill(beam.firedTank);
              explosions.add(new Explosion(tank.centerX, tank.centerY));
              break;
            } else
              collision = false;
          }
        }
      }
    }
  }
}


public void drawStats()
{
tint(255, 80);
  image(statsTemplate, 1200/2, 900/2);
tint(255, 255);
  float inBetween = (1200.0+200)/(tankList.size()+1);
  float y = 450;
  for (int i = 0; i < tankList.size(); i++)
  {
    Tank tank = tankList.get(i);

    float x = (i+1)*inBetween-100;
    if (tank.team.equals("Green"))
    {
      image(greenStats, x, y);
    } else if (tank.team.equals("Red"))
    {
      image(redStats, x, y);
    } else if (tank.team.equals("Blue"))
    {
      image(blueStats, x, y);
    } else if (tank.team.equals("Orange"))
    {
      image(orangeStats, x, y);
    }


    fill(#000000);
    float textOffset =90;
    float lineHeight = 40;
    textFont(regular, 16);
    textAlign(LEFT);
    String text = "";
    int index = 0;
    for (Tank tank2 : tankList)
    {
      if (tank2.team != tank.team)
      {
        text=text+String.format("%-11s", tank2.team);
        textFont(bold, 30);
        textAlign(CENTER);
        text(tank.getKills(tank2), x-70+index*65, y-95);
        index++;
        textFont(regular, 16);
        textAlign(LEFT);
      }
    }
    text(text, x-90, y-70);

    textAlign(RIGHT);
    textFont(bold, 30);
    text(tank.getKills(tank), x+textOffset, y-15); //suicides
    text(tank.getKD(), x+textOffset, y-15+lineHeight); //KD
    text(tank.bulletsFired, x+textOffset, y-15+lineHeight*2); //bullets fired
    text(tank.getAccuracy(), x+textOffset+5, y-15+lineHeight*3); //accuracy
    textFont(bold, 15);
    text("%", x+textOffset+5, y-15+lineHeight*3);
    textFont(bold, 30);
    text(tank.powerUpsCollected, x+textOffset, y-15+lineHeight*4.1); //power ups collected
    text(tank.fumbles, x+textOffset, y-15+lineHeight*5.1); //fumbles
    drawBarChart(tank, x, y+205);
  }

  textFont(bold, 90);
  textAlign(CENTER);
  text(totalGames-1, 410, 120);
  int milliseconds = millis()-startTime;
  int seconds = (int) (milliseconds / 1000) % 60 ;
  int minutes = (int) ((milliseconds / (1000*60)) % 60);
  int hours   = (int) ((milliseconds / (1000*60*60)) % 24);
  text(String.format("%01d:%02d:%02d", hours, minutes, seconds), 750, 120);
  textFont(bold, 30);
  text("Games Played", 410, 150);
  text("Time Played", 750, 150);


  textAlign(LEFT);
  fill(#000000);
  textFont(regular, 18);
  textSize(18);
  text("ESC to exit", 20, 30);
  //text("FPS: " + String.format("%.01f", frameRate), 1110, 880);
  
}

void drawSmoke(float centerX, float centerY, float R, Tank tank)
{
  float r = R * sqrt(random(0, 1));
  float theta = random(0, 1) * 2 * PI;
  float x = centerX + r * cos(theta);
  float y = centerY + r * sin(theta);
  float opacity = random(120, 180);
  float smokeRadius = random(8, 15);

  if (tank.smokeList.size()< 20 && frameCount%2==0)
  {
    tank.smokeList.add(new Smoke(x, y, smokeRadius, opacity));
  }
}

void drawBarChart(Tank tank, float x, float y)
{
  fill(#414141);
  float chartWidth = tankList.size()*(8+5);

  x = x-chartWidth/2;
  float maxHeight = 35.0;
  for (int i = 0; i < tankList.size(); i++)
  {
    if (i == 0)
    {
      float rectHeight = maxHeight*tank.score/121/(totalGames-1);
      rect(x+13*i, y+35-rectHeight, 8, rectHeight);
    } else if (i == 1)
    {
      float rectHeight = maxHeight*tank.secondPlace/(totalGames-1);
      rect(x+13*i, y+35-rectHeight, 8, rectHeight);
    } else if (i == 2)
    {
      float rectHeight = maxHeight*tank.thirdPlace/(totalGames-1);
      rect(x+13*i, y+35-rectHeight, 8, rectHeight);
    } else if (i == 3)
    {
      float rectHeight = maxHeight*tank.fourthPlace/(totalGames-1);
      rect(x+13*i, y+35-rectHeight, 8, rectHeight);
    }
  }
  fill(#000000);
}

void drawStatsButton()
{
  if (STATS)
  {
    pushMatrix();
    translate(40, 860);
    rotate(statsAngle);
    statsAngle +=0.05;
    image(statsButton, 0, 0);
    popMatrix();
  } else
  {
    image(statsButton, 40, 860);
  }
}
