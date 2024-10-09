import processing.serial.*; // Import the Serial library

Serial myPort; // The serial port object

int sensor1Value = 0; // Store the value from sensor 1
int sensor2Value = 0; // Store the value from sensor 2

boolean sensorTriggeredAnimation = false;
boolean keyTriggeredAnimation = false;

boolean forward = true; // Variable to track animation direction

boolean letterADrawn = false; // Variable to track if letter 'A' is drawn
boolean letterBDrawn = false; // Variable to track if letter 'B' is drawn
boolean letterCDrawn = false; // Variable to track if letter 'C' is drawn
boolean letterDDrawn = false; // Variable to track if letter 'D' is drawn
boolean letterEDrawn = false; // Variable to track if letter 'E' is drawn
boolean letterFDrawn = false; // Variable to track if letter 'F' is drawn
boolean letterGDrawn = false; // Variable to track if letter 'G' is drawn
boolean letterHDrawn = false; // Variable to track if letter 'H' is drawn
boolean letterIDrawn = false; // Variable to track if letter 'I' is drawn
boolean letterJDrawn = false; // Variable to track if letter 'J' is drawn
boolean letterKDrawn = false; // Variable to track if letter 'K' is drawn
int letterVariant = 0; // Variable to track the current variant
int cols = 28; // Number of columns
int rows = 14; // Number of rows
float cellWidth, cellHeight;
boolean animate = false; // Tracks whether to animate
int fps = 10; // Desired frame rate for animation (4 FPS)
int lastFrameTime = 0; // Timer for animation control


void setup() {
  size(1120, 560, P2D);
  frameRate(fps); // Main frame rate
  colorMode(RGB, 255, 255, 255, 1);

  // Calculate the width and height of each cell
  cellWidth = width / (int)cols;
  cellHeight = height / (int)rows;

  // Initialize the virtual display
  virtualDisplay = createGraphics(width, height);

  // Initialize the serial port (Adjust 'COM3' or '/dev/tty...' to your port)
  myPort = new Serial(this, Serial.list()[11], 9600);

  // Core setup functions
  cast_setup();
  config_setup();
  stages_setup();
  ui_setup();
}

void draw() {
  // Check if there is any serial data available
  if (myPort.available() > 0) {
    String sensorData = myPort.readStringUntil('\n'); // Read the incoming data
    if (sensorData != null) {
      sensorData = trim(sensorData); // Remove any whitespace
      String[] sensorValues = split(sensorData, ','); // Split the string by comma
      if (sensorValues.length == 2) {
        // Convert the sensor values to integers
        sensor1Value = int(sensorValues[0]);
        sensor2Value = int(sensorValues[1]);
      }
    }
  }
  
  // Sensor-based animation control
  sensorTriggeredAnimation = sensor2Value < 7300;
  
  // Calculate frame rate adjustment
  int dropUnits = max(0, (7300 - sensor2Value));  // Ensure the drop doesn't go negative
  int rateIncrease = (dropUnits / 500) * 4;  // Every 500 unit drop adds 4 to the frame rate

  // Set the new frame rate
  fps = 10 + rateIncrease;  // Starting frame rate is 10
  frameRate(fps);  // Update the frame rate

  // Combine sensor and key-triggered animation conditions
  animate = sensorTriggeredAnimation || keyTriggeredAnimation;

  virtualDisplay.beginDraw();
  virtualDisplay.strokeWeight(0.3);
  
  // Invert colors if sensor 1 value is below 7300
  if (sensor1Value < 7300 || mousePressed) {
    virtualDisplay.background(255); // White background
    virtualDisplay.fill(0); // Black fill for shapes
  } else {
    virtualDisplay.background(0); // Black background
    virtualDisplay.fill(255); // White fill for shapes
  }

  // Check if we're animating
  if (animate) {
    // Only change the variant if the right time has passed
    if (millis() - lastFrameTime > (1000 / fps)) {
      if (forward) {
        letterVariant++;
        if (letterVariant >= 3) {
          forward = false; // Switch direction to backward
        }
      } else {
        letterVariant--;
        if (letterVariant <= 0) {
          forward = true; // Switch direction to forward
        }
      }
      lastFrameTime = millis(); // Update timer
    }
  }

  // Draw the current letter variant
  if (letterADrawn) {
    drawLetterA();
  } else if (letterBDrawn) {
    drawLetterB();
  } else if (letterCDrawn) {
    drawLetterC();
  } else if (letterDDrawn) {
    drawLetterD();
  } else if (letterEDrawn) {
    drawLetterE();
  } else if (letterFDrawn) {
    drawLetterF();
  } else if (letterGDrawn) {
    drawLetterG();
  } else if (letterHDrawn) {
    drawLetterH();
  } else if (letterIDrawn) {
    drawLetterI();
  } else if (letterJDrawn) {
    drawLetterJ();
  } else if (letterKDrawn) {
    drawLetterK();
  }

  virtualDisplay.endDraw();
  // Render to screen
  ui_render();

  // Process frame
  stage_process();

  // Cast to display
  cast_broadcast();
}

void keyPressed() {
  
  // Reset the letterVariant to start from variant 1
  letterVariant = 0;
  // Toggle letters
  if (key == 'A' || key == 'a') {
    resetLetters();
    letterADrawn = true;
  } else if (key == 'B' || key == 'b') {
    resetLetters();
    letterBDrawn = true;
  } else if (key == 'C' || key == 'c') {
    resetLetters();
    letterCDrawn = true;
  } else if (key == 'D' || key == 'd') {
    resetLetters();
    letterDDrawn = true;
  } else if (key == 'E' || key == 'e') {
    resetLetters();
    letterEDrawn = true;
  } else if (key == 'F' || key == 'f') {
    resetLetters();
    letterFDrawn = true;
  } else if (key == 'G' || key == 'g') {
    resetLetters();
    letterGDrawn = true;
  } else if (key == 'H' || key == 'h') {
    resetLetters();
    letterHDrawn = true;
  } else if (key == 'I' || key == 'i') {
    resetLetters();
    letterIDrawn = true;
  } else if (key == 'J' || key == 'j') {
    resetLetters();
    letterJDrawn = true;
  } else if (key == 'K' || key == 'k') {
    resetLetters();
    letterKDrawn = true;
  } 

  // Start animation when the right arrow key is pressed
  if (keyCode == RIGHT) {
    keyTriggeredAnimation = true;  // Start animation on right arrow key press
  }

  // Show previous variant when the left arrow key is pressed
  if (keyCode == LEFT) {
    letterVariant--;
    if (letterVariant < 0) {
      letterVariant = 3; // Loop back to the last variant if below 0
    }
  }
}

void keyReleased() {
  // Stop animation when the right arrow key is released
  if (keyCode == RIGHT) {
    keyTriggeredAnimation = false;  // Stop animation when right arrow key is released
  }
}

void resetLetters() {
  letterADrawn = letterBDrawn = letterCDrawn = letterDDrawn = letterEDrawn = letterFDrawn = letterGDrawn = letterHDrawn = letterIDrawn = letterJDrawn = letterKDrawn = false;
}

// Draw variants of letter A
void drawLetterA() {
  if (letterVariant == 0) {
    drawVariantA1();
  } else if (letterVariant == 1) {
    drawVariantA2();
  } else if (letterVariant == 2) {
    drawVariantA3();
  } else if (letterVariant == 3) {
    drawVariantA4();
  }
}

// Draw variants of letter B
void drawLetterB() {
  if (letterVariant == 0) {
    drawVariantB1();
  } else if (letterVariant == 1) {
    drawVariantB2();
  } else if (letterVariant == 2) {
    drawVariantB3();
  } else if (letterVariant == 3) {
    drawVariantB4();
  }
}

// Draw variants of letter C
void drawLetterC() {
  if (letterVariant == 0) {
    drawVariantC1();
  } else if (letterVariant == 1) {
    drawVariantC2();
  } else if (letterVariant == 2) {
    drawVariantC3();
  } else if (letterVariant == 3) {
    drawVariantC4();
  }
}

// Draw variants of letter D
void drawLetterD() {
  if (letterVariant == 0) {
    drawVariantD1();
  } else if (letterVariant == 1) {
    drawVariantD2();
  } else if (letterVariant == 2) {
    drawVariantD3();
  } else if (letterVariant == 3) {
    drawVariantD4();
  }
}

// Draw variants of letter E
void drawLetterE() {
  if (letterVariant == 0) {
    drawVariantE1();
  } else if (letterVariant == 1) {
    drawVariantE2();
  } else if (letterVariant == 2) {
    drawVariantE3();
  } else if (letterVariant == 3) {
    drawVariantE4();
  }
}

// Draw variants of letter F
void drawLetterF() {
  if (letterVariant == 0) {
    drawVariantF1();
  } else if (letterVariant == 1) {
    drawVariantF2();
  } else if (letterVariant == 2) {
    drawVariantF3();
  } else if (letterVariant == 3) {
    drawVariantF4();
  }
}

// Draw variants of letter G
void drawLetterG() {
  if (letterVariant == 0) {
    drawVariantG1();
  } else if (letterVariant == 1) {
    drawVariantG2();
  } else if (letterVariant == 2) {
    drawVariantG3();
  } else if (letterVariant == 3) {
    drawVariantG4();
  }
}

// Draw variants of letter H
void drawLetterH() {
  if (letterVariant == 0) {
    drawVariantH1();
  } else if (letterVariant == 1) {
    drawVariantH2();
  } else if (letterVariant == 2) {
    drawVariantH3();
  } else if (letterVariant == 3) {
    drawVariantH4();
  }
}

// Draw variants of letter I
void drawLetterI() {
  if (letterVariant == 0) {
    drawVariantI1();
  } else if (letterVariant == 1) {
    drawVariantI2();
  } else if (letterVariant == 2) {
    drawVariantI3();
  } else if (letterVariant == 3) {
    drawVariantI4();
  }
}

// Draw variants of letter J
void drawLetterJ() {
  if (letterVariant == 0) {
    drawVariantJ1();
  } else if (letterVariant == 1) {
    drawVariantJ2();
  } else if (letterVariant == 2) {
    drawVariantJ3();
  } else if (letterVariant == 3) {
    drawVariantJ4();
  }
}

// Draw variants of letter K
void drawLetterK() {
  if (letterVariant == 0) {
    drawVariantK1();
  } else if (letterVariant == 1) {
    drawVariantK2();
  } else if (letterVariant == 2) {
    drawVariantK3();
  } else if (letterVariant == 3) {
    drawVariantK4();
  }
}

// Variant 1: Original letter A
void drawVariantA1() {
    virtualDisplay.rect(8, 1, 11, 1);
    virtualDisplay.rect(9, 2, 3, 1);
    virtualDisplay.rect(15, 2, 3, 1);
    virtualDisplay.rect(8, 3, 3, 1);
    virtualDisplay.rect(16, 3, 3, 1);
    virtualDisplay.rect(8, 4, 3, 1);
    virtualDisplay.rect(16, 4, 3, 1);
    virtualDisplay.rect(7, 5, 4, 1);
    virtualDisplay.rect(16, 5, 4, 1);
    virtualDisplay.rect(7, 6, 5, 1);
    virtualDisplay.rect(15, 6, 5, 1);
    virtualDisplay.rect(6, 7, 15, 1);
    virtualDisplay.rect(6, 8, 5, 1);
    virtualDisplay.rect(16, 8, 5, 1);
    virtualDisplay.rect(5, 9, 5, 1);
    virtualDisplay.rect(17, 9, 5, 1);
    virtualDisplay.rect(5, 10, 5, 1);
    virtualDisplay.rect(17, 10, 5, 1);
    virtualDisplay.rect(4, 11, 7, 1);
    virtualDisplay.rect(16, 11, 7, 1);
    virtualDisplay.rect(4, 12, 7, 1);
    virtualDisplay.rect(16, 12, 7, 1);
}

// Variant 2: Fatter version of A
void drawVariantA2() {
    virtualDisplay.rect(7, 1, 13, 1);
    virtualDisplay.rect(8, 2, 3, 1);
    virtualDisplay.rect(16, 2, 3, 1);
    virtualDisplay.rect(7, 3, 3, 1);
    virtualDisplay.rect(17, 3, 3, 1);
    virtualDisplay.rect(7, 4, 3, 1);
    virtualDisplay.rect(17, 4, 3, 1);
    virtualDisplay.rect(6, 5, 4, 1);
    virtualDisplay.rect(17, 5, 4, 1);
    virtualDisplay.rect(6, 6, 5, 1);
    virtualDisplay.rect(16, 6, 5, 1);
    virtualDisplay.rect(5, 7, 17, 1);
    virtualDisplay.rect(5, 8, 6, 1);
    virtualDisplay.rect(16, 8, 6, 1);
    virtualDisplay.rect(4, 9, 6, 1);
    virtualDisplay.rect(17, 9, 6, 1);
    virtualDisplay.rect(4, 10, 6, 1);
    virtualDisplay.rect(17, 10, 6, 1);
    virtualDisplay.rect(3, 11, 9, 1);
    virtualDisplay.rect(15, 11, 9, 1);
    virtualDisplay.rect(3, 12, 9, 1);
    virtualDisplay.rect(15, 12, 9, 1);
}

// Variant 3: Even fatter version
void drawVariantA3() {
    virtualDisplay.rect(6, 1, 15, 1);
    virtualDisplay.rect(7, 2, 4, 1);
    virtualDisplay.rect(16, 2, 4, 1);
    virtualDisplay.rect(6, 3, 4, 1);
    virtualDisplay.rect(17, 3, 4, 1);
    virtualDisplay.rect(6, 4, 3, 1);
    virtualDisplay.rect(18, 4, 3, 1);
    virtualDisplay.rect(5, 5, 4, 1);
    virtualDisplay.rect(17, 5, 5, 1);
    virtualDisplay.rect(5, 6, 6, 1);
    virtualDisplay.rect(16, 6, 6, 1);
    virtualDisplay.rect(4, 7, 19, 1);
    virtualDisplay.rect(4, 8, 7, 1);
    virtualDisplay.rect(16, 8, 7, 1);
    virtualDisplay.rect(3, 9, 6, 1);
    virtualDisplay.rect(18, 9, 6, 1);
    virtualDisplay.rect(3, 10, 6, 1);
    virtualDisplay.rect(18, 10, 6, 1);
    virtualDisplay.rect(2, 11, 10, 1);
    virtualDisplay.rect(15, 11, 10, 1);
    virtualDisplay.rect(2, 12, 10, 1);
    virtualDisplay.rect(15, 12, 10, 1);
}

// Variant 4: Fattest version
void drawVariantA4() {
    virtualDisplay.rect(5, 1, 17, 1);
    virtualDisplay.rect(6, 2, 5, 1);
    virtualDisplay.rect(16, 2, 5, 1);
    virtualDisplay.rect(5, 3, 4, 1);
    virtualDisplay.rect(18, 3, 4, 1);
    virtualDisplay.rect(5, 4, 3, 1);
    virtualDisplay.rect(19, 4, 3, 1);
    virtualDisplay.rect(4, 5, 5, 1);
    virtualDisplay.rect(18, 5, 5, 1);
    virtualDisplay.rect(4, 6, 7, 1);
    virtualDisplay.rect(16, 6, 7, 1);
    virtualDisplay.rect(3, 7, 21, 1);
    virtualDisplay.rect(3, 8, 9, 1);
    virtualDisplay.rect(15, 8, 9, 1);
    virtualDisplay.rect(2, 9, 7, 1);
    virtualDisplay.rect(18, 9, 7, 1);
    virtualDisplay.rect(2, 10, 7, 1);
    virtualDisplay.rect(18, 10, 7, 1);
    virtualDisplay.rect(1, 11, 11, 1);
    virtualDisplay.rect(15, 11, 11, 1);
    virtualDisplay.rect(1, 12, 12, 1);
    virtualDisplay.rect(14, 12, 12, 1);
}

// Variant 1: Original letter B
void drawVariantB1() {
    virtualDisplay.rect(4, 0, 18, 1);
    virtualDisplay.rect(5, 1, 2, 1);
    virtualDisplay.rect(21, 1, 2, 1);
    virtualDisplay.rect(6, 2, 2, 1);
    virtualDisplay.rect(22, 2, 2, 1);
    virtualDisplay.rect(7, 3, 2, 1);
    virtualDisplay.rect(14, 3, 3, 1);
    virtualDisplay.rect(23, 3, 1, 1);
    virtualDisplay.rect(8, 4, 2, 1);
    virtualDisplay.rect(13, 4, 5, 1);
    virtualDisplay.rect(23, 4, 1, 1);
    virtualDisplay.rect(9, 5, 2, 1);
    virtualDisplay.rect(14, 5, 3, 1);
    virtualDisplay.rect(22, 5, 2, 1);
    virtualDisplay.rect(9, 6, 2, 1);
    virtualDisplay.rect(21, 6, 2, 1);
    virtualDisplay.rect(9, 7, 2, 1);
    virtualDisplay.rect(19, 7, 3, 1);
    virtualDisplay.rect(9, 8, 2, 1);
    virtualDisplay.rect(14, 8, 3, 1);
    virtualDisplay.rect(21, 8, 2, 1);
    virtualDisplay.rect(8, 9, 2, 1);
    virtualDisplay.rect(13, 9, 5, 1);
    virtualDisplay.rect(22, 9, 2, 1);
    virtualDisplay.rect(7, 10, 2, 1);
    virtualDisplay.rect(14, 10, 3, 1);
    virtualDisplay.rect(23, 10, 1, 1);
    virtualDisplay.rect(6, 11, 2, 1);
    virtualDisplay.rect(23, 11, 1, 1);
    virtualDisplay.rect(5, 12, 2, 1);
    virtualDisplay.rect(22, 12, 2, 1);
    virtualDisplay.rect(4, 13, 19, 1);
}

// Variant 2: Fatter version of B
void drawVariantB2() {
    virtualDisplay.rect(4, 0, 18, 1);
    virtualDisplay.rect(5, 1, 2, 1);
    virtualDisplay.rect(21, 1, 2, 1);
    virtualDisplay.rect(5, 2, 2, 1);
    virtualDisplay.rect(22, 2, 2, 1);
    virtualDisplay.rect(6, 3, 2, 1);
    virtualDisplay.rect(13, 3, 5, 1);
    virtualDisplay.rect(23, 3, 2, 1);
    virtualDisplay.rect(6, 4, 2, 1);
    virtualDisplay.rect(12, 4, 7, 1);
    virtualDisplay.rect(24, 4, 1, 1);
    virtualDisplay.rect(7, 5, 2, 1);
    virtualDisplay.rect(13, 5, 5, 1);
    virtualDisplay.rect(23, 5, 2, 1);
    virtualDisplay.rect(7, 6, 2, 1);
    virtualDisplay.rect(22, 6, 2, 1);
    virtualDisplay.rect(7, 7, 2, 1);
    virtualDisplay.rect(21, 7, 2, 1);
    virtualDisplay.rect(7, 8, 2, 1);
    virtualDisplay.rect(13, 8, 5, 1);
    virtualDisplay.rect(22, 8, 2, 1);
    virtualDisplay.rect(7, 9, 2, 1);
    virtualDisplay.rect(12, 9, 7, 1);
    virtualDisplay.rect(23, 9, 2, 1);
    virtualDisplay.rect(6, 10, 2, 1);
    virtualDisplay.rect(13, 10, 5, 1);
    virtualDisplay.rect(24, 10, 1, 1);
    virtualDisplay.rect(6, 11, 2, 1);
    virtualDisplay.rect(24, 11, 1, 1);
    virtualDisplay.rect(5, 12, 2, 1);
    virtualDisplay.rect(23, 12, 2, 1);
    virtualDisplay.rect(4, 13, 20, 1);
}

// Variant 3: Fatter version of B
void drawVariantB3() {
    virtualDisplay.rect(4, 0, 19, 1);
    virtualDisplay.rect(4, 1, 2, 1);
    virtualDisplay.rect(22, 1, 2, 1);
    virtualDisplay.rect(4, 2, 2, 1);
    virtualDisplay.rect(23, 2, 2, 1);
    virtualDisplay.rect(5, 3, 2, 1);
    virtualDisplay.rect(12, 3, 6, 1);
    virtualDisplay.rect(24, 3, 2, 1);
    virtualDisplay.rect(5, 4, 2, 1);
    virtualDisplay.rect(11, 4, 8, 1);
    virtualDisplay.rect(24, 4, 2, 1);
    virtualDisplay.rect(5, 5, 2, 1);
    virtualDisplay.rect(12, 5, 6, 1);
    virtualDisplay.rect(24, 5, 1, 1);
    virtualDisplay.rect(6, 6, 2, 1);
    virtualDisplay.rect(23, 6, 2, 1);
    virtualDisplay.rect(6, 7, 2, 1);
    virtualDisplay.rect(22, 7, 2, 1);
    virtualDisplay.rect(6, 8, 2, 1);
    virtualDisplay.rect(12, 8, 6, 1);
    virtualDisplay.rect(23, 8, 2, 1);
    virtualDisplay.rect(6, 9, 2, 1);
    virtualDisplay.rect(11, 9, 8, 1);
    virtualDisplay.rect(24, 9, 1, 1);
    virtualDisplay.rect(5, 10, 2, 1);
    virtualDisplay.rect(12, 10, 6, 1);
    virtualDisplay.rect(24, 10, 2, 1);
    virtualDisplay.rect(5, 11, 2, 1);
    virtualDisplay.rect(24, 11, 2, 1);
    virtualDisplay.rect(4, 12, 2, 1);
    virtualDisplay.rect(23, 12, 2, 1);
    virtualDisplay.rect(4, 13, 20, 1);
}

// Variant 4: Fattest version of B
void drawVariantB4() {
    virtualDisplay.rect(4, 0, 20, 1);
    virtualDisplay.rect(4, 1, 2, 1);
    virtualDisplay.rect(23, 1, 2, 1);
    virtualDisplay.rect(4, 2, 2, 1);
    virtualDisplay.rect(24, 2, 2, 1);
    virtualDisplay.rect(4, 3, 2, 1);
    virtualDisplay.rect(12, 3, 7, 1);
    virtualDisplay.rect(25, 3, 1, 1);
    virtualDisplay.rect(4, 4, 2, 1);
    virtualDisplay.rect(11, 4, 9, 1);
    virtualDisplay.rect(25, 4, 1, 1);
    virtualDisplay.rect(4, 5, 2, 1);
    virtualDisplay.rect(12, 5, 7, 1);
    virtualDisplay.rect(24, 5, 2, 1);
    virtualDisplay.rect(4, 6, 2, 1);
    virtualDisplay.rect(22, 6, 3, 1);
    virtualDisplay.rect(4, 7, 2, 1);
    virtualDisplay.rect(20, 7, 4, 1);
    virtualDisplay.rect(4, 8, 2, 1);
    virtualDisplay.rect(12, 8, 7, 1);
    virtualDisplay.rect(22, 8, 3, 1);
    virtualDisplay.rect(4, 9, 2, 1);
    virtualDisplay.rect(11, 9, 8, 1);
    virtualDisplay.rect(24, 9, 2, 1);
    virtualDisplay.rect(4, 10, 2, 1);
    virtualDisplay.rect(12, 10, 7, 1);
    virtualDisplay.rect(25, 10, 1, 1);
    virtualDisplay.rect(4, 11, 2, 1);
    virtualDisplay.rect(25, 11, 1, 1);
    virtualDisplay.rect(4, 12, 2, 1);
    virtualDisplay.rect(24, 12, 2, 1);
    virtualDisplay.rect(4, 13, 21, 1);
}

// Variant 1: Original letter C
void drawVariantC1() {
    virtualDisplay.rect(0, 0, 28, 1);
    virtualDisplay.rect(0, 1, 10, 1);
    virtualDisplay.rect(22, 1, 6, 1);
    virtualDisplay.rect(0, 2, 9, 1);
    virtualDisplay.rect(13, 2, 6, 1);
    virtualDisplay.rect(23, 2, 5, 1);
    virtualDisplay.rect(0, 3, 8, 1);
    virtualDisplay.rect(12, 3, 8, 1);
    virtualDisplay.rect(23, 3, 5, 1);
    virtualDisplay.rect(0, 4, 8, 1);
    virtualDisplay.rect(11, 4, 10, 1);
    virtualDisplay.rect(23, 4, 5, 1);
    virtualDisplay.rect(0, 5, 8, 1);
    virtualDisplay.rect(11, 5, 17, 1);
    virtualDisplay.rect(0, 6, 8, 1);
    virtualDisplay.rect(11, 6, 17, 1);
    virtualDisplay.rect(0, 7, 8, 1);
    virtualDisplay.rect(11, 7, 17, 1);
    virtualDisplay.rect(0, 8, 8, 1);
    virtualDisplay.rect(11, 8, 17, 1);
    virtualDisplay.rect(0, 9, 8, 1);
    virtualDisplay.rect(11, 9, 10, 1);
    virtualDisplay.rect(23, 9, 5, 1);
    virtualDisplay.rect(0, 10, 7, 1);
    virtualDisplay.rect(12, 10, 8, 1);
    virtualDisplay.rect(23, 10, 5, 1);
    virtualDisplay.rect(0, 11, 3, 1);
    virtualDisplay.rect(4, 11, 2, 1);
    virtualDisplay.rect(13, 11, 7, 1);
    virtualDisplay.rect(23, 11, 7, 1);
    virtualDisplay.rect(0, 12, 4, 1);
    virtualDisplay.rect(8, 12, 2, 1);
    virtualDisplay.rect(22, 12, 6, 1);
    virtualDisplay.rect(0, 13, 28, 1);
}

// Variant 2: Fatter version of C
void drawVariantC2() {
    virtualDisplay.rect(0,0,28,1);
    virtualDisplay.rect(0,1,10,1);
    virtualDisplay.rect(22,1,6,1);
    virtualDisplay.rect(0,2,9,1);
    virtualDisplay.rect(12,2,6,1);
    virtualDisplay.rect(23,2,5,1);
    virtualDisplay.rect(0,3,8,1);
    virtualDisplay.rect(11,3,8,1);
    virtualDisplay.rect(23,3,5,1);
    virtualDisplay.rect(0,4,7,1);
    virtualDisplay.rect(11,4,9,1);
    virtualDisplay.rect(23,4,5,1);
    virtualDisplay.rect(0,5,7,1);
    virtualDisplay.rect(11,5,17,1);
    virtualDisplay.rect(0,6,7,1);
    virtualDisplay.rect(11,6,17,1);
    virtualDisplay.rect(0,7,7,1);
    virtualDisplay.rect(11,7,17,1);
    virtualDisplay.rect(0,8,7,1);
    virtualDisplay.rect(11,8,17,1);
    virtualDisplay.rect(0,9,3,1);
    virtualDisplay.rect(4,9,3,1);
    virtualDisplay.rect(11,9,9,1);
    virtualDisplay.rect(23,9,5,1);
    virtualDisplay.rect(0,10,3,1);
    virtualDisplay.rect(4,10,3,1);
    virtualDisplay.rect(11,10,8,1);
    virtualDisplay.rect(23,10,5,1);
    virtualDisplay.rect(0,11,3,1);
    virtualDisplay.rect(4,11,2,1);
    virtualDisplay.rect(12,11,6,1);
    virtualDisplay.rect(23,11,5,1);
    virtualDisplay.rect(0,12,4,1);
    virtualDisplay.rect(8,12,2,1);
    virtualDisplay.rect(22,12,6,1);
    virtualDisplay.rect(0,13,28,1);



}

// Variant 3: Fatter version of C
void drawVariantC3() {
    virtualDisplay.rect(0,0,28,1);
    virtualDisplay.rect(0,1,10,1);
    virtualDisplay.rect(22,1,6,1);
    virtualDisplay.rect(0,2,9,1);
    virtualDisplay.rect(13,2,5,1);
    virtualDisplay.rect(23,2,5,1);
    virtualDisplay.rect(0,3,8,1);
    virtualDisplay.rect(12,3,7,1);
    virtualDisplay.rect(23,3,5,1);
    virtualDisplay.rect(0,4,7,1);
    virtualDisplay.rect(12,4,7,1);
    virtualDisplay.rect(23,4,5,1);
    virtualDisplay.rect(0,5,7,1);
    virtualDisplay.rect(12,5,8,1);
    virtualDisplay.rect(23,5,5,1);
    virtualDisplay.rect(0,6,7,1);
    virtualDisplay.rect(12,6,16,1);
    virtualDisplay.rect(0,7,7,1);
    virtualDisplay.rect(12,7,16,1);
    virtualDisplay.rect(0,8,3,1);
    virtualDisplay.rect(4,8,3,1);
    virtualDisplay.rect(12,8,8,1);
    virtualDisplay.rect(23,8,5,1);
    virtualDisplay.rect(0,9,3,1);
    virtualDisplay.rect(4,9,3,1);
    virtualDisplay.rect(12,9,7,1);
    virtualDisplay.rect(23,9,5,1);
    virtualDisplay.rect(0,10,3,1);
    virtualDisplay.rect(4,10,3,1);
    virtualDisplay.rect(12,10,7,1);
    virtualDisplay.rect(23,10,5,1);
    virtualDisplay.rect(0,11,3,1);
    virtualDisplay.rect(5,11,1,1);
    virtualDisplay.rect(13,11,5,1);
    virtualDisplay.rect(23,11,5,1);
    virtualDisplay.rect(0,12,4,1);
    virtualDisplay.rect(8,12,2,1);
    virtualDisplay.rect(22,12,6,1);
    virtualDisplay.rect(0,13,28,1);




}

// Variant 4: Fattest version of C
void drawVariantC4() {
    virtualDisplay.rect(0,0,28,1);
    virtualDisplay.rect(0,1,10,1);
    virtualDisplay.rect(22,1,6,1);
    virtualDisplay.rect(0,2,9,1);
    virtualDisplay.rect(15,2,3,1);
    virtualDisplay.rect(23,2,5,1);
    virtualDisplay.rect(0,3,8,1);
    virtualDisplay.rect(14,3,5,1);
    virtualDisplay.rect(23,3,5,1);
    virtualDisplay.rect(0,4,7,1);
    virtualDisplay.rect(13,4,6,1);
    virtualDisplay.rect(23,4,5,1);
    virtualDisplay.rect(0,5,7,1);
    virtualDisplay.rect(13,5,7,1);
    virtualDisplay.rect(23,5,5,1);
    virtualDisplay.rect(0,6,7,1);
    virtualDisplay.rect(13,6,15,1);
    virtualDisplay.rect(0,7,3,1);
    virtualDisplay.rect(4,7,3,1);
    virtualDisplay.rect(13,7,15,1);
    virtualDisplay.rect(0,8,3,1);
    virtualDisplay.rect(4,8,3,1);
    virtualDisplay.rect(13,8,7,1);
    virtualDisplay.rect(23,8,5,1);
    virtualDisplay.rect(0,9,3,1);
    virtualDisplay.rect(4,9,3,1);
    virtualDisplay.rect(13,9,6,1);
    virtualDisplay.rect(23,9,5,1);
    virtualDisplay.rect(0,10,3,1);
    virtualDisplay.rect(5,10,1,1);
    virtualDisplay.rect(14,10,5,1);
    virtualDisplay.rect(23,10,5,1);
    virtualDisplay.rect(0,11,3,1);
    virtualDisplay.rect(15,11,3,1);
    virtualDisplay.rect(23,11,5,1);
    virtualDisplay.rect(0,12,4,1);
    virtualDisplay.rect(8,12,2,1);
    virtualDisplay.rect(22,12,6,1);
    virtualDisplay.rect(0,13,28,1);



}

// Variant 1: Original letter D
void drawVariantD1() {
    virtualDisplay.rect(5, 1, 14, 1);
    virtualDisplay.rect(7, 2, 13, 1);
    virtualDisplay.rect(8, 3, 2, 1);
    virtualDisplay.rect(17, 3, 4, 1);
    virtualDisplay.rect(9, 4, 2, 1);
    virtualDisplay.rect(18, 4, 4, 1);
    virtualDisplay.rect(9, 5, 3, 1);
    virtualDisplay.rect(19, 5, 4, 1);
    virtualDisplay.rect(9, 6, 3, 1);
    virtualDisplay.rect(19, 6, 5, 1);
    virtualDisplay.rect(9, 7, 3, 1);
    virtualDisplay.rect(19, 7, 5, 1);
    virtualDisplay.rect(9, 8, 3, 1);
    virtualDisplay.rect(19, 8, 4, 1);
    virtualDisplay.rect(9, 9, 2, 1);
    virtualDisplay.rect(18, 9, 4, 1);
    virtualDisplay.rect(8, 10, 2, 1);
    virtualDisplay.rect(17, 10, 4, 1);
    virtualDisplay.rect(7, 11, 13, 1);
    virtualDisplay.rect(5, 12, 14, 1);
}

// Variant 2: Fatter version of D
void drawVariantD2() {
    virtualDisplay.rect(4,1,15,1);
    virtualDisplay.rect(5,2,15,1);
    virtualDisplay.rect(7,3,3,1);
    virtualDisplay.rect(16,3,5,1);
    virtualDisplay.rect(8,4,3,1);
    virtualDisplay.rect(17,4,5,1);
    virtualDisplay.rect(8,5,3,1);
    virtualDisplay.rect(18,5,5,1);
    virtualDisplay.rect(8,6,4,1);
    virtualDisplay.rect(18,6,6,1);
    virtualDisplay.rect(8,7,4,1);
    virtualDisplay.rect(18,7,6,1);
    virtualDisplay.rect(8,8,3,1);
    virtualDisplay.rect(18,8,5,1);
    virtualDisplay.rect(8,9,3,1);
    virtualDisplay.rect(17,9,5,1);
    virtualDisplay.rect(7,10,3,1);
    virtualDisplay.rect(16,10,5,1);
    virtualDisplay.rect(5,11,15,1);
    virtualDisplay.rect(4,12,15,1);

}

// Variant 3: Fatter version of D
void drawVariantD3() {
    virtualDisplay.rect(3,1,16,1);
    virtualDisplay.rect(4,2,16,1);
    virtualDisplay.rect(5,3,5,1);
    virtualDisplay.rect(15,3,6,1);
    virtualDisplay.rect(6,4,5,1);
    virtualDisplay.rect(16,4,6,1);
    virtualDisplay.rect(6,5,5,1);
    virtualDisplay.rect(17,5,6,1);
    virtualDisplay.rect(7,6,5,1);
    virtualDisplay.rect(17,6,7,1);
    virtualDisplay.rect(7,7,5,1);
    virtualDisplay.rect(17,7,7,1);
    virtualDisplay.rect(6,8,5,1);
    virtualDisplay.rect(17,8,6,1);
    virtualDisplay.rect(6,9,5,1);
    virtualDisplay.rect(16,9,6,1);
    virtualDisplay.rect(5,10,5,1);
    virtualDisplay.rect(15,10,6,1);
    virtualDisplay.rect(4,11,16,1);
    virtualDisplay.rect(3,12,16,1);

}

// Variant 4: Fattest version of D
void drawVariantD4() {
    virtualDisplay.rect(2,1,17,1);
    virtualDisplay.rect(3,2,17,1);
    virtualDisplay.rect(4,3,6,1);
    virtualDisplay.rect(14,3,7,1);
    virtualDisplay.rect(5,4,6,1);
    virtualDisplay.rect(15,4,7,1);
    virtualDisplay.rect(5,5,6,1);
    virtualDisplay.rect(16,5,7,1);
    virtualDisplay.rect(6,6,6,1);
    virtualDisplay.rect(16,6,8,1);
    virtualDisplay.rect(6,7,6,1);
    virtualDisplay.rect(16,7,8,1);
    virtualDisplay.rect(5,8,6,1);
    virtualDisplay.rect(16,8,7,1);
    virtualDisplay.rect(5,9,6,1);
    virtualDisplay.rect(15,9,7,1);
    virtualDisplay.rect(4,10,6,1);
    virtualDisplay.rect(14,10,7,1);
    virtualDisplay.rect(3,11,17,1);
    virtualDisplay.rect(2,12,17,1);

    
  
  }
  
// Variant 1: Original letter E
void drawVariantE1() {
    virtualDisplay.rect(8, 0, 14, 1);
    virtualDisplay.rect(7, 1, 3, 1);
    virtualDisplay.rect(21, 1, 2, 1);
    virtualDisplay.rect(6, 2, 3, 1);
    virtualDisplay.rect(12, 2, 7, 1);
    virtualDisplay.rect(21, 2, 2, 1);
    virtualDisplay.rect(5, 3, 3, 1);
    virtualDisplay.rect(11, 3, 8, 1);
    virtualDisplay.rect(21, 3, 2, 1);
    virtualDisplay.rect(5, 4, 2, 1);
    virtualDisplay.rect(10, 4, 8, 1);
    virtualDisplay.rect(21, 4, 2, 1);
    virtualDisplay.rect(5, 5, 2, 1);
    virtualDisplay.rect(10, 5, 7, 1);
    virtualDisplay.rect(21, 5, 2, 1);
    virtualDisplay.rect(5, 6, 2, 1);
    virtualDisplay.rect(20, 6, 3, 1);
    virtualDisplay.rect(5, 7, 2, 1);
    virtualDisplay.rect(19, 7, 3, 1);
    virtualDisplay.rect(5, 8, 2, 1);
    virtualDisplay.rect(9, 8, 12, 1);
    virtualDisplay.rect(5, 9, 2, 1);
    virtualDisplay.rect(10, 9, 10, 1);
    virtualDisplay.rect(23, 9, 1, 1);
    virtualDisplay.rect(5, 10, 3, 1);
    virtualDisplay.rect(22, 10, 2, 1);
    virtualDisplay.rect(6, 11, 3, 1);
    virtualDisplay.rect(21, 11, 2, 1);
    virtualDisplay.rect(7, 12, 3, 1);
    virtualDisplay.rect(20, 12, 2, 1);
    virtualDisplay.rect(8, 13, 13, 1);
}

// Variant 2: Fatter version of E
void drawVariantE2() {
    virtualDisplay.rect(7,0,16,1);
    virtualDisplay.rect(6,1,3,1);
    virtualDisplay.rect(22,1,2,1);
    virtualDisplay.rect(5,2,3,1);
    virtualDisplay.rect(22,2,2,1);
    virtualDisplay.rect(4,3,3,1);
    virtualDisplay.rect(12,3,6,1);
    virtualDisplay.rect(22,3,2,1);
    virtualDisplay.rect(4,4,2,1);
    virtualDisplay.rect(11,4,7,1);
    virtualDisplay.rect(22,4,2,1);
    virtualDisplay.rect(4,5,2,1);
    virtualDisplay.rect(11,5,6,1);
    virtualDisplay.rect(22,5,2,1);
    virtualDisplay.rect(4,6,2,1);
    virtualDisplay.rect(21,6,3,1);
    virtualDisplay.rect(4,7,2,1);
    virtualDisplay.rect(20,7,3,1);
    virtualDisplay.rect(4,8,2,1);
    virtualDisplay.rect(10,8,12,1);
    virtualDisplay.rect(4,9,2,1);
    virtualDisplay.rect(11,9,10,1);
    virtualDisplay.rect(4,10,3,1);
    virtualDisplay.rect(23,10,2,1);
    virtualDisplay.rect(5,11,3,1);
    virtualDisplay.rect(22,11,2,1);
    virtualDisplay.rect(6,12,3,1);
    virtualDisplay.rect(21,12,2,1);
    virtualDisplay.rect(7,13,15,1);

}

// Variant 3: Fatter version of E
void drawVariantE3() {
    virtualDisplay.rect(6,0,18,1);
    virtualDisplay.rect(5,1,3,1);
    virtualDisplay.rect(23,1,2,1);
    virtualDisplay.rect(4,2,3,1);
    virtualDisplay.rect(23,2,2,1);
    virtualDisplay.rect(3,3,3,1);
    virtualDisplay.rect(12,3,5,1);
    virtualDisplay.rect(23,3,2,1);
    virtualDisplay.rect(3,4,2,1);
    virtualDisplay.rect(11,4,6,1);
    virtualDisplay.rect(23,4,2,1);
    virtualDisplay.rect(3,5,2,1);
    virtualDisplay.rect(11,5,5,1);
    virtualDisplay.rect(23,5,2,1);
    virtualDisplay.rect(3,6,2,1);
    virtualDisplay.rect(22,6,3,1);
    virtualDisplay.rect(3,7,2,1);
    virtualDisplay.rect(21,7,3,1);
    virtualDisplay.rect(3,8,2,1);
    virtualDisplay.rect(8,8,2,1);
    virtualDisplay.rect(20,8,3,1);
    virtualDisplay.rect(3,9,2,1);
    virtualDisplay.rect(9,9,13,1);
    virtualDisplay.rect(3,10,3,1);
    virtualDisplay.rect(24,10,2,1);
    virtualDisplay.rect(4,11,3,1);
    virtualDisplay.rect(23,11,2,1);
    virtualDisplay.rect(5,12,3,1);
    virtualDisplay.rect(22,12,2,1);
    virtualDisplay.rect(6,13,17,1);

}

// Variant 4: Fattest version of E
void drawVariantE4() {
    virtualDisplay.rect(5,0,20,1);
    virtualDisplay.rect(4,1,3,1);
    virtualDisplay.rect(23,1,3,1);
    virtualDisplay.rect(3,2,3,1);
    virtualDisplay.rect(24,2,2,1);
    virtualDisplay.rect(2,3,3,1);
    virtualDisplay.rect(13,3,3,1);
    virtualDisplay.rect(24,3,2,1);
    virtualDisplay.rect(2,4,2,1);
    virtualDisplay.rect(12,4,4,1);
    virtualDisplay.rect(24,4,2,1);
    virtualDisplay.rect(2,5,2,1);
    virtualDisplay.rect(12,5,3,1);
    virtualDisplay.rect(24,5,2,1);
    virtualDisplay.rect(2,6,2,1);
    virtualDisplay.rect(7,6,1,1);
    virtualDisplay.rect(23,6,3,1);
    virtualDisplay.rect(2,7,2,1);
    virtualDisplay.rect(7,7,2,1);
    virtualDisplay.rect(22,7,3,1);
    virtualDisplay.rect(2,8,2,1);
    virtualDisplay.rect(8,8,2,1);
    virtualDisplay.rect(21,8,3,1);
    virtualDisplay.rect(2,9,2,1);
    virtualDisplay.rect(9,9,14,1);
    virtualDisplay.rect(2,10,3,1);
    virtualDisplay.rect(25,10,2,1);
    virtualDisplay.rect(3,11,3,1);
    virtualDisplay.rect(24,11,2,1);
    virtualDisplay.rect(4,12,3,1);
    virtualDisplay.rect(23,12,2,1);
    virtualDisplay.rect(5,13,19,1);

  
  }
  
// Variant 1: Original letter F
void drawVariantF1() {
    virtualDisplay.rect(0,0,16,1);
    virtualDisplay.rect(21,0,7,1);
    virtualDisplay.rect(0,1,15,1);
    virtualDisplay.rect(22,1,6,1);
    virtualDisplay.rect(0,2,14,1);
    virtualDisplay.rect(16,2,4,1);
    virtualDisplay.rect(22,2,6,1);
    virtualDisplay.rect(0,3,14,1);
    virtualDisplay.rect(16,3,4,1);
    virtualDisplay.rect(22,3,6,1);
    virtualDisplay.rect(0,4,13,1);
    virtualDisplay.rect(15,4,6,1);
    virtualDisplay.rect(22,4,6,1);
    virtualDisplay.rect(0,5,13,1);
    virtualDisplay.rect(15,5,13,1);
    virtualDisplay.rect(0,6,8,1);
    virtualDisplay.rect(19,6,9,1);
    virtualDisplay.rect(0,7,9,1);
    virtualDisplay.rect(18,7,10,1);
    virtualDisplay.rect(0,8,11,1);
    virtualDisplay.rect(13,8,15,1);
    virtualDisplay.rect(0,9,11,1);
    virtualDisplay.rect(13,9,15,1);
    virtualDisplay.rect(0,10,6,1);
    virtualDisplay.rect(7,10,3,1);
    virtualDisplay.rect(12,10,16,1);
    virtualDisplay.rect(0,11,6,1);
    virtualDisplay.rect(8,11,2,1);
    virtualDisplay.rect(12,11,16,1);
    virtualDisplay.rect(0,12,6,1);
    virtualDisplay.rect(11,12,17,1);
    virtualDisplay.rect(0,13,7,1);
    virtualDisplay.rect(10,13,18,1);


}

// Variant 2: Fatter version of F
void drawVariantF2() {
    virtualDisplay.rect(0,0,14,1);
    virtualDisplay.rect(22,0,6,1);
    virtualDisplay.rect(0,1,14,1);
    virtualDisplay.rect(23,1,5,1);
    virtualDisplay.rect(0,2,13,1);
    virtualDisplay.rect(18,2,3,1);
    virtualDisplay.rect(23,2,5,1);
    virtualDisplay.rect(0,3,13,1);
    virtualDisplay.rect(17,3,4,1);
    virtualDisplay.rect(23,3,5,1);
    virtualDisplay.rect(0,4,12,1);
    virtualDisplay.rect(16,4,6,1);
    virtualDisplay.rect(23,4,5,1);
    virtualDisplay.rect(0,5,12,1);
    virtualDisplay.rect(16,5,6,1);
    virtualDisplay.rect(23,5,5,1);
    virtualDisplay.rect(0,6,7,1);
    virtualDisplay.rect(19,6,9,1);
    virtualDisplay.rect(0,7,8,1);
    virtualDisplay.rect(18,7,10,1);
    virtualDisplay.rect(0,8,10,1);
    virtualDisplay.rect(14,8,14,1);
    virtualDisplay.rect(0,9,5,1);
    virtualDisplay.rect(6,9,4,1);
    virtualDisplay.rect(14,9,14,1);
    virtualDisplay.rect(0,10,5,1);
    virtualDisplay.rect(6,10,3,1);
    virtualDisplay.rect(13,10,15,1);
    virtualDisplay.rect(0,11,5,1);
    virtualDisplay.rect(7,11,2,1);
    virtualDisplay.rect(13,11,15,1);
    virtualDisplay.rect(0,12,5,1);
    virtualDisplay.rect(12,12,16,1);
    virtualDisplay.rect(0,13,6,1);
    virtualDisplay.rect(11,13,17,1);



}

// Variant 3: Fatter version of F
void drawVariantF3() {
    virtualDisplay.rect(0,0,15,1);
    virtualDisplay.rect(23,0,5,1);
    virtualDisplay.rect(0,1,14,1);
    virtualDisplay.rect(24,1,4,1);
    virtualDisplay.rect(0,2,13,1);
    virtualDisplay.rect(19,2,3,1);
    virtualDisplay.rect(24,2,4,1);
    virtualDisplay.rect(0,3,13,1);
    virtualDisplay.rect(18,3,4,1);
    virtualDisplay.rect(24,3,4,1);
    virtualDisplay.rect(0,4,12,1);
    virtualDisplay.rect(17,4,6,1);
    virtualDisplay.rect(24,4,4,1);
    virtualDisplay.rect(0,5,12,1);
    virtualDisplay.rect(17,5,6,1);
    virtualDisplay.rect(24,5,4,1);
    virtualDisplay.rect(0,6,6,1);
    virtualDisplay.rect(21,6,7,1);
    virtualDisplay.rect(0,7,7,1);
    virtualDisplay.rect(20,7,8,1);
    virtualDisplay.rect(0,8,4,1);
    virtualDisplay.rect(5,8,4,1);
    virtualDisplay.rect(15,8,13,1);
    virtualDisplay.rect(0,9,4,1);
    virtualDisplay.rect(5,9,4,1);
    virtualDisplay.rect(15,9,13,1);
    virtualDisplay.rect(0,10,4,1);
    virtualDisplay.rect(6,10,2,1);
    virtualDisplay.rect(14,10,14,1);
    virtualDisplay.rect(0,11,4,1);
    virtualDisplay.rect(6,11,2,1);
    virtualDisplay.rect(14,11,14,1);
    virtualDisplay.rect(0,12,4,1);
    virtualDisplay.rect(13,12,15,1);
    virtualDisplay.rect(0,13,5,1);
    virtualDisplay.rect(12,13,16,1);


}

// Variant 4: Fattest version of F
void drawVariantF4() {
    virtualDisplay.rect(0,0,14,1);
    virtualDisplay.rect(24,0,4,1);
    virtualDisplay.rect(0,1,13,1);
    virtualDisplay.rect(25,1,3,1);
    virtualDisplay.rect(0,2,12,1);
    virtualDisplay.rect(20,2,2,1);
    virtualDisplay.rect(25,2,3,1);
    virtualDisplay.rect(0,3,12,1);
    virtualDisplay.rect(19,3,4,1);
    virtualDisplay.rect(25,3,3,1);
    virtualDisplay.rect(0,4,11,1);
    virtualDisplay.rect(18,4,5,1);
    virtualDisplay.rect(25,4,3,1);
    virtualDisplay.rect(0,5,11,1);
    virtualDisplay.rect(18,5,6,1);
    virtualDisplay.rect(25,5,3,1);
    virtualDisplay.rect(0,6,5,1);
    virtualDisplay.rect(23,6,1,1);
    virtualDisplay.rect(25,6,3,1);
    virtualDisplay.rect(0,7,3,1);
    virtualDisplay.rect(4,7,2,1);
    virtualDisplay.rect(22,7,6,1);
    virtualDisplay.rect(0,8,3,1);
    virtualDisplay.rect(4,8,4,1);
    virtualDisplay.rect(16,8,12,1);
    virtualDisplay.rect(0,9,3,1);
    virtualDisplay.rect(5,9,3,1);
    virtualDisplay.rect(16,9,12,1);
    virtualDisplay.rect(0,10,3,1);
    virtualDisplay.rect(5,10,2,1);
    virtualDisplay.rect(15,10,13,1);
    virtualDisplay.rect(0,11,3,1);
    virtualDisplay.rect(15,11,13,1);
    virtualDisplay.rect(0,12,3,1);
    virtualDisplay.rect(14,12,14,1);
    virtualDisplay.rect(0,13,4,1);
    virtualDisplay.rect(13,13,15,1);

  
  }
  
// Variant 1: Original letter G
void drawVariantG1() {
    virtualDisplay.rect(13,0,5,1);
    virtualDisplay.rect(11,1,8,1);
    virtualDisplay.rect(10,2,10,1);
    virtualDisplay.rect(9,3,11,1);
    virtualDisplay.rect(9,4,5,1);
    virtualDisplay.rect(18,4,2,1);
    virtualDisplay.rect(8,5,5,1);
    virtualDisplay.rect(19,5,1,1);
    virtualDisplay.rect(8,6,4,1);
    virtualDisplay.rect(8,7,4,1);
    virtualDisplay.rect(18,7,3,1);
    virtualDisplay.rect(8,8,5,1);
    virtualDisplay.rect(19,8,1,1);
    virtualDisplay.rect(9,9,5,1);
    virtualDisplay.rect(18,9,2,1);
    virtualDisplay.rect(9,10,11,1);
    virtualDisplay.rect(10,11,10,1);
    virtualDisplay.rect(11,12,8,1);
    virtualDisplay.rect(13,13,5,1);


}

// Variant 2: Fatter version of G
void drawVariantG2() {
    virtualDisplay.rect(11,0,9,1);
    virtualDisplay.rect(9,1,12,1);
    virtualDisplay.rect(8,2,14,1);
    virtualDisplay.rect(7,3,15,1);
    virtualDisplay.rect(7,4,5,1);
    virtualDisplay.rect(20,4,2,1);
    virtualDisplay.rect(6,5,5,1);
    virtualDisplay.rect(21,5,1,1);
    virtualDisplay.rect(6,6,4,1);
    virtualDisplay.rect(6,7,4,1);
    virtualDisplay.rect(20,7,3,1);
    virtualDisplay.rect(6,8,5,1);
    virtualDisplay.rect(21,8,1,1);
    virtualDisplay.rect(7,9,5,1);
    virtualDisplay.rect(20,9,2,1);
    virtualDisplay.rect(7,10,15,1);
    virtualDisplay.rect(8,11,14,1);
    virtualDisplay.rect(9,12,12,1);
    virtualDisplay.rect(11,13,9,1);



}

// Variant 3: Fatter version of G
void drawVariantG3() {
    virtualDisplay.rect(9,0,13,1);
    virtualDisplay.rect(7,1,16,1);
    virtualDisplay.rect(6,2,18,1);
    virtualDisplay.rect(5,3,19,1);
    virtualDisplay.rect(5,4,5,1);
    virtualDisplay.rect(22,4,2,1);
    virtualDisplay.rect(4,5,5,1);
    virtualDisplay.rect(23,5,1,1);
    virtualDisplay.rect(4,6,4,1);
    virtualDisplay.rect(4,7,4,1);
    virtualDisplay.rect(22,7,3,1);
    virtualDisplay.rect(4,8,5,1);
    virtualDisplay.rect(23,8,1,1);
    virtualDisplay.rect(5,9,5,1);
    virtualDisplay.rect(22,9,2,1);
    virtualDisplay.rect(5,10,19,1);
    virtualDisplay.rect(6,11,18,1);
    virtualDisplay.rect(7,12,16,1);
    virtualDisplay.rect(9,13,13,1);


}

// Variant 4: Fattest version of G
void drawVariantG4() {
    virtualDisplay.rect(7,0,17,1);
    virtualDisplay.rect(5,1,20,1);
    virtualDisplay.rect(4,2,22,1);
    virtualDisplay.rect(3,3,23,1);
    virtualDisplay.rect(3,4,5,1);
    virtualDisplay.rect(24,4,2,1);
    virtualDisplay.rect(2,5,5,1);
    virtualDisplay.rect(25,5,1,1);
    virtualDisplay.rect(2,6,4,1);
    virtualDisplay.rect(2,7,4,1);
    virtualDisplay.rect(24,7,3,1);
    virtualDisplay.rect(2,8,5,1);
    virtualDisplay.rect(25,8,1,1);
    virtualDisplay.rect(3,9,5,1);
    virtualDisplay.rect(24,9,2,1);
    virtualDisplay.rect(3,10,23,1);
    virtualDisplay.rect(4,11,22,1);
    virtualDisplay.rect(5,12,20,1);
    virtualDisplay.rect(7,13,17,1);

  
  }
  
  
// Variant 1: Original letter H
void drawVariantH1() {
    virtualDisplay.rect(0,0,5,1);
    virtualDisplay.rect(11,0,6,1);
    virtualDisplay.rect(23,0,5,1);
    virtualDisplay.rect(0,1,6,1);
    virtualDisplay.rect(11,1,6,1);
    virtualDisplay.rect(22,1,6,1);
    virtualDisplay.rect(0,2,8,1);
    virtualDisplay.rect(12,2,4,1);
    virtualDisplay.rect(20,2,8,1);
    virtualDisplay.rect(0,3,9,1);
    virtualDisplay.rect(13,3,2,1);
    virtualDisplay.rect(19,3,9,1);
    virtualDisplay.rect(0,4,10,1);
    virtualDisplay.rect(13,4,2,1);
    virtualDisplay.rect(18,4,10,1);
    virtualDisplay.rect(0,5,10,1);
    virtualDisplay.rect(13,5,2,1);
    virtualDisplay.rect(18,5,10,1);
    virtualDisplay.rect(0,6,10,1);
    virtualDisplay.rect(18,6,10,1);
    virtualDisplay.rect(0,7,10,1);
    virtualDisplay.rect(18,7,10,1);
    virtualDisplay.rect(0,8,10,1);
    virtualDisplay.rect(13,8,2,1);
    virtualDisplay.rect(18,8,10,1);
    virtualDisplay.rect(0,9,10,1);
    virtualDisplay.rect(13,9,2,1);
    virtualDisplay.rect(18,9,10,1);
    virtualDisplay.rect(0,10,9,1);
    virtualDisplay.rect(13,10,2,1);
    virtualDisplay.rect(19,10,9,1);
    virtualDisplay.rect(0,11,8,1);
    virtualDisplay.rect(12,11,4,1);
    virtualDisplay.rect(20,11,8,1);
    virtualDisplay.rect(0,12,6,1);
    virtualDisplay.rect(11,12,6,1);
    virtualDisplay.rect(22,12,6,1);
    virtualDisplay.rect(0,13,5,1);
    virtualDisplay.rect(11,13,6,1);
    virtualDisplay.rect(23,13,5,1);


}

// Variant 2: Fatter version of H
void drawVariantH2() {
    virtualDisplay.rect(0,0,3,1);
    virtualDisplay.rect(10,0,8,1);
    virtualDisplay.rect(25,0,3,1);
    virtualDisplay.rect(0,1,4,1);
    virtualDisplay.rect(10,1,8,1);
    virtualDisplay.rect(24,1,4,1);
    virtualDisplay.rect(0,2,6,1);
    virtualDisplay.rect(11,2,6,1);
    virtualDisplay.rect(22,2,6,1);
    virtualDisplay.rect(0,3,7,1);
    virtualDisplay.rect(12,3,4,1);
    virtualDisplay.rect(21,3,7,1);
    virtualDisplay.rect(0,4,7,1);
    virtualDisplay.rect(12,4,4,1);
    virtualDisplay.rect(21,4,7,1);
    virtualDisplay.rect(0,5,8,1);
    virtualDisplay.rect(12,5,4,1);
    virtualDisplay.rect(20,5,8,1);
    virtualDisplay.rect(0,6,8,1);
    virtualDisplay.rect(20,6,8,1);
    virtualDisplay.rect(0,7,8,1);
    virtualDisplay.rect(20,7,8,1);
    virtualDisplay.rect(0,8,8,1);
    virtualDisplay.rect(12,8,4,1);
    virtualDisplay.rect(20,8,8,1);
    virtualDisplay.rect(0,9,7,1);
    virtualDisplay.rect(12,9,4,1);
    virtualDisplay.rect(21,9,7,1);
    virtualDisplay.rect(0,10,7,1);
    virtualDisplay.rect(12,10,4,1);
    virtualDisplay.rect(21,10,7,1);
    virtualDisplay.rect(0,11,6,1);
    virtualDisplay.rect(11,11,6,1);
    virtualDisplay.rect(22,11,6,1);
    virtualDisplay.rect(0,12,4,1);
    virtualDisplay.rect(10,12,8,1);
    virtualDisplay.rect(24,12,4,1);
    virtualDisplay.rect(0,13,3,1);
    virtualDisplay.rect(10,13,8,1);
    virtualDisplay.rect(25,13,3,1);



}

// Variant 3: Fatter version of H
void drawVariantH3() {
    virtualDisplay.rect(9,0,10,1);
    virtualDisplay.rect(0,1,3,1);
    virtualDisplay.rect(10,1,8,1);
    virtualDisplay.rect(25,1,3,1);
    virtualDisplay.rect(0,2,5,1);
    virtualDisplay.rect(11,2,6,1);
    virtualDisplay.rect(23,2,5,1);
    virtualDisplay.rect(0,3,6,1);
    virtualDisplay.rect(11,3,6,1);
    virtualDisplay.rect(22,3,6,1);
    virtualDisplay.rect(0,4,6,1);
    virtualDisplay.rect(12,4,4,1);
    virtualDisplay.rect(22,4,6,1);
    virtualDisplay.rect(0,5,7,1);
    virtualDisplay.rect(12,5,4,1);
    virtualDisplay.rect(21,5,7,1);
    virtualDisplay.rect(0,6,7,1);
    virtualDisplay.rect(21,6,7,1);
    virtualDisplay.rect(0,7,7,1);
    virtualDisplay.rect(21,7,7,1);
    virtualDisplay.rect(0,8,7,1);
    virtualDisplay.rect(12,8,4,1);
    virtualDisplay.rect(21,8,7,1);
    virtualDisplay.rect(0,9,6,1);
    virtualDisplay.rect(12,9,4,1);
    virtualDisplay.rect(22,9,6,1);
    virtualDisplay.rect(0,10,6,1);
    virtualDisplay.rect(11,10,6,1);
    virtualDisplay.rect(22,10,6,1);
    virtualDisplay.rect(0,11,5,1);
    virtualDisplay.rect(11,11,6,1);
    virtualDisplay.rect(23,11,5,1);
    virtualDisplay.rect(0,12,3,1);
    virtualDisplay.rect(10,12,8,1);
    virtualDisplay.rect(25,12,3,1);
    virtualDisplay.rect(9,13,10,1);


}

// Variant 4: Fattest version of H
void drawVariantH4() {
    virtualDisplay.rect(9,0,10,1);
    virtualDisplay.rect(9,1,10,1);
    virtualDisplay.rect(0,2,3,1);
    virtualDisplay.rect(10,2,8,1);
    virtualDisplay.rect(25,2,3,1);
    virtualDisplay.rect(0,3,4,1);
    virtualDisplay.rect(10,3,8,1);
    virtualDisplay.rect(24,3,4,1);
    virtualDisplay.rect(0,4,4,1);
    virtualDisplay.rect(11,4,6,1);
    virtualDisplay.rect(24,4,4,1);
    virtualDisplay.rect(0,5,5,1);
    virtualDisplay.rect(11,5,6,1);
    virtualDisplay.rect(23,5,5,1);
    virtualDisplay.rect(0,6,5,1);
    virtualDisplay.rect(23,6,5,1);
    virtualDisplay.rect(0,7,5,1);
    virtualDisplay.rect(23,7,5,1);
    virtualDisplay.rect(0,8,5,1);
    virtualDisplay.rect(11,8,6,1);
    virtualDisplay.rect(23,8,5,1);
    virtualDisplay.rect(0,9,4,1);
    virtualDisplay.rect(11,9,6,1);
    virtualDisplay.rect(24,9,4,1);
    virtualDisplay.rect(0,10,4,1);
    virtualDisplay.rect(10,10,8,1);
    virtualDisplay.rect(24,10,4,1);
    virtualDisplay.rect(0,11,3,1);
    virtualDisplay.rect(10,11,8,1);
    virtualDisplay.rect(25,11,3,1);
    virtualDisplay.rect(9,12,10,1);
    virtualDisplay.rect(9,13,10,1);

  
  }
  
// Variant 1: Original letter I
void drawVariantI1() {
    virtualDisplay.rect(14,1,2,1);
    virtualDisplay.rect(14,2,2,1);
    virtualDisplay.rect(14,4,2,1);
    virtualDisplay.rect(13,5,3,1);
    virtualDisplay.rect(13,6,2,1);
    virtualDisplay.rect(13,7,2,1);
    virtualDisplay.rect(13,8,2,1);
    virtualDisplay.rect(13,9,2,1);
    virtualDisplay.rect(13,10,2,1);
    virtualDisplay.rect(12,11,3,1);
    virtualDisplay.rect(12,12,2,1);


}

// Variant 2: Fatter version of I
void drawVariantI2() {
    virtualDisplay.rect(12,1,5,1);
    virtualDisplay.rect(12,2,5,1);
    virtualDisplay.rect(12,4,5,1);
    virtualDisplay.rect(11,5,6,1);
    virtualDisplay.rect(11,6,5,1);
    virtualDisplay.rect(11,7,5,1);
    virtualDisplay.rect(11,8,5,1);
    virtualDisplay.rect(11,9,5,1);
    virtualDisplay.rect(11,10,5,1);
    virtualDisplay.rect(10,11,6,1);
    virtualDisplay.rect(10,12,5,1);

}

// Variant 3: Fatter version of I
void drawVariantI3() {
    virtualDisplay.rect(8,1,2,1);
    virtualDisplay.rect(11,1,7,1);
    virtualDisplay.rect(19,1,3,1);
    virtualDisplay.rect(8,2,2,1);
    virtualDisplay.rect(11,2,7,1);
    virtualDisplay.rect(19,2,3,1);
    virtualDisplay.rect(8,4,2,1);
    virtualDisplay.rect(11,4,7,1);
    virtualDisplay.rect(19,4,3,1);
    virtualDisplay.rect(7,5,15,1);
    virtualDisplay.rect(7,6,2,1);
    virtualDisplay.rect(10,6,7,1);
    virtualDisplay.rect(18,6,3,1);
    virtualDisplay.rect(7,7,2,1);
    virtualDisplay.rect(10,7,7,1);
    virtualDisplay.rect(18,7,3,1);
    virtualDisplay.rect(7,8,2,1);
    virtualDisplay.rect(10,8,7,1);
    virtualDisplay.rect(18,8,3,1);
    virtualDisplay.rect(7,9,2,1);
    virtualDisplay.rect(10,9,7,1);
    virtualDisplay.rect(18,9,3,1);
    virtualDisplay.rect(7,10,2,1);
    virtualDisplay.rect(10,10,7,1);
    virtualDisplay.rect(18,10,3,1);
    virtualDisplay.rect(6,11,3,1);
    virtualDisplay.rect(10,11,7,1);
    virtualDisplay.rect(18,11,3,1);
    virtualDisplay.rect(6,12,2,1);
    virtualDisplay.rect(9,12,7,1);
    virtualDisplay.rect(17,12,3,1);
}

// Variant 4: Fattest version of I
void drawVariantI4() {
    virtualDisplay.rect(8,1,2,1);
    virtualDisplay.rect(12,1,2,1);
    virtualDisplay.rect(16,1,2,1);
    virtualDisplay.rect(20,1,2,1);
    virtualDisplay.rect(8,2,2,1);
    virtualDisplay.rect(12,2,2,1);
    virtualDisplay.rect(16,2,2,1);
    virtualDisplay.rect(20,2,2,1);
    virtualDisplay.rect(8,4,2,1);
    virtualDisplay.rect(12,4,2,1);
    virtualDisplay.rect(16,4,2,1);
    virtualDisplay.rect(20,4,2,1);
    virtualDisplay.rect(7,5,3,1);
    virtualDisplay.rect(11,5,3,1);
    virtualDisplay.rect(15,5,3,1);
    virtualDisplay.rect(19,5,3,1);
    virtualDisplay.rect(7,6,2,1);
    virtualDisplay.rect(11,6,2,1);
    virtualDisplay.rect(15,6,2,1);
    virtualDisplay.rect(19,6,2,1);
    virtualDisplay.rect(7,7,2,1);
    virtualDisplay.rect(11,7,2,1);
    virtualDisplay.rect(15,7,2,1);
    virtualDisplay.rect(19,7,2,1);
    virtualDisplay.rect(7,8,2,1);
    virtualDisplay.rect(11,8,2,1);
    virtualDisplay.rect(15,8,2,1);
    virtualDisplay.rect(19,8,2,1);
    virtualDisplay.rect(7,9,2,1);
    virtualDisplay.rect(11,9,2,1);
    virtualDisplay.rect(15,9,2,1);
    virtualDisplay.rect(19,9,2,1);
    virtualDisplay.rect(7,10,2,1);
    virtualDisplay.rect(11,10,2,1);
    virtualDisplay.rect(15,10,2,1);
    virtualDisplay.rect(19,10,2,1);
    virtualDisplay.rect(6,11,3,1);
    virtualDisplay.rect(10,11,3,1);
    virtualDisplay.rect(14,11,3,1);
    virtualDisplay.rect(18,11,3,1);
    virtualDisplay.rect(6,12,2,1);
    virtualDisplay.rect(10,12,2,1);
    virtualDisplay.rect(14,12,2,1);
    virtualDisplay.rect(18,12,2,1);

  
  }
  
// Variant 1: Original letter J
void drawVariantJ1() {
    virtualDisplay.rect(8, 0, 14, 1);

}

// Variant 2: Fatter version of J
void drawVariantJ2() {
    virtualDisplay.rect(7,0,16,1);


}

// Variant 3: Fatter version of J
void drawVariantJ3() {
    virtualDisplay.rect(6,0,18,1);

}

// Variant 4: Fattest version of J
void drawVariantJ4() {
    virtualDisplay.rect(5,0,20,1);
  
  }
  
  
// Variant 1: Original letter K
void drawVariantK1() {
    virtualDisplay.rect(8, 0, 14, 1);

}

// Variant 2: Fatter version of K
void drawVariantK2() {
    virtualDisplay.rect(7,0,16,1);


}

// Variant 3: Fatter version of K
void drawVariantK3() {
    virtualDisplay.rect(6,0,18,1);

}

// Variant 4: Fattest version of K
void drawVariantK4() {
    virtualDisplay.rect(5,0,20,1);
  
  }
