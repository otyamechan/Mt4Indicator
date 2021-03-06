//+------------------------------------------------------------------+
//|                                       Otyame  No.005             |
//|                                    Otyame005_Super_Bollinger.mq4 |
//|                                       2014.05.22                 |
//+------------------------------------------------------------------+

#property copyright   "2015,Otyame Trader"
#property description "Otyame005_Super_Bollinger"
#property strict

#property indicator_buffers 8

#property indicator_chart_window

#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Black
#property indicator_color4 Black
#property indicator_color4 Black
#property indicator_color4 Black

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width4 4
#property indicator_width4 4

#define distance 30


#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Aqua
#property indicator_color7 Aqua
#property indicator_color8 Magenta

#property indicator_width1 2 
#property indicator_width2 2 
#property indicator_width3 2 
#property indicator_width4 2 
#property indicator_width5 2 
#property indicator_width6 2 
#property indicator_width7 2 
#property indicator_width8 2 

//---- buffers
double MA[];
double Usigma_1[];
double Lsigma_1[];
double Usigma_2[];
double Lsigma_2[];
double Usigma_3[];
double Lsigma_3[];
double Chikou[];



extern int MAPeriod = 21;            //中心期間
extern   string _MAMethod = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int MAMethod = 0;            //中心線用MA Method
extern  bool center_sen = true;            // 中心線描画
extern bool sigma_1_sen = true;           //1σ描画
extern bool sigma_2_sen = true;           //2σ描画
extern bool sigma_3_sen = true;           //3σ描画
extern bool Chikou_sen = true;            //遅行スパン描画
extern int Chikou_Idou = -20;            //遅行スパン描画



int init()
{

//---- indicators
   IndicatorDigits(Digits+1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexLabel(0,"MA");

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Lsigma_1);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexLabel(1,"-1σ");

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Usigma_1);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexLabel(2,"+1σ");

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Lsigma_2);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexLabel(3,"-2σ");

   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Usigma_2);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexLabel(4,"+2σ");

   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Lsigma_3);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexLabel(5,"-3σ");

   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,Usigma_3);
   SetIndexEmptyValue(6,EMPTY_VALUE);
   SetIndexLabel(6,"+3σ");

   SetIndexEmptyValue(7,EMPTY_VALUE);
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,Chikou);
   SetIndexShift(7,Chikou_Idou);
   SetIndexLabel(7,"Chikou Span");
 	IndicatorShortName("Otyame005_Super_Bollinger");

 
   return(0);
}
int deinit()
{
   return(0);
}



int start()
{
   int i;
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   for( i = limit -1 ; i>= 0 ; i--) {
      if  ( center_sen == true ) {
         MA[i]   = iMA(NULL,0,MAPeriod,0,MAMethod,PRICE_CLOSE,i);
      }
      else  {
         MA[i] = EMPTY_VALUE;
      }
      
      if  ( sigma_1_sen == true ) {
         Lsigma_1[i]   = iBands(NULL,0,MAPeriod,1,0,PRICE_CLOSE,MODE_LOWER,i);
         Usigma_1[i]   = iBands(NULL,0,MAPeriod,1,0,PRICE_CLOSE,MODE_UPPER,i);
      }
      else {
         Lsigma_1[i]   = EMPTY_VALUE;
         Usigma_1[i]   = EMPTY_VALUE;
      }         
      if  ( sigma_2_sen == true ) {
         Lsigma_2[i]   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,i);
         Usigma_2[i]   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,i);
      }
      else {
         Lsigma_2[i]   = EMPTY_VALUE;
         Usigma_2[i]   = EMPTY_VALUE;
      }         
      if  ( sigma_3_sen == true ) {
         Lsigma_3[i]   = iBands(NULL,0,MAPeriod,3,0,PRICE_CLOSE,MODE_LOWER,i);
         Usigma_3[i]   = iBands(NULL,0,MAPeriod,3,0,PRICE_CLOSE,MODE_UPPER,i);
      }
      else {
         Lsigma_3[i]   = EMPTY_VALUE;
         Usigma_3[i]   = EMPTY_VALUE;
      }
      Chikou[i] = Close[i];
      
      
      if  ( Chikou_sen == false ) {
            Chikou[i]   = EMPTY_VALUE;
      }
   }     
   return(0);
}

