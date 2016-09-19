// Template for 2D projects
// Author: Jarek ROSSIGNAC
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!

//**************************** global variables ****************************
pts P = new pts(); // class containing array of points, used to standardize GUI

float t=0, f=0;
boolean animate=true, fill=false, timing=false;
boolean lerp=true, slerp=true, spiral=true; // toggles to display vector interpoations

int ms=0, me=0; // milli seconds start and end for timing
//int npts=20000; // number of points <--DELETE??

pt A, B;
int aX, aY, bX, bY; //coordinates of arrow points

//BOOLEANS FOR CHECKING ARROW
boolean abInsidePolygon = false;
boolean bool1, bool2, bool3, bool4, bool5, bool6;
boolean noRedEdges = false;

//**************************** initialization ****************************
void setup()               // executed once at the begining 
  {
  size(800, 800);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** TODO replace that file with your pic of your own face
  P.declare(); // declares all points in P. MUST BE DONE BEFORE ADDING POINTS 
  // P.resetOnCircle(4); // sets P to have 4 points and places them in a circle on the canvas <--DELETE??
  P.loadPts("data/pts");  // loads points form file saved with this program
  } // end of setup

//**************************** display current frame ****************************
void draw()      // executed at each frame
  {
  if(recordingPDF) startRecordingPDF(); // starts recording graphics to make a PDF
  
    background(white); // clear screen and paints white background
    pen(black,3); fill(yellow); P.drawCurve(); P.IDs(); // shows polyloop with vertex labels
    stroke(red); pt G=P.Centroid(); show(G,10); // shows centroid
         
    //************************ ARROW STUFF **********************************      
    //If A has been placed but B hasn't, draw B where mouse is hovering
    if(arrowStarted) {
      B=P(mouseX, mouseY);
      pen(green,5); arrow(A,B);
    } 
    //ONCE THE ARROW IS PLACED...
    if(arrowPlaced) {
      //...CHECK IF POINTS A AND B ARE BOTH INSIDE POLYGON
      color colorA = get(aX, aY);
      color colorB = get(bX, bY);
      if((colorA != white) && (colorB != white)) {
        abInsidePolygon = true;
      } else {
        abInsidePolygon = false;
      }
      //...CHECK IF ARROW CROSSES ANY EDGES
      for(int i=0; i<P.nv; i++) {
        pt C = P.G[i];
        pt D = P.G[i+1];
        vec ab = V(A, B);
        vec ad = V(A, D);
        vec ac = V(A, C);
        vec cd = V(C, D); 
        vec ca = V(C, A);
        vec cb = V(C, B);
        bool1 = (det(ab, ad)>0) && (det(ab, ac)<0);
        bool2 = (det(ab, ad)<0) && (det(ab, ac)>0);
        bool3 = (det(cd, ca)>0) && (det(cd, cb)<0);
        bool4 = (det(cd, ca)<0) && (det(cd, cb)>0);
        bool5 = bool1 || bool2; 
        bool6 = bool3 || bool4; 
        if (bool5 && bool6) {
          i=P.nv;
          noRedEdges = false;
        } else {
          noRedEdges = true;
        }
      }
      //...THEN DRAW ARROW RED IF IT'S A BAD ARROW
      if(abInsidePolygon && noRedEdges) {
        pen(green,5); arrow(A,B);
      } else {
        pen(red, 5); arrow(A,B);
      }
      //...HIGHLIGHT EDGES THAT ARROW VECTOR CROSSES
      for(int i=0; i<P.nv; i++) {
        pt C = P.G[i];
        pt D = P.G[i+1];
        float topHalfX = (A.x * B.y - A.y * B.x)*(C.x - D.x) - (A.x - B.x)*(C.x * D.y - C.y * D.x);
        float bottomHalf = (A.x - B.x)*(C.y -D.y) - (A.y - B.y)*(C.x - D.x);
        float topHalfY = (A.x * B.y - A.y * B.x)*(C.y - D.y) - (A.y - B.y)*(C.x * D.y - C.y * D.x);
        if (bottomHalf == 0)
        {
          println("No intersection at points: " + i + ", " + (i+1));
        } else { 
          pen(blue, 5);
          println("AB Intersects with the edge between vector " + i + " and " + (i+1));
          float interX = topHalfX/bottomHalf;
          float interY = topHalfY/bottomHalf;
          println("At point: " + interX + ", " + interY);
          ellipse(interX, interY, 5, 5);
        }  
      }  
      println("new line");
      
    }  

      
  if(recordingPDF) endRecordingPDF();  // end saving a .pdf file with the image of the canvas

  fill(black); displayHeader(); // displays header
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 

  if(filming && (animating || change)) snapFrameToTIF(); // saves image on canvas as movie frame 
  if(snapTIF) snapPictureToTIF();   
  if(snapJPG) snapPictureToJPG();   
  change=false; // to avoid capturing movie frames when nothing happens
  }  // end of draw
  