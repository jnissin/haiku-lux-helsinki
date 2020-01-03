public class TriangleChain
{
  ArrayList<Triangle> triangles;
  float beta;
  int age;
  int maxAge;
  int speed;
  color chainColor;
  PVector origin;

  public TriangleChain(float x, float y, boolean rot, color chainColor, int speed, int maxAge)
  {
    this.chainColor = chainColor;
    this.origin = new PVector(x, y);
    this.maxAge = maxAge;
    this.speed = speed;
    this.triangles = new ArrayList<Triangle>();
    this.triangles.add(new Triangle(null, null, null, x, y, speed, maxAge, chainColor));
    
    if (rot)
    {
      this.beta = TWO_PI / 3;
    }
    else
    {
      this.beta = 0;
    }
  }

  public void display()
  {    
    pushMatrix();
    translate(origin.x, origin.y);
    rotate(beta);
    translate(-origin.x, -origin.y);
    
    Triangle toAdd = null;
    Triangle toRemove = null;
    
    for (Triangle t : triangles)
    {
      toAdd = t.update();
      t.display();

      if (t.isFinished())
      {
        toRemove = t;
      }
    }
    
    if (toAdd != null)
    {
      // Check if triangle is the last one for this chain
      toAdd.last = this.age >= this.maxAge;
      
      // Add the new triangle and display it - this avoids flickering
      // if the triangle underneath is removed next
      triangles.add(toAdd);
      toAdd.display();
    }
    
    // Remove finished triangles
    if (toRemove != null)
    {
      triangles.remove(toRemove);
    }
    
    popMatrix();
    this.age++;
  }
  
  public boolean isFinished()
  {
    return triangles.size() == 0;
  }
}
