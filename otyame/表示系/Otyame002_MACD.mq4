//+------------------------------------------------------------------+
//|                                           Otyame002_MACD.mq4     |
//|                                      Copyright otyame trader     |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "2015,Otyame Trader"
#property description "Otyame002_MACD"
//#property strict

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Magenta
#property indicator_color2 Yellow
#property indicator_color3 Lime
#property indicator_color4 Aqua
#property indicator_color5 CLR_NONE
#property indicator_color6 CLR_NONE


//---- input parameters
extern bool AlertON=false;             //アラート表示　
extern bool EmailON=true;              //メール送信
extern int Alert_Bar = 0;
extern int       FastMAPeriod=12;
extern int       SlowMAPeriod=26;
extern string _ma = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int       MAMethod = MODE_EMA;
extern int       SignalMAPeriod=9;
extern int       SignalMAMethod = MODE_SMA;
extern bool       Histogram_Disp = true;



//---- buffers
double HistogramBufferUP[];
double HistogramBufferLOW[];
double SignalLineBuffer[];
double MACDLineBuffer[];
double MaxBuffer[];
double MinBuffer[];
datetime goober;

datetime goober1;
double Hist;

string message;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(Digits+2);
   //---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,HistogramBufferUP);
//   SetIndexDrawBegin(0,SlowMAPeriod+SignalMAPeriod);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,HistogramBufferLOW);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,MACDLineBuffer);



//   SetIndexDrawBegin(1,SlowMAPeriod);
   SetIndexStyle(3,DRAW_LINE/*,STYLE_DOT*/);
   SetIndexBuffer(3,SignalLineBuffer);
//   SetIndexDrawBegin(2,SlowMAPeriod+SignalMAPeriod);
   SetIndexBuffer(4,MaxBuffer);
   SetIndexBuffer(5,MinBuffer);
   
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Otyame002_MACD+("+IntegerToString(FastMAPeriod)+","+IntegerToString(SlowMAPeriod)+","+IntegerToString(SignalMAPeriod)+")");
   SetIndexLabel(0,"Hist");
   SetIndexLabel(1,"Hist");
   SetIndexLabel(2,"MACD");
   SetIndexLabel(3,"Signal");
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
   double FastMA,SlowMA;
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   limit = Bars - counted_bars;

   for(i=limit; i>=0; i--)
   {
      FastMA =  iMA(NULL,0,FastMAPeriod,0,MAMethod,PRICE_CLOSE,i);
      SlowMA =  iMA(NULL,0,SlowMAPeriod,0,MAMethod,PRICE_CLOSE,i);
     
      MACDLineBuffer[i] = FastMA-SlowMA ;

      SignalLineBuffer[i] = iMAOnArray(MACDLineBuffer,0,SignalMAPeriod,0,SignalMAMethod,i);
      if ( Histogram_Disp == true ) {
         if ( HistogramBufferUP[i+1] != EMPTY_VALUE ) {
            Hist = HistogramBufferUP[i+1];
         }
         else if ( HistogramBufferLOW[i+1] !=EMPTY_VALUE) {
            Hist = HistogramBufferLOW[i+1];
         }      
         if ( MACDLineBuffer[i] - SignalLineBuffer[i] >= Hist ) {
            HistogramBufferUP[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
            HistogramBufferLOW[i] = EMPTY_VALUE;
         }
         else if ( MACDLineBuffer[i] - SignalLineBuffer[i] < Hist ) {
            HistogramBufferLOW[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
            HistogramBufferUP[i] = EMPTY_VALUE;
         }
         if ( HistogramBufferUP[i] == EMPTY_VALUE ) {
            Hist = HistogramBufferLOW[i];
         }
         else if ( HistogramBufferLOW[i] == EMPTY_VALUE ) {
            Hist = HistogramBufferUP[i];
         }            
         MaxBuffer[i]=MathMax(MathMax(MathAbs(MACDLineBuffer[i]),MathAbs(SignalLineBuffer[i])), MathAbs(Hist));
         MinBuffer[i]=-MaxBuffer[i];
      }
      else {
         HistogramBufferUP[i] = EMPTY_VALUE;
         HistogramBufferLOW[i] = EMPTY_VALUE;
         MaxBuffer[i]=MathMax(MathAbs(MACDLineBuffer[i]),MathAbs(SignalLineBuffer[i]));
         MinBuffer[i]=-MaxBuffer[i];
      }
   }
   if (AlertON)
    {
     if ( (MACDLineBuffer[1+Alert_Bar] <= SignalLineBuffer[1+Alert_Bar]) && (MACDLineBuffer[0+Alert_Bar] > SignalLineBuffer[0+Alert_Bar]) && (goober < Time[0]) )
      {
        Alert("MACD GOLDEN CROSS , "+Symbol()+" , M_"+IntegerToString(Period())+" , Ask = ",Ask," , Hour = ",Hour()," , Minute = ",Minute()," .");
        //PlaySound("email.wav");
        goober = Time[0];
      }
     if ( (MACDLineBuffer[1+Alert_Bar] >= SignalLineBuffer[1+Alert_Bar]) && (MACDLineBuffer[0+Alert_Bar] < SignalLineBuffer[0+Alert_Bar]) && (goober < Time[0]) )
      {
        Alert("MACD DEAD CROSS , "+Symbol()+" , M_"+IntegerToString(Period())+" , Bid = ",Bid," , Hour = ",Hour()," , Minute = ",Minute()," .");
        //PlaySound("email.wav");
        goober = Time[0];
      }
    }
   if (EmailON)
    {
     if ( (MACDLineBuffer[1+Alert_Bar] <= SignalLineBuffer[1+Alert_Bar]) && (MACDLineBuffer[0+Alert_Bar] > SignalLineBuffer[0+Alert_Bar]) && (goober1 < Time[0]) )
      {
              message = "MACD GOLDEN CROSS"+"\r\n"+"["+Symbol()+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES)+"\r\n ";
              message = message + "\r\n"+"ASK = "+DoubleToStr(Ask);
              message = message + "\r\n"+"MAIN = "+DoubleToStr(MACDLineBuffer[0+Alert_Bar]);
              message = message +  "\r\n"+"Signal = "+DoubleToStr(SignalLineBuffer[0+Alert_Bar]);
              SendMail("MACD情報："+Symbol()+" , M_"+IntegerToString(Period()),message);



        //PlaySound("email.wav");
        goober1 = Time[0];
      }
     if ( (MACDLineBuffer[1+Alert_Bar] >= SignalLineBuffer[1+Alert_Bar]) && (MACDLineBuffer[0+Alert_Bar] < SignalLineBuffer[0+Alert_Bar]) && (goober1 < Time[0]) )
      {
              message = "MACD DEAD CROSS"+"\r\n"+"["+Symbol()+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES)+"\r\n ";
              message = message + "\r\n"+"Bid = "+DoubleToStr(Bid);
              message = message + "\r\n"+"MAIN = "+DoubleToStr(MACDLineBuffer[0+Alert_Bar]);
              message = message +  "\r\n"+"Signal = "+DoubleToStr(SignalLineBuffer[0+Alert_Bar]);
              SendMail("MACD情報："+Symbol()+" , M_"+IntegerToString(Period()),message);
               goober1 = Time[0];
      }
    }
   
   //----
   return(0);
}
//+------------------------------------------------------------------+-----------------------------------------------------+