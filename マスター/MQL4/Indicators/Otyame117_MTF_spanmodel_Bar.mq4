//+------------------------------------------------------------------+
//|                                      Otyame117_MTF_Spanmodel_Bar.mq4 |
//+------------------------------------------------------------------+
#property copyright   "2015,Otyame Trader"
#property description "Otyame117_MTF_Spanmodel_Bar"

#property indicator_separate_window
#property indicator_minimum -0.5
#property indicator_maximum 3
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Black
#property indicator_color4 Black
#property indicator_color5 Red
#property indicator_color6 Red

//---- buffers

double buf_SpanBUP_UP[];
double buf_SpanBDOWN_UP[];
double buf_SpanBUP_EQUAL[];
double buf_SpanBDOWN_EQUAL[];
double buf_SpanBUP_DOWN[];
double buf_SpanBDOWN_DOWN[];
extern double Data_Pos = 0.0; // Gap between the lines of bars

extern int TimeFrame = 0;

extern int InpTenkan=9;   // Tenkan-sen
extern int InpKijun=25;   // Kijun-sen
extern int InpSenkou=52;  // Senkou Span B
extern int Bar_Shift = 0; // Bar_Shift;
extern int O_SpanBUP_UP=110;   // Tenkan-sen
extern int O_SpanBDOWN_UP=108;   // Tenkan-sen
extern int O_SpanBUP_EQUAL=110;   // Tenkan-sen
extern int O_SpanBDOWN_EQUAL=108;   // Tenkan-sen
extern int O_SpanBUP_DOWN =110;   // Tenkan-sen
extern int O_SpanBDOWN_DOWN=108;   // Tenkan-sen
double  SpanB_Old;
string TimeFrameStr ="";
bool SpanB_UP = false;
int pos;

string shortname = "";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
  
    switch(TimeFrame)
   {
      case 1 : TimeFrameStr="_M1"; break;
      case 5 : TimeFrameStr="_M5"; break;
      case 15 : TimeFrameStr="_M15"; break;
      case 30 : TimeFrameStr="_M30"; break;
      case 60 : TimeFrameStr="_H1"; break;
      case 240 : TimeFrameStr="_H4"; break;
      case 1440 : TimeFrameStr="_D1"; break;
      case 10080 : TimeFrameStr="_W1"; break;
      case 43200 : TimeFrameStr="_MN1"; break;
      default : TimeFrameStr="_Current Timeframe";
   } 
   
  
   shortname = "Otyame117_MTF_Spanmodel_Bar("+TimeFrameStr+")";
   
   IndicatorShortName(shortname);
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,O_SpanBUP_UP);
   SetIndexBuffer(0,buf_SpanBUP_UP);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,O_SpanBDOWN_UP);
   SetIndexBuffer(1,buf_SpanBDOWN_UP);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,O_SpanBUP_EQUAL);
   SetIndexBuffer(2,buf_SpanBUP_EQUAL);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,O_SpanBDOWN_EQUAL);
   SetIndexBuffer(3,buf_SpanBDOWN_EQUAL);
   SetIndexEmptyValue(3,EMPTY_VALUE);

   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,O_SpanBUP_DOWN);
   SetIndexBuffer(4,buf_SpanBUP_DOWN);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,O_SpanBDOWN_DOWN);
   SetIndexBuffer(5,buf_SpanBDOWN_DOWN);
   SetIndexEmptyValue(5,EMPTY_VALUE);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
   shortname = "Otyame117_MTF_Spanmodel_Bar("+TimeFrameStr+")";
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit,i,y;
   datetime TimeArray[];
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;

   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 

   limit = Bars - counted_bars;
   if ( limit < 2 ) limit = 2;
   for(i= limit-1;i>=1;i--){
      y = iBarShift(NULL,TimeFrame,Time[i],true);
      if ( Time[i] > TimeArray[y]) {
         y++;
      }
      if ( y != pos ) {
         pos = y;
         double SpanA = iCustom(NULL, TimeFrame,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou, Bar_Shift,5,y);
         double SpanB = iCustom(NULL, TimeFrame,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou, Bar_Shift,6,y);
         buf_SpanBUP_UP[i] = EMPTY_VALUE; //   iCustom(NULL, prd, "SuperTrend", false, 1, yy);
         buf_SpanBDOWN_UP[i] = EMPTY_VALUE; //iCustom(NULL, prd, "SuperTrend", false, 0, yy);
         buf_SpanBUP_EQUAL[i] = EMPTY_VALUE; //   iCustom(NULL, prd, "SuperTrend", false, 1, yy);
         buf_SpanBDOWN_EQUAL[i] = EMPTY_VALUE; //   iCustom(NULL, prd, "SuperTrend", false, 1, yy);
         buf_SpanBUP_DOWN[i] = EMPTY_VALUE; //iCustom(NULL, prd, "SuperTrend", false, 0, yy);
         buf_SpanBDOWN_UP[i] = EMPTY_VALUE; //   iCustom(NULL, prd, "SuperTrend", false, 1, yy);
         if (SpanA > SpanB ) {
            if ( SpanB_Old < SpanB ) {
               buf_SpanBUP_UP[i] = Data_Pos;
               SpanB_UP = true;
            }
            else if ( SpanB_Old == SpanB ) {
               if ( SpanB_UP == true ) {
                  buf_SpanBUP_UP[i] = Data_Pos;
                  SpanB_UP = true;
               }
               else {
                  buf_SpanBDOWN_UP[i] = Data_Pos;
                  SpanB_UP = false;
               }
            }
            else {
               buf_SpanBDOWN_UP[i] = Data_Pos;
               SpanB_UP = false;
            }
         }     
         else if ( SpanA == SpanB ) {
            if ( SpanB_Old < SpanB ) {
               buf_SpanBUP_EQUAL[i] = Data_Pos;
               SpanB_UP = true;
            }
            else if ( SpanB_Old == SpanB ) {
               if ( SpanB_UP == true ) {
                  buf_SpanBUP_EQUAL[i] = Data_Pos;
                  SpanB_UP = true;
               }
               else {
                  buf_SpanBDOWN_EQUAL[i] = Data_Pos;
                  SpanB_UP = false;
               }
            }
            else {
               buf_SpanBDOWN_EQUAL[i] = Data_Pos;
               SpanB_UP = false;
            }
         } 
         else  {
            if ( SpanB_Old < SpanB ) {
               buf_SpanBUP_DOWN[i] = Data_Pos;
               SpanB_UP = true;
            }
            else if ( SpanB_Old == SpanB ) {
               if ( SpanB_UP == true ) {
                  buf_SpanBUP_DOWN[i] = Data_Pos;
                  SpanB_UP = true;
               }
               else {
                  buf_SpanBDOWN_DOWN[i] = Data_Pos;
                  SpanB_UP = false;
               }
            }
            else {
               buf_SpanBDOWN_DOWN[i] = Data_Pos;
               SpanB_UP = false;
            }
         }
         SpanB_Old = SpanB;
      }
      else {
         buf_SpanBUP_UP[i] = buf_SpanBUP_UP[i+1];
         buf_SpanBDOWN_UP[i] = buf_SpanBDOWN_UP[i+1];
         buf_SpanBUP_EQUAL[i]= buf_SpanBUP_EQUAL[i+1];
         buf_SpanBDOWN_EQUAL[i] = buf_SpanBDOWN_EQUAL[i+1];
         buf_SpanBUP_DOWN[i] = buf_SpanBUP_DOWN[i+1];
         buf_SpanBDOWN_DOWN[i] = buf_SpanBDOWN_DOWN[i+1];
      
      
      
      }
   }

   return(0);
  }
//+------------------------------------------------------------------+

