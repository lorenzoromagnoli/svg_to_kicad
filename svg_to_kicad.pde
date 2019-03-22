import geomerative.*;
import controlP5.*;

ControlP5 cp5;
controlP5.Textfield path, destinationFolder, fileName;
controlP5.Slider zoomSlider;


float angle = 1;
float zoom = 1;


RShape shp;
RShape polyshp;
RPoint[] points;

float ImgWidth=0;
float ImgHeight=0;

float scaledImgWPX;
float scaledImgHPX;

PrintWriter output;

String svgFilePath, exportDirectory, footprintName, fullOutputPath;

boolean svgLoaded=false;


void setup() {
  size(600, 600);
  smooth();

  // VERY IMPORTANT: Allways initialize the library before using it
  RG.init(this);

  println(ImgWidth+" "+ImgHeight);

  cp5 = new ControlP5(this);

  fill(0);


  cp5.addButton("load_svg")
    .setPosition(width-150-20, 20)
    .setSize(150, 19)
    ;

  path=cp5.addTextfield("svgFilePath")
    .setPosition(width-150-20, 20+30)
    .setSize(150, 19)
    ;

  cp5.addSlider("angle")
    .setPosition(width-150-20, 90)
    .setRange(0, 1)
    .setLabel("angle")
    ;

  zoomSlider=cp5.addSlider("zoom")
    .setPosition(width-150-20, 90+30)
    .setSize(150, 10)
    .setRange(1, 10)
    ;

  zoomSlider.getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE);
  zoomSlider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);


  cp5.addButton("setDestination")
    .setPosition(width-150-20, 120+30)
    .setSize(150, 19)
    .setLabel("set destination folder")
    ;

  destinationFolder=cp5.addTextfield("destinationFolder")
    .setPosition(width-150-20, 150+30)
    .setSize(150, 19)
    .setLabel("destination folder")
    ;

  fileName=cp5.addTextfield("footprintName")
    .setPosition(width-150-20, 190+30)
    .setSize(150, 19)
    ;

  cp5.addButton("export")
    .setPosition(width-150-20, 230+30)
    .setSize(150, 19)
    ;
}

void draw() {
  background(100);

  pushMatrix();

  zoomAndPan();

  if (svgLoaded) {


    // We create the polygonized version
    RG.setPolygonizer(RG.ADAPTATIVE);
    RG.setPolygonizerAngle(angle);

    //RG.setPolygonizerStep(pointSeparation);

    polyshp = RG.polygonize(shp);

    translate(width/2, height/2);

    // We draw the polygonized group with the SVG styles
    noStroke();
    RG.shape(polyshp);

    points = polyshp.getPoints();


    // If there are any points
    if (points != null) {
      fill(255, 0, 0);
      noStroke();
      for (int i=0; i<points.length; i++) {
        ellipse(points[i].x, points[i].y, 1, 1);
      }
    }
  }
  popMatrix();
}

public void controlEvent(ControlEvent theEvent) {
  //println(theEvent.getController().getName());
}

// function colorA will receive changes from 
// controller with name colorA
public void export() {

  fullOutputPath=""+destinationFolder.getText()+"/"+fileName.getText()+".kicad_mod";

  println("saving component to:"+fullOutputPath);
  output = createWriter(fullOutputPath);

  println("exporting to kicad...");
  writeComponentSettings();
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
}

void zoomAndPan() {
  scale(zoom);

  scaledImgWPX=width*zoom;
  scaledImgHPX=height*zoom;

  float relativeMouseX=mouseX*zoom;
  float relativeMouseY=mouseY*zoom;

  translate(scaledImgWPX/2-relativeMouseX, scaledImgHPX/2-relativeMouseY);
}

void writeComponentSettings() {
  output.println("(module svg (layer F.Cu)");
  output.println("(fp_text reference REF** (at 0 -2.6) (layer F.SilkS)(effects (font (size 1 1) (thickness 0.15))))");
  output.println("(fp_text value SVG (at 0 3) (layer F.Fab)(effects (font (size 1 1) (thickness 0.15))))");

  //here starts the a lopygon

  for (int k=0; k<polyshp.countChildren(); k++) {
    RShape s = polyshp.children[k];
    //start the poligon
    output.println("(fp_poly(pts");

    //each poligon might be mad of multiples lines 
    for (int i=0; i<s.countPaths(); i++) {
      println("p");
      RPath p = s.paths[i];
      RPoint[] points = p.getPoints();
      //here starts the point list
      for (int j=0; j<points.length; j++) {
        output.print("(xy "+points[j].x+" "+points[j].y+")");
        println("(xy "+points[j].x+" "+points[j].y+")");
      }
      //here ends the point list
    }
    //close the polygon
    output.println("");
    output.println(")(layer B.SilkS)(width  0.010000))");
  }
  //here ends the module
  output.println(")");
}

void load_svg() {
  selectInput("Select a svgFile", "fileSelected");
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    svgFilePath=selection.getAbsolutePath();
    path.setText(svgFilePath);
    loadShape();
    println("User selected " + selection.getAbsolutePath());
  }
}


void loadShape() {
  shp = RG.loadShape(svgFilePath);
  shp = RG.centerIn(shp, g, 1);

  ImgWidth=shp.width;
  ImgHeight=shp.height;
  svgLoaded=true;
}

void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    exportDirectory=selection.getAbsolutePath();
    destinationFolder.setText(exportDirectory);
  }
}

void setDestination() {
  selectFolder("Select a folder where to export your module:", "folderSelected");
}
