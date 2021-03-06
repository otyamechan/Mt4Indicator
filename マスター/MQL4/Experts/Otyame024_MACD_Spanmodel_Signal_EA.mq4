//+------------------------------------------------------------------+
//|                                       Otyame  No.0022            |
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
// マジックナンバーの定義
#define MAGIC 1234


#property copyright "Otyame"
#property link      ""




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
#define ST_UP 2
#define ST_DOWN 1
#define ST_NO 0

#define SUPER_BOLLIN_UP 2
#define SUPER_BOLLIN_DOWN 1
#define SUPER_BOLLIN_NO 0




//---- buffers

string message;
string M15_mes,M5_mes;
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

extern bool H1_Super_Bollin_Check_Entry = false;
extern bool H1_Super_Bollin_Check_Exit = false;
extern string _H1_Supper_Bollin = "Supper_Bollin";
extern int  _H1_Supper_Bollin_MA_Period= 21;

extern string _MA_Setting= "MA Setting";
extern bool H1_MA_Check_Entry = false;
extern bool H1_MA_Check_Exit = false;
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
extern double Span_Pips = 50.0;
extern int M5_Tenkan = 9;           //転換線
extern int M5_Kijun = 25;           //基準線 
extern int M5_Senkou = 52;          //先行スパン 
extern bool M5_Chiko_Check_Entry = false;
extern bool M5_Chiko_Check_Exit = false;

extern bool M1_Span_model_Check_Entry = false;
extern bool M1_Span_model_Check_Exit = false;
extern int M1_Tenkan = 9;           //転換線
extern int M1_Kijun = 25;           //基準線 
extern int M1_Senkou = 52;          //先行スパン 
extern bool M1_Chiko_Check_Entry = false;
extern bool M1_Chiko_Check_Exit = false;

extern bool M5_SHORT_STOCHASTIC_CHECK = false;
extern bool M5_LONG_STOCHASTIC_CHECK = false;
extern string Short_Stochastic = "Short Stochastic Setting";
extern   int Short_Kperiod = 8;           //MACD期間
extern   int Short_Dperiod = 4;           //MACD期間
extern   int Short_Slowing = 4;           //MACD期間
extern string Method_Setting = "0:SMA 1:EMA 2:SSMA 3:LWMA"; 
extern   int Short_Method = MODE_LWMA;           //MACD期間
extern string Price_setting="0：Low/High、1：Close/Close";
extern   int Short_Price = 1;           //MACD期間

extern string Long_Stochastic = "Long Stochastic Setting";
extern   int Long_Kperiod = 20;           //MACD期間
extern   int Long_Dperiod = 10;           //MACD期間
extern   int Long_Slowing = 5;           //MACD期間
extern   int Long_Method = MODE_LWMA;           //MACD期間
extern   int Long_Price = 1;           //MACD期間
extern double Uper_Line = 80.0;
extern double Lower_Line = 20.0;

//パラメーターの設定//
extern double Lots = 1.0;     //取引ロット数
extern int Slip = 10;         //許容スリッページ数
extern string Comments =  ""; //コメント


 
datetime k15mtime[];             //15分足格納用
datetime k1Htime[];              //1時間足格納用


//変数
int c_15m,c_1H;         //時間位置
int H1_Chk_candle,M5_Chk_candle;
int H1_FastMAPeriod,H1_SlowMAPeriod,H1_SignalMAPeriod;
int H1_MACD_MAPeriod;
int M5_FastMAPeriod,M5_SlowMAPeriod,M5_SignalMAPeriod;
int M5_MACD_MAPeriod;

double H1_MACD_0,H1_MACD_1,H1_MACD_MA_0,H1_MACD_MA_1,H1_MACD_MA_0_J,H1_MACD_MA_1_J;
double H1_MA_0,H1_MA_1;
double M5_MACD_0,M5_MACD_1,M5_MACD_MA_0,M5_MACD_MA_1;
double M15_Sen1,M15_Sen2;
double M5_Sen1,M5_Sen2;
double M1_Sen1,M1_Sen2;
double chk_pips_MACD;
double chk_pips_MA;
double H1_Supper_Bollin_P1sigma,H1_Supper_Bollin_M1sigma;
double H1_Supper_Bollin_P2sigma,H1_Supper_Bollin_M2sigma;
double M5_Ten;

double Short_St_Main;
double Short_St_Signal;
double Long_St_Main;
double Long_St_Signal;

int H1_MACD_Rule,M5_MACD_Rule;
int H1_MA,H1_CHIKO;
int M15_SPAN,M15_CHIKO;
int M5_SPAN,M5_CHIKO;
int M1_SPAN,M1_CHIKO;
int M5_SHORT_ST;
int M5_LONG_ST;
int H1_Super_Bollin;


bool Entry_buy,Exit_buy;
bool Entry_sell,Exit_sell;

string H1_MACD_Rule_mes,M5_MACD_Rule_mes;
string H1_MA_mes,H1_CHIKO_mes;
string M15_SPAN_mes,M15_CHIKO_mes;
string M5_SPAN_mes,M5_CHIKO_mes;

double M5_Short_St_Main;
double M5_Short_St_Signal;
double M5_Long_St_Main;
double M5_Long_St_Signal;


int count_15m ;     //15分足時間格納
int count_1H ;       //1時間足時間格納

int O_BandS;
int BandS;
int Kind;
datetime TimeOld;

int pos;
double pos_chk;

// 変数の設定//
int Ticket_L = 0; // 買い注文の結果をキャッチする変数
int Ticket_S = 0; // 売り注文の結果をキャッチする変数
int Exit_L = 0; // 買いポジションの決済注文の結果をキャッチする変数
int Exit_S = 0; // 売りポジションの決済注文の結果をキャッチする変数


int start()
{

   if ( Time[0] != TimeOld ) {

   
   //１H足MACD Rule の計算            
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

   H1_MACD_0 = iCustom(NULL,PERIOD_H1,"MACD++",H1_FastMAPeriod,H1_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",H1_MACD_Method,H1_SignalMAPeriod,H1_Signal_MAMethod,false,0,1,1);
   H1_MACD_1 = iCustom(NULL,PERIOD_H1,"MACD++",H1_FastMAPeriod,H1_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",H1_MACD_Method,H1_SignalMAPeriod,H1_Signal_MAMethod,false,0,1,1+H1_Chk_candle);
   H1_MACD_MA_0 = iMA(NULL,PERIOD_H1,H1_MACD_MAPeriod,0,H1_MACD_MA_Method,PRICE_CLOSE,1);
   H1_MACD_MA_1 = iMA(NULL,PERIOD_H1,H1_MACD_MAPeriod,0,H1_MACD_MA_Method,PRICE_CLOSE,1+H1_Chk_candle);
   
//   Print( "c_1h =",c_1H,"H1_Chk_candle = ",H1_Chk_candle,"H1_MACD_0 = ",H1_MACD_0,"H1_MACD_1 = ",H1_MACD_1,"H1_MACD_MA_0 = ",H1_MACD_MA_0,"H1_MACD_MA_1 = ",H1_MACD_MA_1);
//   H1_MACD_MA_0_J = iMA(NULL,PERIOD_H1,480,0,0,PRICE_CLOSE,c_1H);
//   H1_MACD_MA_1_J = iMA(NULL,PERIOD_H1,480,0,0,PRICE_CLOSE,c_1H+H1_Chk_candle);

//   H1_Sen1 = iCustom(NULL,PERIOD_H1,"span_model",M15_Kijun,M15_Tenkan,M15_Senkou,5,c_1H);
//   H1_Sen2 = iCustom(NULL,PERIOD_H1,"span_model",M15_Kijun,M15_Tenkan,M15_Senkou,6,c_1H);
         
         //1時間足　移動平均線の計算            
   H1_MA_0 = iMA(NULL,PERIOD_H1,_H1_MA_Period,0,_H1_MA_Method,PRICE_CLOSE,1);
   H1_MA_1 = iMA(NULL,PERIOD_H1,_H1_MA_Period,0,_H1_MA_Method,PRICE_CLOSE,1+H1_Chk_candle);


         //1時間足　移動平均線の計算            
   H1_Supper_Bollin_P1sigma = iBands(NULL,PERIOD_H1,_H1_Supper_Bollin_MA_Period,1,0,PRICE_CLOSE,MODE_UPPER,1);
   H1_Supper_Bollin_M1sigma = iBands(NULL,PERIOD_H1,_H1_Supper_Bollin_MA_Period,1,0,PRICE_CLOSE,MODE_LOWER,1);
   H1_Supper_Bollin_P2sigma = iBands(NULL,PERIOD_H1,_H1_Supper_Bollin_MA_Period,2,0,PRICE_CLOSE,MODE_UPPER,1);
   H1_Supper_Bollin_M2sigma = iBands(NULL,PERIOD_H1,_H1_Supper_Bollin_MA_Period,2,0,PRICE_CLOSE,MODE_LOWER,1);


      //15分足　スパンモデル　            

   M15_Sen1 = iCustom(NULL,PERIOD_M15,"span_model",M15_Kijun,M15_Tenkan,M15_Senkou,5,1);
   M15_Sen2 = iCustom(NULL,PERIOD_M15,"span_model",M15_Kijun,M15_Tenkan,M15_Senkou,6,1);
   
   M5_Short_St_Main = iStochastic(NULL,0,Short_Kperiod,Short_Kperiod,Short_Slowing,Short_Method,Short_Price,MODE_MAIN,1);
   M5_Short_St_Signal = iStochastic(NULL,0,Short_Kperiod,Short_Kperiod,Short_Slowing,Short_Method,Short_Price,MODE_SIGNAL,1);
   M5_Long_St_Main = iStochastic(NULL,0,Long_Kperiod,Long_Kperiod,Long_Slowing,Long_Method,Long_Price,MODE_MAIN,1);
   M5_Long_St_Signal = iStochastic(NULL,0,Long_Kperiod,Long_Kperiod,Long_Slowing,Long_Method,Long_Price,MODE_SIGNAL,1);




         //5H足MACD Rule の計算            
   if ( Compare_Period < PERIOD_M5 ) {
      M5_Chk_candle = 1;
   }
   else  {
	   M5_Chk_candle = Compare_Period / PERIOD_M5 ;
   }      
   M5_MACD_0 = iCustom(NULL,0,"MACD++",M5_FastMAPeriod,M5_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",M5_MACD_Method,M5_SignalMAPeriod,M5_Signal_MAMethod,false,0,1,1);
   M5_MACD_1 = iCustom(NULL,0,"MACD++",M5_FastMAPeriod,M5_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",M5_MACD_Method,M5_SignalMAPeriod,M5_Signal_MAMethod,false,0,1,1+M5_Chk_candle);
   M5_MACD_MA_0 = iMA(NULL,0,M5_MACD_MAPeriod,0,M5_MACD_MA_Method,PRICE_CLOSE,1);
   M5_MACD_MA_1 = iMA(NULL,0,M5_MACD_MAPeriod,0,M5_MACD_MA_Method,PRICE_CLOSE,1+M5_Chk_candle);

         //5分足　スパンモデル　            

   M5_Sen1 = iCustom(NULL,0,"span_model",M5_Kijun,M5_Tenkan,M5_Senkou,5,1);
   M5_Sen2 = iCustom(NULL,0,"span_model",M5_Kijun,M5_Tenkan,M5_Senkou,6,1);
   M5_Ten = iCustom(NULL,0,"span_model",M5_Kijun,M5_Tenkan,M5_Senkou,0,1);

   M1_Sen1 = iCustom(NULL,PERIOD_M1,"span_model",M1_Kijun,M1_Tenkan,M1_Senkou,5,1);
   M1_Sen2 = iCustom(NULL,PERIOD_M1,"span_model",M1_Kijun,M1_Tenkan,M1_Senkou,6,1);

//1時間足MACDルール判定

   if (( H1_MACD_1 - H1_MACD_0 ) > 0)   {        //MACD下降中
      if (( H1_MACD_MA_1 - H1_MACD_MA_0 ) >0) {                     //MA下降中
         H1_MACD_Rule = MACD_DOWN;                               //MACDルール下降中と成立
      }
      else  {
         H1_MACD_Rule = MACD_NO;                            //MACDルール下降成立
      }
   }
   else if (( H1_MACD_1 - H1_MACD_0 ) <0 )  {  //MACD上昇中
      if (( H1_MA_1 - H1_MA_0 ) < 0 ) {                //MAは下降中
         H1_MACD_Rule = MACD_UP;                                     //MACDルール不成立
      }
      else  {
         H1_MACD_Rule = MACD_NO;                                     //MACDルール上昇成立
      }
   }
   else if ((H1_MACD_1 - H1_MACD_0 ) == 0 ) { 
 //     if ((  H1_MA_1 - H1_MA_0 ) > 0)    {  
 //        H1_MACD_Rule = MACD_DOWN;                            //MACDルール不成立
 //     }
 //     else if (( H1_MACD_MA_1 - H1_MACD_MA_0 ) < 0 ){
 //        H1_MACD_Rule = MACD_UP;                            //MACDルール不成立
 //     }
 //     else  {
         H1_MACD_Rule = MACD_NO;                                     //MACDルール上昇成立
 //     }
   }
//1時間足移動平均線判定
   if ((  H1_MA_1 - H1_MA_0 ) > 0)    {
       H1_MA = MA_DOWN;
   }  
   else if ((  H1_MA_1 - H1_MA_0 ) < 0)    {
      H1_MA = MA_UP;
   }
   else {
      H1_MA = MA_NO;
   }
//1時間足移動平均線判定

   if (  H1_Supper_Bollin_P1sigma  <= iClose(Symbol(),PERIOD_H1,1) ){
       H1_Super_Bollin = SUPER_BOLLIN_UP;
   }  

   else if (  H1_Supper_Bollin_M1sigma >= iClose(Symbol(),PERIOD_H1,1)) {
       H1_Super_Bollin = SUPER_BOLLIN_DOWN;
   }

   else {
       H1_Super_Bollin = SUPER_BOLLIN_NO;
   }

//1時間足遅行スパン判定
   if ( iClose(Symbol(),PERIOD_H1,1) > iOpen(Symbol(),PERIOD_H1,1+H1_Chiko_Time)) {
      H1_CHIKO = CHIKO_UP;
   }
   else if ( iClose(Symbol(),PERIOD_H1,1) < iClose(Symbol(),PERIOD_H1,1+H1_Chiko_Time)) { 
      H1_CHIKO = CHIKO_DOWN;
   }
   else  {
      H1_CHIKO = CHIKO_NO;
   }            

//15分足スパンモデル判定
   if ( M15_Sen1 > M15_Sen2 ) {
      M15_SPAN = SPAN_UP;
   }
   else if ( M15_Sen1 < M15_Sen2 ) {            
      M15_SPAN = SPAN_DOWN;
   }
   else  {
      M15_SPAN = SPAN_NO;
   }            
 //15分足遅行スパン判定
   if ( iClose(Symbol(),PERIOD_M15,c_15m) > iOpen(Symbol(),PERIOD_M15,c_15m+25)) {
      M15_CHIKO = CHIKO_UP;
   }
   else if ( iClose(Symbol(),PERIOD_M15,c_15m) < iClose(Symbol(),PERIOD_M15,c_15m+25)) {
       M15_CHIKO = CHIKO_DOWN;
   }
   else  {
      M15_CHIKO = CHIKO_NO;
   }

//5分足MACDルール判定
   if (( M5_MACD_1 - M5_MACD_0 ) > 0)   {        //MACD下降中
      if (( M5_MACD_MA_1 - M5_MACD_MA_0 ) > 0) {                     //MA下降中
         M5_MACD_Rule = MACD_DOWN;                               //MACDルール下降中と成立
      }
      else  {
         M5_MACD_Rule = MACD_NO;                            //MACDルール下降成立
      }
   }
   else if (( M5_MACD_1 - M5_MACD_0 ) <0 )   {  //MACD上昇中
      if (( M5_MACD_MA_1 - M5_MACD_MA_0 ) < 0 ) {                //MAは下降中
         M5_MACD_Rule = MACD_UP;                                     //MACDルール不成立
      }
      else  {
         M5_MACD_Rule = MACD_NO;                                     //MACDルール上昇成立
      }
   }
   else if ((M5_MACD_1 - M5_MACD_0 )  ==0 ) { 
 //     if ((  M5_MACD_MA_1 - M5_MACD_MA_0 ) >  0)    {  
 //         M5_MACD_Rule = MACD_DOWN;                            //MACDルール不成立
 //     }
 //     else if (( M5_MACD_MA_1 - M5_MACD_MA_0 ) < 0 ){
 //        M5_MACD_Rule = MACD_UP;                            //MACDルール不成立
 //    }
 //     else  {
         M5_MACD_Rule = MACD_NO;                                     //MACDルール上昇成立
 //     }
   }

//5分足スパンモデル判定
   if (( M5_Sen1 > M5_Sen2 ) && (M5_Ten >= M5_Sen1)&& ( MathAbs(iClose(Symbol(),PERIOD_M5,1)- M5_Sen1) < Span_Pips))  {
      M5_SPAN = SPAN_UP;
   }
   else if (( M5_Sen1 < M5_Sen2 ) && ( M5_Ten <= M5_Sen1)&& ( MathAbs(iClose(Symbol(),PERIOD_M5,1)- M5_Sen1) < Span_Pips)) {            
      M5_SPAN = SPAN_DOWN;
   }
   else  {
      M5_SPAN = SPAN_NO;
   }            

//5分足遅行スパン判定
   if ( iClose(Symbol(),PERIOD_M5,1) > iOpen(Symbol(),PERIOD_M5,1+25)) {
      M5_CHIKO = CHIKO_UP;
   }
   else if ( iClose(Symbol(),PERIOD_M5,1) < iClose(Symbol(),PERIOD_M5,1+25)) {
      M5_CHIKO = CHIKO_DOWN;
   }
   else  {
      M5_CHIKO = CHIKO_NO;
   }            
//1分足スパンモデル判定
   if ( M1_Sen1 > M1_Sen2 ) {
      M1_SPAN = SPAN_UP;
   }
   else if ( M1_Sen1 < M1_Sen2 ) {            
      M5_SPAN = SPAN_DOWN;
   }
   else  {
      M1_SPAN = SPAN_NO;
   }            

//1分足遅行スパン判定
   if ( iClose(Symbol(),PERIOD_M1,1) > iOpen(Symbol(),PERIOD_M1,1+25)) {
      M1_CHIKO = CHIKO_UP;
   }
   else if ( iClose(Symbol(),PERIOD_M1,1) < iClose(Symbol(),PERIOD_M1,1+25)) {
      M1_CHIKO = CHIKO_DOWN;
   }
   else  {
      M1_CHIKO = CHIKO_NO;
   }            //5分足ショートストキャスチェック
   if ( M5_Short_St_Main > M5_Short_St_Signal )  {
      M5_SHORT_ST = ST_UP;
   }
   else if ( M5_Short_St_Main < M5_Short_St_Signal  ) {            
      M5_SHORT_ST = ST_DOWN;
   }
   else  {
      M5_SHORT_ST = ST_NO;
   }            
//5分足ロンgつストキャスチェック
   if ( M5_Long_St_Main > M5_Long_St_Signal ) {
      M5_LONG_ST = ST_UP;
   }
   else if ( M5_Long_St_Main < M5_Long_St_Signal  )  {            
      M5_LONG_ST = ST_DOWN;
   }
   else  {
      M5_LONG_ST = ST_NO;
   }            



//entry チェック
   Entry_buy = true;
   Entry_sell = true;
   
   if (( H1_MACD_Rule_Check_Entry ==  true ) && (( Entry_buy == true ) || (Entry_sell == true ))){
      switch(H1_MACD_Rule) {
      case MACD_NO:
          Entry_buy = false;
          Entry_sell = false;
          break;
      case MACD_UP:
          Entry_sell = false;
          break;
      case MACD_DOWN:
          Entry_buy = false;
          break;
      }    
   }               
   if (( H1_MA_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(H1_MA) {
      case MA_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case MA_UP:
         Entry_sell = false;
         break;
      case MA_DOWN:
         Entry_buy = false;
         break;
      }    
   }               
   if (( H1_Chiko_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(H1_CHIKO) {
      case CHIKO_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case CHIKO_UP:
         Entry_sell = false;
         break;
      case CHIKO_DOWN:
         Entry_buy = false;
         break;
      }    
   }               
   if (( H1_Super_Bollin_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(H1_Super_Bollin) {
      case SUPER_BOLLIN_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case SUPER_BOLLIN_UP:
         Entry_sell = false;
         break;
      case SUPER_BOLLIN_DOWN:
         Entry_buy = false;
         break;
      }    
   }               
   if (( H1_Chiko_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(H1_CHIKO) {
      case CHIKO_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case CHIKO_UP:
         Entry_sell = false;
         break;
      case CHIKO_DOWN:
         Entry_buy = false;
         break;
      }    
   }               
   if (( M15_Span_model_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(M15_SPAN) {
      case SPAN_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case SPAN_UP:
         Entry_sell = false;
         break;
      case SPAN_DOWN:
         Entry_buy = false;
         break;
      }    
   }               
   if (( M15_Chiko_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(M15_CHIKO) {
      case CHIKO_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case CHIKO_UP:
         Entry_sell = false;
         break;
      case CHIKO_DOWN:
         Entry_buy = false;
         break;
      }    
   }
               
   if (( M5_MACD_Rule_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(M5_MACD_Rule) {
      case MACD_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case MACD_UP:
         Entry_sell = false;
         break;
      case MACD_DOWN:
         Entry_buy = false;
         break;
      }    
   }               

   if (( M5_Span_model_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(M5_SPAN) {
      case SPAN_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case SPAN_UP:
         Entry_sell = false;
         break;
      case SPAN_DOWN:
         Entry_buy = false;
         break;
      }    
   }               
   if (( M5_Chiko_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(M5_CHIKO) {
      case CHIKO_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case CHIKO_UP:
         Entry_sell = false;
         break;
      case CHIKO_DOWN:
         Entry_buy = false;
         break;
      }
   }    
   if (( M1_Span_model_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(M1_SPAN) {
      case SPAN_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case SPAN_UP:
         Entry_sell = false;
         break;
      case SPAN_DOWN:
         Entry_buy = false;
         break;
      }    
   }               
   if (( M1_Chiko_Check_Entry ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(M1_CHIKO) {
      case CHIKO_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case CHIKO_UP:
         Entry_sell = false;
         break;
      case CHIKO_DOWN:
         Entry_buy = false;
         break;
      }
   }    
   if (( M5_SHORT_STOCHASTIC_CHECK ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(M5_SHORT_ST) {
      case ST_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case ST_UP:
         Entry_sell = false;
         break;
      case ST_DOWN:
         Entry_buy = false;
         break;
      }    
  }               
   if (( M5_LONG_STOCHASTIC_CHECK ==  true ) && (( Entry_buy == true ) ||  (Entry_sell == true ))){
      switch(M5_LONG_ST) {
      case ST_NO:
         Entry_buy = false;
         Entry_sell = false;
         break;
      case ST_UP:
         Entry_sell = false;
         break;
      case ST_DOWN:
         Entry_buy = false;
         break;
      }    
  }               

//exit チェック
   Exit_buy = true;
   Exit_sell = true;

   if (( H1_MACD_Rule_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(H1_MACD_Rule) {
      case MACD_NO:
         Exit_buy = false;
         Exit_sell = false;
         break;
      case MACD_UP:
         Exit_sell = false;
         break;
      case MACD_DOWN:
         Exit_buy = false;
         break;
      }    
   }               
   if (( H1_MA_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(H1_MA) {
      case MA_NO:
         Exit_buy = false;
         Exit_sell = false;
         break;
      case MA_UP:
         Exit_sell = false;
         break;
         case MA_DOWN:
         Exit_buy = false;
         break;
      }    
   }               
   if (( H1_Chiko_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(H1_CHIKO) {
      case CHIKO_NO:
         Exit_buy = false;
         Exit_sell = false;
         break;
      case CHIKO_UP:
         Exit_sell = false;
         break;
      case CHIKO_DOWN:
         Exit_buy = false;
         break;
      }    
  }               
   if (( H1_Super_Bollin_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(H1_Super_Bollin) {
      case SUPER_BOLLIN_NO:
         Exit_buy = false;
         Exit_sell = false;
         break;
      case SUPER_BOLLIN_UP:
         Exit_sell = false;
         break;
      case SUPER_BOLLIN_DOWN:
         Exit_buy = false;
         break;
      }    
   }               

  if (( M15_Span_model_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(M15_SPAN) {
      case SPAN_NO:
         Exit_buy = false;
         Exit_sell = false;
         break;
      case SPAN_UP:
         Exit_sell = false;
         break;
      case SPAN_DOWN:
         Exit_buy = false;
         break;
      }    
   }               
   if (( M15_Chiko_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(M15_CHIKO) {
      case CHIKO_NO:
         Exit_buy = false;
         Exit_sell = false;
         break;
         case CHIKO_UP:
         Exit_sell = false;
         break;
      case CHIKO_DOWN:
         Exit_buy = false;
          break;
       }    
   }               

   if (( M5_MACD_Rule_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(M5_MACD_Rule) {
      case MACD_NO:
         Exit_buy = false;
         Exit_sell = false;
         break;
      case MACD_UP:
         Exit_sell = false;
         break;
      case MACD_DOWN:
         Exit_buy = false;
         break;
      }    
   }               

   if (( M5_Span_model_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(M5_SPAN) {
      case SPAN_NO:
         Exit_sell = false;
         Entry_sell = false;
         break;
      case SPAN_UP:
         Exit_sell = false;
         break;
      case SPAN_DOWN:
         Exit_buy = false;
         break;
      }    
   }               
   if (( M5_Chiko_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(M5_CHIKO) {
      case CHIKO_NO:
         Exit_buy = false;
         Exit_sell = false;
         break;
      case CHIKO_UP:
         Exit_sell = false;
         break;
      case CHIKO_DOWN:
         Exit_buy = false;
         break;
      }    
   }          
   if (( M1_Span_model_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(M1_SPAN) {
      case SPAN_NO:
         Exit_sell = false;
         Entry_sell = false;
         break;
      case SPAN_UP:
         Exit_sell = false;
         break;
      case SPAN_DOWN:
         Exit_buy = false;
         break;
      }    
   }               
   if (( M1_Chiko_Check_Exit ==  true ) && (( Exit_buy == true ) ||  (Exit_sell == true ))){
      switch(M1_CHIKO) {
      case CHIKO_NO:
         Exit_buy = false;
         Exit_sell = false;
         break;
      case CHIKO_UP:
         Exit_sell = false;
         break;
      case CHIKO_DOWN:
         Exit_buy = false;
         break;
      }    
   }          

   switch( O_BandS ) {
      case NO_POSITION:
         if ( Entry_buy == true ) {
            BandS = BUY_POSITION;
            Kind = BUY_POSITION;
         }
         else if ( Entry_sell == true ) {
            BandS = SELL_POSITION;
            Kind = SELL_POSITION;
         }
         else {
            BandS = NO_POSITION;
            Kind = NO_POSITION;
         }
         break;         
      case BUY_POSITION:
         if ( Exit_buy == true ) {
            BandS = BUY_POSITION;
            Kind = 0;
         }
         else if ( Entry_sell == true ) {
            BandS = SELL_POSITION;
            Kind = SELL_POSITION;
         }
         else {
            BandS = NO_POSITION;
            Kind = BUY_KESSAI;
         }
         break;         
      case SELL_POSITION:
         if ( Entry_buy == true ) {
            BandS = BUY_POSITION;
            Kind = BUY_POSITION;
         }
         else if ( Exit_sell == true ) {
            BandS = SELL_POSITION;
            Kind = 0;
         }
         else {
            BandS = NO_POSITION;
            Kind = SELL_KESSAI;
         }
         break;         
   }
   O_BandS = BandS;
   Print("TIme = ",TimeToStr(Time[0],TIME_DATE | TIME_MINUTES)," BandS = ",BandS," Kind = ",Kind,"H1_MACD_Rule = ",H1_MACD_Rule," M5_MACD_Rule = ",M5_MACD_Rule," H1_MA = ",H1_MA,"　H1_CHIKO=",H1_CHIKO,"　M15_SPAN　=",M15_SPAN," M15_CHIKO =", M15_CHIKO," M5_SPAN = ",M5_SPAN," M5_CHIKO = ",M5_CHIKO, "M5_SHORT_ST =",M5_SHORT_ST," M5_LONG_ST = ",M5_LONG_ST);


//   Print("TIme = ",TimeToStr(Time[0],TIME_DATE | TIME_MINUTES)," BandS = ",BandS," Kind = ",Kind);

//exit チェック
    
   //買いポジションのエグジット
   if(  (Kind == BUY_KESSAI )
       && ( Ticket_L != 0 && Ticket_L != -1 ))
    {     
      Exit_L = OrderClose(Ticket_L,Lots,Bid,Slip,Red);
      if( Exit_L ==1 ) {Ticket_L = 0;}
    }    
    
   //売りポジションのエグジット
   if(  (Kind == SELL_KESSAI )
       && ( Ticket_S != 0 && Ticket_S != -1 ))
    {     
      Exit_S = OrderClose(Ticket_S,Lots,Ask,Slip,Blue);
      if( Exit_S ==1 ) {Ticket_S = 0;} 
    }   
    
   //買いエントリー
   if(    (Kind == BUY_POSITION )
       && ( Ticket_L == 0 || Ticket_L == -1 ) 
       && ( Ticket_S == 0 || Ticket_S == -1 ))
    {  
      Ticket_L = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
    }
    
   //売りエントリー
   if(    (Kind == SELL_POSITION )
       && ( Ticket_S == 0 || Ticket_S == -1 )
       && ( Ticket_L == 0 || Ticket_L == -1 ))
    {   
      Ticket_S = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);     
    } 
      TimeOld = Time[0];
   }

   return(0);
}

void Write(string str)
 {
string Filename = "aaa.txt"; //ここはＥＡ名などのお好きなファイル名（start関数の前に書くとスマートです）

int Handle;

 Handle = FileOpen(Filename, FILE_READ|FILE_WRITE|FILE_CSV, "/t");
 if (Handle < 1){
Print("Error opening audit file: Code ", GetLastError());
 return;
}

 if (!FileSeek(Handle, 0, SEEK_END)){
 Print("Error seeking end of audit file: Code ", GetLastError());
 return;
}

 if (FileWrite(Handle, TimeToStr(CurTime(), TIME_DATE|TIME_SECONDS) + " " + str) < 1){
 Print("Error writing to audit file: Code ", GetLastError());
 return;
}

 FileClose(Handle);
}
