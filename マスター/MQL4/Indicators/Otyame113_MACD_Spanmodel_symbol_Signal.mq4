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
#property indicator_color3 Black
#property indicator_color4 Black

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4

#define NO_POSITION  0
#define BUY_POSITION  1 
#define SELL_POSITION  2
#define BUY_KESSAI  11
#define SELL_KESSAI 12

#define MACD_UP 2
#define MACD_DOWN 1
#define MACD_NO 0
#define MA_UP 2
#define MA_DOWN 1
#define MA_NO 0
#define CHIKO_UP 2
#define CHIKO_DOWN 1
#define CHIKO_NO 0
#define SPAN_UP 2
#define SPAN_DOWN 1
#define SPAN_NO 0


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

extern string _ALL_Setting = "ALL Setting";
extern int Compare_Period = 60;

extern string _H1_Setting = "1JIKAN ASHI Setting";
extern bool H1_MACD_Rule_Check_Entry = true;
extern bool H1_MACD_Rule_Check_Exit = true;
extern string _MACD_Rule_Setting= "MACD Rule Setting";
extern string _MODE_Seting = "JissenKai = true:JISSENKAI ON false:JISSENKAI OFF";
extern bool JissenKai = true; 
extern int _H1_MACD_Period = 20;           	//MACD 短期
extern int H1_MACD_Method = 3;         	//MACD ＷＭＡ
extern int _H1_Signal_MAPeriod = 5;      	//MACD MA期間
extern int H1_Signal_MAMethod = 3;      	//MACD
extern int _H1_MACD_MA_Period= 20;
extern int H1_MACD_MA_Method = 0;

extern string _MA_Setting= "MA Setting";
extern bool H1_MA_Check_Entry = true;
extern bool H1_MA_Check_Exit = true;
extern string _MA = "MA";
extern int  _H1_MA_Period= 21;
extern int _H1_MA_Method = 0;

extern string _1H_Chiko_Span_Setting= "Chiko Span_Setting";
extern bool H1_Chiko_Check_Entry  = false;
extern bool H1_Chiko_Check_Exit  = false;
extern int  H1_Chiko_Time= 20;

extern string _15M_Setting = "15FUN ASHI Setting";
extern bool M15_Span_model_Check_Entry = true;
extern bool M15_Span_model_Check_Exit = true;
extern int M15_Tenkan = 9;           //転換線
extern int M15_Kijun = 25;           //基準線 
extern int M15_Senkou = 52;          //先行スパン 
extern bool M15_Chiko_Check_Entry  = false;
extern bool M15_Chiko_Check_Exit  = false;

extern string _5M_Setting = "5FUN ASHI Setting";
extern bool M5_MACD_Rule_Check_Entry = false;
extern bool M5_MACD_Rule_Check_Exit = false;
extern int _M5_MACD_Period = 20;           	//MACD 短期
extern int M5_MACD_Method = 3;         	//MACD ＷＭＡ
extern int _M5_Signal_MAPeriod = 5;      	//MACD MA期間
extern int M5_Signal_MAMethod = 3;      	//MACD
extern int _M5_MACD_MA_Period= 20;
extern int M5_MACD_MA_Method = 0;

extern bool M5_Span_model_Check_Entry = true;
extern bool M5_Span_model_Check_Exit = true;
extern int M5_Tenkan = 9;           //転換線
extern int M5_Kijun = 25;           //基準線 
extern int M5_Senkou = 52;          //先行スパン 
extern bool M5_Chiko_Check_Entry = false;
extern bool M5_Chiko_Check_Exit = false;

extern  int  Signal_Pos = 20;    //5分足考慮
extern int Localtime = 6;

extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 10;
extern string symbol1 = "USDJPY";
extern string symbol2 = "EURJPY";
extern string symbol3 = "EURUSD";
extern string symbol4 = "GBPJPY";
extern string symbol5 = "AUDJPY";
extern string symbol6 = "AUDUSD";
extern string symbol7 = "GBPUSD";
extern string symbol8 = "CADJPY";
extern string symbol9 = "EURGBP";
extern string symbol10 = "NZDJPY";
 
bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

datetime TimeOld= D'1970.01.01 00:00:00';
datetime k15mtime[];             //15分足格納用
datetime k1Htime[];              //1時間足格納用


//変数
int c_15m,c_1H;         //時間位置
int H1_Chk_candle,M5_Chk_candle;
int H1_FastMAPeriod,H1_SlowMAPeriod,H1_SignalMAPeriod;
int H1_MACD_MAPeriod;
int M5_FastMAPeriod,M5_SlowMAPeriod,M5_SignalMAPeriod;
int M5_MACD_MAPeriod;

double H1_MACD_0[10],H1_MACD_1[10],H1_MACD_MA_0[10],H1_MACD_MA_1[10],H1_MACD_MA_0_J[10],H1_MACD_MA_1_J[10];
double H1_MA_0[10],H1_MA_1[10];
double M5_MACD_0[10],M5_MACD_1[10],M5_MACD_MA_0[10],M5_MACD_MA_1[10];
double M15_Sen1[10],M15_Sen2[10];
double M5_Sen1[10],M5_Sen2[10];

int H1_MACD_Rule[10],M5_MACD_Rule[10];
int H1_MA[10],H1_CHIKO[10];
int M15_SPAN[10],M15_CHIKO[10];
int M5_SPAN[10],M5_CHIKO[10];

bool Entry_buy[10],Exit_buy[10];
bool Entry_sell[10],Exit_sell[10];

string H1_MACD_Rule_mes[10],M5_MACD_Rule_mes[10];
string H1_MA_mes[10],H1_CHIKO_mes[10];
string M15_SPAN_mes[10],M15_CHIKO_mes[10];
string M5_SPAN_mes[10],M5_CHIKO_mes[10];

datetime H1_MACD_Rule_time[10],M5_MACD_Rule_time[10];
datetime H1_MA_time[10],H1_CHIKO_time[10];
datetime M15_SPAN_time[10],M15_CHIKO_time[10];
datetime M5_SPAN_time[10],M5_CHIKO_time[10];

int H1_MACD_Rule_time_set[10],M5_MACD_Rule_time_set[10];
int H1_MA_time_set[10],H1_CHIKO_time_set[10];
int M15_SPAN_time_set[10],M15_CHIKO_time_set[10];
int M5_SPAN_time_set[10],M5_CHIKO_time_set[10];

int count_15m ;     //15分足時間格納
int count_1H ;       //1時間足時間格納

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
double pos_chk;
bool buy[10];
bool sell[10];

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
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,234);
   SetIndexBuffer(2,UpKessaiArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,DownKessaiArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);

   //1時間足設定
   if ( Compare_Period < PERIOD_H1 ) {
	   H1_Chk_candle = 1;
   }
   else  {
	   H1_Chk_candle = Compare_Period / PERIOD_H1 ;
   }      
   if ( JissenKai == false ) {
      H1_FastMAPeriod = _H1_MACD_Period * PERIOD_H4 / PERIOD_H1;
      H1_SlowMAPeriod = _H1_MACD_Period * PERIOD_D1 / PERIOD_H1;
      H1_SignalMAPeriod = _H1_Signal_MAPeriod * PERIOD_H4 /PERIOD_H1;
      H1_MACD_MAPeriod = _H1_MACD_MA_Period * PERIOD_D1 / PERIOD_H1;
   }
   else  {
      H1_FastMAPeriod = _H1_MACD_Period;
      H1_SlowMAPeriod = _H1_MACD_Period * PERIOD_H4 /PERIOD_H1;
      H1_SignalMAPeriod= 8;
      H1_MACD_MAPeriod = 52;
      H1_MACD_MA_Method = 3;
   }                  
   //5分足設定
   if ( Compare_Period < PERIOD_M5 ) {
      M5_Chk_candle = 1;
   }
   else  {
	   M5_Chk_candle = Compare_Period / PERIOD_M5 ;
   }      
   M5_FastMAPeriod = _M5_MACD_Period * PERIOD_M15 /PERIOD_M5;
   M5_SlowMAPeriod = _M5_MACD_Period * PERIOD_H1 / PERIOD_M5;
   M5_SignalMAPeriod =_M5_Signal_MAPeriod * PERIOD_M15 /PERIOD_M5;
   M5_MACD_MAPeriod = _M5_MACD_MA_Period * PERIOD_H1 / PERIOD_M5;
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
         pos_chk = MarketInfo(symbol_chk[cnt],MODE_POINT);
         rtn = GetLastError();         
         if ( rtn == ERR_UNKNOWN_SYMBOL ) {
            Print(symbol_chk[cnt]+"は存在しません。 ERR NO = ",rtn);
            symbol_true[cnt] = false;
         }
         else {
            for ( i = 0 ; pos_chk < 1 ;i++) {
               pos[cnt]++;
               pos_chk = pos_chk * 10;
            } 
            pos[cnt]++;
         }
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
      count_15m = ArrayCopySeries(k15mtime,MODE_TIME,Symbol(),PERIOD_M15);     //15分足時間格納
      count_1H = ArrayCopySeries(k1Htime,MODE_TIME,Symbol(),PERIOD_H1);       //1時間足時間格納
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
            if (Period() != PERIOD_M5 ) continue; 

 
            c_1H = iBarShift(NULL,PERIOD_H1,Time[i],true);
            if ( k1Htime[c_1H] > Time[i] ) {
               c_1H++;
            }            
            c_15m = iBarShift(NULL,PERIOD_M15,Time[i],true);
            if ( k15mtime[c_15m] > Time[i] ) {
               c_15m++;
            }
             if (c_1H == 0 ) c_1H++;
            if (c_15m == 0 ) c_15m++;

            //１H足MACD Rule の計算            
            H1_MACD_0[cnt] = iCustom(symbol_chk[cnt],PERIOD_H1,"MACD++",H1_FastMAPeriod,H1_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",H1_MACD_Method,H1_SignalMAPeriod,H1_Signal_MAMethod,false,0,1,c_1H);
            H1_MACD_1[cnt] = iCustom(symbol_chk[cnt],PERIOD_H1,"MACD++",H1_FastMAPeriod,H1_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",H1_MACD_Method,H1_SignalMAPeriod,H1_Signal_MAMethod,false,0,1,c_1H+H1_Chk_candle);
            H1_MACD_MA_0[cnt] = iMA(symbol_chk[cnt],PERIOD_H1,H1_MACD_MAPeriod,0,H1_MACD_MA_Method,PRICE_CLOSE,c_1H);
            H1_MACD_MA_1[cnt] = iMA(symbol_chk[cnt],PERIOD_H1,H1_MACD_MAPeriod,0,H1_MACD_MA_Method,PRICE_CLOSE,c_1H+H1_Chk_candle);
            H1_MACD_MA_0_J[cnt] = iMA(symbol_chk[cnt],PERIOD_H1,480,0,0,PRICE_CLOSE,c_1H);
            H1_MACD_MA_1_J[cnt] = iMA(symbol_chk[cnt],PERIOD_H1,480,0,0,PRICE_CLOSE,c_1H+H1_Chk_candle);

         
            //1時間足　移動平均線の計算            
            H1_MA_0[cnt] = iMA(symbol_chk[cnt],PERIOD_H1,_H1_MA_Period,0,_H1_MA_Method,PRICE_CLOSE,c_1H);
            H1_MA_1[cnt] = iMA(symbol_chk[cnt],PERIOD_H1,_H1_MA_Period,0,_H1_MA_Method,PRICE_CLOSE,c_1H+H1_Chk_candle);

            //15分足　スパンモデル　            
            M15_Sen1[cnt] = iCustom(symbol_chk[cnt],PERIOD_M15,"span_model",M15_Kijun,M15_Tenkan,M15_Senkou,5,c_15m);
            M15_Sen2[cnt] = iCustom(symbol_chk[cnt],PERIOD_M15,"span_model",M15_Kijun,M15_Tenkan,M15_Senkou,6,c_15m);

            //5H足MACD Rule の計算            
            M5_MACD_0[cnt] = iCustom(symbol_chk[cnt],PERIOD_M5,"MACD++",M5_FastMAPeriod,M5_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",M5_MACD_Method,M5_SignalMAPeriod,M5_Signal_MAMethod,false,0,1,i);
            M5_MACD_1[cnt] = iCustom(symbol_chk[cnt],PERIOD_M5,"MACD++",M5_FastMAPeriod,M5_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",M5_MACD_Method,M5_SignalMAPeriod,M5_Signal_MAMethod,false,0,1,i+M5_Chk_candle);
            M5_MACD_MA_0[cnt] = iMA(symbol_chk[cnt],PERIOD_M5,M5_MACD_MAPeriod,0,M5_MACD_MA_Method,PRICE_CLOSE,i);
            M5_MACD_MA_1[cnt] = iMA(symbol_chk[cnt],PERIOD_M5,M5_MACD_MAPeriod,0,M5_MACD_MA_Method,PRICE_CLOSE,i+M5_Chk_candle);

            //5分足　スパンモデル　            
            M5_Sen1[cnt] = iCustom(symbol_chk[cnt],PERIOD_M5,"span_model",M5_Kijun,M5_Tenkan,M5_Senkou,5,i);
            M5_Sen2[cnt] = iCustom(symbol_chk[cnt],PERIOD_M5,"span_model",M5_Kijun,M5_Tenkan,M5_Senkou,6,i);



//1時間足MACDルール判定
            if (( H1_MACD_1[cnt] - H1_MACD_0[cnt] ) > 0)   {        //MACD下降中
                  if (( H1_MACD_MA_1[cnt] - H1_MACD_MA_0[cnt] ) >= 0) {                     //MA下降中
                     H1_MACD_Rule[cnt] = MACD_DOWN;                               //MACDルール下降中と成立
                     if ( H1_MACD_Rule_time_set[cnt] != MACD_DOWN ) {
                        H1_MACD_Rule_time[cnt] = k1Htime[c_1H] + 3600 * Localtime;
                     }
                     H1_MACD_Rule_time_set[cnt] = MACD_DOWN;
                  }
                  else  {
                     H1_MACD_Rule[cnt] = MACD_NO;                            //MACDルール下降成立
                     H1_MACD_Rule_time_set[cnt] = MACD_NO;
                  }
               }
               else if (( H1_MACD_1[cnt] - H1_MACD_0[cnt] ) <0 )  {  //MACD上昇中
                  if (( H1_MA_1[cnt] - H1_MA_0[cnt] ) <= 0 ) {                //MAは下降中
                     H1_MACD_Rule[cnt] = MACD_UP;                                     //MACDルール不成立
                     if ( H1_MACD_Rule_time_set[cnt] != MACD_UP ) {
                        H1_MACD_Rule_time[cnt] = k1Htime[c_1H] + 3600 * Localtime;
                     }
                     H1_MACD_Rule_time_set[cnt] = MACD_UP;
                  }
                  else  {
                     H1_MACD_Rule[cnt] = MACD_NO;                                     //MACDルール上昇成立
                     H1_MACD_Rule_time_set[cnt] = MACD_NO;
                  }
               }
               else if ((H1_MACD_1[cnt] - H1_MACD_0[cnt] ) == 0 ) { 
                  if ((  H1_MA_1[cnt] - H1_MA_0[cnt] ) > 0)    {  
                     H1_MACD_Rule[cnt] = MACD_DOWN;                            //MACDルール不成立
                     if ( H1_MACD_Rule_time_set[cnt] != MACD_DOWN ) {
                        H1_MACD_Rule_time[cnt] = k1Htime[c_1H] + 3600 * Localtime;
                     }
                     H1_MACD_Rule_time_set[cnt] = MACD_DOWN;
                  }
                  else if (( H1_MACD_MA_1[cnt] - H1_MACD_MA_0[cnt] ) < 0 ){
                     H1_MACD_Rule[cnt] = MACD_UP;                            //MACDルール不成立
                     if ( H1_MACD_Rule_time_set[cnt] != MACD_UP ) {
                        H1_MACD_Rule_time[cnt] = k1Htime[c_1H] + 3600 * Localtime;
                     }
                     H1_MACD_Rule_time_set[cnt] = MACD_UP;
                  }
                  else  {
                     H1_MACD_Rule[cnt] = MACD_NO;                                     //MACDルール上昇成立
                     H1_MACD_Rule_time_set[cnt] = MACD_NO;
                  }

               }
//1時間足移動平均線判定
               if ((  H1_MA_1[cnt] - H1_MA_0[cnt] ) > 0)    {
                  H1_MA[cnt] = MA_DOWN;
                  if ( H1_MA_time_set[cnt] != MA_DOWN ) {
                     H1_MA_time[cnt] = k1Htime[c_1H] + 3600 * Localtime;
                  }
                  H1_MA_time_set[cnt] = MA_DOWN;
               }  
               else if ((  H1_MA_1[cnt] - H1_MA_0[cnt] ) < 0)    {
                  H1_MA[cnt] = MA_UP;
                  if ( H1_MA_time_set[cnt] != MA_UP ) {
                     H1_MA_time[cnt] = k1Htime[c_1H] + 3600 * Localtime;
                  }
                  H1_MA_time_set[cnt] = MA_UP;

               }
               else {
                  H1_MA[cnt] = MA_NO;
                  H1_MA_time_set[cnt] = MA_NO;
               }
//1時間足遅行スパン判定
               if ( iClose(symbol_chk[cnt],PERIOD_H1,c_1H) > iClose(symbol_chk[cnt],PERIOD_H1,c_1H+H1_Chiko_Time)) {
                  H1_CHIKO[cnt] = CHIKO_UP;
                  if ( H1_CHIKO_time_set[cnt] != CHIKO_UP ) {
                     H1_CHIKO_time[cnt] = k1Htime[c_1H] + 3600 * Localtime;
                  }
                  H1_CHIKO_time_set[cnt] = CHIKO_UP;

               }
               else if ( iClose(symbol_chk[cnt],PERIOD_H1,c_1H) < iClose(symbol_chk[cnt],PERIOD_H1,c_1H+H1_Chiko_Time)) { 
                  H1_CHIKO[cnt] = CHIKO_DOWN;
                  if ( H1_CHIKO_time_set[cnt] != CHIKO_DOWN ) {
                     H1_CHIKO_time[cnt] = k1Htime[c_1H] + 3600 * Localtime;
                  }
                  H1_CHIKO_time_set[cnt] = CHIKO_DOWN;
               }
               else  {
                  H1_CHIKO[cnt] = CHIKO_NO;
                  H1_CHIKO_time_set[cnt] = CHIKO_NO;
               }            

//15分足スパンモデル判定
               if ( M15_Sen1[cnt] > M15_Sen2[cnt] ) {
                  M15_SPAN[cnt] = SPAN_UP;
                  if ( M15_SPAN_time_set[cnt] != SPAN_UP ) {
                     M15_SPAN_time[cnt] = k15mtime[c_15m] + 3600 * Localtime;
                  }
                  M15_SPAN_time_set[cnt] = SPAN_UP;
               }
               else if ( M15_Sen1[cnt] < M15_Sen2[cnt] ) {            
                  M15_SPAN[cnt] = SPAN_DOWN;
                  if ( M15_SPAN_time_set[cnt] != SPAN_DOWN ) {
                     M15_SPAN_time[cnt] = k15mtime[c_15m] + 3600 * Localtime;
                  }
                  M15_SPAN_time_set[cnt] = SPAN_DOWN;
               }
               else  {
                  M15_SPAN[cnt] = SPAN_NO;
                  M15_SPAN_time_set[cnt] = SPAN_NO;
               }            
 //15分足遅行スパン判定
               if ( iClose(symbol_chk[cnt],PERIOD_M15,c_15m) > iClose(symbol_chk[cnt],PERIOD_M15,c_15m+25)) {
                  M15_CHIKO[cnt] = CHIKO_UP;
                  if ( M15_CHIKO_time_set[cnt] != CHIKO_UP ) {
                     M15_CHIKO_time[cnt] = k15mtime[c_15m] + 3600 * Localtime;
                  }
                  M15_CHIKO_time_set[cnt] = CHIKO_UP;
               }
               else if ( iClose(symbol_chk[cnt],PERIOD_M15,c_15m) < iClose(symbol_chk[cnt],PERIOD_M15,c_15m+25)) {
                  M15_CHIKO[cnt] = CHIKO_DOWN;
                  if ( M15_CHIKO_time_set[cnt] != CHIKO_DOWN ) {
                     M15_CHIKO_time[cnt] = k15mtime[c_15m] + 3600 * Localtime;
                  }
                  M15_CHIKO_time_set[cnt] = CHIKO_DOWN;
               }
               else  {
                  M15_CHIKO[cnt] = CHIKO_NO;
                  M15_CHIKO_time_set[cnt] = CHIKO_NO;
               }
//5分足MACDルール判定
               if (( M5_MACD_1[cnt] - M5_MACD_0[cnt] ) > 0)   {        //MACD下降中
                  if (( M5_MACD_MA_1[cnt] - M5_MACD_MA_0[cnt] ) >= 0) {                     //MA下降中
                     M5_MACD_Rule[cnt] = MACD_DOWN;                               //MACDルール下降中と成立
                     if ( M5_MACD_Rule_time_set[cnt] != MACD_DOWN ) {
                        M5_MACD_Rule_time[cnt] = Time[i] + 3600 * Localtime;
                     }
                     M5_MACD_Rule_time_set[cnt] = MACD_DOWN;
                  }
                  else  {
                     M5_MACD_Rule[cnt] = MACD_NO;                            //MACDルール下降成立
                     M5_MACD_Rule_time_set[cnt] = MACD_NO;
                  }
               }
               else if (( M5_MACD_1[cnt] - M5_MACD_0[cnt] ) <0 )   {  //MACD上昇中
                  if (( M5_MACD_MA_1[cnt] - M5_MACD_MA_0[cnt] ) <= 0 ) {                //MAは下降中
                     M5_MACD_Rule[cnt] = MACD_UP;                                     //MACDルール不成立
                     if ( M5_MACD_Rule_time_set[cnt] != MACD_UP ) {
                        M5_MACD_Rule_time[cnt] = Time[i] + 3600 * Localtime;
                     }
                     M5_MACD_Rule_time_set[cnt] = MACD_UP;
                  }
                  else  {
                     M5_MACD_Rule[cnt] = MACD_NO;                                     //MACDルール上昇成立
                     M5_MACD_Rule_time_set[cnt] = MACD_NO;
                  }
               }
               else if ((M5_MACD_1[cnt] - M5_MACD_0[cnt] )  ==0 ) { 
                  if ((  M5_MACD_MA_1[cnt] - M5_MACD_MA_0[cnt] ) >  0)    {  
                     M5_MACD_Rule[cnt] = MACD_DOWN;                            //MACDルール不成立
                     if ( M5_MACD_Rule_time_set[cnt] != MACD_DOWN ) {
                        M5_MACD_Rule_time[cnt] = Time[i] + 3600 * Localtime;
                     }
                     M5_MACD_Rule_time_set[cnt] = MACD_DOWN;
                  }
                  else if (( M5_MACD_MA_1[cnt] - M5_MACD_MA_0[cnt] ) < 0 ){
                     M5_MACD_Rule[cnt] = MACD_UP;                            //MACDルール不成立
                     if ( M5_MACD_Rule_time_set[cnt] != MACD_UP ) {
                        M5_MACD_Rule_time[cnt] = Time[i] + 3600 * Localtime;
                     }
                     M5_MACD_Rule_time_set[cnt] = MACD_UP;
                  }
                  else  {
                     M5_MACD_Rule[cnt] = MACD_NO;                                     //MACDルール上昇成立
                     M5_MACD_Rule_time_set[cnt] = MACD_NO;
                  }

               }

//5分足スパンモデル判定
               if ( M5_Sen1[cnt] > M5_Sen2[cnt] ) {
                  M5_SPAN[cnt] = SPAN_UP;
                  if ( M5_SPAN_time_set[cnt] != SPAN_UP ) {
                     M5_SPAN_time[cnt] = Time[i] + 3600 * Localtime;
                  }
                  M5_SPAN_time_set[cnt] = SPAN_UP;
               }
               else if ( M5_Sen1[cnt] < M5_Sen2[cnt] ) {            
                  M5_SPAN[cnt] = SPAN_DOWN;
                  if ( M5_SPAN_time_set[cnt] != SPAN_DOWN ) {
                     M5_SPAN_time[cnt] = Time[i] + 3600 * Localtime;
                  }
                  M5_SPAN_time_set[cnt] = SPAN_DOWN;
               }
               else  {
                  M5_SPAN[cnt] = SPAN_NO;
                  M5_SPAN_time_set[cnt] = SPAN_NO;
               }            
//5分足遅行スパン判定
               if ( iClose(symbol_chk[cnt],PERIOD_M5,i) > iClose(symbol_chk[cnt],PERIOD_M5,i+25)) {
                  M5_CHIKO[cnt] = CHIKO_UP;
                  if ( M5_CHIKO_time_set[cnt] != CHIKO_UP ) {
                     M5_CHIKO_time[cnt] = Time[i] + 3600 * Localtime;
                  }
                  M5_CHIKO_time_set[cnt] = CHIKO_UP;
               }
               else if ( iClose(symbol_chk[cnt],PERIOD_M5,i) < iClose(symbol_chk[cnt],PERIOD_M5,i+25)) {
                  M5_CHIKO[cnt] = CHIKO_DOWN;
                  if ( M5_CHIKO_time_set[cnt] != CHIKO_DOWN ) {
                     M5_CHIKO_time[cnt] = Time[i] + 3600 * Localtime;
                  }
                  M5_CHIKO_time_set[cnt] = CHIKO_DOWN;
               }
               else  {
                  M5_CHIKO[cnt] = CHIKO_NO;
                  M5_CHIKO_time_set[cnt] = CHIKO_NO;
            }            
  
//entry チェック
            Entry_buy[cnt] = true;
            Entry_sell[cnt] = true;
            if (( H1_MACD_Rule_Check_Entry ==  true ) && (( Entry_buy[cnt] == true ) || (Entry_sell[cnt] == true ))){
               switch(H1_MACD_Rule[cnt]) {
               case MACD_NO:
                  Entry_buy[cnt] = false;
                  Entry_sell[cnt] = false;
                  break;
               case MACD_UP:
                  Entry_sell[cnt] = false;
                  break;
               case MACD_DOWN:
                  Entry_buy[cnt] = false;
                  break;
               }    
            }               
            if (( H1_MA_Check_Entry ==  true ) && (( Entry_buy[cnt] == true ) ||  (Entry_sell[cnt] == true ))){
               switch(H1_MA[cnt]) {
               case MA_NO:
                  Entry_buy[cnt] = false;
                  Entry_sell[cnt] = false;
                  break;
               case MA_UP:
                  Entry_sell[cnt] = false;
                  break;
               case MA_DOWN:
                  Entry_buy[cnt] = false;
                  break;
               }    
            }               
            if (( H1_Chiko_Check_Entry ==  true ) && (( Entry_buy[cnt] == true ) ||  (Entry_sell[cnt] == true ))){
               switch(H1_CHIKO[cnt]) {
               case CHIKO_NO:
                  Entry_buy[cnt] = false;
                  Entry_sell[cnt] = false;
                  break;
               case CHIKO_UP:
                  Entry_sell[cnt] = false;
                  break;
               case CHIKO_DOWN:
                  Entry_buy[cnt] = false;
                  break;
               }    
            }               
            if (( M15_Span_model_Check_Entry ==  true ) && (( Entry_buy[cnt] == true ) ||  (Entry_sell[cnt] == true ))){
               switch(M15_SPAN[cnt]) {
               case SPAN_NO:
                  Entry_buy[cnt] = false;
                  Entry_sell[cnt] = false;
                  break;
               case SPAN_UP:
                  Entry_sell[cnt] = false;
                  break;
               case SPAN_DOWN:
                  Entry_buy[cnt] = false;
                  break;
               }    
            }               
            if (( M15_Chiko_Check_Entry ==  true ) && (( Entry_buy[cnt] == true ) ||  (Entry_sell[cnt] == true ))){
               switch(M15_CHIKO[cnt]) {
               case CHIKO_NO:
                  Entry_buy[cnt] = false;
                  Entry_sell[cnt] = false;
                  break;
               case CHIKO_UP:
                  Entry_sell[cnt] = false;
                  break;
               case CHIKO_DOWN:
                  Entry_buy[cnt] = false;
                  break;
               }    
            }               
            if (( M5_MACD_Rule_Check_Entry ==  true ) && (( Entry_buy[cnt] == true ) ||  (Entry_sell[cnt] == true ))){
               switch(M5_MACD_Rule[cnt]) {
               case MACD_NO:
                  Entry_buy[cnt] = false;
                  Entry_sell[cnt] = false;
                  break;
               case MACD_UP:
                  Entry_sell[cnt] = false;
                  break;
               case MACD_DOWN:
                  Entry_buy [cnt]= false;
                  break;
               }    
            }               
            if (( M5_Span_model_Check_Entry ==  true ) && (( Entry_buy[cnt] == true ) ||  (Entry_sell[cnt] == true ))){
               switch(M5_SPAN[cnt]) {
               case SPAN_NO:
                  Entry_buy[cnt] = false;
                  Entry_sell[cnt] = false;
                  break;
               case SPAN_UP:
                  Entry_sell[cnt] = false;
                  break;
               case SPAN_DOWN:
                  Entry_buy[cnt] = false;
                  break;
               }    
            }               
            if (( M5_Chiko_Check_Entry ==  true ) && (( Entry_buy[cnt] == true ) ||  (Entry_sell[cnt] == true ))){
               switch(M5_CHIKO[cnt]) {
               case CHIKO_NO:
                  Entry_buy[cnt] = false;
                  Entry_sell[cnt] = false;
                  break;
               case CHIKO_UP:
                  Entry_sell[cnt] = false;
                  break;
               case CHIKO_DOWN:
                  Entry_buy[cnt] = false;
                  break;
               }    
            }               
//exit チェック
            Exit_buy[cnt] = true;
            Exit_sell[cnt] = true;
            if (( H1_MACD_Rule_Check_Exit ==  true ) && (( Exit_buy[cnt] == true ) ||  (Exit_sell[cnt] == true ))){
               switch(H1_MACD_Rule[cnt]) {
               case MACD_NO:
                  Exit_buy[cnt] = false;
                  Exit_sell[cnt] = false;
                  break;
               case MACD_UP:
                  Exit_sell[cnt] = false;
                  break;
               case MACD_DOWN:
                  Exit_buy[cnt] = false;
                  break;
               }    
            }               
            if (( H1_MA_Check_Exit ==  true ) && (( Exit_buy[cnt] == true ) ||  (Exit_sell[cnt] == true ))){
               switch(H1_MA[cnt]) {
               case MA_NO:
                  Exit_buy[cnt] = false;
                  Exit_sell[cnt] = false;
                  break;
               case MA_UP:
                  Exit_sell[cnt] = false;
                  break;
               case MA_DOWN:
                  Exit_buy[cnt] = false;
                  break;
               }    
            }               
            if (( H1_Chiko_Check_Exit ==  true ) && (( Exit_buy[cnt] == true ) ||  (Exit_sell[cnt] == true ))){
               switch(H1_CHIKO[cnt]) {
               case CHIKO_NO:
                  Exit_buy[cnt] = false;
                  Exit_sell[cnt] = false;
                  break;
               case CHIKO_UP:
                  Exit_sell[cnt] = false;
                  break;
               case CHIKO_DOWN:
                  Exit_buy[cnt] = false;
                  break;
               }    
            }               
            if (( M15_Span_model_Check_Exit ==  true ) && (( Exit_buy[cnt] == true ) ||  (Exit_sell[cnt]== true ))){
               switch(M15_SPAN[cnt]) {
               case SPAN_NO:
                  Exit_buy[cnt] = false;
                  Exit_sell[cnt] = false;
                  break;
               case SPAN_UP:
                  Exit_sell[cnt] = false;
                  break;
               case SPAN_DOWN:
                  Exit_buy[cnt] = false;
                  break;
               }    
            }               
            if (( M15_Chiko_Check_Exit ==  true ) && (( Exit_buy[cnt] == true ) ||  (Exit_sell[cnt] == true ))){
               switch(M15_CHIKO[cnt]) {
               case CHIKO_NO:
                  Exit_buy[cnt] = false;
                  Exit_sell[cnt] = false;
                  break;
               case CHIKO_UP:
                  Exit_sell[cnt] = false;
                  break;
               case CHIKO_DOWN:
                  Exit_buy[cnt] = false;
                  break;
               }    
            }               
            if (( M5_MACD_Rule_Check_Exit ==  true ) && (( Exit_buy[cnt] == true ) ||  (Exit_sell[cnt] == true ))){
               switch(M5_MACD_Rule[cnt]) {
               case MACD_NO:
                  Exit_buy[cnt]= false;
                  Exit_sell[cnt] = false;
                  break;
               case MACD_UP:
                  Exit_sell[cnt] = false;
                  break;
               case MACD_DOWN:
                  Exit_buy[cnt] = false;
                  break;
               }    
            }               
            if (( M5_Span_model_Check_Exit ==  true ) && (( Exit_buy[cnt] == true ) ||  (Exit_sell[cnt] == true ))){
               switch(M5_SPAN[cnt]) {
               case SPAN_NO:
                  Exit_sell[cnt] = false;
                  Entry_sell[cnt] = false;
                  break;
               case SPAN_UP:
                  Exit_sell[cnt] = false;
                  break;
               case SPAN_DOWN:
                  Exit_buy[cnt] = false;
                  break;
               }    
            }               
            if (( M5_Chiko_Check_Exit ==  true ) && (( Exit_buy[cnt] == true ) ||  (Exit_sell[cnt] == true ))){
               switch(M5_CHIKO[cnt]) {
               case CHIKO_NO:
                  Exit_buy[cnt] = false;
                  Exit_sell[cnt] = false;
                  break;
               case CHIKO_UP:
                  Exit_sell[cnt] = false;
                  break;
               case CHIKO_DOWN:
                  Exit_buy[cnt] = false;
                  break;
               }    
            }          
            switch( O_BandS[cnt] ) {
               case NO_POSITION:
                  if ( Entry_buy[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpArrow[i]=Low[i] - Point * Signal_Pos;
                     }
                     BandS[cnt] = BUY_POSITION;
                     Kind[cnt] = BUY_POSITION;
                  }
                  else if ( Entry_sell[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownArrow[i]=High[i] + Point * Signal_Pos;
                     }
                     BandS[cnt] = SELL_POSITION;
                     Kind[cnt] = SELL_POSITION;
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
                  else if ( Entry_sell[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownArrow[i]=High[i] + Point * Signal_Pos;
                     }
                     BandS[cnt] = SELL_POSITION;
                     Kind[cnt] = SELL_POSITION;
                  }
                  else {
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpKessaiArrow[i] = High[i]  + Point * Signal_Pos;
                     }
                     BandS[cnt] = NO_POSITION;
                     Kind[cnt] = BUY_KESSAI;
                  }
                  break;         
               case SELL_POSITION:
                  if ( Entry_buy[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpArrow[i]=Low[i]  - Point * Signal_Pos;
                     }
                     BandS[cnt] = BUY_POSITION;
                     Kind[cnt] = BUY_POSITION;
                  }
                  else if ( Exit_sell[cnt] == true ) {
                     BandS[cnt] = SELL_POSITION;
                     Kind[cnt] = 0;
                  }
                  else {
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownKessaiArrow[i] = Low[i]  - Point * Signal_Pos;
                     }
                     BandS[cnt] = NO_POSITION;
                     Kind[cnt] = SELL_KESSAI;
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
            switch(H1_MACD_Rule[cnt]) {
            case MACD_NO:
               H1_MACD_Rule_mes[cnt] = "1時間足MACDルール不成立";
               break;
            case MACD_UP:
               H1_MACD_Rule_mes[cnt] = TimeToStr(H1_MACD_Rule_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"1時間足MACDルール上昇";
               break;
            case MACD_DOWN:
               H1_MACD_Rule_mes[cnt] = TimeToStr(H1_MACD_Rule_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"1時間足MACDルール下降";
               break;
            }    
            switch(H1_MA[cnt]) {
            case MA_NO:
               H1_MA_mes[cnt] = "1時間足移動平均線不成立";
               break;
            case MA_UP:
               H1_MA_mes[cnt] = TimeToStr(H1_MA_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"1時間足移動平均線上昇";
               break;
            case MA_DOWN:
               H1_MA_mes[cnt] = TimeToStr(H1_MA_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"1時間足移動平均線下降";
               break;
            }    
            switch(H1_CHIKO[cnt]) {
            case CHIKO_NO:
               H1_CHIKO_mes[cnt] = "1時間足遅行スパン不成立";
               break;
            case CHIKO_UP:
               H1_CHIKO_mes[cnt] = TimeToStr(H1_CHIKO_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"1時間足遅行スパン上昇";
               break;
            case CHIKO_DOWN:
               H1_CHIKO_mes[cnt] = TimeToStr(H1_CHIKO_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"1時間足遅行スパン下降";
               break;
            }    
            switch(M15_SPAN[cnt]) {
            case SPAN_NO:
               M15_SPAN_mes[cnt] = "15分足スパンモデル不成立";
               break;
            case SPAN_UP:
               M15_SPAN_mes[cnt] = TimeToStr(M15_SPAN_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"15分足スパンモデル上昇";
               break;
            case SPAN_DOWN:
               M15_SPAN_mes[cnt] = TimeToStr(M15_SPAN_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"15分足スパンモデル下降";
               break;
            }    
            switch(M15_CHIKO[cnt]) {
            case CHIKO_NO:
               M15_CHIKO_mes[cnt] = "15分足遅行スパン不成立";
               break;
            case CHIKO_UP:
               M15_CHIKO_mes[cnt] = TimeToStr(M15_CHIKO_time[cnt],TIME_DATE | TIME_MINUTES)+" "+ "15分足遅行スパン上昇";
               break;
            case CHIKO_DOWN:
               M15_CHIKO_mes[cnt] = TimeToStr(M15_CHIKO_time[cnt],TIME_DATE | TIME_MINUTES)+" "+ "15分足遅行スパン下降";
               break;
            }    
            switch(M5_MACD_Rule[cnt]) {
            case MACD_NO:
               M5_MACD_Rule_mes[cnt] = "5分足MACDルール不成立";
               break;
            case MACD_UP:
               M5_MACD_Rule_mes[cnt] = TimeToStr(M5_MACD_Rule_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"5分足MACDルール上昇";
               break;
            case MACD_DOWN:
               M5_MACD_Rule_mes[cnt] = TimeToStr(M5_MACD_Rule_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"5分足MACDルール下降";
               break;
            }    
            switch(M5_SPAN[cnt]) {
            case SPAN_NO:
               M5_SPAN_mes[cnt] = "5分足スパンモデル不成立";
               break;
            case SPAN_UP:
               M5_SPAN_mes[cnt] = TimeToStr(M5_SPAN_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"5分足スパンモデル上昇";
               break;
            case SPAN_DOWN:
               M5_SPAN_mes[cnt] = TimeToStr(M5_SPAN_time[cnt],TIME_DATE | TIME_MINUTES)+" "+"5分足スパンモデル下降";
               break;
            }    
            switch(M5_CHIKO[cnt]) {
            case CHIKO_NO:
               M5_CHIKO_mes[cnt] = "5分足遅行スパン不成立";
               break;
            case CHIKO_UP:
               M5_CHIKO_mes[cnt] = TimeToStr(M5_CHIKO_time[cnt],TIME_DATE | TIME_MINUTES)+" "+ "5分足遅行スパン上昇";
               break;
            case CHIKO_DOWN:
               M5_CHIKO_mes[cnt] = TimeToStr(M5_CHIKO_time[cnt],TIME_DATE | TIME_MINUTES)+" "+ "5分足遅行スパン下降";
               break;
            }    

            switch(Kind[cnt])   {
            case BUY_POSITION:
               message= "買い Chance!!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
               break;
            case SELL_POSITION:
               message= "売り Chance!!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
               break;
            case BUY_KESSAI:
               message= "買い決済 "+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
               break;
            case SELL_KESSAI:
               message= "売り決済"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
               break;
            }
            message = message + "\r\n"+H1_MACD_Rule_mes[cnt];
            message = message +  "\r\n"+H1_MA_mes[cnt];
            message = message +  "\r\n"+H1_CHIKO_mes[cnt];
            message = message +  "\r\n"+M15_SPAN_mes[cnt];
         
            message = message +  "\r\n"+M15_CHIKO_mes[cnt];
            message = message +  "\r\n"+M5_MACD_Rule_mes[cnt];
            message = message +  "\r\n"+M5_SPAN_mes[cnt];
            message = message +  "\r\n"+M5_CHIKO_mes[cnt];

            if ( Kind[cnt] != 0 ) SendMail("複合ルール " +"["+symbol_chk[cnt]+"]["+Period()+"]",message);
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
                  Alert("Spanmodel+MACD Rule BUY Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case SELL_POSITION:
                  Alert("Spanmodel+MACD Rule SELL Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case BUY_KESSAI:
                  Alert("Spanmodel+MACD Rule BUY Kessai Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case SELL_KESSAI:
                  Alert("Spanmodel+MACD Rule SELl Kessai Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               }
            }
         }
      }
      Alertflag = false;
   }
   return(0);
}

