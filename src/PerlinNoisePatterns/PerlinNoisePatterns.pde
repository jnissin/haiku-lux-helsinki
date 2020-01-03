import java.util.*;

ArrayList<Particle> PARTICLES;
Theme SELECTED_THEME;
PGraphics PG;
int INITIAL_PARTICLE_COUNT = 200;
int MAX_PARTICLES = 2000;
int SEED = 1339;
PerlinNoisePatterns APP;
int SMOOTHING = 4;
OpticalFlow OPTICAL_FLOW;

int PARTICLE_GENERATION_COOLDOWN_MS = 100;
int LAST_PARTICLE_GENERATION_TIME_MS = 0;
int PARTICLE_IDX = 0;
int PARTICLE_THEME_CHANGE_COUNT = 3000;
int THEME_IDX = 0;
int RESET_COUNT = 0;
boolean INITIALIZED = false;

public void settings()
{
  size(1024, 1024, P2D);
  smooth(SMOOTHING);
}

public void setup()
{
  APP = this;
  PG = createGraphics(width, height, P2D);
  SELECTED_THEME = THEMES[THEME_IDX];
  PARTICLES = new ArrayList<Particle>();
  OPTICAL_FLOW = new OpticalFlow(1280/2, 720/2, 1280/(2*16), 720/(2*16));
}

public void initialize()
{
  noiseSeed(SEED + RESET_COUNT);
  randomSeed(SEED + RESET_COUNT);
  noiseDetail((int)random(1, 4), random(0.2, 0.5));
  
  PG.smooth(SMOOTHING);
  PG.beginDraw();
  PG.clear();
  PG.noStroke();
  PG.background(SELECTED_THEME.backgroundColor);
  PG.endDraw();
  
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
  PG.beginDraw();

  // For some reason this needs to be right here otherwise the graphics will bug out
  // [+] If we have not initialized the scene initialize it
  // [+] If we have gone through all the themes reinitialize the scene
  if (!INITIALIZED || PARTICLE_IDX/PARTICLE_THEME_CHANGE_COUNT >= THEMES.length)
  {
    initialize();
  }

  // Update the optical flow - spawn any particles necessary
  updateOpticalFlow();

  // Update and display all the particles 
  for (int i = 0; i < PARTICLES.size(); i++)
  {
    PARTICLES.get(i).update();
    PARTICLES.get(i).display(PG);
  }
  
  PG.endDraw();
  
  // Show the pgraphics buffer
  image(PG, 0, 0);
  
  // Update the theme index
  THEME_IDX = (PARTICLE_IDX/PARTICLE_THEME_CHANGE_COUNT)%THEMES.length;
  SELECTED_THEME = THEMES[THEME_IDX];
}

public void updateOpticalFlow()
{
  OPTICAL_FLOW.update();
  
  if (millis() > LAST_PARTICLE_GENERATION_TIME_MS + PARTICLE_GENERATION_COOLDOWN_MS)
  { 
    PGraphics2D oflowTexture = OPTICAL_FLOW.getOpticalFlowTexture();
   
    //fill(0);
    //rect(0, 0, PG_OFLOW.width, PG_OFLOW.height);
    //image(PG_OFLOW, 0, 0);
    
    for (int i = 0; i < oflowTexture.width * oflowTexture.height; i++)
    {
      int y = i/oflowTexture.height;
      int x = i%oflowTexture.width;
      color c = oflowTexture.pixels[i];
      float b = brightness(c);

      if (b == 255)
      {
        int xMin = OPTICAL_FLOW.oflowBinWidth * x;
        int xMax = OPTICAL_FLOW.oflowBinWidth * (x+1);
        int yMin = OPTICAL_FLOW.oflowBinHeight * y;
        int yMax = OPTICAL_FLOW.oflowBinHeight * (y+1);
        //println("Creating particle @ " + (int)x_pos + ", " + (int)y_pos);

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
