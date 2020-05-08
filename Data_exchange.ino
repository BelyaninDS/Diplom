int received;
int output;

#define outPin_0 11
#define outPin_1 12

#define inPin_0 2
#define inPin_1 3
#define inPin_2 4
#define inPin_3 5
#define inPin_4 6
#define inPin_5 7
#define inPin_6 8
#define inPin_7 9



//Установка входов и выходов
void setup() 
{
  pinMode(outPin_0,OUTPUT);
  pinMode(outPin_1,OUTPUT);
  
  pinMode(inPin_0,INPUT);
  pinMode(inPin_1,INPUT);
  pinMode(inPin_2,INPUT);
  pinMode(inPin_3,INPUT);
  pinMode(inPin_4,INPUT);
  pinMode(inPin_5,INPUT);
  pinMode(inPin_6,INPUT);
  pinMode(inPin_7,INPUT);
  
  Serial.begin(9600);
}


void loop()
//Чтение данных 
{
  if (Serial.available() > 0) 
      received = Serial.read();
  
  //Анализ принятых данных и установка выходов    
  if((received & 1) == 1) 
    digitalWrite(outPin_0,HIGH);
  else if((received & 1) == 0)  
    digitalWrite(outPin_0,LOW);


  if((received & 2) == 2) 
    digitalWrite(outPin_1,HIGH);
  else if((received & 2) == 0)  
    digitalWrite(outPin_1,LOW);

    
  //Запись данных в массив перед отправкой
  if(digitalRead(inPin_0) == LOW)
    output &= 254;    
  else if(digitalRead(inPin_0) == HIGH)
    output |= 1;  

  if(digitalRead(inPin_1) == LOW)
    output &= 253;    
  else if(digitalRead(inPin_1) == HIGH)
    output |= 2;    

  if(digitalRead(inPin_2) == LOW)
    output &= 251;    
  else if(digitalRead(inPin_2) == HIGH)
    output |= 4;   

  if(digitalRead(inPin_3) == LOW)
    output &= 247;    
  else if(digitalRead(inPin_3) == HIGH)
    output |= 8;   

  if(digitalRead(inPin_4) == LOW)
    output &= 239;    
  else if(digitalRead(inPin_4) == HIGH)
    output |= 16;   
     
  if(digitalRead(inPin_5) == LOW)
    output &= 223;    
  else if(digitalRead(inPin_5) == HIGH)
    output |= 32;     

  if(digitalRead(inPin_6) == LOW)
    output &= 191;    
  else if(digitalRead(inPin_6) == HIGH)
    output |= 64;   
     
  if(digitalRead(inPin_7) == LOW)
    output &= 127;    
  else if(digitalRead(inPin_7) == HIGH)
    output |= 128;   

  //Отправка данных
  if (Serial.available() > 0)
  { 
    Serial.write(output);
   
    delay(50); 
  }     
}
