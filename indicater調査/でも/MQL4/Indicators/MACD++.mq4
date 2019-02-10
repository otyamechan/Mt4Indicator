//+------------------------------------------------------------------+
//|                                                         MACD.mq4 |
//|                                Copyright © 2005, David W. Thomas |
//|                                           mailto:davidwt@usa.net |
//+------------------------------------------------------------------+
// This is the correct computation and display of MACD.
#property copyright "Copyright © 2005, David W. Thomas"
#property link      "mailto:davidwt@usa.net"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Green
#property indicator_color2 Blue
#property indicator_color3 Red

#property indicator_color4 DeepPink
#property indicator_width4 2
#property indicator_color5 Aqua
#property indicator_width5 2
#property indicator_color6 CLR_NONE
#property indicator_color7 CLR_NONE


//---- input parameters
extern int       FastMAPeriod=12;
extern int       SlowMAPeriod=26;
extern string _ma = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int       MAMethod = MODE_LWMA;
extern int       SignalMAPeriod=9;
extern int       SignalMAMethod = MODE_LWMA;

extern bool ShowSignal = true;
extern double SignalDiff = 0.000175;
//---- buffers
double MACDLineBuffer[];
double SignalLineBuffer[];
double HistogramBuffer[];
double AlertUpBuffer[];
double AlertDownBuffer[];

double MaxBuffer[];
double MinBuffer[];
//---- variables
double alpha = 0;
double alpha_1 = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   //---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,HistogramBuffer);
   SetIndexDrawBegin(0,SlowMAPeriod+SignalMAPeriod);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MACDLineBuffer);
   SetIndexDrawBegin(1,SlowMAPeriod);
   SetIndexStyle(2,DRAW_LINE/*,STYLE_DOT*/);
   SetIndexBuffer(2,SignalLineBuffer);
   SetIndexDrawBegin(2,SlowMAPeriod+SignalMAPeriod);

   SetIndexBuffer(3,AlertDownBuffer);
   SetIndexDrawBegin(3,SlowMAPeriod+SignalMAPeriod);
   SetIndexBuffer(4,AlertUpBuffer);
   SetIndexDrawBegin(4,SlowMAPeriod+SignalMAPeriod);

   SetIndexBuffer(5,MaxBuffer);
   SetIndexBuffer(6,MinBuffer);
   
   if(ShowSignal){
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,119);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,119);
   }else{
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   }
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD+("+FastMAPeriod+","+SlowMAPeriod+","+SignalMAPeriod+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"Hist");
   SetIndexLabel(3,NULL); SetIndexLabel(4,NULL);
   SetIndexLabel(5,NULL); SetIndexLabel(6,NULL);
   //----
	//alpha = 2.0 / (SignalMAPeriod + 1.0);
	//alpha_1 = 1.0 - alpha;
   //----
   if(StringFind(Symbol(),"JPY")!=-1) SignalDiff=SignalDiff*100;
   //Print("SignalDiff = ",SignalDiff);
   return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //---- 
   
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int limit,i;
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   limit = Bars - counted_bars;

   for(i=limit; i>=0; i--)
   {
      MACDLineBuffer[i] = iMA(NULL,0,FastMAPeriod,0,MAMethod,PRICE_CLOSE,i) - iMA(NULL,0,SlowMAPeriod,0,MAMethod,PRICE_CLOSE,i);
   }
   for(i=limit; i>=0; i--)
   {
      //SignalLineBuffer[i] = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
      SignalLineBuffer[i] = iMAOnArray(MACDLineBuffer,0,SignalMAPeriod,0,SignalMAMethod,i);
      
      HistogramBuffer[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
      
      if(MACDLineBuffer[i] >MACDLineBuffer[i+1]+SignalDiff ){
         AlertUpBuffer[i]=MACDLineBuffer[i];
      }else{
         AlertUpBuffer[i]=EMPTY_VALUE;
      }
      if(MACDLineBuffer[i] <MACDLineBuffer[i+1]-SignalDiff){
         AlertDownBuffer[i]=MACDLineBuffer[i];
      }else{
         AlertDownBuffer[i]=EMPTY_VALUE;
      }
      MaxBuffer[i]=MathMax(MathMax(MathAbs(MACDLineBuffer[i]),MathAbs(SignalLineBuffer[i])), MathAbs(HistogramBuffer[i]));
      MinBuffer[i]=-MaxBuffer[i];
      
   }
   
   //----
   return(0);
}
//+------------------------------------------------------------------+