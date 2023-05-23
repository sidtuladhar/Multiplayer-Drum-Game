import processing.serial.*;
import osteele.processing.SerialRecord.*;
import processing.sound.*;
import processing.video.*;

// declare move object
Movie movie1;
Movie movie2;

// declare a SoundFile object
SoundFile sound1;
SoundFile sound2;
SoundFile sound3;

Serial serialPort;
SerialRecord serialRecord;

ArrayList tile = new ArrayList();
static int gameWidth = 1200, gameHeight = 600;
int score=0;
int misses=0;
String questionMessage1;
String questionMessage2;
boolean first_time = true;
boolean display_question = false;
int blue;
int yellow;
int red;
int difficulty_num;
float difficulty_speed = 1.5;
float duration;
int gamestatus = 0;

void setup() {
  String serialPortName = SerialUtils.findArduinoPort();
  serialPort = new Serial(this, serialPortName, 9600);
  serialRecord = new SerialRecord(this, serialPort, 3);

  fullScreen();
  noStroke();
  questionMessage1 = "Do You Want To Play Again?";
  questionMessage2 = "Choose Your Difficulty";
  askingQuestion = true;
  textSize(18);

  sound1 = new SoundFile(this, "christmas.mp3"); // It's Beginning To Look A Lot Like Christmas - Perry Como
  sound2 = new SoundFile(this, "tree.mp3"); // Christmas Tree Farm - Taylor Swift
  sound3 = new SoundFile(this, "santa.mp3"); // Santa Tell Me - Ariana Grande

  movie1 = new Movie(this, "opening.mp4");
  movie1.play();

  //image(movie, 0, 0, width, height);

  //beginning video or instruction video
}

void draw() {

  serialRecord.read();
  blue = serialRecord.values[1]; //blue
  yellow = serialRecord.values[2]; //yellow
  red = serialRecord.values[0]; //red

  background(50, 150, 200, 200);

  if (gamestatus == 0) {
    if (movie1.available()) {
      movie1.read();
      print(questionMessage2);
    } else if (movie1.available() == false) {
      print(questionMessage1);
      gamestatus = 1;
    }
    image(movie1, 0, 0, width, height);
  } else if (gamestatus == 1) {




    //image(movie, 0, 0, width, height);


    tiles til = new tiles(int(random(difficulty_num)), int(random(3)));

    fill(#aa0000, 50);
    rect(0, 600, width, 100);

    if (frameCount%50==6) {            //amount of notes generates per second, frameCount%10=6 notes/second
      tile.add(til);
    }

    fill(#aaaaaa);
    rect(200, 0, 20, height);
    rect(450, 0, 20, height);
    rect(700, 0, 20, height);
    rect(950, 0, 20, height);

    for (int i=0; i<tile.size(); i++) {

      tiles ta = (tiles) tile.get(i);
      ta.run();
      ta.display();
      ta.move(difficulty_speed);
      if ( red > 10 && ta.location.y > 550 && ta.location.y < 750&& ta.location.x == 160.0) { //red
        ta.gone=true;
        serialRecord.read();

        red = serialRecord.values[0];
      }
      if (blue > 10 && ta.location.y > 550 && ta.location.y < 750 && ta.location.x==410.0) { //blue
        ta.gone=true;
        serialRecord.read();
        blue = serialRecord.values[1];
      }
      if (yellow > 10 && ta.location.y > 550 && ta.location.y < 750 && ta.location.x==660.0) { //yellow
        ta.gone=true;
        serialRecord.read();
        yellow = serialRecord.values[2];
      }
      if (yellow > 30 && blue > 30 && ta.location.y > 550 && ta.location.y < 700 &&ta.location.x==910.0) { //green
        ta.gone=true;
        serialRecord.read();
        
        yellow = serialRecord.values[2];
        blue = serialRecord.values[1];
      }
      if (red > 30 && blue > 30 && ta.location.y > 550 && ta.location.y < 700&&ta.location.x==910.0) { //purple
        ta.gone=true;
        serialRecord.read();
        
        red = serialRecord.values[0];
        blue = serialRecord.values[1];
      }
      if (red > 30 && yellow > 30 && ta.location.y > 550 && ta.location.y < 700 &&ta.location.x==910.0) { //orange
        ta.gone=true;
        serialRecord.read();
        
        red = serialRecord.values[1];
        yellow = serialRecord.values[2];
      }


      if (ta.location.y>1000) {
        tile.remove(i);
        misses++;
      }
      if (ta.gone==true) {
        score+=ta.location.y>650?30:ta.location.y>600?20:10;    //scoring system(you get more points if you do better)
        tile.remove(i);
      }
    }

    fill(#0000aa); // score display
    textAlign(CENTER);
    textSize(50);
    text(score, 1300, 130);

    if (sound1.isPlaying() == false && sound2.isPlaying() == false && sound3.isPlaying() == false) {
      if (first_time == true) {
        drawDifficulty();
        first_time = false;
      } else if (display_question == false) {
        display_question = true;
        askingQuestion = true;
        for (int i=0; i<tile.size(); i++) { // removes all tiles after song stops
          tile.remove(i);
        }

        drawScore();
      } else if (display_question == true) {
        askingQuestion = true;
        display_question = false;
        drawDifficulty();
        score = 0;
        misses = 0;
      }
    }
  } else if (gamestatus == 2) {
    movie2 = new Movie(this, "ending.mp4");
    movie2.play();
    if (movie2.available()) {
      movie2.read();
      println("Game Over! Thanks for playing, please refresh the page when you are ready to PLAY AGAIN!");
    } else if (movie2.available() == false) {
      println("bug!");
      gamestatus = 3;
    }
    image(movie2, 0, 0, width, height);
  } else if (gamestatus == 3) {
    endGame();
  }
}

void mousePressed() {
  int check1 = checkAnswer1();
  if (check1 == YES) {
    loop();
  }
  if (check1 == NO) {

    // add end video
    gamestatus = 2;
  }

  int check2 = checkAnswer2();
  if (check2 == EASY) {
    print(check2);
    difficulty_num = 3;
    difficulty_speed = 1.5;
    sound1.play();
    duration = sound1.duration();
    loop();
  } else if (check2 == MEDIUM) {
    difficulty_num = 4;
    difficulty_speed = 1.5;
    print(check2);
    sound2.play();
    duration = sound2.duration();
    loop();
  } else if (check2 == HARD) {
    difficulty_num = 4;
    difficulty_speed = 2.8;
    sound3.play();
    duration = sound3.duration();
    loop();
    print(check2);
  }
}


class tiles {
  PVector location;
  Boolean gone=false;
  color tile_color;

  tiles(int i, int j) {
    color[] colors = {#19ad05, #9504de, #fc8403};
    location = new PVector((i*250) + 160, 0);
    tile_color = colors[j];
  }


  void run() {
    display();
    move(difficulty_speed);
  }

  void display() { //#19ad05, #9504de, #edd602
    fill(location.x>=0 && location.x<200 ?#de0404: location.x>200 && location.x<=410 ?#0416de:
      location.x>410 && location.x<=660 ?#edd602: location.x>660 && location.x<=910?tile_color: location.x>900 && location.x<1200?#fc7600:#fafafa);
    rect(location.x, location.y, 100, 50, 40);
  }

  void move(float speed) {
    location.y+=speed;
    //note speed, changing this will up the difficulity, putting it too high will make
  }                                  //it literally impossible
}


static boolean askingQuestion = false, answer = false;
static int questionX=gameWidth/2-150, questionY=gameHeight/2-40, questionWidth=370, questionHeight=100;
final static int NO_ANSWER = 0;
final static int YES = 1;
final static int NO = 2;
final static int EASY = 3;
final static int MEDIUM = 4;
final static int HARD = 5;

int checkAnswer2() { //Check to see if user clicked which difficulty
  if (mouseX >= questionX && mouseX <= questionWidth + 650 && mouseY >= questionY + 50 && mouseY <= questionY+questionHeight && askingQuestion == true) {
    loop();
    askingQuestion = false;
    answer = true;
    return EASY;
  }
  if (mouseX >= questionX && mouseX <= questionWidth + 650 && mouseY >= questionY + 100 && mouseY <= questionY + 140 && askingQuestion == true) {
    loop();
    askingQuestion = false;
    answer = true;
    return MEDIUM;
  }
  if (mouseX >= questionX && mouseX <= questionWidth + 650 && mouseY >= questionY + 150 && mouseY <= questionY + 190 && askingQuestion == true) {
    loop();
    askingQuestion = false;
    answer = true;
    return HARD;
  }

  return NO_ANSWER;
}

int checkAnswer1() { //Check to see if user clicked yes or no
  if (mouseX >= questionX + 600 && mouseX <= questionX + 783 && mouseY >= questionY + 150 && mouseY <= questionY + 190 && askingQuestion == true) {
    loop();
    askingQuestion = false;
    answer = true;
    return YES;
  }
  if (mouseX >= questionX + 783 && mouseX <= questionX + 950 && mouseY >= questionY + 150 && mouseY <= questionY + 190 && askingQuestion == true) {
    loop();
    askingQuestion = false;
    answer = true;
    return NO;
  }

  return NO_ANSWER;
}


void drawScore() {
  stroke(225);
  fill(50);
  //rect(questionX - 2, questionY - 2, questionWidth + 10, questionHeight + 4);
  rect(questionX + 600, questionY, questionWidth, questionHeight - 50);
  rect(questionX + 600, questionY + 50, questionWidth, questionHeight - 50);
  rect(questionX + 600, questionY + 100, questionWidth, questionHeight - 50);
  rect(questionX + 600, questionY + 150, questionWidth, questionHeight - 50);
  rect(questionX + 783, questionY + 150, questionWidth - 183, questionHeight - 50);
  stroke(225);
  fill(225);
  textSize(30);
  text(questionMessage1, questionX + 790, questionY + questionHeight - 66);

  text("Score: " + score, questionX + 685, questionY + questionHeight - 18);
  text("Misses: " + misses, questionX + 682, questionY + questionHeight + 34);
  text("Yes", questionX + 684, questionY + questionHeight + 83);
  text("No", questionX + 872, questionY + questionHeight + 83);
  noLoop();
}

void drawDifficulty() {
  stroke(225);
  fill(50);
  //rect(questionX - 2, questionY - 2, questionWidth + 10, questionHeight + 4);
  rect(questionX, questionY, questionWidth + 160, questionHeight - 50);
  rect(questionX, questionY + 50, questionWidth + 160, questionHeight - 50);
  rect(questionX, questionY + 100, questionWidth + 160, questionHeight - 50);
  rect(questionX, questionY + 150, questionWidth + 160, questionHeight - 50);
  stroke(225);
  fill(225);
  textSize(30);
  text(questionMessage2, questionX + 250, questionY + questionHeight - 66);
  textSize(20);
  text("Easy: It's Beginning To Look A Lot Like Christmas - Perry Como", questionX + 267, questionY + questionHeight - 18);
  text("Medium: Christmas Tree Farm - Taylor Swift", questionX + 190, questionY + questionHeight + 34);
  text("Hard: Santa Tell Me - Ariana Grande", questionX + 158, questionY + questionHeight + 81);
  noLoop();
}

void endGame() {
  noLoop();
  exit();
}
