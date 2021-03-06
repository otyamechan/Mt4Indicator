//+------------------------------------------------------------------+
//|                                       Otyame  No.001             |
//|                                       スパンモデル            　 |
//|                                       2014.05.20                 |
//+------------------------------------------------------------------+
/*
  スパンモデルシグナル配信版 
 説明：上位足のスパンモデルのシグナルと売買が一致した時にシグナルを発信する
 　　　時刻を変更しても、対応。下位足のシグナルについては無視する
 
   パラメータ
      Tenkan = 9;          //転換線
      Kijun = 26;          //基準線 
      Senkou = 52;         //先行スパン 
      kansi_5m = true;     //5分足考慮
      kansi_15m = true;    //15分足考慮
      kansi_30m = true;    //30分足考慮
      kansi_1H = true;     //1時間足考慮
      kansi_4H = true;     //4時間足考慮
      kansi_1D = true;     //日足考慮
      AlertON=true;        //アラート表示　
      EmailON=true;        //メール送信

   色
      買い矢印
      売り矢印
      決済矢印（未使用）


*/

#property copyright "Otyame"
#property link      ""

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
