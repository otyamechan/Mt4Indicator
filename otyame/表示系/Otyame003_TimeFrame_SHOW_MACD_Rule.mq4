//+------------------------------------------------------------------+
//|                           Otyame  No.001                         |
//|                           Otyame003_TimeFrame_SHOW_MACD_Rule.mq4 |
//|                           2014.05.20                             |
//+------------------------------------------------------------------+
#property copyright   "2015,Otyame Trader"
#property description "Otyame003_TimeFrame_SHOW_MACD_Rule"
#property strict


#property indicator_buffers 4

#property indicator_separate_window

#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Aqua
#property indicator_color4 Red

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 1



//---- buffers
double Short_MACD[];
double Short_Signal[];
double Long_MACD[];
double Long_Signal[];


extern   int MACD_Period = 20;           //MACD期間
extern   string _MACD_Method = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern   int  Method = 3;           //演算方式
extern   int Signal = 5;           //基本となるシグナル機関
extern   int  Signal_Method = 3;           //演算方式

int FastMAPeriod[2];
int SlowMAPeriod[2];
int MACD_Method[2];
int SignalMAPeriod[2];
int SignalMAMethod[2];

bool Histogram = false;     //ヒストグラム表示

int init()
{

//---- indicators
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Short_MACD);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexLabel(0,"Short_MACD");
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Short_Signal);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexLabel(1,"Short_Signal");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Long_MACD);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexLabel(2,"Long_MACD");
 
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Long_Signal);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexLabel(3,"Long_Signal");
	IndicatorShortName("Otyame003_TimeFrame_SHOW_MACD_Rule");

   return(0);
}
int deinit()
{
   return(0);
}
int start()
{
   int i;
   switch(Period())  {
      case PERIOD_M1:
         FastMAPeriod[0] = MACD_Period;
         SlowMAPeriod[0] = MACD_Period * PERIOD_M15 / Period();
         MACD_Method[0] = Method;
         SignalMAPeriod[0] =Signal;
         SignalMAMethod[0] = Signal_Method;

         FastMAPeriod[1] = MACD_Period * PERIOD_M5 /Period();
         SlowMAPeriod[1] = MACD_Period * PERIOD_M15 / Period();
         MACD_Method[1] = Method;
         SignalMAPeriod[1] =Signal * PERIOD_M5 /Period();
         SignalMAMethod[1] = Signal_Method;
         break;
      case PERIOD_M5:
         FastMAPeriod[0] = MACD_Period;
         SlowMAPeriod[0] = MACD_Period * PERIOD_H1 / Period();
         MACD_Method[0] = Method;
         SignalMAPeriod[0] =Signal;
         SignalMAMethod[0] = Signal_Method;

         FastMAPeriod[1] = MACD_Period * PERIOD_M15 /Period();
         SlowMAPeriod[1] = MACD_Period * PERIOD_H1 / Period();
         MACD_Method[1] = Method;
         SignalMAPeriod[1] =Signal * PERIOD_M15 /Period();
         SignalMAMethod[1] = Signal_Method;
         break;
      case PERIOD_M15:
         FastMAPeriod[0] = MACD_Period;
         SlowMAPeriod[0] = MACD_Period * PERIOD_H4/ Period();
         MACD_Method[0] = Method;
         SignalMAPeriod[0] =Signal;
         SignalMAMethod[0] = Signal_Method;

         FastMAPeriod[1] = MACD_Period * PERIOD_H1 /Period();
         SlowMAPeriod[1] = MACD_Period * PERIOD_H4 / Period();
         MACD_Method[1] = Method;
         SignalMAPeriod[1] =Signal * PERIOD_H1 /Period();
         SignalMAMethod[1] = Signal_Method;
         break;
      case PERIOD_H1:
         FastMAPeriod[0] = MACD_Period;
         SlowMAPeriod[0] = MACD_Period * PERIOD_D1/ Period();
         MACD_Method[0] = Method;
         SignalMAPeriod[0] =Signal;
         SignalMAMethod[0] = Signal_Method;

         FastMAPeriod[1] = MACD_Period * PERIOD_H4 / Period();
         SlowMAPeriod[1] = MACD_Period * PERIOD_D1 / Period();
         MACD_Method[1] = Method;
         SignalMAPeriod[1] =Signal * PERIOD_H4 /Period();
         SignalMAMethod[1] = Signal_Method;
         break;
      case PERIOD_H4:
         FastMAPeriod[0] = MACD_Period;
         SlowMAPeriod[0] = MACD_Period * (PERIOD_D1*5) / Period();
         MACD_Method[0] = Method;
         SignalMAPeriod[0] =Signal;
         SignalMAMethod[0] = Signal_Method;

         FastMAPeriod[1] = MACD_Period * PERIOD_D1 / Period();
         SlowMAPeriod[1] = MACD_Period * (PERIOD_D1*5) / Period();
         MACD_Method[1] = Method;
         SignalMAPeriod[1] =Signal * PERIOD_D1 / Period();
         SignalMAMethod[1] = Signal_Method;
         break;
      case PERIOD_D1:
         FastMAPeriod[0] = MACD_Period;
         SlowMAPeriod[0] = MACD_Period * (PERIOD_D1*5*4) / Period();
         MACD_Method[0] = Method;
         SignalMAPeriod[0] =Signal;
         SignalMAMethod[0] = Signal_Method;

         FastMAPeriod[1] = MACD_Period * (PERIOD_D1*5) / Period();
         SlowMAPeriod[1] = MACD_Period * (PERIOD_D1*5*4) / Period();
         MACD_Method[1] = Method;
         SignalMAPeriod[1] =Signal * (PERIOD_D1*5) / Period();
         SignalMAMethod[1] = Signal_Method;
         break;
      case PERIOD_W1:
         FastMAPeriod[0] = MACD_Period;
         SlowMAPeriod[0] = MACD_Period * 48 ;
         MACD_Method[0] = Method;
         SignalMAPeriod[0] =Signal;
         SignalMAMethod[0] = Signal_Method;

         FastMAPeriod[1] = MACD_Period * 4;
         SlowMAPeriod[1] =MACD_Period * 48;
         MACD_Method[1] = Method;
         SignalMAPeriod[1] =Signal * 4;
         SignalMAMethod[1] = Signal_Method;
         break;
   }
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;

   for( i = limit -1 ; i>= 0 ; i--) {
      switch(Period())  {
         case PERIOD_M1:
         case PERIOD_M5:
         case PERIOD_M15:
         case PERIOD_H1:
         case PERIOD_H4:
         case PERIOD_D1:
         case PERIOD_W1:
            Short_MACD[i] = iCustom(NULL,0,"Otyame002_MACD",false,false,0,FastMAPeriod[0],SlowMAPeriod[0],"0:SMA 1:EMA 2:SMMA 3:LWMA",MACD_Method[0],SignalMAPeriod[0],SignalMAMethod[0],false,2,i);
            Short_Signal[i] = iCustom(NULL,0,"Otyame002_MACD",false,false,0,FastMAPeriod[0],SlowMAPeriod[0],"0:SMA 1:EMA 2:SMMA 3:LWMA",MACD_Method[0],SignalMAPeriod[0],SignalMAMethod[0],false,3,i);
            Long_MACD[i] = iCustom(NULL,0,"Otyame002_MACD",false,false,0,FastMAPeriod[1],SlowMAPeriod[1],"0:SMA 1:EMA 2:SMMA 3:LWMA",MACD_Method[1],SignalMAPeriod[1],SignalMAMethod[1],false,2,i);
            Long_Signal[i] = iCustom(NULL,0,"Otyame002_MACD",false,false,0,FastMAPeriod[1],SlowMAPeriod[1],"0:SMA 1:EMA 2:SMMA 3:LWMA",MACD_Method[1],SignalMAPeriod[1],SignalMAMethod[1],false,3,i);
            break;       
         default :
            Short_MACD[i] = EMPTY_VALUE;
            Short_Signal[i] = EMPTY_VALUE;
            Long_MACD[i] = EMPTY_VALUE;
            Long_Signal[i] = EMPTY_VALUE;
            break;
      }
   }
   return(0);
}

