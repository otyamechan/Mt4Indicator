//+------------------------------------------------------------------+
//|                                      Otyame020_ATR_HIST.mq4 |
//+------------------------------------------------------------------+
#property copyright   "2016,Otyame Trader"
#property description "Otyame020_ATR_HIST"

#property  indicator_buffers 1
#property indicator_separate_window
#property indicator_color1 Blue

//---- buffers

double buf_ATR[];


extern int ATRPeriod = 1; // Bar_Shift;

int limit;
int i;
string shortname = "";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
  
   
  
   shortname = "Otyame020_ATR_HIST";
   
   IndicatorShortName(shortname);
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,buf_ATR);
   SetIndexEmptyValue(0,EMPTY_VALUE);


//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
   shortname = "Otyame020_ATR_HIST";
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   limit = Bars - counted_bars;
   
      for( i = limit -1 ; i>= 0 ; i--) {
         buf_ATR[i] = iCustom(NULL,0,"ATR",ATRPeriod,0,i);
      }

   return(0);
  }
//+------------------------------------------------------------------+

