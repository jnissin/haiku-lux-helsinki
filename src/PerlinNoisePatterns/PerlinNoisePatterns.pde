import codeanticode.syphon.*;

int INITIAL_PARTICLE_COUNT = 200;
int MAX_PARTICLES = 2000;
int RANDOM_SEED = 1339;
int SMOOTHING = 4;

int PARTICLE_GENERATION_COOLDOWN_MS = 100;
int LAST_PARTICLE_GENERATION_TIME_MS = 0;
int PARTICLE_IDX = 0;
int PARTICLE_THEME_CHANGE_COUNT = 3000;
int THEME_IDX = 0;
int RESET_COUNT = 0;
boolean INITIALIZED = false;

ArrayList<Particle> PARTICLES;
Theme SELECTED_THEME;
PGraphics PG_CANVAS;
PerlinNoisePatterns APP;
Kinect2OpticalFlow K2_OPTICAL_FLOW;
SyphonServer SYPHON_SERVER;

int TARGET_FRAME_RATE = 30;
int LAST_PARTICLE_UPDATE = 0;
int LAST_OFLOW_UPDATE = 0;
int OFLOW_UPDATE_INTERVAL = 1000/(TARGET_FRAME_RATE/3);


public void settings()
{
  size(1920/2, 1280/2, P2D);
  smooth(SMOOTHING);
}

public void setup()
{
  APP = this;
  PG_CANVAS = createGraphics(width, height, P2D);
  SELECTED_THEME = THEMES[THEME_IDX];
  PARTICLES = new ArrayList<Particle>();
  K2_OPTICAL_FLOW = new Kinect2OpticalFlow(32);
  SYPHON_SERVER = new SyphonServer(this, "Processing: Perlin Noise Patterns");
  frameRate(TARGET_FRAME_RATE);
}

public void initialize()
{
  noiseSeed(RANDOM_SEED + RESET_COUNT);
  randomSeed(RANDOM_SEED + RESET_COUNT);
  noiseDetail((int)random(1, 4), random(0.2, 0.5));
  
  PG_CANVAS.smooth(SMOOTHING);
  PG_CANVAS.beginDraw();
  PG_CANVAS.clear();
  PG_CANVAS.noStroke();
  PG_CANVAS.background(SELECTED_THEME.backgroundColor);
  PG_CANVAS.endDraw();
  
  PARTICLES.clear();  
  PARTICLE_IDX = 0;
  spawnParticles(INITIAL_PARTICLE_COUNT, 0, width, 0, height);
  
  RESET_COUNT++;
  INITIALIZED = true;
}

public void draw()
{
  surface.setTitle("Flow: " + SELECTED_THEME.name + " @ " + (int)frameRate + " FPS");
  
  // Begin draw
  PG_CANVAS.beginDraw();

  // For some reason this needs to be right here otherwise the graphics will bug out
  // [+] If we have not initialized the scene initialize it
  // [+] If we have gone through all the themes reinitialize the scene
  if (!INITIALIZED || PARTICLE_IDX/PARTICLE_THEME_CHANGE_COUNT >= THEMES.length)
  {
    INITIALIZED = false;
    initialize();
  }

  // Update the optical flow every N ms - spawn any particles necessary
  if (millis() - LAST_OFLOW_UPDATE > OFLOW_UPDATE_INTERVAL)
  {
    updateOpticalFlow();
    LAST_OFLOW_UPDATE = millis();
  }

  // Update and display all the particles 
  for (int i = 0; i < PARTICLES.size(); i++)
  {
    PARTICLES.get(i).update();
    PARTICLES.get(i).display(PG_CANVAS);
  }
  
  PG_CANVAS.endDraw();
  
  // Show the pgraphics buffer
  image(PG_CANVAS, 0, 0);
  SYPHON_SERVER.sendImage(PG_CANVAS);
  
  // Update the theme index according to the particle index
  THEME_IDX = (PARTICLE_IDX/PARTICLE_THEME_CHANGE_COUNT)%THEMES.length;
  SELECTED_THEME = THEMES[THEME_IDX];
}

public void updateOpticalFlow()
{
  K2_OPTICAL_FLOW.update();
  
  if (millis() > LAST_PARTICLE_GENERATION_TIME_MS + PARTICLE_GENERATION_COOLDOWN_MS)
  { 
    PGraphics2D oflowTexture = K2_OPTICAL_FLOW.getOpticalFlowTexture();
    
    // Uncomment to view oflow texture as debug
    //fill(0);
    //rect(0, 0, oflowTexture.width, oflowTexture.height);
    //image(oflowTexture, 0, 0);
    
    for (int i = 0; i < oflowTexture.width * oflowTexture.height; i++)
    {
      int y = i/oflowTexture.height;
      int x = i%oflowTexture.width;
      color c = oflowTexture.pixels[i];
      
      // Depth is encoded into the alpha channel
      float d = alpha(c);

      if (d == 255)
      {
        int xMin = K2_OPTICAL_FLOW.oflowBinWidth * x;
        int xMax = K2_OPTICAL_FLOW.oflowBinWidth * (x+1);
        int yMin = K2_OPTICAL_FLOW.oflowBinHeight * y;
        int yMax = K2_OPTICAL_FLOW.oflowBinHeight * (y+1);

        spawnParticles(1, xMin, xMax, yMin, yMax);
      }
    }
    
    LAST_PARTICLE_GENERATION_TIME_MS = millis();
  }
}

public void spawnParticles(int num, float xMin, float xMax, float yMin, float yMax)
{
  for (int i = 0; i < num; i ++)
  {
    float xPos = random(xMin, xMax);
    float yPos = random(yMin, yMax);
    //println("Creating particle @ " + (int)xPos + ", " + (int)yPos);

    float t = (float)(PARTICLE_IDX%PARTICLE_THEME_CHANGE_COUNT)/PARTICLE_THEME_CHANGE_COUNT;
    float radius = map(t, 0f, 1f, 10f, 2f);
    float speed = map(radius, 4f, 7f, 0.4f, 0.8f);
    Particle particle = new Particle(xPos, yPos, SELECTED_THEME.getNextThemeColor(), radius, speed);
    
    if (PARTICLE_IDX < MAX_PARTICLES)
    {
      PARTICLES.add(particle);
    }
    else
    {
       PARTICLES.set((PARTICLE_IDX+1)%MAX_PARTICLES, particle);
    }
    
    PARTICLE_IDX++;
  }
}

public void mousePressed()
{
  spawnParticles(1, mouseX-30, mouseX+30, mouseY-30, mouseY+30);
}

public void mouseDragged()
{
  spawnParticles(1, mouseX-30, mouseX+30, mouseY-30, mouseY+30);
}
