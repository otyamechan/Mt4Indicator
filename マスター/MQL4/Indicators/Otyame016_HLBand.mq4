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

#property indicator_buffers 3

#property indicator_chart_window

#property indicator_color1 Purple
#property indicator_color2 LightBlue
#property indicator_color3 Pink


#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4


//---- buffers
double BufMed[];
double BufHigh[];
double BufLow[];


extern  int  BandPeriod = 3;    //5分足考慮
extern  int PriceField = 0;

datetime TimeOld = D'1970/01/01 00:00:00';

int init()
{

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,BufMed);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BufHigh);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BufLow);

   return(0);
}
int deinit()
{
   return(0);
}
int start()
{

   int i;
   bool Check_flag = false;
   if (Time[0] != TimeOld)                      //時間が更新された場合
   {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( limit < 2 ) limit = 2;
      for(i= limit-1;i>=1;i--) {
         if ( PriceField == 0 ) {
            BufHigh[i] = High[iHighest(NULL,0,MODE_HIGH,BandPeriod,i)];
            BufLow[i] = Low[iLowest(NULL,0,MODE_LOW,BandPeriod,i)];
         }
         else {
            BufHigh[i] = Close[iHighest(NULL,0,MODE_HIGH,BandPeriod,i)];
            BufLow[i] = Close[iLowest(NULL,0,MODE_LOW,BandPeriod,i)];
         }
         BufMed[i] = ( BufHigh[i] + BufLow[i])/2;
      }
   }
         
         
         

   return(0);
}
