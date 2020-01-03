ArrayList<TriangleChain> chains;
float R, r;
Boolean pressed = false;
PVector[] palette;

Theme SELECTED_THEME;
float TRIANGLE_SIZE = 60;
int MIN_TRIANGLE_CHAIN_COUNT = 10;
int MAX_TRIANGLE_CHAIN_COUNT = 500;
int INITIAL_TRIANGLE_CHAIN_COUNT = 10;

public void settings()
{
  size(800, 800, P3D); 
}

public void setup() {
  initialize();
}

public void initialize()
{
  chains = new ArrayList<TriangleChain>();
  R = TRIANGLE_SIZE;//random(15, 120);
  r = sqrt(3) * R / 2;
  SELECTED_THEME = THEMES[(int)random(THEMES.length)];
  spawnTriangleChains(INITIAL_TRIANGLE_CHAIN_COUNT);
}

public void draw()
{
  surface.setTitle("Origami: " + SELECTED_THEME.name + " @ " + (int)frameRate + " FPS");
  background(SELECTED_THEME.backgroundColor);
  
  // If mouse is pressed add new triangle chains
  if (pressed)
  {
    spawnTriangleChains(1);
  }
  
  if (chains.size() < MIN_TRIANGLE_CHAIN_COUNT)
  {
    spawnTriangleChains(MIN_TRIANGLE_CHAIN_COUNT - chains.size());
  }
  
  
  
  // Display each triangle chain and prune finished triangle chains
  ArrayList<TriangleChain> chainsToRemove = new ArrayList<TriangleChain>();

  for (TriangleChain c : chains)
  {
    c.display();
    
    if (c.isFinished())
    {
      chainsToRemove.add(c);
    }
  }
  
  // Prune finished triangle chains
  for (TriangleChain c : chainsToRemove)
  {
    chains.remove(c);
  }
  
  if (millis()%20 == 0)
  {
    pressed = true;
  }
  else
  {
    pressed = false;
  }
}

public void mousePressed()
{
  pressed = true;
}

public void mouseReleased()
{
  pressed = false;
}

public void keyPressed()
{ 
  initialize();
}

public void spawnTriangleChains(int num)
{
  for (int i = 0; i < num && chains.size() <= MAX_TRIANGLE_CHAIN_COUNT; i++)
  {
    int rx = round(random(0, width) / r);
    int ry = round(random(0, height) / R);
    boolean bx = rx % 2 == 0;
    boolean by = ry % 2 == 0;
    float x = rx * r;
    float y = (ry - (bx ? 0 : .5)) * R;
    chains.add(new TriangleChain(x, y, bx != by, SELECTED_THEME.getNextThemeColor(), (int)random(20, 50), (int)random(1000, 2000)));    
  }
}
