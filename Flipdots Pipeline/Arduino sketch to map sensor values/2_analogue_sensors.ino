int sensor1Pin = A0; // Pin connected to sensor 1
int sensor2Pin = A1; // Pin connected to sensor 2

void setup() {
  Serial.begin(9600); // Start serial communication at 9600 bps
}

void loop() {
  int sensor1Value = analogRead(sensor1Pin); // Read sensor 1 value
  int sensor2Value = analogRead(sensor2Pin); // Read sensor 2 value

  // Send the sensor values separated by a comma
  Serial.print(sensor1Value*10);
  Serial.print(",");
  Serial.println(sensor2Value*10);

  delay(100); // Delay for 100ms
}

