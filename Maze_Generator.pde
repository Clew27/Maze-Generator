/** Recursive Backtracker Maze Generating Algorithm
 LINK: https://en.wikipedia.org/wiki/Maze_generation_algorithm
 */

// Simulation control 
int CANVAS_SIZE = 1500; // Don't forget to change it in size( x, y );
int REFRESH_RATE = 60;  // Updates per second
int GRIDS = 20; // Number of GRIDS in each column/row
int CELL_DIMENSION = CANVAS_SIZE / GRIDS; // Global dimension of each cell (px)
int STARTING_NODE_X = (int) Math.floor( GRIDS / 2 ); // X position ( X axis = 0 to GRIDS - 1 )
int STARTING_NODE_Y = (int) Math.floor( GRIDS / 2 ); // Y position ( Y axis = 0 to GRIDS - 1 )

// Display control
boolean DISPLAY_STACK          = true; // Display all cells in the stacks
boolean DISPLAY_ACCESSED_CELLS = true; // Display all cells that have been accessed
boolean DISPLAY_SOLUTION       = true; // Display the solution to the maze

// Display constants
int BACKGROUND_COLOR    = 0xFF333333; // HEX Color Code for the background
int BORDER_COLOR        = 0xFFFFFFFF; // HEX Color Code for the lines
int CURRENT_CELL_COLOR  = 0xFFFFF07C; // HEX Color Code for the current node
int STACK_CELL_COLOR    = 0xFFFF69B4; // HEX Color Code for all elements in the stack
int ACCESSED_CELL_COLOR = 0xFF7EE8FA; // HEX Color Code for all elements that have been accessed
int FURTHEST_CELL_COLOR = 0xFF80FF72; // HEX Color Code for the longest path
int SOLVE_PATH_COLOR    = 0xFFC8FF69; // HEX Color Code for the solution's path

int BORDER_STROKE     = 3;  // Stroke for the border
int SOLVE_PATH_WIDTH  = 10; // Line width = SOLVE_PATH_WIDTH% of CELL_DIMENSION

// Saved variable
boolean isSaved = false;

// Data storage
ArrayList<Cell> cells = new ArrayList<Cell>(); // Stores cell positions in a 1D array
ArrayList<Cell> traversedNodes = new ArrayList<Cell>(); // Stack of indexes traveled

// Tracking endpoint ( A.K.A. Longest path of the maze )
Cell currentNode;
Cell furthestNode;
int furthestDistance = 0;
int currentDistance = 0;
ArrayList<Cell> solvePath = new ArrayList<Cell>();


void setup() {
  size( 1500, 1500 );

  // Generate Cells
  for ( int y = 0; y < GRIDS; y++ ) {
    for ( int x = 0; x < GRIDS; x++ ) {
      Cell cell = new Cell( x, y );
      cells.add(cell);
    }
  }

  // Set currentNode as STARTING_NODE_X, STARTING_NODE_Y
  currentNode = cells.get( GRIDS * STARTING_NODE_Y + STARTING_NODE_X );
  currentNode.accessed = true;
  furthestNode = currentNode;
  traversedNodes.add(currentNode); // Add initial node to stack

  frameRate(REFRESH_RATE); // Helps show the simulation better
}

void draw() {
  background(BACKGROUND_COLOR);
  drawCells();
  update();
}


/***** Methods *****/

/** Renders all the cells
 */
void drawCells() {
  if ( traversedNodes.size() != 1 && DISPLAY_ACCESSED_CELLS )
    drawAccessedCells();
  if ( DISPLAY_STACK )
    colorCells( traversedNodes, STACK_CELL_COLOR ); // Color all cells in stack
  colorCell( furthestNode, FURTHEST_CELL_COLOR ); // Color furthest node
  colorCell( currentNode, CURRENT_CELL_COLOR ); // Color current cell

  for ( Cell cell : cells )
    cell.draw();
}

/** Colors all given cells a certain color
 Parameters: An array of all the cells that need coloring, HEX code for the color of the cells
 */
void colorCells( ArrayList<Cell> coloredCells, int HEX ) {
  for ( Cell cell : coloredCells )
    colorCell( cell, HEX );
}

/** Colors the given cell a certain color
 Parameters: The cell that needs to be colored, HEX code for the color of the cell
 */
void colorCell( Cell cell, int HEX ) {
  noStroke();
  fill(HEX);
  rect( CELL_DIMENSION * cell.x, CELL_DIMENSION * cell.y, CELL_DIMENSION, CELL_DIMENSION );
}

/** Draws a line that shows the solution's path
 Parameters: Array list of the solution's path, Color of the line
 */
void drawSolution( ArrayList<Cell> solution, int HEX ) {
  noStroke();
  fill(SOLVE_PATH_COLOR);
  for ( int i = 0; i < solution.size(); i++ ) {
    int centerX = CELL_DIMENSION * solution.get(i).x + CELL_DIMENSION / 2;
    int centerY = CELL_DIMENSION * solution.get(i).y + CELL_DIMENSION / 2;
    int CELL_DIMENSIONHalfed = CELL_DIMENSION / 2;
    float width = CELL_DIMENSION * SOLVE_PATH_WIDTH / 100;
    float widthHalfed = width / 2;

    // Draw the first half of the line
    if ( i != 0 ) { // If there's a cell in front
      int prevCellPos = solution.get(i).getPosition( solution.get(i - 1) );
      if ( prevCellPos == 0 )      // Top
        rect( centerX - widthHalfed, centerY - CELL_DIMENSIONHalfed, width, widthHalfed + CELL_DIMENSIONHalfed );
      else if ( prevCellPos == 1 ) // Left
        rect( centerX - CELL_DIMENSIONHalfed, centerY - widthHalfed, widthHalfed + CELL_DIMENSIONHalfed, width );
      else if ( prevCellPos == 2 ) // Bottom
        rect( centerX - widthHalfed, centerY - widthHalfed, width, widthHalfed + CELL_DIMENSIONHalfed );
      else                         // Right
      rect( centerX - widthHalfed, centerY - widthHalfed, widthHalfed + CELL_DIMENSIONHalfed, width );
    }

    // Draw the second half of the line
    if ( i != solution.size() - 1 ) { // If there's a cell behind
      int nextCellPos = solution.get(i).getPosition( solution.get(i + 1) );
      if ( nextCellPos == 0 )      // Top
        rect( centerX - widthHalfed, centerY - CELL_DIMENSIONHalfed, width, widthHalfed + CELL_DIMENSIONHalfed );
      else if ( nextCellPos == 1 ) // Left
        rect( centerX - CELL_DIMENSIONHalfed, centerY - widthHalfed, widthHalfed + CELL_DIMENSIONHalfed, width );
      else if ( nextCellPos == 2 ) // Bottom
        rect( centerX - widthHalfed, centerY - widthHalfed, width, widthHalfed + CELL_DIMENSIONHalfed );
      else                         // Right
      rect( centerX - widthHalfed, centerY - widthHalfed, widthHalfed + CELL_DIMENSIONHalfed, width );
    }
  }
}

/** Draws all the cells that have been accessed
 */
void drawAccessedCells() {
  for ( Cell cell : cells )
    if ( cell.accessed )
      colorCell( cell, ACCESSED_CELL_COLOR );
}

/** Implements the algorithm that goes through all the individual cells to create a maze
 */
void update() {
  ArrayList<Cell> neighbors = currentNode.getNeighbors();
  // Go to random neighbor
  if ( neighbors.size() != 0 ) { // If there are neighbors
    currentNode = neighbors.get( (int) Math.floor(Math.random() * neighbors.size()) ); // Selects a random neighbor
    currentNode.accessed = true;
    currentNode.breakWalls(traversedNodes.get(traversedNodes.size() - 1));
    traversedNodes.add(currentNode);

    currentDistance++;
    // Updates the endpoint if possible
    if ( currentDistance > furthestDistance ) {
      furthestNode = currentNode;
      furthestDistance = currentDistance;
      arraylistCopyTo( traversedNodes, solvePath );
    }
  } else if ( traversedNodes.size() > 1 ) { // If the current node has no neighbors, pop the stack
    traversedNodes.remove(traversedNodes.size() - 1);
    currentNode = traversedNodes.get(traversedNodes.size() - 1);

    currentDistance--;
  } else { // If the maze is done rendering
    if ( !isSaved ) {
      save("maze.jpg"); // Saves image to program folder
      if ( traversedNodes.size() == 1 && DISPLAY_SOLUTION ) {
        drawSolution( solvePath, SOLVE_PATH_COLOR );
        save("maze solution.jpg");
      }
      isSaved = true;
    }
  }
}

/** Copies individual elements (not immutable) from the initial array list to the target array list
 Makes sure that the two array lists don't have the same references
 Parameters: The initial array, The array that will be copied to
 */
void arraylistCopyTo( ArrayList<Cell> init, ArrayList<Cell> target ) {
  if ( target != null )
    target.clear();
  if ( init == null ) // If both array lists are null
    return;
  for ( int i = 0; i < init.size(); i++ )
    target.add( init.get(i) );
}



/***** Classes *****/

/** Base cell class
 */
class Cell {
  public int x; // Too lazy...
  public int y; // Didn't make accessor functions
  public boolean accessed = false; // Make accessor functions ( I'm lazy :P )
  private boolean walls[] = { true, true, true, true }; // Which walls have lines
  //                             TOP  LEFT  BOTTOM RIGHT                         

  public Cell( int x, int y ) {
    this.x = x;
    this.y = y;
  }

  /** Draws the walls of the cell as indivdual lines
   */
  public void draw() {
    int left = CELL_DIMENSION * x;
    int right = CELL_DIMENSION * (x + 1);
    int top = CELL_DIMENSION * y;
    int bottom = CELL_DIMENSION * (y + 1);    

    stroke(BORDER_COLOR);
    strokeWeight(BORDER_STROKE);

    // TOP
    if ( walls[0] )
      line( left, top, right, top );
    // LEFT
    if ( walls[1] )
      line( left, top, left, bottom );
    // BOTTOM
    if ( walls[2] )
      line( left, bottom, right, bottom );
    // RIGHT
    if ( walls[3] )
      line( right, top, right, bottom );
  }

  /** Finds all bordering cells that have not been accessed before
   Return: An arraylist with all available neighbors
   */
  public ArrayList<Cell> getNeighbors() {
    ArrayList<Cell> neighbors = new ArrayList<Cell>();
    int translatedIndex = GRIDS * y + x; // Index of cell translated to corresponding array position
    int scaledX = CELL_DIMENSION * x;
    int scaledY = CELL_DIMENSION * y;

    // Check cell above
    if ( scaledY - CELL_DIMENSION >= 0 && !cells.get(translatedIndex - GRIDS).accessed )
      neighbors.add( cells.get(translatedIndex - GRIDS) );
    // Check cell to the left
    if ( scaledX - CELL_DIMENSION >= 0 && !cells.get(translatedIndex - 1).accessed )
      neighbors.add( cells.get(translatedIndex - 1) );
    // Check cell below
    if ( scaledY + CELL_DIMENSION < CANVAS_SIZE && !cells.get(translatedIndex + GRIDS).accessed )
      neighbors.add( cells.get(translatedIndex + GRIDS) );
    // Check cell to the right
    if ( scaledX + CELL_DIMENSION < CANVAS_SIZE && !cells.get(translatedIndex + 1).accessed )
      neighbors.add( cells.get(translatedIndex + 1) );

    return neighbors;
  }

  /** Removes walls in between the current cell and the given cell
   Parameters: The other cell
   */
  public void breakWalls( Cell other ) {
    int compPosition = getPosition( other );
    // If on the top
    if ( compPosition == 0 ) {
      walls[0] = false;
      other.walls[2] = false;
    }
    // If on the left
    else if ( compPosition == 1 ) {
      walls[1] = false;
      other.walls[3] = false;
    }
    // If on the bottom
    else if ( compPosition == 2 ) {
      walls[2] = false;
      other.walls[0] = false;
    }
    // If on the right
    else {
      walls[3] = false;
      other.walls[1] = false;
    }
  }

  /** Checks the position of the other cell relative to the current cell
   Return: 0 Top, 1 Left, 2 Bottom, 3 Right
   */
  public int getPosition( Cell other ) {
    // If on the top
    if ( y > other.y ) {
      return 0;
    }
    // If on the left
    else if ( x > other.x ) {
      return 1;
    }
    // If on the bottom
    else if ( y < other.y ) {
      return 2;
    }
    // If on the right
    return 3;
  }
}
