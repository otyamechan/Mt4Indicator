//+------------------------------------------------------------------+
//|                                                 MACD(Custom).mq4 |
//|                    Copyright(C) 2006 S.B.T. All Rights Reserved. |
//|                                     http://sufx.core.t3-ism.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright(C) 2005 S.B.T. All Rights Reserved."
#property  link      "http://sufx.core.t3-ism.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  MediumSeaGreen
#property  indicator_color2  DarkOrange
#property  indicator_color3  Crimson
#property  indicator_color4  SteelBlue

//---- indicator parameters
extern int FastMA=12;
extern int SlowMA=26;
extern int MA_Method=1;
extern int SignalMA=9;
extern int SignalMA_Method=0;
extern int Apply=0;
extern int Timeframe=0;

//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];
double     ind_buffer3[];
double     ind_buffer4[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name1,short_name2,short_name3;

//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexDrawBegin(1,SignalMA);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- indicator buffers mapping
   if(!SetIndexBuffer(0,ind_buffer1) && !SetIndexBuffer(1,ind_buffer2) && !SetIndexBuffer(2,ind_buffer3) && !SetIndexBuffer(3,ind_buffer4))
      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   switch(MA_Method)
     {
      case 1 : short_name1="EMA("; break;
      case 2 : short_name1="SMMA("; break;
      case 3 : short_name1="LWMA("; break;
      default :
         MA_Method=0;
         short_name1="SMA(";
     }
   switch(SignalMA_Method)
     {
      case 1 : short_name2="EMA("; break;
      case 2 : short_name2="SMMA("; break;
      case 3 : short_name2="LWMA("; break;
      default :
         SignalMA_Method=0;
         short_name2="SMA(";
     }
   switch(Apply)
     {
      case 1 : short_name3="Apply to Open price"; break;
      case 2 : short_name3="Apply to High price"; break;
      case 3 : short_name3="Apply to Low price"; break;
      case 4 : short_name3="Apply to Median price, (high+low)/2"; break;
      case 5 : short_name3="Apply to Typical price, (high+low+close)/3"; break;
      case 6 : short_name3="Apply to Weighted close price, (high+low+close+close)/4"; break;
      default :
         Apply=0;
         short_name3="Apply to Close price";
     }
   IndicatorShortName("MACD("+short_name1+FastMA+"),"+short_name1+SlowMA+"),"+short_name2+SignalMA+")) "+short_name3);
   SetIndexLabel(0,"Oscillator");
   SetIndexLabel(1,"Oscillator");
   SetIndexLabel(2,"Signal");
   SetIndexLabel(3,"MACD");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st buffer
   for(int i=0; i<limit; i++) {
      ind_buffer4[i]=iMA(NULL,Timeframe,FastMA,0,MA_Method,Apply,i)-iMA(NULL,Timeframe,SlowMA,0,MA_Method,Apply,i);
   }
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++) {
      ind_buffer3[i]=iMAOnArray(ind_buffer4,Bars,SignalMA,0,SignalMA_Method,i);
   }
//---- done
//---- signal line counted in the 3-rd buffer
   for(i=0; i<limit; i++) {
      ind_buffer1[i]=ind_buffer4[i]-ind_buffer3[i];
   }
   for(i=0; i<limit-1; i++) {
      if (ind_buffer1[i]<ind_buffer1[i+1]) ind_buffer2[i]=ind_buffer1[i]; else ind_buffer2[i]=0;
   }
//---- done
   return(0);
  }

