import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.DwOpticalFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;

import processing.core.*;
import processing.opengl.PGraphics2D;
import processing.video.Capture;

public class OpticalFlow
{
  public int cameraWidth;
  public int cameraHeight;
  public int oflowWidth;
  public int oflowHeight;
  public int oflowBinWidth;
  public int oflowBinHeight;
  
  private DwPixelFlow pfContext;
  private DwOpticalFlow pfOpticalFlow;
  private Capture cam;
  private PGraphics2D pgCam;
  private PGraphics2D pgOflow;
  
  public OpticalFlow(int cameraWidth, int cameraHeight, int oflowWidth, int oflowHeight)
  {
    this.cameraWidth = cameraWidth;
    this.cameraHeight = cameraHeight;
    this.oflowWidth = oflowWidth;
    this.oflowHeight = oflowHeight;
    
    this.oflowBinWidth = width/oflowWidth;
    this.oflowBinHeight = height/oflowHeight;
    
    this.pfContext = new DwPixelFlow(APP);
    this.pfContext.print();
    this.pfContext.printGL();
    
    this.pfOpticalFlow = new DwOpticalFlow(this.pfContext, this.cameraWidth, this.cameraHeight);
  
    this.cam = new Capture(APP, this.cameraWidth, cameraHeight, 30);
    this.cam.start();
    
    this.pgCam = (PGraphics2D) createGraphics(this.cameraWidth, this.cameraHeight, P2D);
    this.pgCam.noSmooth();
    this.pgOflow = (PGraphics2D) createGraphics(this.oflowWidth, this.oflowHeight, P2D);
    this.pgOflow.smooth(2);
  }
   
  public void update()
  {
    if (this.cam.available())
    {
      this.cam.read();
    
      // Render camera image to off-screen buffer
      this.pgCam.beginDraw();
      this.pgCam.clear();
      this.pgCam.image(this.cam, 0, 0);
      this.pgCam.endDraw();
    
      // Update optical flow
      this.pfOpticalFlow.update(this.pgCam);
    }
  
    // Render optical flow as velocity shading to the texture
    this.pgOflow.beginDraw();
    this.pgOflow.clear();
    this.pgOflow.endDraw();
    this.pfOpticalFlow.param.display_mode = 0;
    this.pfOpticalFlow.renderVelocityShading(this.pgOflow);
  }
  
  public PGraphics2D getOpticalFlowTexture()
  {
    this.pgOflow.loadPixels();
    return this.pgOflow;
  }
}
