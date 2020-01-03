public class Triangle
{
  boolean isMoving = true;
  boolean last = false;
  PVector A, B, C, D, M, w;
  float theta;
  float speed;
  int age = 0, maxAge;
  color triangleColor;

  public Triangle(PVector pA, PVector pB, PVector pC, float x, float y, float speed, int maxAge, color triangleColor)
  {
    this.theta = 0f;
    this.speed = speed;
    this.maxAge = maxAge;
    this.triangleColor = triangleColor;
    
    // First triangle
    if (pA == null)
    {
      A = new PVector(x+2*r/3, y);
      B = new PVector(x+2*r*cos(TWO_PI/3)/3, y+2*r*sin(TWO_PI/3)/3);
      C = new PVector(x+2*r*cos(-TWO_PI/3)/3, y+2*r*sin(-TWO_PI/3)/3);
    }
    else
    {
      A = pA;
      B = pB;
      C = pC;
    }
    
    D = A.copy();
    M = new PVector((B.x+C.x)/2, (B.y+C.y)/2);//middle of [BC]
    w = A.copy();
    w.sub(M);//vector MA
  }

  public Triangle update()
  {
    Triangle newTriangle = null;
    
    if (!isFinished())
    {      
      if (!this.last && this.theta < PI)
      {
        this.theta += (PI - this.theta) / this.speed;

        this.D.x = cos(this.theta) * w.x;
        this.D.y = cos(this.theta) * w.y;
        this.D.z = r * sin(this.theta);
        this.D.add(M);

        if (this.theta >= .99 * PI)
        {
          this.theta = 45;
          
          if (random(0.0, 1.0) > .5)
          {
            newTriangle = new Triangle(B, C, D, 0, 0, speed, maxAge, this.triangleColor);
          }
          else
          {
            newTriangle = new Triangle(B, D, C, 0, 0, speed, maxAge, this.triangleColor);
          }
        }
      }
    }
    
    this.age = constrain(this.age+1, 0, this.maxAge);
    return newTriangle;
  }

  public void display(PGraphics pg)
  {
    if (!isFinished())
    {
      float alpha = map(this.age, 0, this.maxAge, 255, 0);
      pg.beginShape(TRIANGLES);
      pg.fill(this.triangleColor, alpha);
      pg.stroke(20, alpha);
      pg.vertex(A.x, A.y, 0);
      pg.vertex(B.x, B.y, 0);
      pg.vertex(C.x, C.y, 0);

      if (!this.last && this.theta < PI)
      {
        pg.vertex(B.x, B.y, 0);
        pg.vertex(C.x, C.y, 0);
        pg.vertex(D.x, D.y, D.z);
      }         
      pg.endShape();
    }
  }
  
  public boolean isFinished()
  {
    return min(this.age, this.maxAge) == this.maxAge;
  }
}
