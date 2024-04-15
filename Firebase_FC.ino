#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <SoftwareSerial.h>
#include <FirebaseESP32.h>
#include <EEPROM.h>
#include <WiFi.h>
#include <WiFiClient.h>
#include "TickTwo.h"
#include <HTTPClient.h>
#include <ZMPT101B.h>

FirebaseConfig config;
FirebaseAuth auth;

#define WIFI_SSID "***********"  // Wifi Username
#define WIFI_PASSWORD "**********"   // Password
String GOOGLE_SCRIPT_ID = "****************";


const char* host = "script.google.com";
const int httpsPort = 443;

LiquidCrystal_I2C lcd(0x27, 20, 4);


FirebaseData firebaseData;

#define SENSITIVITY 490.0f
ZMPT101B voltageSensor(34, 50.0);

// Variables for energy calculation
float kWh = 0.0;
float lastKWhSent = 0.0;  // Track the last kWh sent for billing
float lastKWhSentfirebase=0.0;
unsigned long lastMillis = 0; // Fix typo: Change "mills()" to "0"
unsigned long previousMillis = 0;
const long intervel=5000;
bool firstRun = true; // Variable to track if it's the first run

// EEPROM addresses for each variable
const int addrVrms = 0;
const int addrIrms = 12;
const int addrPower = 4;
const int addrKWh = 8;

// SIM900A module setup
#define RX_PIN 16
#define TX_PIN 17

SoftwareSerial SerialSIM900A(RX_PIN, TX_PIN); // RX, TX
const char apn[] = "dialogbb";

// Billing rates
const float rateBlock1 = 12.00;
const float rateBlock2 = 30.00;
const float rateBlock3 = 38.00;
const float rateBlock4 = 41.00;
const float rateBlock5 = 59.00;
const float rateBlock6 = 89.00;

// Function prototypes
void sendEnergyDataToFirebase();
void readEnergyDataFromEEPROM();
void saveEnergyDataToEEPROM();
void sendBillSMS();

// timer for sending data to firebase and sms
TickTwo timer1(sendEnergyDataToFirebase,5000);
TickTwo timer2(sendBillSMS,30000);

void setup() {

  Serial.begin(115200);
  delay(1000);

  // wifi Connecting
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  //Firebase
  config.host="*************************";
  config.api_key="******************************";

  auth.user.email = "********************"; // Replace with your email used for Firebase
  auth.user.password = "***************************"; // Replace with your Firebase password

  // Initialize the LCD
  lcd.init();
  lcd.backlight();

  // Setup Firebase
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

   timer1.start();
   timer2.start();

  // Initialize EEPROM with the size of the data to be stored
  EEPROM.begin(32); // Only one float value, kWh


  // Read the stored energy data from EEPROM
  readEnergyDataFromEEPROM();


  // SIM900A module initialization
  SerialSIM900A.begin(9600);
  delay(1000);

  // Connect to the GSM network
  Serial.println("Connecting to GSM network...");
  if (initializeSIM900A()) {
    Serial.println("Connected to GSM network");
  } else {
    Serial.println("Unable to connect to GSM network");
  }
  // A small delay for the system to stabilize
  delay(1000);

  voltageSensor.setSensitivity(SENSITIVITY);
}

void loop() {
   timer1.update();
   timer2.update(); 
}

void sendEnergyDataToFirebase() {

  float voltage = voltageSensor.getRmsVoltage();
  float Irms=calculateIrms(33,2000);
  float Power = voltage*Irms;

  if (voltage < 180 ) {
    voltage=0;
    Irms=0;
    Power=0;
  }

  // Calculate energy consumed in kWh
  unsigned long currentMillis = millis();
  kWh += Power * (currentMillis - lastMillis) / 3600000000.0;
  lastMillis = currentMillis;

  // If the initial kWh is zero, set power to zero
  if (kWh == 0) {
    Power = 0.0;
  }

  // Print data to Serial for debugging
  Serial.printf("Vrms: %.4fV\tIrms: %.4fA\tPower: %.4fW\tkWh: %.5fkWh\n",
                voltage, Irms, Power, kWh);

  // Save the latest values to EEPROM
  saveEnergyDataToEEPROM();

    Firebase.setFloat(firebaseData, "EnergyData/Voltage", voltage);
    Firebase.setFloat(firebaseData, "EnergyData/Current", Irms);
    Firebase.setFloat(firebaseData, "EnergyData/Power", Power);
    Firebase.setFloat(firebaseData, "EnergyData/KWh", kWh);
    float usage = kWh-lastKWhSentfirebase;
    float bill = calculateBill(usage);
    // Firebase update bill in every 5sec
    Firebase.setFloat(firebaseData, "EnergyData/Bill", bill);
    //firebase rest the bill amount in every 1min 
    if(currentMillis-previousMillis>=60000){
      previousMillis=currentMillis;
      bill=0.0;
      lastKWhSentfirebase=kWh;
    }
  
  // Update the LCD with the new values
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Vrms: ");
  lcd.print(voltage, 2);
  lcd.print(" V");

  lcd.setCursor(0, 1);
  lcd.print("Irms: ");
  lcd.print(Irms, 4);
  lcd.print(" A");

  lcd.setCursor(0, 2);
  lcd.print("Power: ");
  lcd.print(Power, 4);
  lcd.print(" W");

  lcd.setCursor(0, 3);
  lcd.print("kWh: ");
  lcd.print(kWh, 5);
  lcd.print(" kWh");
}

// (Remaining functions remain unchanged)
bool initializeSIM900A() {
  // Initialize SIM900A module
  SerialSIM900A.println("AT");
  delay(1000);

  // Set the SIM card APN
  SerialSIM900A.print("AT+CSTT=\"");
  SerialSIM900A.print(apn);
  SerialSIM900A.println("\"");
  delay(2000);

  // Enable GPRS
  SerialSIM900A.println("AT+CIICR");
  delay(2000);

  // Get local IP address
  SerialSIM900A.println("AT+CIFSR");
  delay(1000);

  return true; // You might need to add more checks based on your specific setup
}



void sendBillSMS()
{
  Send data to Spreadsheet
  unsigned long currentMillis = millis();
  
  float usage = kWh-lastKWhSent;
  float billAmount;

  if(currentMillis-previousMillis>=60000){
      previousMillis=currentMillis;
      billAmount=0.0;
      lastKWhSentfirebase=kWh;
    }

  else{
    float billAmount = calculateBill(usage);
  }
  
   String urlFinal = "***********************"+GOOGLE_SCRIPT_ID+"/exec?"+"Kwh="+ String(usage)+"&Amount=" + String(billAmount);
    Serial.print("POST data to spreadsheet:");
    Serial.println(urlFinal);
    HTTPClient http;
    http.begin(urlFinal.c_str());
    http.setFollowRedirects(HTTPC_STRICT_FOLLOW_REDIRECTS);
    int httpCode = http.GET(); 
    Serial.print("HTTP Status Code: ");
    Serial.println(httpCode);
    //getting response from google sheet
    String payload;
    if (httpCode > 0) {
        payload = http.getString();
        Serial.println("Payload: "+payload);    
    }
    http.end();

  
  // Check if the GSM module is connected to the network
  if (isSIM900AConnected()) {
    // Calculate bill amount based on consumption
  float usage = kWh-lastKWhSent;
  float billAmount = calculateBill(usage);
  lastKWhSent=kWh;

  // Send SMS using the SIM900A module
  char message[50];
  snprintf(message, sizeof(message), "Energy Consumed: %.5f kWh\nBill Amount: Rs. %.4f", usage, billAmount);

  sendSMS("****************", message);
  Serial.println("SMS Sent");
  } else {
    Serial.println("GSM not ready, retrying...");
  }

}

bool isSIM900AConnected() {
  // Check if SIM900A is connected to the network
  SerialSIM900A.println("AT+CREG?");
  delay(2000);

  if (SerialSIM900A.find("+CREG: 0,1") || SerialSIM900A.find("+CREG: 0,5")) {
    return true;
  } else {
    return false;
  }
}


float calculateBill(float energyConsumed)
{
  float billAmount = 0.0;

  if (energyConsumed <= 30)
    billAmount = energyConsumed * rateBlock1;
  else if (energyConsumed <= 60)
    billAmount = 30 * rateBlock1 + (energyConsumed - 30) * rateBlock2;
  else if (energyConsumed <= 90)
    billAmount = 30 * rateBlock1 + 30 * rateBlock2 + (energyConsumed - 60) * rateBlock3;
  else if (energyConsumed <= 120)
    billAmount = 30 * rateBlock1 + 30 * rateBlock2 + 30 * rateBlock3 + (energyConsumed - 90) * rateBlock4;
  else if (energyConsumed <= 180)
    billAmount = 30 * rateBlock1 + 30 * rateBlock2 + 30 * rateBlock3 + 30 * rateBlock4 + (energyConsumed - 120) * rateBlock5;
  else
    billAmount = 30 * rateBlock1 + 30 * rateBlock2 + 30 * rateBlock3 + 30 * rateBlock4 + 60 * rateBlock5 + (energyConsumed - 180) * rateBlock6;

  return billAmount;
}

void sendSMS(const char *phoneNumber, const char *message)
{
  // Send SMS using the SIM900A module
  SerialSIM900A.print("AT+CMGF=1\r"); // Set SMS mode to text
  delay(1000);
  
  SerialSIM900A.print("AT+CMGS=\"");
  SerialSIM900A.print(phoneNumber);
  SerialSIM900A.println("\"");
  delay(1000);
  
  SerialSIM900A.print(message);
  delay(100);
  
  SerialSIM900A.write(26); // Send Ctrl+Z to indicate the end of the message
  delay(1000);
}
 
 
void readEnergyDataFromEEPROM()
{
  // Read the stored kWh value from EEPROM
  EEPROM.get(addrKWh, kWh);
 
  // Check if the read value is a valid float. If not, initialize it to zero
  if (isnan(kWh))
  {
    kWh = 0.0;
    saveEnergyDataToEEPROM(); // Save initialized value to EEPROM
  }
}
 
void saveEnergyDataToEEPROM()
{
  // Write the current kWh value to EEPROM
  EEPROM.put(addrKWh, kWh);
  // Commit changes to EEPROM
  EEPROM.commit();
}

String urlEncode(const String &value) {
  String encodedValue = "";
  char c;
  for (size_t i = 0; i < value.length(); i++) {
    c = value.charAt(i);
    if (isAlphaNumeric(c) || c == '-' || c == '.' || c == '_' || c == '~') {
      encodedValue += c;
    } else {
      encodedValue += "%" + String(c, HEX);
    }
  }
  return encodedValue;
}



float calculateIrms(float value, int sampleCount) {
  float mappedValue = 0;
  float sumSquareValue = 0;

  for (int i = 0; i < sampleCount; i++) {
    int sensorValue = analogRead(33);
    float voltage = sensorValue * (3.3 / 4095);
    float dcCurrent = (voltage - 2.38) / 0.1;
    mappedValue = dcCurrent;
    float squreValue = (pow(mappedValue, 2));
    sumSquareValue += squreValue;
    delay(1);
  }
  float result = sqrt(sumSquareValue / sampleCount)-0.088;
  if (result <= 0) {
    return 0;
  } else {
    return result;
  }
}