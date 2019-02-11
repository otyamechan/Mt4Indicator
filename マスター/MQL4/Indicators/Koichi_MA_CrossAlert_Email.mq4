//+------------------------------------------------------------------+
//|                                        a_MA_CrossAlert_Email.mq4 |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "anchan"
#property link      "http://anchan.jp"

#property indicator_buffers 2

#property indicator_chart_window

#property indicator_color1 Yellow
#property indicator_color2 Red

//---- buffers
double Buffer1[];
double Buffer2[];

extern int FastMA_Period = 12;          //ˆÚ“®•½‹Ïü‚Ì’ZŠúü‚Ì“ú”
extern int FastMA_Mode =1;             // 0=sma, 1=ema, 2=smma, 3=lwma

extern int SlowMA_Period = 20;       //ˆÚ“®•½‹Ïü‚Ì’·Šúü‚Ì“ú”
extern int SlowMA_Mode =1;           // 0=sma, 1=ema, 2=smma, 3=lwma

extern bool AlertOn=true;
extern bool EmailON=true;
eteren bool GandDON=true;


int maxLines;

datetime TimeOld;

int init()
{

   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   

   SetIndexBuffer(0,Buffer1); // Buffer1 = Fast_MA
   SetIndexBuffer(1,Buffer2); // Buffer2 = Slow_MA

   maxLines = WindowBarsPerChart();
   TimeOld = Time[0];

   return(0);
}



int deinit()
{
   return(0);
}



int start()
{

   if (Time[0] != TimeOld)
   {
      //ˆ—‚ðÄ‚Ñ‰Â”\‚É‚·‚éB
      AlertOn = true;
      EmailON = true;
      TimeOld = Time[0];
   }
     
   for(int i=WindowBarsPerChart(); i>=0; i--){
//FastMA
      Buffer1[i]= iMA(NULL,0,FastMA_Period,0,FastMA_Mode,PRICE_OPEN,i);
//SlowMA
      Buffer2[i]= iMA(NULL,0,SlowMA_Period,0,SlowMA_Mode,PRICE_OPEN,i); 
   }

                  
   double crossing=(Buffer2[0]-Buffer1[0])*(Buffer2[1]-Buffer1[1]);
   if (crossing < 0 && AlertOn){
      Alert("EMA cross on ", Symbol(), " ", Period());
      AlertOn=false;
   }

   if (crossing < 0 && EmailON){
      SendMail("MA Cross Alert["+Symbol()+"]"+"["+Period()+"]","LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+Symbol()+","+Period()+"\r\n FastEMA="+DoubleToStr(Buffer1[1],4)+","+DoubleToStr(Buffer1[0],4)+"\r\n SlowEMA="+DoubleToStr(Buffer2[1],4)+","+DoubleToStr(Buffer2[0],4));
      EmailON=false;
   }

   
   return(0);
}

//+------------------------------------------------------------------+