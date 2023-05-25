#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <ESP8266WiFi.h>
#define SERVER_PORT 80

ESP8266WebServer server(SERVER_PORT);

void routes()
{
  server.on("/test", handleTest);
  server.on("/restart", handleReset);
  server.on("/run/water_pump", handleRunWaterPump);
  server.on("/wifi/update_setting", handleWifiUpdateSetting);
  server.on("/wifi/reset_setting", handleWifiResetSetting);
}

void createHttpServer() {
  routes();
  server.begin();
  debug("HTTP server started");
}

void listen()
{
  server.handleClient();
  MDNS.update();
}

bool validate(int typeMethod)
{
  if (server.method() != typeMethod) {
    String message = "{\"status\":\"ERROR\", \"message\": \"Request method not supported\"}";
    server.send(400, "application/json", message);
    
    return false;
  }

  return true;
}

void handleTest() 
{ 
  String message = "{\"status\":\"OK\"}";
  server.send(200, "application/json", message);
}

void handleRunWaterPump() 
{
  if (server.method() != HTTP_POST) {
    String message = "{\"status\":\"ERROR\", \"message\": \"Request method not supported\"}";
    server.send(400, "application/json", message);
    return;
  }

  String microsecondsParam = server.arg("microseconds");
  int microseconds = microsecondsParam.toInt();

  debug("run at microseconds:" + microseconds);

  if (microseconds <= 0) {
    String message = "{\"status\":\"ERROR\", \"message\": \"Microseconds must be greater than 0\"}";
    server.send(200, "application/json", message);
    return;
  }

  String message = "{\"status\":\"OK\", \"message\": \"Water pump start\"}";
  server.send(200, "application/json", message); 

  runWaterPump(microseconds);
}

void handleWifiUpdateSetting() 
{
  if (server.method() != HTTP_POST) {
    String message = "{\"status\":\"ERROR\", \"message\": \"Request method not supported\"}";
    server.send(400, "application/json", message);
    return;
  }

  String ssid = server.arg("ssid");
  String password = server.arg("password");

  setSettings(ssid, password);

  String message = "{\"status\":\"OK\", \"message\": \"Settings is saved\"}";
  server.send(200, "application/json", message); 

}

void handleWifiResetSetting() 
{
  if (server.method() != HTTP_DELETE) {
    String message = "{\"status\":\"ERROR\", \"message\": \"Request method not supported\"}";
    server.send(400, "application/json", message);
    return;
  }

  resetSettings();

  String message = "{\"status\":\"OK\", \"message\": \"Settings is reset\"}";
  server.send(200, "application/json", message); 
} 

void handleReset() 
{
  if (!validate(HTTP_GET)) {
    return;
  }

  String message = "{\"status\":\"OK\", \"message\": \"Device is reset\"}";
  server.send(200, "application/json", message); 

  restart();
} 
