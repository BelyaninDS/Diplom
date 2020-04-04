import controlP5.*; 
import processing.serial.*;
import java.util.Arrays;

ControlP5 cp5;
Serial serial;
PGraphics pg;

PFont font;
PImage transporterImg;

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

Button btn_manual;
int btnMan_xPos = 300;
int btnMan_yPos = 105;
int btnMan_width = 90;
int btnMan_height = 40;
boolean manualControl = false;

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

//Вспомогательные флаги
boolean grabActive = false;

Timer tmr1, tmr2;
Cargo cargo1, cargo2;

//Инициализация объектов программы
void setup()
{
  loader = new Loader(liftX, liftY, grabX, min_x, max_x, min_y, max_y, angle, liftDelay);
  tmr1 = new Timer(2);  
  tmr2 = new Timer(2);
  cargo1 = new Cargo(80,60);
  cargo2 = new Cargo(80,130);
    
  transporterImg = loadImage("Transporter.png");
  pg = createGraphics(680,300);
  cp5 = new ControlP5(this);
  font = createFont("calibri", 20);     
  
  //Задание параметров окна    
  surface.setTitle("Обмен данными");
  size(800, 650);
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
  
  btn_manual = cp5.addButton("Ручное")     
    .setPosition(btnMan_xPos, btnMan_yPos)  
    .setSize(btnMan_width, btnMan_height)      
    .setFont(font)
    .setColorBackground(colorInactiveBtn);  
  
  //Создание текстового поля вывода  
  textarea = cp5.addTextarea("txt")
                  .setPosition(10,30)
                  .setSize(80,30)
                  .setFont(createFont("arial",20))
                  .setLineHeight(20)
                  .hideScrollbar()
                  .setColor(color(128))
                  .setColorBackground(color(255,100));
                        
  text("Состояние входов",5,20);
  text("Подать\nсигнал",215,20);
 
  line(190,10,190,160);  
}


void draw()
{  
  if(serial.available() > 0)
  {   
     received = serial.read();
     textarea.setText(ToBinary(received,4));     
  }
   
//Кнопки--------------------------------  
  
  if (btnTransp1.isPressed() && !cargo1.isActive)
  {
    btnTransp1.setColorBackground(colorLockedBtn);
    cargo1.isActive = true;    
  }
  
  if (btnTransp2.isPressed() && !cargo2.isActive)
  {
    btnTransp2.setColorBackground(colorLockedBtn);
    cargo2.isActive = true;
  }
  
  if (btn_manual.isPressed())
  {   
    manualControl = btnHold(btn_manual, manualControl);   
    
  }
  
  if(manualControl)
  {
    fill(color(255,0,0));
    text("! РЕЖИМ РУЧНОГО УПРАВЛЕНИЯ !", 500, 100);  
  }  
  else
  {
    stroke(color(200));
    fill(color(200));
    rect(500,100,400,-20);
  }
  
    
//Управление-----------------------------
  //Ручное управление   
    //Подъем погрузчика
  if(manualControl) 
  {
    if((received & 1) == 1)
    {
       loader.RaiseUp();
    }
    //Опускание погрузчика
    if((received & 2) == 2)
    {
       loader.PutDown();
    }
    //Выдвижение захвата
    if((received & 4) == 4) 
       loader.PutForward();
    
    //Возврат захвата
    if((received & 8) == 8) 
       loader.PushIn();
  }
  
  
  //Автоматика
  else
  {
    println(grabActive);
    println(cargo1.isDelivered);
    
    if(!cargo1.isActive && !cargo2.isActive)
      stepWait();
    
    //Верхняя лента (К6)   
    if(cargo1.isActive && cargo2.yPos == 130)
    {            
      //Движение груза
      if(cargo1.xPos < -30 && !grabActive)
        cargo1.yPos +=2;
                   
      if((!K6 & !grabActive & !cargo1.isDelivered))
        cargo1.xPos--;      
      else if(K3 && K5 & !grabActive)
        cargo1.xPos--;

      if(cargo1.xPos < -20)
        grabActive = true;
                                
      if(grabActive && cargo2.xPos >= 0)
        cargo1.Follow(loader.grabX - 120, loader.liftY);

          
      if(K1 & K5 & grabActive)
        cargo1.isDelivered = true;        
      
      if(cargo1.isDelivered)
      {
        cargo1.xPos++;
        grabActive = false;
      }  
      
      if(K8 && cargo1.isDelivered)
      {
        cargo1.Reset();
        btnTransp1.setColorBackground(colorInactiveBtn);
      }
      
      //Перемещение захвата
      stepDeliverCargo1();
    }
      
    if(cargo2.isActive && cargo1.yPos == 60)
    {  
      //Движение груза
      if(cargo2.xPos < -30 && !grabActive)
        cargo2.yPos +=2;
                   
      if((!K7 & !grabActive & !cargo2.isDelivered))
        cargo2.xPos--;      
      else if(K2 && K5 & !grabActive)
        cargo2.xPos--;

      if(cargo2.xPos < -20)
        grabActive = true;
                                
      if(grabActive && cargo1.xPos >= 0 )
        cargo2.Follow(loader.grabX - 120, loader.liftY);

          
      if(K1 & K5 & grabActive)
        cargo2.isDelivered = true;        
      
      if(cargo2.isDelivered)
      {
        cargo2.xPos++;
        grabActive = false;
      }  
      
      if(K8 && cargo2.isDelivered)
      {
        cargo2.Reset();
        btnTransp2.setColorBackground(colorInactiveBtn);
      }
      
      //Перемещение захвата
      if(!cargo1.isActive | cargo1.isDelivered)
        stepDeliverCargo2();
    }
  }
  
  //Отображение объекта---------------------------------
  pg.beginDraw();
    pg.background(230);
    pg.stroke(110);

    //Конвейер 1
    pg.translate(520,0);
    pg.line(0,60,100,60);
    pg.line(0,76,100,76);   
    pg.image(transporterImg,-8,60);
    
    //Конвейер 2
    pg.line(0,130,100,130);
    pg.line(0,146,100,146);
    pg.image(transporterImg,-8,130);
    
    //Конвейер 3
    pg.line(0,200,100,200);
    pg.line(0,216,100,216);
    pg.image(transporterImg,-8,200);
    
    
    //Грузы
    pg.fill(180,0,0);
    if(cargo1.isActive)
    {
      pg.rect(cargo1.xPos, cargo1.yPos,20,-15);    
    }
    
    if(cargo2.isActive)
    {
      pg.rect(cargo2.xPos, cargo2.yPos,20,-15);    
    }
    
    pg.translate(-520,0);
    
    //Лейблы------------------------------
    //K1
    if(loader.liftY == max_y){
      pg.fill(255,255,0);
      K1 = true; 
    }
    else{
      pg.fill(255,119,0);
      K1 = false;
    }
    pg.rect(10,192,20,16);
    pg.line(30,200,300,200);
    pg.fill(0);
    pg.text("K1",13,205);
    
    //K2
    if(loader.liftY == (max_y + min_y)/2){
      pg.fill(255,255,0);
      K2 = true; 
    }
    else{
      pg.fill(255,119,0);
      K2 = false;
    }
    pg.rect(10,122,20,16);
    pg.line(30,130,300,130);
    pg.fill(0);
    pg.text("K2",13,135);
    
    //K3
    if(loader.liftY == min_y){
      pg.fill(255,255,0);
      K3 = true; 
    }
    else{
      pg.fill(255,119,0);
      K3 = false;
    }
    pg.rect(10,52,20,16);
    pg.line(30,60,300,60);
    pg.fill(0);
    pg.text("K3",13,65);
    
    //K4
    if(loader.grabX == min_x){
      pg.fill(255,255,0);
      K4 = true; 
    }
    else{
      pg.fill(255,119,0);
      K4 = false;
    }
    pg.rect(90,10,20,16);
    pg.line(100,27,100,250);
    pg.fill(0);
    pg.text("K4",93,23);
    
    //K5
    if(loader.grabX == max_x){
      pg.fill(255,255,0);
      K5 = true; 
    }
    else{
      pg.fill(255,119,0);
      K5 = false;
    }
    pg.rect(90 + max_x,10,20,16);
    pg.line(100 + max_x,27,100 + max_x,250);
    pg.fill(0);
    pg.text("K5",93 + max_x,23);
    
    //K6
    if(cargo1.xPos == 0 & cargo1.yPos == 60){
      pg.fill(255,255,0);
      K6 = true; 
    }
    else{
      pg.fill(255,119,0);
      K6 = false;
    }
    pg.rect(420 + max_x,15,20,16);
    pg.fill(0);
    pg.text("K6",423 + max_x,28);
    
    //K7
    if(cargo2.xPos == 0 & cargo2.yPos == 130){
      pg.fill(255,255,0);
      K7 = true; 
    }
    else{
      pg.fill(255,119,0);
      K7 = false;
    }
    pg.rect(420 + max_x,90,20,16);
    pg.fill(0);
    pg.text("K7",423 + max_x,103);
    
    //K8
    if(cargo1.xPos > 80 | cargo2.xPos > 80){
      pg.fill(255,255,0);
      K8 = true; 
    }
    else{
      pg.fill(255,119,0);
      K8 = false;
    }
    pg.rect(500 + max_x,160,20,16);
    pg.fill(0);
    pg.text("K8",503 + max_x,173);
    
    
    
    //Погрузчик---------------------------          
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



//Обработка нажатия на клавишу "Выход 0"
/*void Btn0_press()
{
  if(!isPressed_Transp1)
  { 
    output |= 1; 
    isPressed_Transp1 = true;
    btnTransp1.setColorBackground(colorInactiveBtn);
    delay(100);
  }
  else if(isPressed_Transp1)
  {
    output &= 254; 
    isPressed_Transp1 = false;
    delay(100);
    btnTransp1.setColorBackground(colorActiveBtn);
  }  
}


//Обработка нажатия на клавишу "Выход 1"
void Btn1_press()
{
  if(!isPressed_Transp2)
  { 
    output |= 2;
    isPressed_Transp2 = true;
    btnTransp2.setColorBackground(colorInactiveBtn);
    delay(100);
  }
  else if(isPressed_Transp2)
  {
    output &= 253;
    isPressed_Transp2 = false;
    btnTransp2.setColorBackground(colorActiveBtn);
    delay(100);
  }  
}*/


boolean btnHold(Button button, boolean btnFlag)
{  
  if(!btnFlag)
  {        
    button.setColorBackground(colorInactiveBtn);
    btnFlag = true;
    delay(100);
  }
   
  else if(btnFlag)
  {        
    button.setColorBackground(colorActiveBtn);
    btnFlag = false;
    delay(100);
  }
  
  return btnFlag;
}


void btnPress(Button button, boolean btnFlag)                                                  
{
  button.setColorBackground(colorInactiveBtn);
  btnFlag = true;
  delay(100);
  btnFlag = false;
  button.setColorBackground(colorActiveBtn);
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
}


class Timer
{
  private int value;
  private int setup;

  Timer(int setup)
  {
    this.setup = setup;
    this.value = 0;
  }

  public void Set(int setup)
  {
    this.setup = setup;
  }
  
  public void Reset()
  {
    this.value = 0;
  }

  public void setActive()
  {
      this.value++;
  }
   
  public boolean isReady()
  {
    if(this.value < this.setup)
      return false;
     else
      return true;    
  }
}


class Cargo
{
 private int startX;
 private int startY;
 public int xPos;
 public int yPos;
 public boolean isDelivered;
 public boolean isActive;
 
 Cargo(int startX, int startY)
 {
   this.startX = startX;
   this.startY = startY;
   this.xPos = startX;
   this.yPos = startY;
   this.isDelivered = false;
   this.isActive = false;
 }
 
 public void Reset()
 {
   this.xPos = this.startX;
   this.yPos = this.startY;
   this.isDelivered = false;
   this.isActive = false;
 }

 public void Follow(int x,int y)
 {
   this.xPos = x;
   this.yPos = y;
 } 
} 
 

void stepDeliverCargo1()
{
  if(cargo1.isDelivered)
  {
    if(!K4 && !K1)
      stepWait();
  }  
  
  else if(!grabActive)
  {
    if(!K3)
      loader.RaiseUp();
    else if(!K5)
      loader.PutForward();
  }
  
  else if(grabActive)
  {
    if(!K4 && K3)
      loader.PushIn();
    else if(!K1)
      loader.PutDown();
    else if(!K5)
      loader.PutForward();
  }   
}


void stepDeliverCargo2()
{
  if(cargo2.isDelivered)
  {
    if(!K4 && !K1)
      stepWait();
  }  
  
  else if(!grabActive)
  {
    if(!K2)
      loader.RaiseUp();
    else if(!K5)
      loader.PutForward();
  }
  
  else if(grabActive)
  {
    if(!K4 && K2)
      loader.PushIn();
    else if(!K1)
      loader.PutDown();
    else if(!K5)
      loader.PutForward();
  }  
}


void stepWait()
{
  if(!K1)
    loader.PutDown();
  if(!K4)
    loader.PushIn();
}
