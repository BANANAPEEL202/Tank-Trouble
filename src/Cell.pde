/*
  Maze Generator.
  Written in Processing 3.
*/

public class Cell{
  public Cell(int x, int y){
    this.x = x;
    this.y = y;
    this.isInMaze = false;;
    this.walls = new Wall[4];
    topLeft = false;
  topRight = false;
  bottomLeft = false;
  bottomRight = false;

  }
  
  public Cell(Cell cell2){
    this.x = cell2.x;
    this.y = cell2.y;
    this.isInMaze = cell2.isInMaze;
    this.walls = cell2.walls;
    topLeft = cell2.topLeft;
  topRight = cell2.topRight;
  bottomLeft = cell2.bottomLeft;
  bottomRight = cell2.bottomRight;
  parent = cell2.parent;
  this.visited= cell2.visited;
  this.hasTank = cell2.hasTank;
  this.target = cell2.target;
  }
  

  public void setIsInMaze(){
    this.isInMaze = true;
  }

  int x;
  int y;
  boolean isInMaze;
  boolean topLeft, topRight, bottomLeft, bottomRight;
  boolean visited = false;
  boolean hasTank = false;
  PowerUp powerUp;
  Cell parent = null;
  
  int target=-1; //0 = top, 1 = bottom, 2 = left, 3 = right
  

  Wall[] walls; // TOP, BOTTOM, LEFT, RIGHT
  
  public float right()
  {
    return y * CELL_SIZE + CELL_SIZE;
  }
  
  public float left()
  {
    return y * CELL_SIZE;
  }
  public float top()
  {
    return x * CELL_SIZE;
  }
  
  public float bottom()
  {
    return x * CELL_SIZE + CELL_SIZE;
  }
  
  public Cell getParent()
  {
    return this.parent;
  }
  
    public void display()
  {
    fill(#FF0000, 25);
    noStroke();
    rect(left(), top(), CELL_SIZE, CELL_SIZE);
  }
  
   public void display2()
  {
    fill(#00FF00, 50);
    noStroke();
    rect(left(), top(), CELL_SIZE, CELL_SIZE);
  }
  
  
}
