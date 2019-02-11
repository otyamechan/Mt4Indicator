//+------------------------------------------------------------------+
//|                                      Otyame018_Spanmodel_Kairi.mq4 |
//+------------------------------------------------------------------+
#property copyright   "2016,Otyame Trader"
#property description "Otyame018_Spanmodel_Kairi"

#property  indicator_buffers 2
#property indicator_separate_window
#property indicator_color1 Blue
#property indicator_color2 Red

//---- buffers

double buf_SpanA_Kairi[];
double buf_SpanB_Kairi[];


extern int InpTenkan=9;   // Tenkan-sen
extern int InpKijun=25;   // Kijun-sen
extern int InpSenkou=52;  // Senkou Span B
extern int Bar_Shift = 0; // Bar_Shift;

int limit;
int i;
string shortname = "";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
  
   
  
   shortname = "Otyame018_Spanmodel_Kairi";
   
   IndicatorShortName(shortname);
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,buf_SpanA_Kairi);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,buf_SpanB_Kairi);
   SetIndexEmptyValue(1,EMPTY_VALUE);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
   shortname = "Otyame018_Spanmodel_Kairi";
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
         double SpanA = iCustom(NULL, 0,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou, Bar_Shift,5,i);
         double SpanB = iCustom(NULL, 0,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou, Bar_Shift,6,i);
         if (( SpanA != 0 ) && (SpanB != 0)) {
            buf_SpanA_Kairi[i] = ((Close[i] - SpanA) / SpanA) * 100 ;
            buf_SpanB_Kairi[i] = ((Close[i] - SpanB) / SpanB) * 100 ;
         }
      }

   return(0);
  }
//+------------------------------------------------------------------+

