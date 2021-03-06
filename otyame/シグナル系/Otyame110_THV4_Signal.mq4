//+------------------------------------------------------------------+
//|                                       Otyame  No.0023            |
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

#property indicator_buffers 4

#property indicator_chart_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Orange
#property indicator_color4 Lime

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4

#define NO_POSITION  0
#define BUY_POSITION  1 
#define SELL_POSITION  2
#define BUY_KESSAI  11
#define SELL_KESSAI 12

#define GOLLDEN_CROSS  1
#define DED_CROSS   2 
#define UP  3
#define DOWN 4
#define EQUAL 5


//---- buffers
double UpArrow[];
double DownArrow[];
double UpKessaiArrow[];
double DownKessaiArrow[];

string message;
string M15_mes[10],M5_mes[10];

extern bool AlertON=false;        //アラート表示　
extern bool EmailON=true;        //メール送信
extern  bool Redraw = false;    //5分足考慮
extern string _Signal_Setting = "--Signal Setting--";
extern string _Kumo_Senkou1 = "先行スパン１を判断する(true)";
extern bool Kumo_Senkou1 = false;
extern string _Kumo_Senkou2 = "先行スパン２を判断する(true)";
extern bool Kumo_Senkou2 = false;
extern string _Kumo_UpDown = "雲の状態を判断する(true)";
extern bool Kumo_UpDown = true;
extern string _Kumo_Out = "雲抜けを判断する(true)";
extern bool Kumo_Out = false;
extern string _MACD_Cross = "MACDのクロス時のみ(true)";
extern bool  MACD_Cross = false;
extern string _MACD_Filter = "MACDのヒストグラムのチェックをする(true)";
extern bool MACD_Filter = false;
extern string _MACD_Filter_value = "MACDのヒストグラムの値(±）";
extern double MACD_Filter_value = 0.1;


extern  int  Signal_Pos = 20;    //5分足考慮
extern int Localtime = 6;

extern string  _Andy_KumoMTFLine_Setting = "MTF Kumo Setting";
extern int Andy_Timeframe = 30;
extern int Andy_tenkan = 9;
extern int Andy_kijun = 26;
extern int Andy_Senkou = 52;
extern int Andy_Shift = 1;
extern bool Andy_interpolate = true;

//extern string  _Bollinger_Bands_Setting = "Bollinger Bands Setting";
//extern int Bollinger_Bands_Period = 14;
//extern int Bollinger_Bands_Sigma = 2;

extern string  _MTF_Macd2_Setting = "MTF Macd2 Setting";
extern int MTF_Macd2_Timeframe = 30;
extern int MTF_Macd2_FastEMA = 12;
extern int MTF_Macd2_SlowEMA = 26;
extern int MTF_Macd2_SignalEMA = 9;

extern string _Stochastic_MTF_Setting = "Stochastic MTF Setting";
extern int Stochastic_MTF_TimeFrame= 30;
extern int Stochastic_MTF_KPeriod= 9;
extern int Stochastic_MTF_DPeriod= 5;
extern int Stochastic_MTF_Slowing= 5;
extern int Stochastic_MTF_MAMethod= 3;
extern int Stochastic_MTF_PriceField= 1;


extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 10;
extern string symbol1 = "USDJPY";
extern string symbol2 = "EURJPY";
extern string symbol3 = "EURUSD";
extern string symbol4 = "GBPJPY";
extern string symbol5 = "GBPUSD";
extern string symbol6 = "AUDUSD";
extern string symbol7 = "AUDJPY";
extern string symbol8 = "CADJPY";
extern string symbol9 = "EURGBP";
extern string symbol10 = "NZDJPY";
 
bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

datetime TimeOld= D'1970.01.01 00:00:00';


//変数
double Andy_KumoMTFLine_Senkou1[10],Andy_KumoMTFLine_Senkou2[10];
double MTF_Macd2_Signal[10],MTF_Macd2_MACD[10];
double Stochastic_MTF_Signal[10],Stochastic_MTF_MAIN[10];
double Andy_KumoMTFLine_Senkou1_old[10],Andy_KumoMTFLine_Senkou2_old[10];
double MTF_Macd2_Signal_old[10],MTF_Macd2_MACD_old[10];
double MTF_Macd2_Hist_Disp[10],MTF_Macd2_Hist[10],MTF_Macd2_Hist1[10],MTF_Macd2_Hist2[10];
double Stochastic_MTF_Signal_old[10],Stochastic_MTF_MAIN_old[10];


bool buy[10],sell[10];
bool Exit_buy[10],Exit_sell[10];



int O_BandS[10];
int BandS[10];
int Kind[10];
bool symbol_true[10];
int symbol_max;
string symbol_chk[10];
int cnt;
int rtn;
int pos[10];
bool Timeflg = false;
double pos_chk[10];
double pos_UP[10];
bool Senkou1_UPDOWN[10],Senkou2_UPDOWN[10];
int MACD_Info[10];
int Stochastic_Info[10];
int init()
{

//---- indicators
   IndicatorShortName("Otyame120_THV4_symbol_Signal");

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,UpArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,DownArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,253);
   SetIndexBuffer(2,UpKessaiArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,253);
   SetIndexBuffer(3,DownKessaiArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);

   //1時間足設定
  if ( symbol_suu >= 10 ) {
      symbol_max = 10;
   }
   else    symbol_max = symbol_suu;
   symbol_chk[0] = symbol1;
   symbol_chk[1] = symbol2;
   symbol_chk[2] = symbol3;
   symbol_chk[3] = symbol4;
   symbol_chk[4] = symbol5;
   symbol_chk[5] = symbol6;
   symbol_chk[6] = symbol7;
   symbol_chk[7] = symbol8;
   symbol_chk[8] = symbol9;
   symbol_chk[9] = symbol10;
    int i;

 
   if (symbol_max == 0 ) {
      symbol_max = 1;
      symbol_true[0] = true;
      symbol_chk[0] = Symbol();
    }
    else      {
      for ( cnt = 0 ; cnt < symbol_max ; cnt++) {
         pos[cnt] = 0;
         symbol_true[cnt] = true;
         pos_chk[cnt] = MarketInfo(symbol_chk[cnt],MODE_POINT);
         rtn = GetLastError();         
         if ( rtn == ERR_UNKNOWN_SYMBOL ) {
            Print(symbol_chk[cnt]+"は存在しません。 ERR NO = ",rtn);
            symbol_true[cnt] = false;
         }
         else {
            pos_UP[cnt] = 1;
            for ( i = 0 ; pos_chk[cnt] < 1 ;i++) {
               pos[cnt]++;
               pos_chk[cnt] = pos_chk[cnt] * 10;
               pos_UP[cnt] = pos_UP[cnt] * 10;
               
            } 
            pos[cnt]++;
         }
         Senkou1_UPDOWN[cnt] = false;
         Senkou2_UPDOWN[cnt] = false;
      } 
           
   }   
   

   return(0);
}
int deinit()
{
   return(0);
}
int start()
{
   int i;
   if (Time[0] != TimeOld)    {                     //時間が更新された場合
      Timeflg = true;
      for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
         if ( symbol_true[cnt] == true ) {
            if (iTime(symbol_chk[cnt],Period(),0) != Time[0])  {
               Timeflg = false;
               break;
            }
         }
      }                      
   }
   else {
      Timeflg = false;
   }
   if ( Timeflg == true ) {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      if ( limit < 2 ) limit = 2;
      for (  cnt = 0 ; cnt < symbol_max ; cnt++) {  
         for(i= limit-1;i>=1;i--){
            //１H足MACD Rule の計算            
            Andy_KumoMTFLine_Senkou1[cnt] = iCustom(symbol_chk[cnt],0,"Andy_KumoMTFLine", Andy_Timeframe,Andy_tenkan,Andy_kijun,Andy_Senkou,Andy_Shift,Andy_interpolate,5,i);
            Andy_KumoMTFLine_Senkou2[cnt] = iCustom(symbol_chk[cnt],0,"Andy_KumoMTFLine", Andy_Timeframe,Andy_tenkan,Andy_kijun,Andy_Senkou,Andy_Shift,Andy_interpolate,6,i);
            Andy_KumoMTFLine_Senkou1_old[cnt] = iCustom(symbol_chk[cnt],0,"Andy_KumoMTFLine", Andy_Timeframe,Andy_tenkan,Andy_kijun,Andy_Senkou,Andy_Shift,Andy_interpolate,5,i+1);
            Andy_KumoMTFLine_Senkou2_old[cnt] = iCustom(symbol_chk[cnt],0,"Andy_KumoMTFLine", Andy_Timeframe,Andy_tenkan,Andy_kijun,Andy_Senkou,Andy_Shift,Andy_interpolate,6,i+1);
            MTF_Macd2_Signal[cnt] = iCustom(symbol_chk[cnt],0,"#mtf_Macd-2", MTF_Macd2_Timeframe,MTF_Macd2_FastEMA,MTF_Macd2_SlowEMA,MTF_Macd2_SignalEMA,2,i);
            MTF_Macd2_MACD[cnt] = iCustom(symbol_chk[cnt],0,"#mtf_Macd-2", MTF_Macd2_Timeframe,MTF_Macd2_FastEMA,MTF_Macd2_SlowEMA,MTF_Macd2_SignalEMA,3,i);
            MTF_Macd2_Hist1[cnt] = iCustom(symbol_chk[cnt],0,"#mtf_Macd-2", MTF_Macd2_Timeframe,MTF_Macd2_FastEMA,MTF_Macd2_SlowEMA,MTF_Macd2_SignalEMA,0,i);
            MTF_Macd2_Hist2[cnt] = iCustom(symbol_chk[cnt],0,"#mtf_Macd-2", MTF_Macd2_Timeframe,MTF_Macd2_FastEMA,MTF_Macd2_SlowEMA,MTF_Macd2_SignalEMA,1,i);
            MTF_Macd2_Signal_old[cnt] = iCustom(symbol_chk[cnt],0,"#mtf_Macd-2", MTF_Macd2_Timeframe,MTF_Macd2_FastEMA,MTF_Macd2_SlowEMA,MTF_Macd2_SignalEMA,2,i+1);
            MTF_Macd2_MACD_old[cnt] = iCustom(symbol_chk[cnt],0,"#mtf_Macd-2", MTF_Macd2_Timeframe,MTF_Macd2_FastEMA,MTF_Macd2_SlowEMA,MTF_Macd2_SignalEMA,3,i+1);
            Stochastic_MTF_Signal[cnt] = iCustom(symbol_chk[cnt],0,"Stochastic_MTF_w-Alert", "AS",false,0,"TF",Stochastic_MTF_TimeFrame,"SS",Stochastic_MTF_KPeriod,Stochastic_MTF_DPeriod,Stochastic_MTF_Slowing,Stochastic_MTF_MAMethod,Stochastic_MTF_PriceField,1,i);
            Stochastic_MTF_MAIN[cnt] = iCustom(symbol_chk[cnt],0,"Stochastic_MTF_w-Alert", "AS",false,0,"TF",Stochastic_MTF_TimeFrame,"SS",Stochastic_MTF_KPeriod,Stochastic_MTF_DPeriod,Stochastic_MTF_Slowing,Stochastic_MTF_MAMethod,Stochastic_MTF_PriceField,0,i);
            Stochastic_MTF_Signal_old[cnt] = iCustom(symbol_chk[cnt],0,"Stochastic_MTF_w-Alert", "AS",false,0,"TF",Stochastic_MTF_TimeFrame,"SS",Stochastic_MTF_KPeriod,Stochastic_MTF_DPeriod,Stochastic_MTF_Slowing,Stochastic_MTF_MAMethod,Stochastic_MTF_PriceField,1,i+1);
            Stochastic_MTF_MAIN_old[cnt] = iCustom(symbol_chk[cnt],0,"Stochastic_MTF_w-Alert", "AS",false,0,"TF",Stochastic_MTF_TimeFrame,"SS",Stochastic_MTF_KPeriod,Stochastic_MTF_DPeriod,Stochastic_MTF_Slowing,Stochastic_MTF_MAMethod,Stochastic_MTF_PriceField,0,i+1);
            if ( Andy_KumoMTFLine_Senkou1_old[cnt] < Andy_KumoMTFLine_Senkou1[cnt] ) {
               Senkou1_UPDOWN[cnt] = true;
            }
            else if( Andy_KumoMTFLine_Senkou1_old[cnt] > Andy_KumoMTFLine_Senkou1[cnt] ) {
               Senkou1_UPDOWN[cnt] = false;
            }
            if ( Andy_KumoMTFLine_Senkou2_old[cnt] < Andy_KumoMTFLine_Senkou2[cnt] ) {
               Senkou2_UPDOWN[cnt] = true;
            }
            else if( Andy_KumoMTFLine_Senkou2_old[cnt] > Andy_KumoMTFLine_Senkou2[cnt] ) {
               Senkou2_UPDOWN[cnt] = false;
            }


            buy[cnt] = true;
            sell[cnt] = true;
            if(Kumo_Senkou1 == true ) {
               if (Senkou1_UPDOWN[cnt] == false ) {
                  buy[cnt] = false;
               }
               else if ( Senkou1_UPDOWN[cnt] == true ) {
                  sell[cnt] = false;
               }
            }               
            if ( Kumo_Senkou2 == true ) {
               if (Senkou1_UPDOWN[cnt] == false ) {
                  buy[cnt] = false;
               }
               else if ( Senkou2_UPDOWN[cnt] == true ) {
                  sell[cnt] = false;
               }
            }               
            if ( Kumo_UpDown == true ) {
               if (Andy_KumoMTFLine_Senkou2[cnt] >= Andy_KumoMTFLine_Senkou1[cnt] ) {
                  buy[cnt] = false;
               }
               else if ( Andy_KumoMTFLine_Senkou2[cnt] <= Andy_KumoMTFLine_Senkou1[cnt] ) {
                  sell[cnt] = false;
               }
            }               
            if ( Kumo_Out == true ) {
               if ( iClose(symbol_chk[cnt],0,i) < Andy_KumoMTFLine_Senkou1[cnt] ) {
                  buy[cnt] = false;
               }
               else if ( iClose(symbol_chk[cnt],0,i) > Andy_KumoMTFLine_Senkou1[cnt] ) {
                  sell[cnt] = false;
               }
            }               
//            Print(TimeToStr(Time[i],TIME_DATE|TIME_MINUTES)," Spread =",MarketInfo(symbol_chk[cnt],MODE_SPREAD)* Point);
            MACD_Info[cnt] = -1;
            if (( MTF_Macd2_Signal_old[cnt] <=  MTF_Macd2_MACD_old[cnt] ) && ( MTF_Macd2_Signal[cnt] >  MTF_Macd2_MACD[cnt] )){
               MACD_Info[cnt] = GOLLDEN_CROSS;
            }
            else if(( MTF_Macd2_Signal_old[cnt] <=  MTF_Macd2_MACD_old[cnt] ) && ( MTF_Macd2_Signal[cnt] >  MTF_Macd2_MACD[cnt] )) {
               MACD_Info[cnt] = DED_CROSS;
            }
            else if ( MTF_Macd2_Signal[cnt] >  MTF_Macd2_MACD[cnt] ) {
               MACD_Info[cnt] = UP;
            }
            else if ( MTF_Macd2_Signal[cnt] <  MTF_Macd2_MACD[cnt] ) {
               MACD_Info[cnt] = DOWN;
            }
            else if ( MTF_Macd2_Signal[cnt] ==  MTF_Macd2_MACD[cnt] ) {
               MACD_Info[cnt] = EQUAL;
            }
            switch(MACD_Info[cnt] ) {
               case GOLLDEN_CROSS:
                  sell[cnt] = false;
                  break;
               case DED_CROSS:
                  buy[cnt] = false;
                  break;
               case UP:
                  sell[cnt] = false;
                  if ( MACD_Cross == true ) {
                     buy[cnt] = false;
                  }
                  break;
               case DOWN:
                  buy[cnt] = false;
                  if ( MACD_Cross == true ) {
                     sell[cnt] = false;
                  }
                  break;
               case EQUAL:
                  buy[cnt] = false;
                  sell[cnt] = false;
                  break;
            }
            if ( NormalizeDouble(MTF_Macd2_Hist1[cnt],pos[cnt]) == 0.0 ) {
               MTF_Macd2_Hist_Disp[cnt] = MTF_Macd2_Hist2[cnt];
            }
            else if ( NormalizeDouble(MTF_Macd2_Hist2[cnt],pos[cnt]) == 0.0 ) {
               MTF_Macd2_Hist_Disp[cnt] = MTF_Macd2_Hist1[cnt];
            }
            MTF_Macd2_Hist1[cnt] = MTF_Macd2_Hist1[cnt] * pos_UP[cnt] / 100; 
            MTF_Macd2_Hist2[cnt] = MTF_Macd2_Hist2[cnt] * pos_UP[cnt] / 100; 
//            Print(TimeToStr(Time[i],TIME_DATE|TIME_MINUTES)," ","Hist1 = " ,MTF_Macd2_Hist1[0],"Hist2 = " ,MTF_Macd2_Hist2[0]);
//            Print(TimeToStr(Time[i],TIME_DATE|TIME_MINUTES)," ","buy = ",buy[0]," sell= ",sell[0]);
            if ( MACD_Filter == true ) {
               if ( NormalizeDouble(MTF_Macd2_Hist1[cnt],pos[cnt]) == 0.0 ) {
                  MTF_Macd2_Hist[cnt] = MathAbs(MTF_Macd2_Hist2[cnt]);
               }
               else if ( NormalizeDouble(MTF_Macd2_Hist2[cnt],pos[cnt]) == 0.0 ) {
                  MTF_Macd2_Hist[cnt] = MathAbs(MTF_Macd2_Hist1[cnt]);
               }
               if ( MTF_Macd2_Hist[cnt] <= MACD_Filter_value ) {
                  buy[cnt] = false;
                  sell[cnt] = false;
               }
            }

            Stochastic_Info[cnt] = -1;
            if (( Stochastic_MTF_Signal_old[cnt] <=  Stochastic_MTF_MAIN_old[cnt] ) && ( Stochastic_MTF_Signal[cnt] >  Stochastic_MTF_MAIN[cnt] )){
               Stochastic_Info[cnt] = GOLLDEN_CROSS;
            }
            else if(( Stochastic_MTF_Signal_old[cnt] <=  Stochastic_MTF_MAIN_old[cnt] ) && ( Stochastic_MTF_Signal[cnt] >  Stochastic_MTF_MAIN[cnt] )) {
               Stochastic_Info[cnt] = DED_CROSS;
            }
            else if ( Stochastic_MTF_Signal[cnt] >  Stochastic_MTF_MAIN[cnt] ) {
               Stochastic_Info[cnt] = UP;
            }
            else if ( Stochastic_MTF_Signal[cnt] <  Stochastic_MTF_MAIN[cnt] ) {
               Stochastic_Info[cnt] = DOWN;
            }
            else if ( Stochastic_MTF_Signal[cnt] ==  Stochastic_MTF_MAIN[cnt] ) {
               Stochastic_Info[cnt] = EQUAL;
            }
            Exit_buy[cnt] = true;
            Exit_sell[cnt] = true;
//            Print(TimeToStr(Time[i],TIME_DATE|TIME_MINUTES)," ","buy = ",buy[0]," sell= ",sell[0]," Stochastic_Info = ",Stochastic_Info[0]," MAIN = ",Stochastic_MTF_MAIN[0]," Signal = ",Stochastic_MTF_Signal[0]);

            switch(Stochastic_Info[cnt] ) {
               case GOLLDEN_CROSS:
                  sell[cnt] = false;
                  Exit_sell[cnt] = false;
                  break;
               case DED_CROSS:
                  buy[cnt] = false;
                  Exit_buy[cnt] = false;
                  break;
               case UP:
                  sell[cnt] = false;
                  Exit_sell[cnt] = false;
                  break;
               case DOWN:
                  buy[cnt] = false;
                  Exit_buy[cnt] = false;
                  break;
               case EQUAL:
                  buy[cnt] = false;
                  sell[cnt] = false;
                  Exit_buy[cnt] = false;
                  Exit_sell[cnt] = false;
                  break;
            }
            switch( O_BandS[cnt] ) {
               case NO_POSITION:
                  if ( buy[cnt] == true ) {
                     BandS[cnt] = BUY_POSITION;
                     Kind[cnt] = BUY_POSITION;
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpArrow[i]=Low[i] - Point * Signal_Pos;
                     }
                  }                     
                  else if ( sell[cnt] == true ) {
                     BandS[cnt] = SELL_POSITION;
                     Kind[cnt] = SELL_POSITION;
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownArrow[i]=High[i] + Point * Signal_Pos;
                     }
                  }
                  else {
                     BandS[cnt] = NO_POSITION;
                     Kind[cnt] = NO_POSITION;
                  }                                       
                  break;
               case BUY_POSITION:
                  if ( Exit_buy[cnt] == true ) {
                     BandS[cnt] = BUY_POSITION;
                     Kind[cnt] = 0;
                  }
                  else {
                     BandS[cnt] = NO_POSITION;
                     Kind[cnt] = BUY_KESSAI;
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpKessaiArrow[i]=High[i] + Point * Signal_Pos;
                     }
                  }
                  break;
               case SELL_POSITION:
                  if ( Exit_sell[cnt] == true ) {
                     BandS[cnt] = SELL_POSITION;
                     Kind[cnt] = 0;
                  }
                  else {
                     BandS[cnt] = NO_POSITION;
                     Kind[cnt] = SELL_KESSAI;
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownKessaiArrow[i]=Low[i]  - Point * Signal_Pos;
                     }
                  }
                  break;         
            }
            O_BandS[cnt] = BandS[cnt];
         }
      }
      datetime a = D'1970.01.01 00:00:00'; 
      if ( TimeOld != a ) { 
         Emailflag = EmailON;                      //メール送信設定
         Alertflag = AlertON;                      //アラート出力設定
      }
      else
      {   
         Emailflag = false;                      //メール送信設定
         Alertflag = false;                      //アラート出力設定
      }         
      TimeOld = Time[0];                        //時間を更新
      if (Emailflag== true) {
          for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
            if (symbol_true[cnt] == false ) {
               continue;
            }
            switch(Kind[cnt])   {
            case BUY_POSITION:
               message= "買いシグナル!!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
               break;
            case SELL_POSITION:
               message= "売りシグナル!!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
               break;
            case BUY_KESSAI:
               message= "買い決済 "+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
               break;
            case SELL_KESSAI:
               message= "売り決済"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
               break;
            }
              message = message + "\r\n"+"先行1:" + Andy_KumoMTFLine_Senkou1[cnt];
              message = message + "\r\n"+"先行2:" + Andy_KumoMTFLine_Senkou2[cnt];
              message = message +  "\r\n"+"MACD:"+MTF_Macd2_MACD[cnt];
              message = message +  "\r\n"+"MACD Signal:"+MTF_Macd2_Signal[cnt];
              message = message +  "\r\n"+"MACD Histgram:"+MTF_Macd2_Hist_Disp[cnt];
              message = message +  "\r\n"+"ST Main:"+Stochastic_MTF_MAIN[cnt];
              message = message +  "\r\n"+"ST Signal:"+Stochastic_MTF_Signal_old[cnt];
//            message = message +  "\r\n"+H1_CHIKO_mes[cnt];
//            message = message +  "\r\n"+M15_SPAN_mes[cnt];
         
//            message = message +  "\r\n"+M15_CHIKO_mes[cnt];
//            message = message +  "\r\n"+M5_MACD_Rule_mes[cnt];
//            message = message +  "\r\n"+M5_SPAN_mes[cnt];
//            message = message +  "\r\n"+M5_CHIKO_mes[cnt];

            if ( Kind[cnt] != 0 ) SendMail("THV4ルール " +"["+symbol_chk[cnt]+"]["+Period()+"]",message);
         }      
      }
      Emailflag = false;      
      if (Alertflag== true) {
         for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
 
            if (symbol_true[cnt] == false ) {
               continue;
            }

      
            if (Alertflag== true) {
               switch(Kind[cnt])   {
               case BUY_POSITION:
                  Alert("THV4 Rule BUY Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case SELL_POSITION:
                  Alert("THV4 Rule SELL Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case BUY_KESSAI:
                  Alert("THV4 Rule BUY Kessai Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case SELL_KESSAI:
                  Alert("THV4 Rule SELl Kessai Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               }
            }
         }
      }
      Alertflag = false;
   }
   return(0);
}

