//+------------------------------------------------------------------+
//|                                      Otyame019_Spanmodel_kairi_HIST.mq4 |
//+------------------------------------------------------------------+
#property copyright   "2016,Otyame Trader"
#property description "Otyame019_Spanmodel_kairi_HIST"

#property  indicator_buffers 2
#property indicator_separate_window
#property indicator_color1 Blue
#property indicator_color2 Red

//---- buffers

double buf_SpanA_Kairi[];
double buf_SpanB_Kairi[];

extern bool SpanA_Display = true;
extern bool SpanB_Display = true;

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
  
  
   
  
   shortname = "Otyame019_Spanmodel_kairi_HIST";
   
   IndicatorShortName(shortname);
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,buf_SpanA_Kairi);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
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
   
   shortname = "Otyame019_Spanmodel_kairi_HIST";
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
         if ( SpanA_Display == true ) {
           buf_SpanA_Kairi[i] = Close[i] - SpanA; 
         }
         if ( SpanB_Display == true ) {
           buf_SpanB_Kairi[i] = Close[i] - SpanB; 
         }
      }

   return(0);
  }
//+------------------------------------------------------------------+

