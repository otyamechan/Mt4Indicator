//+------------------------------------------------------------------+
//|                                            MTF_MovingAverage.mq4 |
//|        ©2011 Best-metatrader-indicators.com. All rights reserved |
//|                        http://www.best-metatrader-indicators.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011 Best-metatrader-indicators.com."
#property link      "http://www.best-metatrader-indicators.com"

//----
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters

extern string TimeFrameNote="TimeFrame =0 - Current Timeframe, =1 - 1MIN, =5 - 5MIN, =15 - 15MIN, =30 - 30MIN, =60 - 1H, =240 - 4H, =1440 - D1, =10080 - W1, =43200 - MN1";
extern int TimeFrame=0;
extern int MAPeriod=13;
extern int ma_shift=0;
extern int ma_method=MODE_SMA;
extern int applied_price=PRICE_CLOSE;
//----
double ExtMapBuffer1[];
string Copyright="\xA9 WWW.BEST-METATRADER-INDICATORS.COM";  
string MPrefix="FI";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
//---- name for DataWindow and indicator subwindow label   
   switch(ma_method)
     {
      case 1 : short_name="MTF_EMA("; break;
      case 2 : short_name="MTF_SMMA("; break;
      case 3 : short_name="MTF_LWMA("; break;
      default : short_name="MTF_SMA(";
     }
   switch(TimeFrame)
     {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
     }
   IndicatorShortName(short_name+MAPeriod+") "+TimeFrameStr);
   DL("001", Copyright, 5, 20,Gold,"Arial",10,0); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ClearObjects(); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,shift,limit,y=0,counted_bars=IndicatorCounted();
   // Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
//----
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
      //----
      ExtMapBuffer1[i]=iMA(NULL,TimeFrame,MAPeriod,ma_shift,ma_method,applied_price,y);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| DL function                                                      |
//+------------------------------------------------------------------+
 void DL(string label, string text, int x, int y, color clr, string FontName = "Arial",int FontSize = 12, int typeCorner = 1)
 
{
   string labelIndicator = MPrefix + label;   
   if (ObjectFind(labelIndicator) == -1)
   {
      ObjectCreate(labelIndicator, OBJ_LABEL, 0, 0, 0);
  }
   
   ObjectSet(labelIndicator, OBJPROP_CORNER, typeCorner);
   ObjectSet(labelIndicator, OBJPROP_XDISTANCE, x);
   ObjectSet(labelIndicator, OBJPROP_YDISTANCE, y);
   ObjectSetText(labelIndicator, text, FontSize, FontName, clr);
  
}  

//+------------------------------------------------------------------+
//| ClearObjects function                                            |
//+------------------------------------------------------------------+
void ClearObjects() 
{ 
  for(int i=0;i<ObjectsTotal();i++) 
  if(StringFind(ObjectName(i),MPrefix)==0) { ObjectDelete(ObjectName(i)); i--; } 
}
//+------------------------------------------------------------------+