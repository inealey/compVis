
// Receive with start- and end-markers combined with parsing
// 

const byte numChars = 32;
char receivedChars[numChars];
char tempChars[numChars];        // temporary array for use when parsing

// variables to hold the parsed data
char messageFromPC[numChars] = {0};
float floatFromPC = 0.0;

// pin assignments
const int inKnob = A0;
const int ctrl1 = 3;
const int ctrl2 = 9;
const int ctrl3 = 10;
const int ctrl4 = 11;

float input, inverse, ctrlVal[4];

boolean newData = false;

//============

void setup() {
    // init analog and PWM pins
    pinMode(inKnob, INPUT);
    pinMode(ctrl1, OUTPUT);
    pinMode(ctrl2, OUTPUT);
    pinMode(ctrl3, OUTPUT);
    pinMode(ctrl4, OUTPUT);
    
    // init serial
    Serial.begin(9600);

    // pull down ctrl pins
    for(int i = 0; i < 4; i++) {
      ctrlVal[i] = 0;
    }
    
    Serial.println("This script expects 2 pieces of data - text and a floating point value");
    Serial.println("Enter data in this style <text, 0.76>  ");
    Serial.println();
}

//============

void loop() {
    // read knob
    input = float(analogRead(inKnob)) / 682;
    if( input >= 0.95 ) { input = 0.99; }
    inverse = 1 - input;
    
    recvWithStartEndMarkers();
    if (newData == true) {
        strcpy(tempChars, receivedChars);
            // this temporary copy is necessary to protect the original data
            //   because strtok() used in parseData() replaces the commas with \0
        parseData();
        //showParsedData();
        assignParsedData();
        newData = false;
    }

    // write out to pins
    analogWrite(ctrl1, ctrlVal[0]);
    analogWrite(ctrl2, ctrlVal[1]);
    analogWrite(ctrl3, ctrlVal[2]);
    //analogWrite(ctrl4, ctrlVal[3]);
    //Serial.println(inverse * 168);
    analogWrite(ctrl4, inverse * 168);
}

//============

void recvWithStartEndMarkers() {
    static boolean recvInProgress = false;
    static byte ndx = 0;
    char startMarker = '<';
    char endMarker = '>';
    char rc;

    while (Serial.available() > 0 && newData == false) {
        rc = Serial.read();

        if (recvInProgress == true) {
            if (rc != endMarker) {
                receivedChars[ndx] = rc;
                ndx++;
                if (ndx >= numChars) {
                    ndx = numChars - 1;
                }
            }
            else {
                receivedChars[ndx] = '\0'; // terminate the string
                recvInProgress = false;
                ndx = 0;
                newData = true;
            }
        }

        else if (rc == startMarker) {
            recvInProgress = true;
        }
    }
}

//============

void parseData() {      // split the data into its parts

    char * strtokIndx; // this is used by strtok() as an index

    strtokIndx = strtok(tempChars,",");      // get the first part - the string
    strcpy(messageFromPC, strtokIndx); // copy it to messageFromPC

    strtokIndx = strtok(NULL, ",");
    floatFromPC = atof(strtokIndx);     // convert this part to a float

}

//============

void assignParsedData() {
  if( strcmp(messageFromPC, "one" ) == 0 ) { ctrlVal[0] = (1 - floatFromPC) * 168; }
  else if( strcmp(messageFromPC, "two" ) == 0 ) { ctrlVal[1] = (1 - floatFromPC) * 168; }
  else if( strcmp(messageFromPC, "three" ) == 0 ) { ctrlVal[2] = (1 - floatFromPC) * 168; }
  //else if( strcmp(messageFromPC, "four" ) == 0 ) { ctrlVal[3] = (1 - floatFromPC) * 168; }
}

//============

void showParsedData() {
    Serial.print("Label: ");
    Serial.println(messageFromPC);
    Serial.print("Value: ");
    Serial.println(floatFromPC);
    //Serial.println((1 - floatFromPC) * 168);
    Serial.println();
}
