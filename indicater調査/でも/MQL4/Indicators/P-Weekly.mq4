//+------------------------------------------------------------------+
//|                                                     Weekly Pivot |
//|                                    Copyright © 2006, Profitrader |
//|                                    Coded/Verified by Profitrader |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Profitrader."
#property link      "profitrader@inbox.ru"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Yellow
#property indicator_color2 LightPink
#property indicator_color3 LightGreen
#property indicator_color4 LightPink
#property indicator_color5 LightGreen
#property indicator_color6 LightPink
#property indicator_color7 LightGreen
//---- buffers
double PBuffer[];
double S1Buffer[];
double R1Buffer[];
double S2Buffer[];
double R2Buffer[];
double S3Buffer[];
double R3Buffer[];
int new_week_bar;
double P,S1,R1,S2,R2,S3,R3;
double last_week_high,last_week_low,last_week_close,this_week_open;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,PBuffer);
   SetIndexBuffer(1,S1Buffer);
   SetIndexBuffer(2,R1Buffer);
   SetIndexBuffer(3,S2Buffer);
   SetIndexBuffer(4,R2Buffer);
   SetIndexBuffer(5,S3Buffer);
   SetIndexBuffer(6,R3Buffer);
   SetIndexStyle(0,DRAW_LINE,0,3);
   SetIndexStyle(1,DRAW_LINE,0,3);
   SetIndexStyle(2,DRAW_LINE,0,3);
   SetIndexStyle(3,DRAW_LINE,0,3);
   SetIndexStyle(4,DRAW_LINE,0,3);
   SetIndexStyle(5,DRAW_LINE,0,3);
   SetIndexStyle(6,DRAW_LINE,0,3);
   SetIndexLabel(0,"Weekly Pivot Point");
   SetIndexLabel(1,"Weekly Support 1");
   SetIndexLabel(2,"Weekly Resistant 1");
   SetIndexLabel(3,"Weekly Support 2");
   SetIndexLabel(4,"Weekly Resistant 2");
   SetIndexLabel(5,"Weekly Support 3");
   SetIndexLabel(6,"Weekly Resistant 3");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("Weekly Pivot");
   ObjectDelete("Weekly Sup1");
   ObjectDelete("Weekly Res1");
   ObjectDelete("Weekly Sup2");
   ObjectDelete("Weekly Res2");
   ObjectDelete("Weekly Sup3");
   ObjectDelete("Weekly Res3");   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;  
   int limit=Bars-counted_bars;
   
   if(Period()>PERIOD_H4) return(-1);
   if(counted_bars==0)
     {
      ObjectCreate("Weekly Pivot",OBJ_TEXT,0,0,0);
      ObjectSetText("Weekly Pivot","",8,"Arial",Red);
      ObjectCreate("Weekly Sup1",OBJ_TEXT,0,0,0);
      ObjectSetText("Weekly Sup1","",8,"Arial",Red);
      ObjectCreate("Weekly Res1",OBJ_TEXT,0,0,0);
      ObjectSetText("Weekly Res1","",8,"Arial",Red);
      ObjectCreate("Weekly Sup2", OBJ_TEXT,0,0,0);
      ObjectSetText("Weekly Sup2","",8,"Arial",Red);
      ObjectCreate("Weekly Res2",OBJ_TEXT,0,0,0);
      ObjectSetText("Weekly Res2","",8,"Arial",Red);
      ObjectCreate("Weekly Sup3",OBJ_TEXT,0,0,0);
      ObjectSetText("Weekly Sup3","",8,"Arial",Red);
      ObjectCreate("Weekly Res3",OBJ_TEXT,0,0,0);
      ObjectSetText("Weekly Res3","",8,"Arial",Red);
     }
   for(i=limit-1; i>=0; i--)
      {
       // 1sts Days of Week
	    if(TimeDayOfWeek(Time[i])==1 && TimeHour(Time[i])==0 && TimeMinute(Time[i])==0 && TimeSeconds(Time[i])==0)
	      {
	      if (true)
	      {
	       new_week_bar=i; //set the value of i to be that time hence i+1 is when all those things occur again.
		    last_week_close=Close[i+1];
		    P=(last_week_high+last_week_low+last_week_close)/3;
          R1=(2*P)-last_week_low;
          S1=(2*P)-last_week_high;
          R2=P+(last_week_high-last_week_low);
          S2=P-(last_week_high-last_week_low);
          R3=(2*P)+(last_week_high-(2*last_week_low));
          S3=(2*P)-((2*last_week_high)-last_week_low); 
          
          last_week_low=Low[i];
          last_week_high=High[i];
         }
      ObjectMove("Weekly Pivot",0,Time[i],P);
      ObjectMove("Weekly Sup1",0,Time[i],S1);
      ObjectMove("Weekly Res1",0,Time[i],R1);
      ObjectMove("Weekly Sup2",0,Time[i],S2);
      ObjectMove("Weekly Res2",0,Time[i],R2);
      ObjectMove("Weekly Sup3",0,Time[i],S3);
      ObjectMove("Weekly Res3",0,Time[i],R3);
      }       
 last_week_low=MathMin(last_week_low,Low[i]);   
 last_week_high=MathMax(last_week_high,High[i]);
 PBuffer[i]=P;
 S1Buffer[i]=S1;
 R1Buffer[i]=R1;
 S2Buffer[i]=S2;
 R2Buffer[i]=R2;
 S3Buffer[i]=S3;
 R3Buffer[i]=R3;
    }
//----
   return(0);
  }
//+------------------------------------------------------------------+