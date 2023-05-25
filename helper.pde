#define DEBUG true

void debug(String message) 
{
  if (DEBUG == false) {
    return;
  }
  
  Serial.println(message);  
} 
