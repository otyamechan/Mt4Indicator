//+------------------------------------------------------------------+
//|                                           Otyame010_MACD.mq4     |
//|                                      Copyright otyame trader     |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "2015,Otyame Trader"
#property description "Otyame010_MACD"
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
extern int       TimeFrame = 0;
extern bool AlertON=false;             //アラート表示　
extern bool EmailON=true;              //メール送信
extern int Alert_Bar = 0;
extern int       FastMAPeriod=12;
extern int       SlowMAPeriod=26;
extern string _ma = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int       MAMethod = MODE_EMA;
extern int       SignalMAPeriod=9;
extern int       SignalMAMethod = MODE_SMA;
extern bool       Histgram_DISP = true;



//---- buffers
double HistogramBufferUP[];
double HistogramBufferLOW[];
double SignalLineBuffer[];
double MACDLineBuffer[];
double MaxBuffer[];
double MinBuffer[];
string TimeFrameStr;
datetime goober;
datetime goober1;
string message;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
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
   IndicatorShortName("Otyame010_MACD+("+IntegerToString(FastMAPeriod)+","+IntegerToString(SlowMAPeriod)+","+IntegerToString(SignalMAPeriod)+")");
   SetIndexLabel(0,"Hist");
   SetIndexLabel(1,"Hist");
   SetIndexLabel(2,"MACD");
   SetIndexLabel(3,"Signal");
 
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
   int limit,i,y;
   datetime TimeArray[];
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;

   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 

   limit = Bars - counted_bars;

   for(i=0,y=0;i<limit;i++)
   {
      if (Time[i]<TimeArray[y]) y++; 
      HistogramBufferUP[i] =iCustom(NULL,TimeFrame,"Otyame002_MACD",false,false,0,FastMAPeriod,SlowMAPeriod,_ma,MAMethod,SignalMAPeriod,SignalMAMethod,Histgram_DISP,0,y);
      HistogramBufferLOW[i] =iCustom(NULL,TimeFrame,"Otyame002_MACD",false,false,0,FastMAPeriod,SlowMAPeriod,_ma,MAMethod,SignalMAPeriod,SignalMAMethod,Histgram_DISP,1,y);
      MACDLineBuffer[i] =iCustom(NULL,TimeFrame,"Otyame002_MACD",false,false,0,FastMAPeriod,SlowMAPeriod,_ma,MAMethod,SignalMAPeriod,SignalMAMethod,Histgram_DISP,2,y);
      SignalLineBuffer[i] =iCustom(NULL,TimeFrame,"Otyame002_MACD",false,false,0,FastMAPeriod,SlowMAPeriod,_ma,MAMethod,SignalMAPeriod,SignalMAMethod,Histgram_DISP,3,y);
      MaxBuffer[i] =iCustom(NULL,TimeFrame,"Otyame002_MACD",false,false,0,FastMAPeriod,SlowMAPeriod,_ma,MAMethod,SignalMAPeriod,SignalMAMethod,Histgram_DISP,4,y);
      MinBuffer[i] =iCustom(NULL,TimeFrame,"Otyame002_MACD",false,false,0,FastMAPeriod,SlowMAPeriod,_ma,MAMethod,SignalMAPeriod,SignalMAMethod,Histgram_DISP,5,y);
   }
    if (AlertON)
    {
     if ( (MACDLineBuffer[1+Alert_Bar] <= SignalLineBuffer[1+Alert_Bar]) && (MACDLineBuffer[0+Alert_Bar] > SignalLineBuffer[0+Alert_Bar]) && (goober < Time[0]) )
      {
        Alert("MACD GOLDEN CROSS , "+Symbol()+" , M_"+IntegerToString(Period())+" , Ask = ",DoubleToStr(Ask)," , Hour = ",Hour()," , Minute = ",Minute()," .");
        //PlaySound("email.wav");
        goober = Time[0];
      }
     if ( (MACDLineBuffer[1+Alert_Bar] >= SignalLineBuffer[1+Alert_Bar]) && (MACDLineBuffer[0+Alert_Bar] < SignalLineBuffer[0+Alert_Bar]) && (goober < Time[0]) )
      {
        Alert("MACD DEAD CROSS , "+Symbol()+" , M_"+IntegerToString(Period())+" , Bid = ",DoubleToStr(Bid)," , Hour = ",Hour()," , Minute = ",Minute()," .");
        //PlaySound("email.wav");
        goober = Time[0];
      }
    }
   if (EmailON)
    {
     if ( (MACDLineBuffer[1+Alert_Bar] <= SignalLineBuffer[1+Alert_Bar]) && (MACDLineBuffer[0+Alert_Bar] > SignalLineBuffer[0+Alert_Bar]) && (goober1 < Time[0]) )
      {
              message = "MTF MACD GOLDEN CROSS"+"\r\n"+"["+Symbol()+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n";
              message = message + "\r\n"+"ASK = "+DoubleToStr(Ask);
              message = message + "\r\n"+"MAIN = "+DoubleToStr(MACDLineBuffer[0+Alert_Bar]);
              message = message +  "\r\n"+"Signal = "+DoubleToStr(SignalLineBuffer[0+Alert_Bar]);
              SendMail("MACD情報："+Symbol()+" , M_"+IntegerToString(Period()),message);



        //PlaySound("email.wav");
        goober1 = Time[0];
      }
     if ( (MACDLineBuffer[1+Alert_Bar] >= SignalLineBuffer[1+Alert_Bar]) && (MACDLineBuffer[0+Alert_Bar] < SignalLineBuffer[0+Alert_Bar]) && (goober1 < Time[0]) )
      {
              message = "MTF MACD DEAD CROSS"+"\r\n"+"["+Symbol()+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n";
              message = message + "\r\n"+"Bid = "+DoubleToStr(Bid);
              message = message + "\r\n"+"MAIN = "+DoubleToStr(MACDLineBuffer[0+Alert_Bar]);
              message = message +  "\r\n"+"Signal = "+DoubleToStr(SignalLineBuffer[0+Alert_Bar]);
              SendMail("MACD情報："+Symbol()+" , M_"+IntegerToString(Period()),message);
               goober1 = Time[0];
      }
    }  //----
   return(0);
}
//+------------------------------------------------------------------+-----------------------------------------------------+