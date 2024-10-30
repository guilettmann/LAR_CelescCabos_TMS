#include <esp_sleep.h>  
#include <math.h>

#define adcInputPin A0
#define adcMaxResolution 4095
#define upperResist 100000
#define thermistorNominalResist 100000
#define nominalTemp 298.15  // Kelvin (25°C)
#define beta 3950
#define LEDBuiltIn 8  // LED integrado no GPIO 8

#define WINDOW_SIZE 10  // Tamanho da janela para média móvel

float tempReadings[WINDOW_SIZE];  // Array para armazenar as leituras
int currentIndex = 0;  // Índice atual no array
bool isInitialized = false;  // Flag para inicialização das leituras

// Função para calcular a média das últimas N leituras
float movingAverage() {
  float sum = 0;
  for (int i = 0; i < WINDOW_SIZE; i++) {
    sum += tempReadings[i];
  }
  return sum / WINDOW_SIZE;
}

void readTemp() {
  float rawAdcVal = analogRead(adcInputPin);

  // Verificar leitura válida do ADC
  if (rawAdcVal <= 0) {
    Serial.println("ADC error: No valid reading");
    return;
  }

  float voltage = (3.3 * rawAdcVal) / adcMaxResolution;

  // Verificar divisão por zero
  if (voltage >= 3.3) {
    Serial.println("Voltage out of range");
    return;
  }

  float thermistorResist = (voltage * upperResist) / (3.3 - voltage);
  float tempK = 1 / (1 / nominalTemp + log(thermistorResist / thermistorNominalResist) / beta);
  float tempC = tempK - 273.15;

  // Inicializa o array com a primeira leitura válida
  if (!isInitialized) {
    for (int i = 0; i < WINDOW_SIZE; i++) {
      tempReadings[i] = tempC;
    }
    isInitialized = true;
  }

  // Armazenar a nova leitura no array
  tempReadings[currentIndex] = tempC;
  currentIndex = (currentIndex + 1) % WINDOW_SIZE;  // Incrementar o índice circularmente

  float avgTempC = movingAverage();  // Calcular a média móvel

  Serial.print("Average Temperature: ");
  Serial.print(avgTempC);
  Serial.println(" °C");

  // Ativar LED se a média móvel for maior que 40°C
  if (avgTempC > 40) {
    digitalWrite(LEDBuiltIn, HIGH);
  } else {
    digitalWrite(LEDBuiltIn, LOW);
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(LEDBuiltIn, OUTPUT);
}

void loop() {
  readTemp();
  delay(1000);  // Espera de 1 segundo entre leituras

  // Configuração do deep sleep (comentada para teste)
  // esp_sleep_enable_timer_wakeup(1000000);  // Acordar após 1 segundo
  // esp_deep_sleep_start();  // Entrar em deep sleep
}
