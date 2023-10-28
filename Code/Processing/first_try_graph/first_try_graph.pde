import processing.serial.*;
import grafica.*;

Serial port; 
////////////////////////////////////////////////////////////////////////////////////////
PrintWriter output;


/////////////////////////////////////////////////////////////////////////////////////////

boolean waitForStart = true;

boolean Finish = false;

///////////////////////////////////////////////////////////////////////////////////////
int lf=10;

float time = 0.0; // initial time value

String myString = null;
//String myString ="10.4";
float angle=0.0;



int samplingFrequency = 30;
float samplingTime = 1.0/samplingFrequency;

float maxTime = 6.0; // maximum time value for the graph

float value = 0.0; // potentiometer value (0-1023)

float maxSpeed=5;


ArrayList<Float> angleList;

int sizeList = 10;   


float angle_speed;
float previous_angle_speed;

float angle_acceleration;    
float previous_angle_acceleration;


float angle_knee = 0.0; // initial angle value
float previous_angle_knee = 0.0;


int current_phase = 0;
int previous_phase = 0;




//////////////////////////////////////////////////////////////////////////



float graphWidth = 1000.0; // width of the graph
float graphHeight = 600.0; // height of the graph

float margin = 700.0; // margin from the edge
float marginy = 200;


int dialSize = 360; // size of the speedometer dial
int dialAngle = 240; // angle of the speedometer dial (in degrees)
int dialStart = 150; // starting angle of the speedometer dial (in degrees)
int margin1 = 300;
int margin2=margin1+500;

int sizex=1900;
int sizey=1600;

////////////////////////////////////////////////////////////////////////////////

GPlot plot;
int step = 0;
int stepsPerCycle = int(maxTime)*samplingFrequency*100;

float Timedelta = 6.0;
float lowest_x = 0.0;
float upper_x = lowest_x + Timedelta;

GPointsArray points1 = new GPointsArray(stepsPerCycle);

ArrayList<Integer> pointColors;

////////////////////////////////////////////////////////////////////////////////////////

void setup() {
  size(1900,1600);
  background(255);
  port = new Serial (this, "COM14", 9600); 
  
  String filename = "test_post_analysis.txt";
  output = createWriter(filename);
  angleList = new ArrayList<Float>();
  create_graph();
  pointColors = new ArrayList<Integer>(stepsPerCycle);
}


//////////////////////////////////////////////////////////////////////////////////////

void draw() {
  stroke(0);
  
  draw_graph();

  // draw the speedometer dial
  draw_speedometer();
  
  
  
  
  if (!waitForStart && !Finish){
    
    
    myString = port.readStringUntil(lf);
  
   if (myString != null) {
      angle_knee= float(myString);
      //angle_knee=cos((time)*30.0/TWO_PI)*20.0+50.0;
      time += samplingTime;
  }

  
  
  if(Math.abs( angle_knee - previous_angle_knee) < 30 || angleList.size() ==0){   
  
    value = angle_knee;
    gait_analysis();
    draw_point();
    previous_angle_knee = angle_knee;
  } 
  }
   
}

///////////////////////////////////////////////////////////////////////////////
void gait_analysis(){
  
  output.println(value);
  angleList.add(angle_knee);
  if (angleList.size() > sizeList) {
        angleList.remove(0);
  }
  calculateSpeed();
  calculateAcceleration();
  println(current_phase,time, angle_knee,angle_speed,angle_acceleration,previous_angle_acceleration);
  CurrentPhase();
  //println(current_phase);
}


void calculateSpeed(){
  
  if (angleList.size() > 1) {
    float currentAngle = angleList.get(angleList.size() - 1);
    float previousAngle = angleList.get(angleList.size() - 2); 
    previous_angle_speed = angle_speed;
    angle_speed = (currentAngle - previousAngle) ;/// deltaTime;
  } else {
 previous_angle_speed = 0.0;
    angle_speed = 0.0;
  }

}

void calculateAcceleration() {
  
  if (angleList.size() > 2) {
    float currentSpeed = angle_speed;
    float previousSpeed = previous_angle_speed;
    
    previous_angle_acceleration = angle_acceleration;
    angle_acceleration = (currentSpeed - previousSpeed) ;/// deltaTime;
  } else {
    previous_angle_acceleration =0.0;
    angle_acceleration = 0.0;
  }
}


void CurrentPhase(){
   previous_phase = current_phase;
  
  if (angleList.size()< 2){
    current_phase = 0;
  }
  else if(Math.abs( angle_knee - previous_angle_knee) <1.0){
    current_phase = current_phase; 
  }
  else if (Math.abs( angle_knee - previous_angle_knee) > 10){
    current_phase = 5;
  }
  else if(current_phase == 0 && angle_speed >=0.0){
    current_phase = 0;
  }
  else if(current_phase == 0 && angle_speed <0.0){
    current_phase = 1;
  }
  else if(current_phase == 1 && angle_speed <=0.0){
    current_phase = 1;
  }
  else if(current_phase == 1 && angle_speed >0.0){
current_phase = 2;
  }
  else if(current_phase == 2 && angle_acceleration >=0.0){
    current_phase = 2;
  }
  else if(current_phase == 2 && angle_acceleration < 0.0){// && previous_angle_acceleration <=0.000){
    current_phase = 3;
  }
  else if(current_phase == 3 && angle_speed >=0.0){
    current_phase = 3;
  }
  else if(current_phase == 3 && angle_speed < 0.0){
    current_phase = 4;
  }
  else if(current_phase == 4 && angle_speed < 0.0){
    current_phase = 4;
  }
  else if(current_phase == 4 && angle_speed > 0.0){
  current_phase =0;
  output.println("new");
  }
  else{
   current_phase = current_phase; 
  }
   
  
}


//////////////////////////////////////////////////////////////////////////////:

void keyPressed() {
  if (key == 'c' || key == 'C') {
    background(255); 
    for(int j =0;j<50;j++){
     for (int i=0; i < plot.getPointsRef().getNPoints();i++){
          plot.removePoint(0);
    } 
    }
    pointColors.clear();
    angleList.clear();
    plot.setXLim(0, 0+Timedelta);
    lowest_x=0;
    upper_x= 0+Timedelta;
    time = 0.0;
    waitForStart = true;
    Finish = false;
    step=0;
  }
  if (key == 's' || key == 'S') {
    pointColors.clear();
    waitForStart = false;
    time = 0.0;
    current_phase = 0;
  }
  
  if (key == 'e' || key == 'E') {
    Finish = true;
  }
  if(key == 'x' || key == 'X'){
    
     output.flush();
     output.close();
     exit();
  }
  
  
}

void mousePressed() {
output.println("new");
current_phase = 0;
}


///////////////////////////////////////////////////////////////////////////////


void create_graph(){
  plot = new GPlot(this);
  plot.setPos(margin, marginy);
  plot.setDim(graphWidth, graphHeight);


  // Set the plot limits (this will fix them)
  plot.setXLim(lowest_x, upper_x);
  plot.setYLim(0, 90);


  plot.getXAxis().setAxisLabelText("Time (s)");
  plot.getYAxis().setAxisLabelText("Knee angle (deg)");

  // Activate the panning effect
  plot.activatePanning(); 
  
}

void draw_graph(){
   
  
  plot.beginDraw();
  plot.drawBackground();
  plot.drawBox();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTopAxis();
  plot.drawRightAxis();
  plot.getMainLayer().drawPoints();
  plot.endDraw();
  
 
  
  //title
  textAlign(CENTER, TOP);
  fill(0);
  textSize(50);
  text("Gait analysis",sizex/2,30);

  //text("Time evolution of the knee angle", graphWidth/2 + margin, marginy-90);
  
  
 
  //phase legend
  stroke(255,255,255);
  fill(186,12,47);
  rect(margin-600,margin1+dialSize/2-40,40,20);
  fill(0);
  textAlign(LEFT,CENTER);
  textSize(20);
  text("1st phase",margin-540,margin1+dialSize/2-32);
  
  fill(152,29,151);
  rect(margin-600,margin1+dialSize/2-10,40,20);
  fill(0);
  textSize(20);
  text("2nd phase",margin-540,margin1+dialSize/2-2);
  
  fill(0,181,226);
  rect(margin-600,margin1+dialSize/2+20,40,20);
  fill(0);
  textSize(20);
  text("3rd phase",margin-540,margin1+dialSize/2+28);
  
  fill(120,190,32);
  rect(margin-350,margin1+dialSize/2-40,40,20);
  fill(0);
  textSize(20);
  text("4th phase",margin-290,margin1+dialSize/2-32);
  
  fill(255,209,0);
  rect(margin-350,margin1+dialSize/2-10,40,20);
  fill(0);
  textSize(20);
  text("5th phase",margin-290,margin1+dialSize/2-2);
  
  fill(255,163,0);
  rect(margin-350,margin1+dialSize/2+20,40,20);
  fill(0);
  textSize(20);
  text("Out of range",margin-290,margin1+dialSize/2+28);

  
 
}

void draw_speedometer(){
  
  pushMatrix();
  translate(margin1,margin1-50);
  //text("°",margin1+90,margin1);
  strokeWeight(2);
  stroke(0);
  noFill();
  arc(0, 0, dialSize, dialSize, radians(dialStart), radians(dialStart + dialAngle));
  for (int i = 0; i <= dialAngle/10; i++) {
    float angle = radians(dialStart + i * 10);
    float x1 = (dialSize/2 - 10) * cos(angle);
    float y1 = (dialSize/2 - 10) * sin(angle);
    float x2 = dialSize/2 * cos(angle);
    float y2 = dialSize/2 * sin(angle);
    line(x1, y1, x2, y2);
  }
  fill(0);
  
  
  popMatrix();
  
  pushMatrix();
  translate(margin1,margin2-50);
  //text("°",margin1+90,margin1);
  strokeWeight(2);
  stroke(0);
  noFill();
  arc(0, 0, dialSize, dialSize, radians(dialStart), radians(dialStart + dialAngle));
  for (int i = 0; i <= dialAngle/10; i++) {
    float angle = radians(dialStart + i * 10);
    float x1 = (dialSize/2 - 10) * cos(angle);
    float y1 = (dialSize/2 - 10) * sin(angle);
    float x2 = dialSize/2 * cos(angle);
    float y2 = dialSize/2 * sin(angle);
    line(x1, y1, x2, y2);
  }
  
  popMatrix();
  
  textSize(35);
  textAlign(CENTER, CENTER);
  text("Angle value",margin1,margin1-70+dialSize/2);
  text("Angle speed",margin1,margin2-70+dialSize/2);
}
void draw_point(){
  
  float handAngleSpeed=-12*angle_speed;
  
  textAlign(CENTER, CENTER);
  textSize(36);
  noStroke();
  fill(255);
  circle(margin1,margin2-50,dialSize*0.85); //white circle, overwriting the previous line, to draw a new line on top of it
  fill(255);
  rect(margin1-50,margin2,100,50);
  fill(0);
  text(nf(angle_speed, 0, 2)+"°/s", margin1, margin2+20);
  stroke(0);
  line(margin1,margin2-50, margin1-dialSize*0.375*sin(radians(handAngleSpeed)),margin2-50-dialSize*0.375*cos(radians(handAngleSpeed))); //drawing the speedometer hand
  
  float handAngle=120-4*value/3; //converting knee angle to speedometer angle
  
  // draw the value as text
  textAlign(CENTER, CENTER);
  textSize(36);
  noStroke();
  fill(255);
  circle(margin1,margin1-45,dialSize*0.85); //white circle, overwriting the previous line, to draw a new line on top of it
  fill(255);
  rect(margin1-40,margin1,80,50);
  
  //// Color according to angle
  if (current_phase == 0){
  fill(186,12,47);
  text(nf(value, 0, 2)+"°", margin1, margin1+20); 
  
  }
  else if (current_phase == 1){
  fill(152,29,151);
  text(nf(value, 0, 2)+"°", margin1, margin1+20); 
  
  }
   else if (current_phase == 2){
  fill(0,181,226);
  text(nf(value, 0, 2)+"°", margin1, margin1+20); 
  
  }
   else if (current_phase == 3){
  fill(120,190,32);
  text(nf(value, 0, 2)+"°", margin1, margin1+20); 
  
  }
   else if (current_phase == 4){
  fill(255,209,0);
  text(nf(value, 0, 2)+"°", margin1, margin1+20); 
  
  }
   else{
  fill(255,163,0);
  text(nf(value, 0, 2)+"°", margin1, margin1+20); 
  }
  stroke(0);
  line(margin1,margin1-50, margin1-dialSize*0.375*sin(radians(handAngle)),margin1-50-dialSize*0.375*cos(radians(handAngle))); //drawing the speedometer hand
  
  
  GPoint current_point = new GPoint(time,value);

  
  if (maxTime < time){
       
        lowest_x=lowest_x+ samplingTime/2.0;
        upper_x= upper_x+ samplingTime/2.0;
        println("limit",lowest_x);
        plot.setXLim(lowest_x, upper_x);
        

   }
   if (step >= stepsPerCycle){
     plot.removePoint(0);
     pointColors.remove(0); 
   }
 
  if (current_phase == 0){
    plot.addPoint(current_point);
    pointColors.add(color(186,12,47));
  
  }
  else if (current_phase == 1){
    
     plot.addPoint(current_point);
     pointColors.add(color(152,29,151));
  
  }
   else if (current_phase == 2){
      plot.addPoint(current_point);
    pointColors.add(color(0,181,226));
  
  }
   else if (current_phase == 3){

     plot.addPoint(current_point);
     pointColors.add(color(120,190,32));
  
  }
   else if (current_phase == 4){

     plot.addPoint(current_point);
     pointColors.add(color(255,209,0));
  
  }
   else{
      plot.addPoint(current_point);
     pointColors.add(color(255, 163, 0));
    current_phase = previous_phase;
  }
 
   int[] arr = pointColors.stream().mapToInt(Integer::intValue).toArray();
  plot.setPointColors(arr);
  step++;
     
}
