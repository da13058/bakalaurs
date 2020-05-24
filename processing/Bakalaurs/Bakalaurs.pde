// Dmitrijs Arkašarins, da16019
// Lietotāja vadīts reljefa ģenerēšanas algoritms, bakalaura darbs
// Kods darbināms iekš Processing IDE (https://processing.org/)
// .pde datnei jāatrodas tāda paša nosaukuma direktorijā
// Pēc noklusējuma, algoritms skatās uz HEIGHT_{A,B,C vai D}, RANGE_MAX un RANGE_MIN parametriem
private static final boolean RENDER_2D = false; //divdimensiju renderēšana
private static final boolean SAVE_RESULT = true; // rezultāts automātiski tiek saglabāts projekta direktorijā
private static final boolean MARGIN = false; // pielietot augstumu ierobežojumu
private static final boolean CENTERED = false; // nepieciešams salu, konisko kalnu, ezeru un plato ģenerēšanai
private static final boolean THREE_PEAK = false; //trīs pīķi blakus
private static final boolean SHIFT_PEAK = false; //nobīdīts konisks kalns
private static final boolean MULTY_PEAK = false; //vairāki koniski kalni
private static final boolean LAKE = false; //nepieciešams ezeru ģenerēšanai
private static final boolean PLATO = false; //nepieciešams plato ģenerēšanai
private static final boolean RENDER_3D = true; //trīsdimensiju renderēšana, RENDER_2D jābūt izslēgtam
private static final int BLUR_RATE = 0; //Gaussian blur radius
private static final int HEIGHT_A = 0; //Sākumpunktu augstumi
private static final int HEIGHT_B = 0;
private static final int HEIGHT_C = 0;
private static final int HEIGHT_D = 0;
private static final float RANGE_MAX = 200; //maksimālais izkliedes augstums
private static final float MARGIN_HEIGHT = 0; //augstumu ierobežojuma līmenis
private static final float PLATO_HEIGHT = 0; //plato nogriezuma augstums
private static final float LAKE_BORDER = 100; //sānu malu paaugstinājumi palīdz ezeram "neizplūst" ārā
private static final float HIGH_POINT = 400; //maksimālais augstums salām/kalniem, lietojams ar CENTERED parametru
private static final float RANGE_MIN = 0; //minimālais izkliedes augstums
private static final float WATER_LVL = 0; //ūdens līmenis divdimensiju renderētājam
private float[][] heightmap;
private color[]colorScheme;

int scl = 5; // jo mazāks šis parametrs, jo detalizētāk renderējas 3D karte
int cols;
int rows;
float[][] terrain;

void setup(){
   size(513,513,P3D); //lielākai kartei var uzstādīt uz 1025, 2049, 4097, t.i. nākamo divieka pakāpi + 1
  cols = height/scl;
  rows = width/scl;
  terrain = new float[rows][cols];
   heightmap = new float[width][height];
   colorScheme = new color[18]; 
   noLoop();
   background(255);
   setColorScheme();
}

void draw(){
   float maxRange = RANGE_MAX;
   int stepSize = width - 1;
   int initialStepsize = width - 1;
   setHeightl(0,0, HEIGHT_A);
   setHeightl(width-1, 0, HEIGHT_B);
   setHeightl(0, height-1, HEIGHT_C);
   setHeightl(width-1, height-1, HEIGHT_D);
   //līdz  1px izmēru
   while(stepSize > 1){
     //romba solis
     for(int x = 0; x < width - 1; x += stepSize){
       for(int y = 0; y < height - 1; y += stepSize){
         int sx = x + (stepSize/2);
         int sy = y + (stepSize/2);
         int[][] points = {
                     {x, y},
                     {x+stepSize, y},
                     {x, y+stepSize},
                     {x+stepSize, y+stepSize},
                   };
           if (CENTERED && (sx == initialStepsize/2 && sy == initialStepsize/2)) {
            setColoring(sx, sy, points, maxRange, true, false);
            } else if (THREE_PEAK && (sx == initialStepsize/4 || sy == initialStepsize/2)) {
            setColoring(sx, sy, points, maxRange, true, false);
            } else if (SHIFT_PEAK && (sx == initialStepsize/4 && sy == initialStepsize/4)) {
            setColoring(sx, sy, points, maxRange, true, false);
            } else if (MULTY_PEAK && (sx == initialStepsize/4 || sy == initialStepsize/8)) {
            setColoring(sx, sy, points, maxRange, true, false);
            } else if (LAKE && ((sy == initialStepsize/2 && sx == initialStepsize) || (sx == initialStepsize/2 && sy == initialStepsize) || (sy == initialStepsize/2 && sx == 0) || (sx == initialStepsize/2 && sy == 0))) {
             setColoring(sx, sy, points, maxRange, false, true);
          } else {
              setColoring(sx, sy, points, maxRange,false, false);
          }
       }
     }
     
     //kvadrāta solis
     for(int x = 0; x < width - 1; x += stepSize){
       for(int y = 0; y < height - 1; y += stepSize){
         int halfstep = stepSize / 2;
         int x1 = x + halfstep;
         int y1 = y;
         int x2 = x;
         int y2 = y + halfstep;
         int[][] points1 = {
                           {x1 - halfstep, y1},
                           {x1, y1 - halfstep},
                           {x1 + halfstep, y1},
                           {x1, y1 + halfstep}
                          };
         int[][] points2 = {
                           {x2 - halfstep, y2},
                           {x2, y2 - halfstep},
                           {x2 + halfstep, y2},
                           {x2, y2 + halfstep}
                          };
        setColoring(x1, y1, points1, maxRange, false, false);
        setColoring(x2, y2, points2, maxRange, false, false);
       }
     }
     maxRange = maxRange / 2;
     stepSize = stepSize / 2;
 }
 if (RENDER_2D) {
   drawTerrain();
 }
 else {
   drawHeightmap();
 }
}

void setColoring(int x, int y, int[][] points, float maxRange, boolean island, boolean setMid){
         float c = 0;
         for(int i = 0; i < 4; i++){
             if(points[i][0] < 0){
               points[i][0] += (width - 1);
             }else if(points[i][0] > width){
               points[i][0] -= (width - 1);
             }else if(points[i][1] < 0){
               points[i][1] += height - 1;
             }else if(points[i][1] > height){
               points[i][1] -= height - 1;
             }
             c += heightmap[points[i][0]][points[i][1]] / 4.0;
         }
         c +=  (random(maxRange) - maxRange / 2);
         if (c < RANGE_MIN){
             c = RANGE_MIN;
         } else if ( c > 255){
             c = 255;
         }
         if (island) {
           c = HIGH_POINT;
         }
         if (setMid) {
           c = LAKE_BORDER;
         }
         if (MARGIN && c > MARGIN_HEIGHT) {
           c = MARGIN_HEIGHT;
         }
         setHeightl(x, y, c);
         if (x == 0) {
           setHeightl(width - 1, y, c);
         }else if(x == width - 1){
           setHeightl(0,y,c);
         }else if(y == 0){
           setHeightl(x, height - 1, c);
         }else if(y == height - 1){
           setHeightl(x, 0, c);
         }
 }

void setHeightl(int x, int y, float c){
       heightmap[x][y] = c;
}

void drawHeightmap() {
  for(int i = 0; i < width; i++){
   for(int j = 0; j < width; j++){
     float h = heightmap[i][j];
     if (PLATO){
       if (h > PLATO_HEIGHT) {
         h = PLATO_HEIGHT + random(3);
       }
     }
         set(i, j, color(h));
   }
 }
 PImage c = get( 0,0, width, height );
 c.filter(BLUR, BLUR_RATE);
 if (RENDER_3D) {
  draw3D(c); 
 } else {
  image(c,0,0); 
 }
 if (SAVE_RESULT) {
   save("heightmap.png");
 }
}

int index(int x, int y) {
  return x+y*width;
}

void draw3D(PImage hmap) {
  lights();
  background(105,105,105);
  noStroke();
  fill(139,69,19);
  for( int y = 0; y < cols; y++) {
    beginShape(TRIANGLE_STRIP);
    for( int x = 0; x < rows; x++){
      color pix = hmap.pixels[index(x*scl,y*scl)];
      float oldG = red(pix);
      terrain[x][y] = map(oldG, 0, 255, -50, 50);
    }
  }
  
  translate(width/2,height/2);
  rotateX(PI/4);
  translate(-width/2,-height/2);
  translate(0, -100);
  
  for( int y = 0; y < cols-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for( int x = 0; x < rows; x++) {
       vertex(x*scl,y*scl, terrain[x][y]);
       vertex(x*scl,(y+1)*scl,terrain[x][y+1]);
    }
    endShape();
  }
}


void drawTerrain(){
  for(int i = 0; i < width; i++){
     for(int j = 0; j < width; j++){
         colorizeTerrain(i,j,heightmap[i][j]);
   }
 }
 if (SAVE_RESULT) {
    save("terrain.png");
 }
}

void colorizeTerrain(int x, int y, float pxval){
  if (WATER_LVL > 0 & WATER_LVL >= pxval) {
     set(x, y, colorScheme[17]);
     return;
  }
  if (pxval <= 15) {
      set(x, y, colorScheme[0]);
  } else if (pxval <= 30) {
      set(x, y, colorScheme[1]);
  } else if (pxval <= 45){
      set(x, y, colorScheme[2]);
  } else if (pxval <= 60){
      set(x, y, colorScheme[3]);
  } else if (pxval <= 75){
      set(x, y, colorScheme[4]);
  } else if (pxval <= 90){
      set(x, y, colorScheme[5]);
  } else if (pxval <= 105){
      set(x, y, colorScheme[6]);
  } else if (pxval <= 120){
      set(x, y, colorScheme[7]);
  } else if (pxval <= 135){
      set(x, y, colorScheme[8]);
  } else if (pxval <= 150){
      set(x, y, colorScheme[9]);
  } else if (pxval <= 165){
      set(x, y, colorScheme[10]);
  } else if (pxval <= 180){
      set(x, y, colorScheme[11]);
  } else if (pxval <= 195){
      set(x, y, colorScheme[12]);
  } else if (pxval <= 210){
      set(x, y, colorScheme[13]);
  } else if (pxval <= 225){
      set(x, y, colorScheme[14]);
  } else if (pxval <= 240){
      set(x, y, colorScheme[15]);
  } else {
      set(x, y, colorScheme[16]);
  }
}

void setColorScheme(){
    colorScheme[0] = color(255,255,142);
    colorScheme[1] = color(255,255,102);
    colorScheme[2] = color(221,249,105);
    colorScheme[3] = color(204,255,153);
    colorScheme[4] = color(178,255,102);
    colorScheme[5] = color(153,255,51);
    colorScheme[6] = color(51,255,51);
    colorScheme[7] = color(51,204,51);
    colorScheme[8] = color(0,204,0);
    colorScheme[9] = color(0,153,0);
    colorScheme[10] = color(0,102,0);
    colorScheme[11] = color(51,77,0);
    colorScheme[12] = color(32,32,32);
    colorScheme[13] = color(64,64,64);
    colorScheme[14] = color(160,160,160);
    colorScheme[15] = color(192,192,192);
    colorScheme[16] = color(224,224,224);
    colorScheme[17] = color(102,178,255);
}
