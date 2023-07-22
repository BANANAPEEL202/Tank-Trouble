/*
  Maze Generator.
 Written in Processing 3.
 */

public class Maze {
  public Maze(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;

    this.grid = new Cell[rows][cols];
    wallList = new ArrayList();
    generateCells();
    generateMaze();
    openMaze();
    addCorners();
    
  }

  private void generateMaze() {
    Cell currentCell = grid[int(random(rows))][int(random(cols))];

    firstCell = currentCell;
    insertCellToMaze(currentCell, null);

    while (!wallList.isEmpty()) {
      Wall currentWall = wallList.get(int(random(wallList.size())));

      if (!currentWall.isEdge) {
        if (!(currentWall.c1.isInMaze && currentWall.c2.isInMaze)) {
          currentWall.toOpenWall();

          if (currentWall.c1.isInMaze) {
            insertCellToMaze(currentWall.c2, currentWall);
          } else {
            insertCellToMaze(currentWall.c1, currentWall);
          }
        }
      }
      wallList.remove(currentWall);
    }

    do {
      endCell = grid[int(random(rows))][int(random(cols))];
    } while (firstCell == endCell);
    //getMazeArray();
  }
  
  void getMazeArray()
  {
    for (int i = 0; i < rows*2-1; i+=2)
    {
      for (int j = 0; j < cols*2-1; j+=2)
      {
        //0 = top
        //1 = bottom
        //2 = left
        //3 = right
        Wall[] walls = grid[i/2][j/2].walls;
        mazeArray[i][j] = 0;
        if (walls[3].isOpen)
        {
          mazeArray[i][j+1] = 1;       
        }
        else
        {
          mazeArray[i][j+1] = 0; 
        }
        if (walls[1].isOpen)
        {
          mazeArray[i+1][j] = 1;       
        }
        else
        {
          mazeArray[i][j+1] = 0; 
        }

      }
    }
     for (int i = 0; i < rows*2-1; i+=2)
    {
      for (int j = 0; j < cols*2-1; j+=2)
      {
        print(mazeArray[i][j]);
      }
      println("");
    }
  }

  //Inserts the cell to the maze and its walls, but skip one of the wall.
  private void insertCellToMaze(Cell pCell, Wall skipWall) {
    pCell.setIsInMaze();
    for (Wall wall : pCell.walls) {
      if (wall != skipWall) {
        wallList.add(wall);
      }
    }
  }

  //Initializes the grid of cells
  private void generateCells() {
    for (int i = 0; i < rows; ++i) {
      for (int j = 0; j < cols; ++j) {
        grid[i][j] = new Cell(i, j);
      }
    }
    generateWalls(); //Set all the walls of the maze.
  }

  //Initializes the walls of cells
  private void generateWalls() {
    for (int i = 0; i < rows; ++i) {
      for (int j = 0; j < cols; ++j) {

        // FIX TOP WALL
        if (i == 0) {
          grid[i][j].walls[0] = new Wall();
          grid[i][j].walls[0].c1 = grid[i][j];
          grid[i][j].walls[0].setIsEdge();
        } else {
          grid[i][j].walls[0] = grid[i-1][j].walls[1]; //The top wall is the same that the bottom wall above the cell.
          grid[i][j].walls[0].c2 = grid[i][j];
        }

        //FIX BOTTOM WALL
        grid[i][j].walls[1] = new Wall();
        grid[i][j].walls[1].c1 = grid[i][j];
        if (i == rows-1) {
          grid[i][j].walls[1].setIsEdge();
        }

        //FIX LEFT WALL
        if (j == 0) {
          grid[i][j].walls[2] = new Wall();
          grid[i][j].walls[2].c1 = grid[i][j];
          grid[i][j].walls[2].setIsEdge();
        } else {
          grid[i][j].walls[2] = grid[i][j-1].walls[3]; //The left wall is the same that the right wall of the previous cell.
          grid[i][j].walls[2].c2 = grid[i][j];
        }

        //FIX RIGHT WALL
        grid[i][j].walls[3] = new Wall();
        grid[i][j].walls[3].c1 = grid[i][j];
        if (j == cols-1) {
          grid[i][j].walls[3].setIsEdge();
        }
      }
    }
  }

  public void addCorners()
  {
    for (int i = 0; i < rows-1; i++)
    {
      for (int j = 0; j < cols-1; j++)
      {
        //0 = top
        //1 = bottom
        //2 = left
        //3 = right
        Wall[] topLeft = grid[i][j].walls;
        Wall[] topRight = grid[i][j+1].walls;
        Wall[] bottomLeft = grid[i+1][j].walls;
        Wall[] bottomRight = grid[i+1][j+1].walls;
        boolean right, left, top, bottom;
        right = false;
        left = false;
        top = false;
        bottom = false;
        if (!topLeft[1].isOpen || !bottomLeft[0].isOpen)
        {
          left = true;
        }
        if (!topRight[1].isOpen || !bottomRight[0].isOpen)
        {
          right = true;
        }
        if (!topRight[2].isOpen || !topLeft[3].isOpen)
        {
          top = true;
        }
        if (!bottomRight[2].isOpen || !bottomLeft[3].isOpen)
        {
          bottom = true;
        }
        
        boolean addCorner = false;
        if (left && bottom && !top && !right)
        {
          addCorner = true; 
        }
        else if (!left && !bottom && top && right)
        {
          addCorner = true;
        }
        else if (!left && !top && bottom && right)
        {
          addCorner = true;
        }
        else if (left && top && !bottom && !right)
        {
          addCorner = true;
        }
        else if (exactlyOneTrue(top, right, left, bottom))
        {
          addCorner = true;
        }
        if (addCorner)
        {
          Corner newCorner = new Corner(j*CELL_SIZE+CELL_SIZE, i*CELL_SIZE+CELL_SIZE);
          newCorner.left = left;
          newCorner.right = right;
          newCorner.top = top;
          newCorner.bottom = bottom;
          corners.add(newCorner);
        }

      }
    }
  }
  
  private void openMaze()
  {
    for (int i = 1; i < rows-1; ++i) {
      for (int j = 1; j < cols-1; ++j) {
          Cell cell = grid[i][j];
          int delete =(int)random(0, 8);
          if (delete == 0)
          {
            for (Wall wall: cell.walls)
            {
              delete =(int)random(0, 3);
          if (delete != 0)
          {
              wall.toOpenWall();
          }
            }
          }
          
        
      }
    }
  }

  public void viewCorners()
  {
    for (Corner corner : corners)
    {
      corner.display();
    }
  }

  public ArrayList<Cell> getSurroundingCells(int cellRow, int cellCol)
  {

    ArrayList<Cell> cells = new ArrayList<Cell>();
    cells.add(grid[cellRow][cellCol]);
    for (int i = cellRow - 1; i <= cellRow+1; i++)
    {
      for (int j = cellCol -1; j <= cellCol+1; j++)
      {
        if (!(i < 0) && !(i>rows-1) && !(j<0) && !(j>cols-1))
        {
          if (!(i == cellRow && j == cellCol))
          {
          cells.add(grid[i][j]);
          }
        }
      }
    }
    return cells;
  }
  
  public void generatePowerUps()
  {
    int count = countPowerUps();
    if (count <= 10)
    {
    for (int i = 0; i < rows; ++i) {
      for (int j = 0; j < cols; ++j) {
          Cell cell = grid[i][j];
          int random =(int)random(0, 40000);

          if (cell.powerUp == null)
          {
            if (random == 0)
            {
              int powerSelector =(int)random(0,6);
              //powerSelector=3;
              cell.powerUp = new PowerUp(j*CELL_SIZE+35, i*CELL_SIZE+35, powerSelector);
              cell.powerUp.playSpawnSound();
              POWERCOUNT+=1;
            }
          }
          
        
      }
    }
    }
  }
  
  public int countPowerUps()
  {
    int count = 0;
    for (int i = 0; i < rows; ++i) {
      for (int j = 0; j < cols; ++j) {
          Cell cell = grid[i][j];
          if (cell.powerUp != null)
          {
             count++;
          }     
        
      }
    }
    return count;
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
  
    public void clearVisited() {
    for (int i = 0; i < rows; ++i) {
      for (int j = 0; j < cols; ++j) {
        grid[i][j].visited = false;
      }
    }
   }
   
    public void clearParents() {
    for (int i = 0; i < rows; ++i) {
      for (int j = 0; j < cols; ++j) {
        grid[i][j].parent=null;
      }
    }
   }


  int rows;
  int cols;

  Cell firstCell;
  Cell endCell;

  Cell[][] grid;
  ArrayList<Wall> wallList;
  ArrayList <Corner> corners = new ArrayList<Corner>();
  
  int[][] mazeArray = new int[20][32];
}
