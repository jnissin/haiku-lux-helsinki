final Theme[] THEMES = new Theme[] {
    new Theme("Magma",
              new color[] { #3A0300, #5D0D02, #EB4700, #FF9F01, #CD5201 },
              #161032),
    new Theme("Night Sky",
              new color[] { #45217C, #0799F2, #FFFFFF },
              #150832),
    new Theme("Fireball",
              new color[] { #581845, #900C3F, #C70039, #FF5733, #FFC30F },
              #1A0633),
    new Theme("Fireflies",
              new color[] { #B7F0AD, #D2FF96, #EDDF7A, #E8D33F, #D17B0F },
              #141115),
    new Theme("Cotton Candy",
              new color[] { #9E9CF6, #A6F7B7, #F4B966, #C9DEE5, #CADA8A, #E2C26E },
              #2D1273)
};

public class Theme
{
  public String name;
  public color[] colors;
  public color backgroundColor;
  
  private int currentColorIdx;
  private float colorStepSize;
  private float colorProgress;
  
  public Theme(String name, color[] colors, color backgroundColor) {
     this.name = name;
     this.colors = colors;
     this.backgroundColor = backgroundColor;
     
     this.currentColorIdx = 0;
     this.colorStepSize = 0.1f;
     this.colorProgress = 0.0f;
  }
  
  public color getNextThemeColor()
  {
    int nextColorIdx = (this.currentColorIdx + 1) % this.colors.length;
    color currentColor = this.colors[this.currentColorIdx];
    color nextColor = this.colors[nextColorIdx];
    
    color c = lerpColor(currentColor, nextColor, this.colorProgress);
    this.colorProgress += colorStepSize;
    
    if (this.colorProgress > 1.0f)
    {
      this.currentColorIdx = nextColorIdx;
      this.colorProgress = 0.0f;
    }
    
    return c;
  }
  
  public color getRandomThemeColor()
  {
    return this.colors[(int)random(0, this.colors.length)];
  }
}
