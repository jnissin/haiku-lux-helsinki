import codeanticode.syphon.*;

boolean PRESSED = false;

Theme SELECTED_THEME;
float TRIANGLE_SIZE = 60;
int MIN_TRIANGLE_CHAIN_COUNT = 10;
int MAX_TRIANGLE_CHAIN_COUNT = 500;
int INITIAL_TRIANGLE_CHAIN_COUNT = 10;
int SMOOTHING = 4;
int TARGET_FRAME_RATE = 30;

ArrayList<TriangleChain> TRIANGLE_CHAINS;
PGraphics PG_CANVAS;
SyphonServer SYPHON_SERVER;
float R;
float r;

public void settings()
{
  size(1920/2, 1280/2, P3D); 
  smooth(SMOOTHING);
}

public void setup()
{
  PG_CANVAS = createGraphics(width, height, P3D);
  SYPHON_SERVER = new SyphonServer(this, "Processing: Origami");
  frameRate(TARGET_FRAME_RATE);
  initialize();
}

public void initialize()
{
  PG_CANVAS.smooth(SMOOTHING);
  TRIANGLE_CHAINS = new ArrayList<TriangleChain>();
  R = TRIANGLE_SIZE;//random(15, 120);
  r = sqrt(3) * R / 2;
  SELECTED_THEME = THEMES[(int)random(THEMES.length)];
  spawnTriangleChains(INITIAL_TRIANGLE_CHAIN_COUNT);
}

public void draw()
{
  surface.setTitle("Origami: " + SELECTED_THEME.name + " @ " + (int)frameRate + " FPS");

  // If mouse is pressed add new triangle chains
  if (PRESSED)
  {
    spawnTriangleChains(1);
  }
  
  if (TRIANGLE_CHAINS.size() < MIN_TRIANGLE_CHAIN_COUNT)
  {
    spawnTriangleChains(MIN_TRIANGLE_CHAIN_COUNT - TRIANGLE_CHAINS.size());
  }
  
  // Display each triangle chain and prune finished triangle chains
  ArrayList<TriangleChain> chainsToRemove = new ArrayList<TriangleChain>();

  PG_CANVAS.beginDraw();
  PG_CANVAS.background(SELECTED_THEME.backgroundColor);
  
  for (TriangleChain c : TRIANGLE_CHAINS)
  {
    c.display(PG_CANVAS);
    
    if (c.isFinished())
    {
      chainsToRemove.add(c);
    }
  }
  
  PG_CANVAS.endDraw();
  image(PG_CANVAS, 0, 0);
  SYPHON_SERVER.sendImage(PG_CANVAS);
  
  // Prune finished triangle chains
  for (TriangleChain c : chainsToRemove)
  {
    TRIANGLE_CHAINS.remove(c);
  }
  
  if (millis()%20 == 0)
  {
    PRESSED = true;
  }
  else
  {
    PRESSED = false;
  }
}

public void mousePressed()
{
  PRESSED = true;
}

public void mouseReleased()
{
  PRESSED = false;
}

public void keyPressed()
{
  // Use 'n' to navigate to next theme
  if (key == 'n')
  {
    initialize();
  }
}

public void spawnTriangleChains(int num)
{
  for (int i = 0; i < num && TRIANGLE_CHAINS.size() <= MAX_TRIANGLE_CHAIN_COUNT; i++)
  {
    int rx = round(random(0, width) / r);
    int ry = round(random(0, height) / R);
    boolean bx = rx % 2 == 0;
    boolean by = ry % 2 == 0;
    float x = rx * r;
    float y = (ry - (bx ? 0 : .5)) * R;
    TRIANGLE_CHAINS.add(new TriangleChain(x, y, bx != by, SELECTED_THEME.getNextThemeColor(), (int)random(20, 50), (int)random(1000, 2000)));    
  }
}
