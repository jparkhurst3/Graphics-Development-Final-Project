// Template for 2D projects
// Author: Jarek ROSSIGNAC
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!

//**************************** global variables ****************************
pts P = new pts(); // class containing array of points, used to standardize GUI
pts currentP = new pts();

//pts inters = new pts();
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

int beforeT1, beforeT2;

ArrayList<pts> arrayOfPs = new ArrayList<pts>();

//**************************** initialization ****************************
void setup()               // executed once at the begining 
  {
  size(800, 800);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing

  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** TODO replace that file with your pic of your own face
  
  P.declare();// declares all points in P. MUST BE DONE BEFORE ADDING POINTS
  P.loadPts("data/pts"); // loads points form file saved with this program
  currentP.declare();
  
  //To start, currentP = P
  for(int i=0; i<P.nv; i++) {
    currentP.addPt(P.G[i]);  
  }  
  
  arrayOfPs.add(P);
  arrayOfPs.add(currentP);
} // end of setup

//**************************** display current frame ****************************
void draw()      // executed at each frame
  {
  if(recordingPDF) startRecordingPDF(); // starts recording graphics to make a PDF
  
    background(white); // clear screen and paints white background
    int lastArray = arrayOfPs.size() - 1;
    
    //Draw Original
    pen(black,3); fill(yellow); arrayOfPs.get(0).drawCurve(); arrayOfPs.get(0).IDs(); // shows polyloop with vertex labels
    //Draw Current/Remaining Polygon
    pen(black,3); fill(blue); arrayOfPs.get(1).drawCurve(); arrayOfPs.get(1).IDs();
    //DrawPieces
    if (arrayOfPs.size() > 2) {
      for(int i=2; i< arrayOfPs.size(); i++) {
        pen(black,3); fill(red); arrayOfPs.get(i).drawCurve(); arrayOfPs.get(i).IDs();    
      }  
    }     
    //************************ ARROW STUFF **********************************      
    //If A has been placed but B hasn't, draw B where mouse is hovering
    if(arrowStarted) {
      B=P(mouseX, mouseY);
      pen(green,5); arrow(A,B);
    } 
    
    //ONCE THE ARROW IS PLACED...
    if(arrowPlaced) {
      //inters = new pts();
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
      //...IF THE ARROW IS PLACED CORRECTLY,
      if(abInsidePolygon && noRedEdges) {
        
        //...FIND THE VECTOR AB'S INTERSECTIONS
        pt t1 = P(0,400);
        pt t2 = P(800,400); 
        pen(green,5); arrow(A,B);
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
            float interX = topHalfX/bottomHalf;
            float interY = topHalfY/bottomHalf;
            pt intersection = P(interX, interY);
            if(get((int)interX, (int)interY) == black)
            { 
              println("AB Intersects with the edge between vector " + i + " and " + (i+1));
              println("At point: " + interX + ", " + interY);
              
              //THEN FIND THE CLOSEST INTERSECTIONS
              if (d(A,intersection) < d(B,intersection))
              {
                if(d(A,intersection) < d(A,t1)) {
                  beforeT1 = i;
                  println("beforeT1 is " + beforeT1);
                  t1 = intersection;
                }
              } else {
                if (d(B,intersection) < d(B,t2)) {
                  beforeT2 = i;
                  println("beforeT2 is " + beforeT2);
                  t2 = intersection;
                }
              }
              pen(blue, 5);
              ellipse((int)interX, (int)interY, 5, 5);
            }
          }
        }
        
        //...ADD THE POINTS TO THE POINTS CLASS  
        if(get((int)t1.x,(int)t1.y) != white && get((int)t2.x,(int)t2.y) != white) {
          pen(green, 5);
          ellipse((int)t1.x, (int)t1.y, 5, 5);
          ellipse((int)t2.x, (int)t2.y, 5, 5);
          println("adding x: " + t1.x + " y: " + t1.y);
          println("adding x: " + t2.x + " y: " + t2.y);
          
          //Decide which intersection comes first
          int firstVectorIntersection, secondVectorIntersection;
          if(beforeT1 < beforeT2) {
            firstVectorIntersection = beforeT1;
            secondVectorIntersection = beforeT2;
          } else {
            firstVectorIntersection = beforeT2;
            secondVectorIntersection = beforeT1;
          }
          
          splitPolygon(t1, t2, firstVectorIntersection, secondVectorIntersection);
          
          ////Insert T1 & T2 into newP
          //for(int i=0; i<firstVectorIntersection+1; i++) {
          //  newP.addPt(P.G[i]);
          //}
          //newP.addPt(t1);
          //for(int i=firstVectorIntersection+1; i<secondVectorIntersection+1; i++) {
          //  newP.addPt(P.G[i]);
          //}
          //newP.addPt(t2);
          //for(int i=secondVectorIntersection+1; i<P.nv; i++) {
          //  newP.addPt(P.G[i]);
          //}
          
          //println("There are " + newP.nv + " vectors in newP");
          //println("and there are " + P.nv + " vectors in P"); 
          
          //newP.empty();
          //P.addPt(t1);
          //P.addPt(t2);
          arrowStarted = false;
          arrowPlaced = false;
          A = P(mouseX, mouseY);
        } else {
          pen(red, 5); arrow(A,B);
        }
   //<>//
      } //end of "If arrow placed correctly" statement
    } //end of "Once the arrow is placed" statement   


  //...FROM ORIGINAL PROJECT CODE    
  if(recordingPDF) endRecordingPDF();  // end saving a .pdf file with the image of the canvas

  fill(black); displayHeader(); // displays header
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 

  if(filming && (animating || change)) snapFrameToTIF(); // saves image on canvas as movie frame 
  if(snapTIF) snapPictureToTIF();   
  if(snapJPG) snapPictureToJPG();   
  change=false; // to avoid capturing movie frames when nothing happens
  } // end of draw
  
  void splitPolygon(pt t1, pt t2, int vectorNumBeforeT1, int vectorNumBeforeT2) {
    pts newP = new pts(); 
    newP.declare();
    pts copyCurrentP = new pts();
    copyCurrentP.declare();
    
    for(int i=0; i<currentP.nv; i++) {
      copyCurrentP.addPt(currentP.G[i]);
    }
    currentP.empty();
    
    for(int i=0; i<copyCurrentP.nv; i++) {
      if(i < vectorNumBeforeT1) currentP.addPt(copyCurrentP.G[i]);
      if(i == vectorNumBeforeT1) {
        currentP.addPt(copyCurrentP.G[i]);
        currentP.addPt(t1);
        newP.addPt(t1);
      }  
      if((i > vectorNumBeforeT1) && (i < vectorNumBeforeT2)) newP.addPt(copyCurrentP.G[i]);
      if(i == vectorNumBeforeT2) {
        newP.addPt(copyCurrentP.G[i]);
        newP.addPt(t2);
        currentP.addPt(t2);
      }  
      if(i > vectorNumBeforeT2) currentP.addPt(copyCurrentP.G[i]);
    }  
    
    arrayOfPs.add(newP);
  }  
  