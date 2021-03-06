//+------------------------------------------------------------------+
//|                                        a_MA_CrossAlert_Email.mq4 |
//|   タイムフレームに合わせて                                                                  |
//+------------------------------------------------------------------+

#property copyright "anchan"
#property link      "http://anchan.jp"

#property indicator_buffers 7

#property indicator_chart_window

#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red

//---- buffers
double MA[];
double Usigma_1[];
double Lsigma_1[];
double Usigma_2[];
double Lsigma_2[];
double Usigma_3[];
double Lsigma_3[];



extern int TimeFrame = 0;          //タイムフレーム
extern int MAPeriod = 20;            //中心期間
extern int MAMethod = 0;            //中心線用MA Method
extern bool sigma_1 = true;         //1σ描画
extern bool sigma_2 = true;         //2σ描画
extern bool sigma_3 = true;         //3σ描画


int init()
{

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Lsigma_1);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Usigma_1);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Lsigma_2);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Usigma_2);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Lsigma_3);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,Usigma_3);
   SetIndexEmptyValue(6,EMPTY_VALUE);
 
   return(0);
}
int deinit()
{
   return(0);
}



int start()
{
   int Kikan;
   int i;
   bool writeflag = true;
   if (TimeFrame != 0  && TimeFrame < Period())  {
      writeflag = false;
   }
   else  {
      if (TimeFrame == 0 ) {
         Kikan = MAPeriod;
      }
      else
      {
         Kikan = MAPeriod * (TimeFrame / Period());
         
      } 
   }
   if (writeflag == true ) {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
      if (counted_bars > 0) counted_bars--;
      int limit = Bars - counted_bars;
      for( i = limit -1 ; i>= 0 ; i--) {
         MA[i]   = iMA(NULL,0,Kikan,0,MAMethod,PRICE_CLOSE,i);
         if  ( sigma_1 == true ) {
            Lsigma_1[i]   = iBands(NULL,0,Kikan,1,0,PRICE_CLOSE,MODE_LOWER,i);
            Usigma_1[i]   = iBands(NULL,0,Kikan,1,0,PRICE_CLOSE,MODE_UPPER,i);
         }
         else {
            Lsigma_1[i]   = EMPTY_VALUE;
            Usigma_1[i]   = EMPTY_VALUE;
         }         
         if  ( sigma_2 == true ) {
            Lsigma_2[i]   = iBands(NULL,0,Kikan,2,0,PRICE_CLOSE,MODE_LOWER,i);
            Usigma_2[i]   = iBands(NULL,0,Kikan,2,0,PRICE_CLOSE,MODE_UPPER,i);
         }
         else {
            Lsigma_2[i]   = EMPTY_VALUE;
            Usigma_2[i]   = EMPTY_VALUE;
         }         
         if  ( sigma_3 == true ) {
            Lsigma_3[i]   = iBands(NULL,0,Kikan,3,0,PRICE_CLOSE,MODE_LOWER,i);
            Usigma_3[i]   = iBands(NULL,0,Kikan,3,0,PRICE_CLOSE,MODE_UPPER,i);
         }
         else {
            Lsigma_3[i]   = EMPTY_VALUE;
            Usigma_3[i]   = EMPTY_VALUE;
         }         
      }
   }     
   return(0);
}

