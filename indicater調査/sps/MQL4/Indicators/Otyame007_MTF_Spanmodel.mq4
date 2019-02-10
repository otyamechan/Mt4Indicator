//+------------------------------------------------------------------+
//|                                      Otyame008_MTF_Spanmodel.mq4 |
//+------------------------------------------------------------------+
#property copyright   "2015,Otyame Trader"
#property description "Otyame007_MTF_Spanmodel"
#property strict

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 White          // Tenkan-sen
#property indicator_color2 White         // Kijun-sen
#property indicator_color3 LightCyan   // Up Kumo
#property indicator_color4 Pink      // Down Kumo
#property indicator_color5 Magenta         // Chikou Span
#property indicator_color6 Blue   // Up Kumo bounding line
#property indicator_color7 Red      // Down Kumo bounding line

#property indicator_width1 0
#property indicator_width2 0
#property indicator_width3 5
#property indicator_width4 5
#property indicator_width5 3
#property indicator_width6 4
#property indicator_width7 4

#property indicator_style1 0
#property indicator_style2 0
#property indicator_style3 0
#property indicator_style4 0
#property indicator_style5 0
#property indicator_style6 0
#property indicator_style7 0

double ExtTenkanBuffer[];
double ExtKijunBuffer[];
double ExtSpanA_Buffer[];
double ExtSpanB_Buffer[];
double ExtChikouBuffer[];
double ExtSpanA2_Buffer[];
double ExtSpanB2_Buffer[];

//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
---------------------------------------
PRICE_CLOSE    0 Close price. 
PRICE_OPEN     1 Open price. 
PRICE_HIGH     2 High price. 
PRICE_LOW      3 Low price. 
PRICE_MEDIAN   4 Median price, (high+low)/2. 
PRICE_TYPICAL  5 Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6 Weighted close price, (high+low+close+close)/4. 
You must use the numeric value of the Applied Price that you want to use
when you set the 'applied_price' value with the indicator inputs.
---------------------------------------
MODE_SMA    0 Simple moving average, 
MODE_EMA    1 Exponential moving average, 
MODE_SMMA   2 Smoothed moving average, 
MODE_LWMA   3 Linear weighted moving average. 
You must use the numeric value of the MA Method that you want to use
when you set the 'ma_method' value with the indicator inputs.

**************************************************************************/
extern int TimeFrame=0;
input int InpTenkan=9;   // Tenkan-sen
input int InpKijun=25;   // Kijun-sen
input int InpSenkou=52;  // Senkou Span B
input int Bar_Shift = 0;


double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
int    ExtBegin;
string TimeFrameStr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
//--- buffers
//---- name for DataWindow and indicator subwindow label   
   IndicatorDigits(Digits);
//---
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtTenkanBuffer);
   SetIndexDrawBegin(0,InpTenkan-1);
   SetIndexLabel(0,"Tenkan Sen");
//---
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtKijunBuffer);
   SetIndexDrawBegin(1,InpKijun-1);
   SetIndexLabel(1,"Kijun Sen");
//---
   ExtBegin=InpKijun;
   if(ExtBegin<InpTenkan)
      ExtBegin=InpTenkan;
//---
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_DOT);
   SetIndexBuffer(2,ExtSpanA_Buffer);
   SetIndexDrawBegin(2,InpKijun+ExtBegin-1);
   SetIndexShift(2,Bar_Shift*TimeFrame/Period());
   SetIndexLabel(2,NULL);
   SetIndexStyle(5,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(5,ExtSpanA2_Buffer);
   SetIndexDrawBegin(5,InpKijun+ExtBegin-1);
   SetIndexShift(5,Bar_Shift*TimeFrame/Period());
   SetIndexLabel(5,"Senkou Span A");
//---
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_DOT);
   SetIndexBuffer(3,ExtSpanB_Buffer);
   SetIndexDrawBegin(3,InpKijun+InpSenkou-1);
   SetIndexShift(3,Bar_Shift*TimeFrame/Period());
   SetIndexLabel(3,NULL);
   SetIndexStyle(6,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(6,ExtSpanB2_Buffer);
   SetIndexDrawBegin(6,InpKijun+InpSenkou-1);
   SetIndexShift(6,Bar_Shift*TimeFrame/Period());
   SetIndexLabel(6,"Senkou Span B");
//---
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtChikouBuffer);
   SetIndexShift(4,-InpKijun);
   SetIndexLabel(4,"Chikou Span");

   switch(TimeFrame)
   {
      case 1 : TimeFrameStr="Period_M1"; break;
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
   return(0);
  }
//----
 
//+------------------------------------------------------------------+
//| MTF Moving Average                                   |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();
    
// Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
   {
   if (Time[i]<TimeArray[y]) y++; 
   
 /***********************************************************   
   Add your main indicator loop below.  You can reference an existing
      indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator timeframe
   Rule 3:  Use 'y' for the indicator's shift value
 **********************************************************/  
    
   ExtTenkanBuffer[i] = iCustom(NULL,TimeFrame,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou,0,0,y);
   ExtKijunBuffer[i]= iCustom(NULL,TimeFrame,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou,0,1,y);
   ExtSpanA_Buffer[i]= iCustom(NULL,TimeFrame,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou,0,2,y);
   ExtSpanB_Buffer[i]= iCustom(NULL,TimeFrame,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou,0,3,y);
//   ExtChikouBuffer[i]= iCustom(NULL,TimeFrame,"span_A",InpTenkan,InpKijun,InpSenkou,4,y);
   ExtSpanA2_Buffer[i]= iCustom(NULL,TimeFrame,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou,0,5,y);
   ExtSpanB2_Buffer[i]= iCustom(NULL,TimeFrame,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou,0,6,y);
   
   }  
     
//
   
  
  
   return(0);
  }
//+------------------------------------------------------------------+