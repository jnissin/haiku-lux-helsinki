import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.DwOpticalFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;

import processing.core.*;
import processing.opengl.PGraphics2D;

import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;

public class Kinect2OpticalFlow
{
  public int cameraWidth;
  public int cameraHeight;
  public int oflowWidth;
  public int oflowHeight;
  public int oflowBinWidth;
  public int oflowBinHeight;
  
  private DwPixelFlow pfContext;
  private DwOpticalFlow pfOpticalFlow;
  private Kinect2 kinect2;
  private PGraphics2D pgCam;
  private PGraphics2D pgOflow;
  
  public Kinect2OpticalFlow(int oflowDivisor)
  {
    // Initialize Kinect 2
    this.kinect2 = new Kinect2(APP);
    this.kinect2.initRegistered();
    this.kinect2.initDevice();
    
    // Kinect 2 registered image is 512x424
    this.cameraWidth = kinect2.depthWidth;
    this.cameraHeight = kinect2.depthWidth;
    
    // Divide by oflowDivisor to make the optical flow image smaller
    // to improve performance
    this.oflowWidth = cameraWidth/oflowDivisor;
    this.oflowHeight = cameraHeight/oflowDivisor;
    
    this.oflowBinWidth = width/this.oflowWidth;
    this.oflowBinHeight = height/this.oflowHeight;
    
    this.pfContext = new DwPixelFlow(APP);
    this.pfContext.print();
    this.pfContext.printGL();
    
    this.pfOpticalFlow = new DwOpticalFlow(this.pfContext, this.cameraWidth, this.cameraHeight);
    
    this.pgCam = (PGraphics2D) createGraphics(this.cameraWidth, this.cameraHeight, P2D);
    this.pgCam.noSmooth();
    this.pgOflow = (PGraphics2D) createGraphics(this.oflowWidth, this.oflowHeight, P2D);
    this.pgOflow.smooth(2);
  }
   
  public void update()
  {
    // Render camera image to off-screen buffer
    this.pgCam.beginDraw();
    this.pgCam.clear();
    this.pgCam.image(kinect2.getRegisteredImage(), 0, 0);
    this.pgCam.endDraw();
  
    // Update optical flow
    this.pfOpticalFlow.update(this.pgCam);
  
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
