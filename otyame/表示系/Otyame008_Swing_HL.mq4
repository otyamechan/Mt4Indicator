//+------------------------------------------------------------------+
//|                                           Otyame008_Swing_HL.mq4 |
//|                                       2014.05.20                 |
//+------------------------------------------------------------------+

#property copyright   "2015,Otyame Trader"
#property description "Otyame008_Swing_HL"
//#property strict

#property indicator_buffers 2

#property indicator_chart_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta


#property indicator_width1 4
#property indicator_width2 4


//---- buffers
double UpArrow[];
double DownArrow[];

double array1_High[10];
double array1_Low[10];

string message;
extern bool Redraw = false;
extern  int  Signal_Pos = 20;    //5分足考慮
extern  int HL_Check_Candle = 3;

datetime TimeOld = D'1970/01/01 00:00:00';

int init()
{

//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,UpArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,DownArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   IndicatorShortName("Otyame008_Swing_HL");

   return(0);
}
int deinit()
{
   return(0);
}
int start()
{

   int i,y;
   bool Check_flag = false;
   if (Time[0] != TimeOld)                      //時間が更新された場合
   {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      ArrayResize(array1_High,HL_Check_Candle*2+1);
      ArrayResize(array1_Low,HL_Check_Candle*2+1);
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      if ( limit < 2 ) limit = 2;
      for(i= limit-1;i>=1;i--) {
         for ( y= 0;y < HL_Check_Candle*2+1;y++) {
            array1_High[y] = High[i + HL_Check_Candle*2-y];
            array1_Low[y] = Low[i + HL_Check_Candle*2-y];
         }
//高値チェック
         Check_flag = true;
         for ( y= 0;y < HL_Check_Candle*2+1;y++) {
            if ( y < HL_Check_Candle ) {
               if ( array1_High[y] > array1_High[HL_Check_Candle]) {
                  Check_flag = false;
                  break;
               }
            }
            else if ( y > HL_Check_Candle ) { 
               if ( array1_High[y] > array1_High[HL_Check_Candle]) {
                  Check_flag = false;
                  break;
               }
            }
         }
         if ( Check_flag == true ) {
            DownArrow[i+HL_Check_Candle] =High[i+HL_Check_Candle] + Point * Signal_Pos;
         }
         else {
            DownArrow[i+HL_Check_Candle] = EMPTY_VALUE;
         }
//安値チェック
         Check_flag = true;
         for ( y= 0;y < HL_Check_Candle*2+1;y++) {
            if ( y < HL_Check_Candle ) {
               if ( array1_Low[y] < array1_Low[HL_Check_Candle]) {
                  Check_flag = false;
                  break;
               }
            }
            else if ( y > HL_Check_Candle ) { 
               if ( array1_Low[y] < array1_Low[HL_Check_Candle]) {
                  Check_flag = false;
                  break;
               }
            }
         }
         if ( Check_flag == true ) {
            UpArrow[i+HL_Check_Candle] =Low[i+HL_Check_Candle] - Point * Signal_Pos;
         }
         else {
             UpArrow[i+HL_Check_Candle] = EMPTY_VALUE;
         }
         
      }
   }
   return(0);
}
