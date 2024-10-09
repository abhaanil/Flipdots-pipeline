PImage img; 
int cols = 28;  // Number of columns in the grid
int rows = 14;  // Number of rows in the grid
float cellSize = 36.8;  // Size of each grid cell
float circleSize = 35.6;  // Circle size 

PrintWriter output;

void setup() {
  size(1037, 523); // Size of images
  
  output = createWriter("animation.txt");
  
  // Loop through all images 
  for (int i = 1; i <= 71; i++) {
    loadImageAndAnalyze(i);
  }
  noLoop();  // Stop the draw loop since we're not using it
  
  output.flush();
  output.close();
}

void loadImageAndAnalyze(int imageIndex) {
  String imageName = "naanchawal_WIP_" + imageIndex + ".png";
  img = loadImage(imageName); // Load the current image
  image(img, 0, 0, width, height); // Display the image
  
  output.println("// Variant " + imageIndex + ": Vaibhav");
  output.println("void drawVariantA" + imageIndex + "() {");
  analyzeImage();  // Analyze the image for active circles
  output.println("}");
  output.println();
}

void analyzeImage() {
  for (int y = 0; y < rows; y++) {
    int startCol = -1;
    int count = 0;
    
    for (int x = 0; x < cols; x++) {
      int imgX = int(x * cellSize + cellSize / 2);
      int imgY = int(y * cellSize + cellSize / 2);
      
      color c = img.get(imgX, imgY);

      if (brightness(c) > 200) {
        fill(0, 255, 0, 150);
        ellipse(imgX, imgY, circleSize - 5, circleSize - 5);
        
        if (startCol == -1) {
          startCol = x;
        }
        count++;
      } else {
        if (count > 0) {
          output.println("    virtualDisplay.rect(" + startCol + ", " + y + ", " + count + ", 1);");
          startCol = -1;
          count = 0;
        }
      }
    }
    if (count > 0) {
      output.println("    virtualDisplay.rect(" + startCol + ", " + y + ", " + count + ", 1);");
    }
  }
}

void draw() {
  // No continuous drawing needed
}
