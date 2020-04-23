import controlP5.*; 
import processing.serial.*;
import java.util.Arrays;

ControlP5 cp5;
Serial serial;
PGraphics pg;

PFont font;
PImage transporterImg;
PImage transporterImg1;
PImage transporterImg2;
PImage transporterImg3;

int frame1 = 0;
int frame2 = 0;
int frame3 = 0;

Textarea textarea;
int received;
short output = 0;

//Объявление кнопок и задание их глобальных параметров
color colorInactiveBtn = color(0,100,200);
color colorActiveBtn = (color(0,50,100));
color colorLockedBtn = color(100);

Button btnTransp1;
int btnTransp1_xPos = 200;
int btnTransp1_yPos = 60;
int btnTransp1_width = 90;
int btnTransp1_height = 40;
//boolean isPressed_Transp1 = false;

Button btnTransp2;
int btnTransp2_xPos = 200;
int btnTransp2_yPos = 105;
int btnTransp2_width = 90;
int btnTransp2_height = 40;
//boolean isPressed_Transp2 = false;

Button btn_demo;
int btnDemo_xPos = 300;
int btnDemo_yPos = 105;
int btnDemo_width = 90;
int btnDemo_height = 40;
boolean manualControl = true;

Button btn_failureReset;
int btnFRes_xPos = 400;
int btnFRes_yPos = 105;
int btnFRes_width = 90;
int btnFRes_height = 40;
boolean failure = false;

//Параметры объекта
int liftY = 200;
int liftX = 0;
int grabX = 0;
int max_y = 200;
int min_y = 60;
int max_x = 100;
int min_x = 0;
int liftDelay = 10;
float angle = 10 ;
Loader loader;

//Датчики положения
boolean K1,K2,K3,K4,K5,K6,K7,K8;

//Шаги
boolean stepCargo1 = false;
boolean stepCargo2 = false;
boolean stepWait = true;
  
Cargo cargo1, cargo2;


//Инициализация объектов программы
void setup()
{
  loader = new Loader(liftX, liftY, grabX, min_x, max_x, min_y, max_y, angle, liftDelay);
  cargo1 = new Cargo(80,60);
  cargo2 = new Cargo(80,130);
    
  transporterImg = loadImage("Transporter.png");
  transporterImg1 = loadImage("Transporter1.png");
  transporterImg2 = loadImage("Transporter2.png");
  transporterImg3 = loadImage("Transporter3.png");
  pg = createGraphics(680,300);
  cp5 = new ControlP5(this);
  font = createFont("calibri", 17);     
  
  //Задание параметров окна    
  surface.setTitle("Обмен данными");
  size(800, 550);
  background(200, 200, 200); 
  fill(10, 10, 100);               
  textFont(font);
  frameRate(60);
  
  //Настройка порта для обмена данными
  String port = "COM4";
  serial = new Serial(this,port, 9600);
  
  println(port);
    
  //Создание кнопок
  btnTransp1 = cp5.addButton("Лента 1")     
    .setPosition(btnTransp1_xPos, btnTransp1_yPos)  
    .setSize(btnTransp1_width, btnTransp1_height)      
    .setFont(font)
    .setColorBackground(colorInactiveBtn); 
    
  btnTransp2 = cp5.addButton("Лента 2")     
    .setPosition(btnTransp2_xPos, btnTransp2_yPos)  
    .setSize(btnTransp2_width, btnTransp2_height)      
    .setFont(font)
    .setColorBackground(colorInactiveBtn);  
   
  btn_demo = cp5.addButton("Демо реж.")     
    .setPosition(btnDemo_xPos, btnDemo_yPos)  
    .setSize(btnDemo_width, btnDemo_height)      
    .setFont(font)
    .setColorBackground(colorInactiveBtn);  
  
  btn_failureReset = cp5.addButton("Сброс ош.")     
    .setPosition(btnFRes_xPos, btnFRes_yPos)  
    .setSize(btnFRes_width, btnFRes_height)      
    .setFont(font)
    .setColorBackground(colorLockedBtn);  
    
  //Создание текстового поля вывода  
  textarea = cp5.addTextarea("txt")
                  .setPosition(10,30)
                  .setSize(110,30)
                  .setFont(createFont("arial",20))
                  .setLineHeight(20)
                  .hideScrollbar()
                  .setColor(color(128))
                  .setColorBackground(color(255,100));
                        
  text("Состояние входов",5,20);
  text("Подать\nсигнал",215,20);
 
  line(190,10,190,160);
  
  //Датчик достижения макс. высоты
  fill(color(150,0,0));
  rect(70,180,10,10);
  //Датчик активации захвата
  fill(color(0,150,0));
  rect(85,180,10,10);
}


void draw()
{  
  if(serial.available() > 0)
  {   
     received = serial.read();
     textarea.setText(ToBinary(received,8));     
  }

//Кнопки--------------------------------    
  //Аварийный режим
  if(failure)
  {
    fill(color(255,0,0));
    text("АВАРИЯ!!", 500, 150); 
    
    btnTransp1.setColorBackground(colorLockedBtn);  
    btnTransp2.setColorBackground(colorLockedBtn);  
    btn_demo.setColorBackground(colorLockedBtn);  
    btn_failureReset.setColorBackground(colorInactiveBtn);  
        
    if (btn_failureReset.isPressed())
    {
      btnTransp1.setColorBackground(colorInactiveBtn);  
      btnTransp2.setColorBackground(colorInactiveBtn);  
      btn_demo.setColorBackground(colorInactiveBtn);  
      btn_failureReset.setColorBackground(colorLockedBtn);  
      
      failure = false;
      cargo1.Reset();
      cargo2.Reset();
    }
  }  
  //Штатный режим
  else
  {
    stroke(color(200));
    fill(color(200));
    rect(500,150,100,-20);

    if(manualControl)
    {
      //Подача груза на ленту К7
      if (btnTransp1.isPressed() && !cargo1.isActive)
      {
        btnTransp1.setColorBackground(colorLockedBtn);
        cargo1.isActive = true;    
      }
      
      //Подача груза на ленту К7
      if (btnTransp2.isPressed() && !cargo2.isActive)
      {
        btnTransp2.setColorBackground(colorLockedBtn);
        cargo2.isActive = true;
      }
      
      //Активация демо-режима
      if (btn_demo.isPressed())
      {   
        manualControl = false;
        btn_demo.setColorBackground(colorLockedBtn);
        btnTransp1.setColorBackground(colorLockedBtn);
        btnTransp2.setColorBackground(colorLockedBtn);
        
        loader.Reset();
        cargo1.Reset();
        cargo2.Reset();        
            
        stroke(color(0));
        fill(color(150,0,0));
        rect(70,180,10,10);
        
        cargo1.isActive = true;
        cargo2.isActive = true;
      }        
    }
        
    //Сброс демо-режима
    if(!cargo1.isActive & !cargo2.isActive & !manualControl)
    {
       manualControl = true;
       btn_demo.setColorBackground(colorInactiveBtn);
       btnTransp1.setColorBackground(colorInactiveBtn);
       btnTransp2.setColorBackground(colorInactiveBtn);
      
       loader.Reset();
       cargo1.Reset();
       cargo2.Reset();
    }     
     
    //Сообщение о включении демо-режима                
    if(!manualControl)
    {
      fill(color(255,0,0));
      text("РЕЖИМ ДЕМОНСТРАЦИИ", 500, 100);  
    }  
    else
    {
      stroke(color(200));
      fill(color(200));
      rect(500,105,400,-25);
    }
  }
  
  //Датчик активации захвата
  stroke(color(0));
  if(loader.grabActive)
  {
    fill(color(0,230,0));
    rect(85,180,10,10);   
  }
  else
  {
      fill(color(0,150,0));
      rect(85,180,10,10);   
  }
//Управление+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //От контроллера-------------------------------------------------------------------   
    //Подъем погрузчика
  if(manualControl) 
  {
    //Штатный режим
    if(!failure)
    {
      //Поднятие погрузчика и срабатывание датчика достижения макс. высоты
      if((received & 1) == 1)
      {
         loader.RaiseUp();
         if(K3)
           fill(color(255,0,0));
         else
           fill(color(150,0,0));
         
         stroke(color(0,0,0));
         rect(70,180,10,10);         
      }
      
      //Опускание погрузчика
      if((received & 2) == 2)
         loader.PutDown();
      
      //Выдвижение захвата
      if((received & 4) == 4) 
         loader.PutForward();
      
      //Возврат захвата
      if((received & 8) == 8) 
         loader.PushIn();
        
      //Активация Захвата
      if((received & 16) == 16) 
         loader.grabActive = true;
      else
         loader.grabActive = false;
    }     
                    
    //Лента K6
    if(cargo1.isActive)
    {           
      if(!failure)
      {      
        if(loader.grabActive & ((cargo1.xPos < -25 & K3 & K5 & !cargo2.isGrabbed) | cargo1.isGrabbed))
          cargo1.Follow(loader.grabX - 125, loader.liftY);
        else if(!(loader.grabActive & K3 & K5) && cargo1.xPos <= -30)      
          failure = true;
          
        if((received | 223) == 223 & cargo1.yPos == cargo1.startY)
          cargo1.xPos--;   
        
        if(cargo1.yPos == 200 && cargo1.xPos > -30)
          cargo1.isDelivered = true;
            
        if((received | 127) == 127 & cargo1.isDelivered & !loader.grabActive)
        {
          cargo1.xPos++;
          cargo1.isGrabbed = false;
        }
        
        if(K8 && cargo1.isDelivered)
        {
          cargo1.Reset();
          btnTransp1.setColorBackground(colorInactiveBtn);
        }
      }
    }
      
    //Лента K7
    if(cargo2.isActive)
    {     
      if(!failure)
      {      
        if(loader.grabActive & ((cargo2.xPos < -25 & K2 & K5 & !cargo1.isGrabbed) | cargo2.isGrabbed))
          cargo2.Follow(loader.grabX - 125, loader.liftY);
        else if(!(loader.grabActive & K2 & K5) && cargo2.xPos <= -30) 
          failure = true;
        
        if((received | 191) == 191 && cargo2.yPos == cargo2.startY)
            cargo2.xPos--; 
        
        if(cargo2.yPos == 200 && cargo2.xPos > -30)
          cargo2.isDelivered = true;
            
        if((received | 127) == 127 && cargo2.isDelivered)
        {
          cargo2.xPos++;
          cargo1.isGrabbed = false;
        }
             
        if(K8 && cargo2.isDelivered & !loader.grabActive)
        {
          cargo2.Reset();
          btnTransp2.setColorBackground(colorInactiveBtn);
        }
      } 
    }
    
    //Авария
    if(failure)
    {
      if(loader.grabActive)
      {
        if(!cargo1.isGrabbed && cargo1.xPos <= -30)
          cargo1.yPos += 2;
        if(!cargo2.isGrabbed && cargo2.xPos <= -30)
          cargo2.yPos += 2;    
      }  
      else
      { 
        if(cargo1.xPos <= -30)
          cargo1.yPos += 2;
        
        if(cargo2.xPos <= -30)
          cargo2.yPos += 2;
      } 
    }   
  }    
  //Демо-режим-------------------------------------------------------------------
  else
  {
    //Переходим в шаг ожидания по умлочанию, оттуда по ситуации на остальные шаги
    StepWait();
    println(stepWait);
    //Верхняя лента (К6)   
    if(cargo1.isActive)
    {            
      //Движение груза                  
      if((!K6 & !loader.grabActive & !cargo1.isDelivered))
        cargo1.xPos--;      
      else if(K3 && K5 & !loader.grabActive)
        cargo1.xPos--;
                                
      if(loader.grabActive && !stepCargo2)
        cargo1.Follow(loader.grabX - 125, loader.liftY);
      
      if(cargo1.isDelivered)
      {
        cargo1.xPos++;
        loader.grabActive = false;
      }  
      
      if(K8 && cargo1.isDelivered)
      {
        cargo1.Reset();
      }
    }
    
    //Нижнияя лента(К7)
    if(cargo2.isActive)
    {  
      //Движение груза                   
      if((!K7 & !loader.grabActive & !cargo2.isDelivered))
        cargo2.xPos--;      
      else if(K2 && K5 & !loader.grabActive)
        cargo2.xPos--;
                                
      if(loader.grabActive && !stepCargo1)
        cargo2.Follow(loader.grabX - 125, loader.liftY);
          
      if(K1 & K5 & loader.grabActive)
        cargo2.isDelivered = true;        
      
      if(cargo2.isDelivered)
      {
        cargo2.xPos++;
        loader.grabActive = false;
      }  
      
      if(K8 && cargo2.isDelivered)
      {
        cargo2.Reset();
      }
    }
  }
  
  //Отображение объекта+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  pg.beginDraw();
    pg.background(230);
    pg.stroke(110);
    
   //Конвейеры----------------------------------------------------------------------
    //Конвейер 1
    pg.translate(520,0);
    pg.line(0,60,100,60);
    pg.line(0,76,100,76);   
        
    //Конвейер 2
    pg.line(0,130,100,130);
    pg.line(0,146,100,146);
    
    //Конвейер 3
    pg.line(0,200,100,200);
    pg.line(0,216,100,216);
   
    //Анимаци вращения лент
    if(manualControl)
    {
      if((received | 223) == 223)
        frame1 = pgTransporterAnimL(-8,60,frame1);
      else
        pg.image(transporterImg,-8,60);
        
      if((received | 191) == 191)
        frame2 = pgTransporterAnimL(-8,130,frame2);
      else
        pg.image(transporterImg,-8,130);
        
      if((received | 127) == 127)
        frame3 = pgTransporterAnimR(-8,200,frame3);
      else
        pg.image(transporterImg,-8,200);        
    }
    else
    {
      if(!K6)
        frame1 = pgTransporterAnimL(-8,60,frame1);
      else
        pg.image(transporterImg,-8,60);
        
      if(!K7)
        frame2 = pgTransporterAnimL(-8,130,frame2);
      else
        pg.image(transporterImg,-8,130);
        
      frame3 = pgTransporterAnimR(-8,200,frame3);
    }   
             
   //Грузы-------------------------------------------------------------------------
    //Груз 1 (лента К6)
    pg.fill(180,0,0);
    if(cargo1.isActive)
    {
      pg.rect(cargo1.xPos, cargo1.yPos,20,-15);    
    }
    
    //Груз 2 (лента К7)
    if(cargo2.isActive)
    {
      pg.rect(cargo2.xPos, cargo2.yPos,20,-15);    
    }
    
    pg.translate(-520,0);
    
   //Датчики------------------------------------------------------------------------
    //K1
    if(loader.liftY == max_y)
    {
      pg.fill(255,255,0);
      K1 = true; 
    }
    else
    {
      pg.fill(255,119,0);
      K1 = false;
    }
    pg.rect(10,192,20,16);
    pg.line(30,200,300,200);
    pg.fill(0);
    pg.text("K1",13,205);
    
    //K2
    if(loader.liftY == (max_y + min_y)/2)
    {
      pg.fill(255,255,0);
      K2 = true; 
    }
    else
    {
      pg.fill(255,119,0);
      K2 = false;
    }
    pg.rect(10,122,20,16);
    pg.line(30,130,300,130);
    pg.fill(0);
    pg.text("K2",13,135);
    
    //K3
    if(loader.liftY == min_y)
    {
      pg.fill(255,255,0);
      K3 = true; 
    }
    else
    {
      pg.fill(255,119,0);
      K3 = false;
    }
    pg.rect(10,52,20,16);
    pg.line(30,60,300,60);
    pg.fill(0);
    pg.text("K3",13,65);
    
    //K4
    if(loader.grabX == min_x)
    {
      pg.fill(255,255,0);
      K4 = true; 
    }
    else
    {
      pg.fill(255,119,0);
      K4 = false;
    }
    pg.rect(90,10,20,16);
    pg.line(100,27,100,250);
    pg.fill(0);
    pg.text("K4",93,23);
    
    //K5
    if(loader.grabX == max_x)
    {
      pg.fill(255,255,0);
      K5 = true; 
    }
    else
    {
      pg.fill(255,119,0);
      K5 = false;
    }
    pg.rect(90 + max_x,10,20,16);
    pg.line(100 + max_x,27,100 + max_x,250);
    pg.fill(0);
    pg.text("K5",93 + max_x,23);
    
    //K6
    if(cargo1.xPos == -10 & cargo1.yPos == 60)
    {
      pg.fill(255,255,0);
      K6 = true; 
    }
    else
    {
      pg.fill(255,119,0);
      K6 = false;
    }
    pg.rect(420 + max_x,15,20,16);
    pg.fill(0);
    pg.text("K6",423 + max_x,28);
    
    //K7
    if(cargo2.xPos == -10 & cargo2.yPos == 130)
    {
      pg.fill(255,255,0);
      K7 = true; 
    }
    else
    {
      pg.fill(255,119,0);
      K7 = false;
    }
    pg.rect(420 + max_x,90,20,16);
    pg.fill(0);
    pg.text("K7",423 + max_x,103);
    
    //K8
    if(cargo1.xPos > 80 | cargo2.xPos > 80)
    {
      pg.fill(255,255,0);
      K8 = true; 
    }
    else
    {
      pg.fill(255,119,0);
      K8 = false;
    }
    pg.rect(500 + max_x,160,20,16);
    pg.fill(0);
    pg.text("K8",503 + max_x,173);
        
   //Погрузчик-------------------------------------------------------------------          
    //Основание    
    pg.fill(150);
    pg.rect(60, loader.liftY, 260, 20);
    
    //Захват
    pg.rect(100 + loader.grabX, loader.liftY - 15, 260, 15);
    
    pg.beginShape();
    pg.vertex(340 + loader.grabX, loader.liftY - 15);
    pg.vertex(410 + loader.grabX, loader.liftY - 15);
    pg.vertex(340 + loader.grabX, loader.liftY - 30);
    pg.endShape();
    
    pg.beginShape();
    pg.vertex(340 + loader.grabX, loader.liftY);
    pg.vertex(410 + loader.grabX, loader.liftY);
    pg.vertex(340 + loader.grabX, loader.liftY + 15);
    pg.endShape();
    
    //Опоры
    pg.translate(10 + loader.liftX,250);
    pg.rotate(-loader.angle/57.3);
    pg.rect(0, 0, 240, 10);
     
    pg.rotate(loader.angle/57.3);
    pg.translate(360 - 2*loader.liftX,0);
    pg.rotate(loader.angle/57.3);
    pg.rect(0, 0, -240, 10);
        
  pg.endDraw();
  
  image(pg, 60, 200); 
           
  serial.write(output);
  delay(50);
}


//Проверка вхождения курсора мыши в границы кнопки
boolean overRect(int x, int y, int width, int height)  
{
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) 
      return true;
  else 
    return false;  
}

//Анимация лент (движение вправо), возвращает номер фрейма анимации
int pgTransporterAnimR(int x, int y, int frame)
{
  switch(frame)
  {
    case 0:{
      pg.image(transporterImg,x,y);
      frame++;
      break;
    }
     case 1:{
      pg.image(transporterImg1,x,y);
      frame++;
      break;
    }   
     case 2:{
      pg.image(transporterImg2,x,y);
      frame++;
      break;
    }
     case 3:{
      pg.image(transporterImg3,x,y);
      frame = 0;
      break;
    }
     default: break;
  }
  return frame;
}
//Движение влево
int pgTransporterAnimL(int x, int y, int frame)
{
  switch(frame)
  {
    case 0:{
      pg.image(transporterImg3,x,y);
      frame++;
      break;
    }
     case 1:{
      pg.image(transporterImg2,x,y);
      frame++;
      break;
    }   
     case 2:{
      pg.image(transporterImg1,x,y);
      frame++;
      break;
    }
     case 3:{
      pg.image(transporterImg,x,y);
      frame = 0;
      break;
    }
     default: break;
  }
  return frame;
}


//Преобразование строки заданной длины в двоичнное число
String ToBinary(int x, int len)
{
  char[] buffer = new char[len];
  
  for(int i = len-1; i >= 0; i--)
  {
    int mask = 1 << i;
    buffer[len - 1-i] = (x & mask) != 0 ? '1' : '0';
  }  
return new String(buffer); 
}


//Класс погрузчика
class Loader
{
  private int liftY;
  private int liftX;
  private int grabX;
  private int min_x;
  private int max_x;
  private int min_y;
  private int max_y;
  private float angle;
  private int liftDelay;
  private boolean grabActive;
  
  Loader(int liftX,int liftY, int grabX, int min_x, int max_x, int min_y, int max_y, float angle, int liftDelay)
  {
    this.liftY = liftY;
    this.liftX = liftX;
    this.grabX = grabX;
    this.min_x = min_x;
    this.max_x = max_x;
    this.min_y = min_y;
    this.max_y = max_y;
    this.angle = angle;
    this.liftDelay = liftDelay;
    this.grabActive = false;
  }
  
  public void RaiseUp()
  {
    if(liftY > min_y)
    {
      liftY--;
      liftX++;
      angle += 0.275/(liftDelay * 0.1);
      delay(liftDelay);
    }
  }
  
  public void PutDown()
  {
    if(liftY < max_y)
    {
      liftY++;  
      liftX--;
      angle -= 0.275/(liftDelay * 0.1);
      delay(liftDelay);
    }
  }
  
  public void PutForward()
  {
    if(grabX < max_x)   
      grabX++;
  }

  public void PushIn()
  {
    if(grabX > min_x)   
      grabX--;
  }     

  public void Reset()
  {
    this.grabActive = false;
    this.liftX = 0;
    this.liftY = 200;
    this.grabX = 0;
    this.angle = 10;    
  }
}


//Класс груза
class Cargo
{
 private int startX;
 private int startY;
 public int xPos;
 public int yPos;
 public boolean isDelivered;
 public boolean isActive;
 public boolean isGrabbed;
 
 Cargo(int startX, int startY)
 {
   this.startX = startX;
   this.startY = startY;
   this.xPos = startX;
   this.yPos = startY;
   this.isDelivered = false;
   this.isActive = false;
   this.isGrabbed = false;
 }
 
 public void Reset()
 {
   this.xPos = this.startX;
   this.yPos = this.startY;
   this.isDelivered = false;
   this.isActive = false;
   this.isGrabbed = false;
 }

 public void Follow(int x,int y)
 {
   this.xPos = x;
   this.yPos = y;
   this.isGrabbed = true;
 } 
} 

//Шаги (для управления автоматикой)++++++++++++++++++++++++++++++++++++++++++++++++++
//Доставка груза 1 с лнты К6 на ленту К8
void stepDeliverCargo1()
{  
  if(cargo1.isDelivered)
  {
    stepCargo1 = false;
    if(!K4 | !K1)
    {
      stepWait = true;
      StepWait();
    }   
  }    
  else if(K6)
  {
    if(!K3)
      loader.RaiseUp();
    else if(!K5)
      loader.PutForward();
    else
      loader.grabActive = true;
  }  
  else if(loader.grabActive)
  {
    if(!K4 && K3)
      loader.PushIn();
    else if(!K1)
      loader.PutDown();
    else if(!K5)
      loader.PutForward();
    else if(K1 && K5)
      cargo1.isDelivered = true;   
  }   
}

//Доставка груза 2 с лнты К7 на ленту К8
void stepDeliverCargo2()
{  
  if(cargo2.isDelivered)
  {
    stepCargo2 = false;
    if(!K4 | !K1)
    {
      stepWait = true;
      StepWait();
    }  
  }   
  else if(K7)
  {
    if(!K2)
      loader.RaiseUp();
    else if(!K5)
      loader.PutForward();
    else
      loader.grabActive = true;
  } 
  else if(loader.grabActive)
  {
    if(!K4 && K2)
      loader.PushIn();
    else if(!K1)
      loader.PutDown();
    else if(!K5)
      loader.PutForward();
    else if(K1 && K5)
      cargo2.isDelivered = true;    
  }  
}

//Ожидание, возарвщение погрузчика в исходное положение
void StepWait()
{
  if(stepWait)
  {
    if(K1 & K4)
      stepWait = false;        
    else
    {
      if(!K1)
        loader.PutDown();
      if(!K4)
        loader.PushIn();
    }
  }  
  else
  {
    if(K6 && !stepCargo2)
        stepCargo1 = true;
    if(stepCargo1)
      stepDeliverCargo1();
    
    if(K7 && !stepCargo1)
       stepCargo2 = true;
    if(stepCargo2)    
      stepDeliverCargo2();
  }
}
