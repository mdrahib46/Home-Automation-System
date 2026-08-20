#define ENABLE_USER_AUTH
#define ENABLE_DATABASE

#include <Arduino.h>
#include <WiFi.h>
#include <NetworkClientSecure.h>
#include <FirebaseClient.h>
#include <DHT.h>

// =====================================================
// WIFI
// =====================================================

#define WIFI_SSID       "Wifi name"
#define WIFI_PASSWORD   "Wifi Password"

// =====================================================
// FIREBASE
// =====================================================

#define API_KEY         "Firebase APi Key "

#define USER_EMAIL      "Place Your Email Address"
#define USER_PASSWORD   "Place Your User Password"

#define DATABASE_URL    "Database Url"

// =====================================================
// BEDROOM
// =====================================================

#define BEDROOM_FAN_PIN       25
#define BEDROOM_LIGHT_PIN     26

// =====================================================
// BEDROOM FAN RELAY
// =====================================================
//
// Relay CH1:
// IN1  -> GPIO 25
// VCC  -> 5V
// GND  -> GND
//
// FAN POWER:
// 9V (+) -> COM1
// NO1    -> Fan (+)
// 9V (-) -> Fan (-)
//
// IMPORTANT:
// This code uses ACTIVE-HIGH relay logic.
//
// HIGH = Relay ON  = Fan ON
// LOW  = Relay OFF = Fan OFF
// =====================================================

#define RELAY_ON              HIGH
#define RELAY_OFF             LOW

// =====================================================
// LIVING ROOM
// =====================================================

#define LIVING_FAN_PIN        18
#define LIVING_LIGHT_PIN      19

// =====================================================
// KITCHEN
// =====================================================

#define KITCHEN_FAN_PIN       21
#define KITCHEN_LIGHT_PIN     22

// =====================================================
// DHT11
// =====================================================

#define DHT_PIN               4
#define DHT_TYPE              DHT11

// =====================================================
// MQ-5
// =====================================================

#define GAS_SENSOR_PIN        39

#define GAS_THRESHOLD_HIGH    3700
#define GAS_THRESHOLD_LOW     3200

// =====================================================
// BUZZER
// =====================================================

#define BUZZER_PIN            23

// =====================================================
// DHT OBJECT
// =====================================================

DHT dht(DHT_PIN, DHT_TYPE);

// =====================================================
// FIREBASE OBJECTS
// =====================================================

NetworkClientSecure ssl_client;

using AsyncClient = AsyncClientClass;

AsyncClient aClient(ssl_client);

UserAuth user_auth(
        API_KEY,
        USER_EMAIL,
        USER_PASSWORD,
        3000
);

FirebaseApp app;
RealtimeDatabase Database;

// =====================================================
// DEVICE STATES
// =====================================================

// Bedroom
bool bedroomFan = false;
bool bedroomLight = false;

// Living
bool livingFan = false;
bool livingLight = false;

// Kitchen
bool kitchenFan = false;
bool kitchenLight = false;

float globalTemperature = 0.0;
float globalHumidity = 0.0;

int gasValue = 0;
bool gasDetected = false;


unsigned long lastFirebaseRead = 0;
unsigned long lastDHTRead = 0;
unsigned long lastGasRead = 0;

const unsigned long FIREBASE_INTERVAL = 1000;
const unsigned long DHT_INTERVAL = 3000;
const unsigned long GAS_INTERVAL = 1000;


void processData(AsyncResult &result)
{
    if (!result.isResult())
        return;

    if (result.isError())
    {
        Serial.print("Firebase Error: ");
        Serial.println(result.error().message());
        return;
    }

    if (result.available())
    {
        Serial.print("Firebase: ");
        Serial.println(result.c_str());
    }
}


void connectWiFi()
{
    Serial.println();
    Serial.println("Connecting to WiFi...");

    WiFi.begin(
            WIFI_SSID,
            WIFI_PASSWORD
    );

    unsigned long startTime = millis();

    while (
            WiFi.status() != WL_CONNECTED &&
            millis() - startTime < 20000
            )
    {
        delay(500);
        Serial.print(".");
    }

    Serial.println();

    if (WiFi.status() == WL_CONNECTED)
    {
        Serial.println("WiFi connected!");

        Serial.print("IP Address: ");
        Serial.println(WiFi.localIP());
    }
    else
    {
        Serial.println("WiFi connection failed!");
    }
}

// =====================================================
// FIREBASE INITIALIZATION
// =====================================================

void initializeFirebase()
{
    ssl_client.setInsecure();

    initializeApp(
            aClient,
            app,
            getAuth(user_auth),
            processData,
            "authTask"
    );

    app.getApp<RealtimeDatabase>(Database);

    Database.url(DATABASE_URL);

    Serial.println("Firebase initialization started.");
}

// =====================================================
// READ BEDROOM FROM FIREBASE
// =====================================================

void readBedroom()
{
    // ---------------------------------------------------
    // FAN
    // ---------------------------------------------------

    bedroomFan = Database.get<bool>(
            aClient,
            "/smart_home/current_state/rooms/bedroom/devices/fan/status"
    );

    // ---------------------------------------------------
    // LIGHT
    // ---------------------------------------------------

    bedroomLight = Database.get<bool>(
            aClient,
            "/smart_home/current_state/rooms/bedroom/devices/light/status"
    );

    Serial.println();
    Serial.println("========== BEDROOM ==========");

    Serial.print("Fan Firebase Status: ");

    if (bedroomFan)
        Serial.println("ON");
    else
        Serial.println("OFF");

    Serial.print("Light Firebase Status: ");

    if (bedroomLight)
        Serial.println("ON");
    else
        Serial.println("OFF");
}

// =====================================================
// READ LIVING ROOM
// =====================================================

void readLivingRoom()
{
    livingFan = Database.get<bool>(
            aClient,
            "/smart_home/current_state/rooms/living_room/devices/fan/status"
    );

    livingLight = Database.get<bool>(
            aClient,
            "/smart_home/current_state/rooms/living_room/devices/light/status"
    );

    Serial.println();
    Serial.println("======= LIVING ROOM ========");

    Serial.print("Fan: ");
    Serial.println(
            livingFan ? "ON" : "OFF"
    );

    Serial.print("Light: ");
    Serial.println(
            livingLight ? "ON" : "OFF"
    );
}

// =====================================================
// READ KITCHEN
// =====================================================

void readKitchen()
{
    kitchenFan = Database.get<bool>(
            aClient,
            "/smart_home/current_state/rooms/kitchen/devices/fan/status"
    );

    kitchenLight = Database.get<bool>(
            aClient,
            "/smart_home/current_state/rooms/kitchen/devices/light/status"
    );

    Serial.println();
    Serial.println("========== KITCHEN ==========");

    Serial.print("Fan: ");
    Serial.println(
            kitchenFan ? "ON" : "OFF"
    );

    Serial.print("Light: ");
    Serial.println(
            kitchenLight ? "ON" : "OFF"
    );
}

// =====================================================
// APPLY BEDROOM
// =====================================================

void applyBedroom()
{
    // ===================================================
    // BEDROOM FAN RELAY
    // ===================================================

    if (bedroomFan == true)
    {
        // Firebase TRUE
        // Relay ON
        // Fan ON

        digitalWrite(
                BEDROOM_FAN_PIN,
                RELAY_ON
        );

        Serial.println(
                "Bedroom Fan Relay: ON"
        );
    }
    else
    {
        // Firebase FALSE
        // Relay OFF
        // Fan OFF

        digitalWrite(
                BEDROOM_FAN_PIN,
                RELAY_OFF
        );

        Serial.println(
                "Bedroom Fan Relay: OFF"
        );
    }

    // ===================================================
    // BEDROOM LIGHT
    // ===================================================

    digitalWrite(
            BEDROOM_LIGHT_PIN,
            bedroomLight ? HIGH : LOW
    );
}

// =====================================================
// APPLY LIVING ROOM
// =====================================================

void applyLivingRoom()
{
    digitalWrite(
            LIVING_FAN_PIN,
            livingFan ? HIGH : LOW
    );

    digitalWrite(
            LIVING_LIGHT_PIN,
            livingLight ? HIGH : LOW
    );
}

// =====================================================
// APPLY KITCHEN
// =====================================================

void applyKitchen()
{
    digitalWrite(
            KITCHEN_FAN_PIN,
            kitchenFan ? HIGH : LOW
    );

    digitalWrite(
            KITCHEN_LIGHT_PIN,
            kitchenLight ? HIGH : LOW
    );
}

// =====================================================
// READ + APPLY ALL DEVICES
// =====================================================

void readAllRooms()
{
    if (!app.ready())
        return;

    // Read existing Firebase values
    readBedroom();
    readLivingRoom();
    readKitchen();

    // Apply values to hardware
    applyBedroom();
    applyLivingRoom();
    applyKitchen();
}

// =====================================================
// DHT11
// =====================================================

void readDHT11()
{
    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();

    if (
            isnan(humidity) ||
            isnan(temperature)
            )
    {
        Serial.println("DHT11 reading failed!");
        return;
    }

    globalTemperature = temperature;
    globalHumidity = humidity;

    Serial.println();
    Serial.println("======= DHT11 =======");

    Serial.print("Temperature: ");
    Serial.print(globalTemperature);
    Serial.println(" °C");

    Serial.print("Humidity: ");
    Serial.print(globalHumidity);
    Serial.println(" %");
}

// =====================================================
// UPLOAD DHT11
// =====================================================

void uploadDHT11()
{
    if (!app.ready())
        return;

    if (
            isnan(globalTemperature) ||
            isnan(globalHumidity)
            )
    {
        return;
    }

    Database.set<number_t>(
            aClient,
            "/smart_home/current_state/global/sensors/temperature",
            number_t(globalTemperature, 1)
    );

    Database.set<number_t>(
            aClient,
            "/smart_home/current_state/global/sensors/humidity",
            number_t(globalHumidity, 1)
    );
}

// =====================================================
// MQ-5
// =====================================================

void readGasSensor()
{
    gasValue = analogRead(GAS_SENSOR_PIN);

    Serial.println();
    Serial.println("========= MQ-5 =========");

    Serial.print("Gas Value: ");
    Serial.println(gasValue);

    Serial.print("Warning Threshold: ");
    Serial.println(GAS_THRESHOLD_HIGH);

    // ---------------------------------------------------
    // GAS DETECTION
    // ---------------------------------------------------

    if (!gasDetected)
    {
        if (gasValue >= GAS_THRESHOLD_HIGH)
        {
            gasDetected = true;

            digitalWrite(
                    BUZZER_PIN,
                    HIGH
            );

            Serial.println(
                    "!!! GAS LEAKAGE DETECTED !!!"
            );
        }
    }
    else
    {
        if (gasValue <= GAS_THRESHOLD_LOW)
        {
            gasDetected = false;

            digitalWrite(
                    BUZZER_PIN,
                    LOW
            );

            Serial.println(
                    "Gas level returned to normal."
            );
        }
    }

    Serial.print("Gas Status: ");

    if (gasDetected)
        Serial.println("DANGER");
    else
        Serial.println("NORMAL");
}

// =====================================================
// UPLOAD GAS
// =====================================================

void uploadGasData()
{
    if (!app.ready())
        return;

    Database.set<int>(
            aClient,
            "/smart_home/current_state/rooms/kitchen/sensors/gas_value",
            gasValue
    );

    Database.set<bool>(
            aClient,
            "/smart_home/current_state/rooms/kitchen/sensors/gas_detected",
            gasDetected
    );
}

// =====================================================
// SETUP
// =====================================================

void setup()
{
    Serial.begin(115200);

    delay(1000);

    Serial.println();
    Serial.println("======================================");
    Serial.println("       ESP32 SMART HOME");
    Serial.println("       BEDROOM RELAY CONTROL");
    Serial.println("======================================");

    // ===================================================
    // GPIO
    // ===================================================

    pinMode(
            BEDROOM_FAN_PIN,
            OUTPUT
    );

    pinMode(
            BEDROOM_LIGHT_PIN,
            OUTPUT
    );

    pinMode(
            LIVING_FAN_PIN,
            OUTPUT
    );

    pinMode(
            LIVING_LIGHT_PIN,
            OUTPUT
    );

    pinMode(
            KITCHEN_FAN_PIN,
            OUTPUT
    );

    pinMode(
            KITCHEN_LIGHT_PIN,
            OUTPUT
    );

    pinMode(
            BUZZER_PIN,
            OUTPUT
    );

    pinMode(
            GAS_SENSOR_PIN,
            INPUT
    );

    // ===================================================
    // IMPORTANT:
    // RELAY OFF AT STARTUP
    // ===================================================

    digitalWrite(
            BEDROOM_FAN_PIN,
            RELAY_OFF
    );

    digitalWrite(
            BEDROOM_LIGHT_PIN,
            LOW
    );

    digitalWrite(
            LIVING_FAN_PIN,
            LOW
    );

    digitalWrite(
            LIVING_LIGHT_PIN,
            LOW
    );

    digitalWrite(
            KITCHEN_FAN_PIN,
            LOW
    );

    digitalWrite(
            KITCHEN_LIGHT_PIN,
            LOW
    );

    digitalWrite(
            BUZZER_PIN,
            LOW
    );

    // ===================================================
    // ADC
    // ===================================================

    analogReadResolution(12);

    // ===================================================
    // DHT
    // ===================================================

    dht.begin();

    // ===================================================
    // SERIAL INFORMATION
    // ===================================================

    Serial.println();
    Serial.println("Bedroom Fan Relay:");
    Serial.println("IN1  -> GPIO 25");
    Serial.println("VCC  -> 5V");
    Serial.println("GND  -> GND");
    Serial.println("COM1 -> 9V Battery (+)");
    Serial.println("NO1  -> Fan (+)");
    Serial.println("Fan (-) -> Battery (-)");
    Serial.println();
    Serial.println("Relay Logic: ACTIVE HIGH");
    Serial.println("HIGH = ON");
    Serial.println("LOW  = OFF");

    // ===================================================
    // WIFI
    // ===================================================

    connectWiFi();

    // ===================================================
    // FIREBASE
    // ===================================================

    initializeFirebase();

    Serial.println();
    Serial.println("Waiting for Firebase...");

    unsigned long startTime = millis();

    while (
            !app.ready() &&
            millis() - startTime < 15000
            )
    {
        app.loop();

        delay(100);

        Serial.print(".");
    }

    Serial.println();

    // ===================================================
    // FIREBASE READY
    // ===================================================

    if (app.ready())
    {
        Serial.println(
                "Firebase connected successfully!"
        );

        // Read existing Firebase data
        // DO NOT overwrite device states

        readAllRooms();

        // Sensors

        readDHT11();
        uploadDHT11();

        readGasSensor();
        uploadGasData();
    }
    else
    {
        Serial.println(
                "Firebase connection failed!"
        );
    }

    Serial.println();
    Serial.println("======================================");
    Serial.println("SYSTEM READY");
    Serial.println("======================================");
}

// =====================================================
// LOOP
// =====================================================

void loop()
{
    // Firebase processing
    app.loop();

    // ===================================================
    // WIFI RECONNECT
    // ===================================================

    if (WiFi.status() != WL_CONNECTED)
    {
        Serial.println(
                "WiFi disconnected!"
        );

        connectWiFi();
    }

    // ===================================================
    // FIREBASE DEVICE READ
    // ===================================================

    if (
            millis() - lastFirebaseRead >=
            FIREBASE_INTERVAL
            )
    {
        lastFirebaseRead = millis();

        readAllRooms();
    }

    // ===================================================
    // DHT11
    // ===================================================

    if (
            millis() - lastDHTRead >=
            DHT_INTERVAL
            )
    {
        lastDHTRead = millis();

        readDHT11();
        uploadDHT11();
    }

    // ===================================================
    // GAS
    // ===================================================

    if (
            millis() - lastGasRead >=
            GAS_INTERVAL
            )
    {
        lastGasRead = millis();

        readGasSensor();
        uploadGasData();
    }
}