class Particle
{  
  public PVector position;
  public PVector filteredPosition;
  public PVector direction;
  public float speed;
  public PVector velocity;
  public color particleColor;
  public float radius;
  
  private int age;
  
  private final static int INITIAL_UPDATE_COUNT = 500;
  private final static float BOUNDS_MARGIN = 300.0;
  private final static float NOISE_SCALE = 256.0;
  
  
  public Particle(float x, float y, color c, float radius, float speed)
  {
    this.position = new PVector(x, y);
    this.filteredPosition = this.position;
    this.direction = new PVector(0f, 0f, 0f);
    this.velocity = new PVector(0f, 0f, 0f);
    this.speed = speed;
    
    this.particleColor = c;
    this.radius = radius;
    this.age = 0;
    
    this.initialize();
  }
  
  private void initialize()
  {
    this.age = 0;
    
    for (int i = 0; i < INITIAL_UPDATE_COUNT; i++)
    {
      this.update();
    }
  }
  
  public void update()
  {
    float angle = noise(this.position.x/NOISE_SCALE, this.position.y/NOISE_SCALE) * TWO_PI * NOISE_SCALE/4.0;
    this.direction.set(cos(angle), sin(angle), 0f);
    this.direction.normalize();
    this.velocity = this.direction.copy();
    this.velocity.mult(this.speed);
    this.position.add(this.velocity);
    
    // If the particle goes outside screen    
    if (this.position.x < -BOUNDS_MARGIN || this.position.x > width + BOUNDS_MARGIN || 
        this.position.y < -BOUNDS_MARGIN || this.position.y > height + BOUNDS_MARGIN)
    {
      this.position.set(random(0, width), random(0, height));
    }
    else
    {
      this.age++;
    }
  }
  
  public void display(PGraphics pg)
  {
    if (this.age > INITIAL_UPDATE_COUNT)
    {
      pg.fill(this.particleColor, 128);
      pg.ellipse(this.position.x, this.position.y, this.radius, this.radius);
    }
  }
}
