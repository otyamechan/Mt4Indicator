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

double H1_MACD_0,H1_MACD_1,H1_MACD_MA_0,H1_MACD_MA_1,H1_MACD_MA_0_J,H1_MACD_MA_1_J;
double H1_MA_0,H1_MA_1;
double M5_MACD_0,M5_MACD_1,M5_MACD_MA_0,M5_MACD_MA_1;
double M15_Sen1,M15_Sen2;
double M5_Sen1,M5_Sen2;
double chk_pips_MACD;
double chk_pips_MA;

int H1_MACD_Rule,M5_MACD_Rule;
int H1_MA,H1_CHIKO;
int M15_SPAN,M15_CHIKO;
int M5_SPAN,M5_CHIKO;

bool Entry_buy,Exit_buy;
bool Entry_sell,Exit_sell;

string H1_MACD_Rule_mes,M5_MACD_Rule_mes;
string H1_MA_mes,H1_CHIKO_mes;
string M15_SPAN_mes,M15_CHIKO_mes;
string M5_SPAN_mes,M5_CHIKO_mes;


int count_15m ;     //15分足時間格納
int count_1H ;       //1時間足時間格納

int O_BandS;
int BandS;
int Kind;

int pos;
double pos_chk;

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

    pos_chk = Point;
   pos = 0;
   int i;
    for ( i = 0 ; pos_chk < 1 ;i++) {
      pos++;
      pos_chk = pos_chk * 10;
   }      
   pos++;
 

   return(0);
}
int deinit()
{
   return(0);
}
int start()
{
   int i;
    


   if (Time[0] != TimeOld)                      //時間が更新された場合
   {
   
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
      for(i= limit-1;i>=1;i--){
         if (Period() != PERIOD_M5 ) continue; 

         c_1H = iBarShift(NULL,PERIOD_H1,Time[i],true);
         if ( k1Htime[c_1H] > Time[i] ) {
            c_1H--;
         }            
         c_15m = iBarShift(NULL,PERIOD_M15,Time[i],true);
         if ( k15mtime[c_15m] > Time[i] ) {
            c_15m--;
         }
         //１H足MACD Rule の計算            
         H1_MACD_0 = iCustom(NULL,PERIOD_H1,"MACD++",H1_FastMAPeriod,H1_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",H1_MACD_Method,H1_SignalMAPeriod,H1_Signal_MAMethod,false,0,1,c_1H);
         H1_MACD_1 = iCustom(NULL,PERIOD_H1,"MACD++",H1_FastMAPeriod,H1_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",H1_MACD_Method,H1_SignalMAPeriod,H1_Signal_MAMethod,false,0,1,c_1H+H1_Chk_candle);
         H1_MACD_MA_0 = iMA(NULL,PERIOD_H1,H1_MACD_MAPeriod,0,H1_MACD_MA_Method,PRICE_CLOSE,c_1H);
         H1_MACD_MA_1 = iMA(NULL,PERIOD_H1,H1_MACD_MAPeriod,0,H1_MACD_MA_Method,PRICE_CLOSE,c_1H+H1_Chk_candle);
         H1_MACD_MA_0_J = iMA(NULL,PERIOD_H1,480,0,0,PRICE_CLOSE,c_1H);
         H1_MACD_MA_1_J = iMA(NULL,PERIOD_H1,480,0,0,PRICE_CLOSE,c_1H+H1_Chk_candle);

         
         //1時間足　移動平均線の計算            
         H1_MA_0 = iMA(NULL,PERIOD_H1,_H1_MA_Period,0,_H1_MA_Method,PRICE_CLOSE,c_1H);
         H1_MA_1 = iMA(NULL,PERIOD_H1,_H1_MA_Period,0,_H1_MA_Method,PRICE_CLOSE,c_1H+H1_Chk_candle);

         //15分足　スパンモデル　            
         M15_Sen1 = iCustom(NULL,PERIOD_M15,"span_model",M15_Kijun,M15_Tenkan,M15_Senkou,5,c_15m);
         M15_Sen2 = iCustom(NULL,PERIOD_M15,"span_model",M15_Kijun,M15_Tenkan,M15_Senkou,6,c_15m);

         //5H足MACD Rule の計算            
         M5_MACD_0 = iCustom(NULL,PERIOD_M5,"MACD++",M5_FastMAPeriod,M5_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",M5_MACD_Method,M5_SignalMAPeriod,M5_Signal_MAMethod,false,0,1,i);
         M5_MACD_1 = iCustom(NULL,PERIOD_M5,"MACD++",M5_FastMAPeriod,M5_SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",M5_MACD_Method,M5_SignalMAPeriod,M5_Signal_MAMethod,false,0,1,i+M5_Chk_candle);
         M5_MACD_MA_0 = iMA(NULL,PERIOD_M5,M5_MACD_MAPeriod,0,M5_MACD_MA_Method,PRICE_CLOSE,i);
         M5_MACD_MA_1 = iMA(NULL,PERIOD_M5,M5_MACD_MAPeriod,0,M5_MACD_MA_Method,PRICE_CLOSE,i+M5_Chk_candle);

         //5分足　スパンモデル　            
         M5_Sen1 = iCustom(NULL,PERIOD_M5,"span_model",M5_Kijun,M5_Tenkan,M5_Senkou,5,i);
         M5_Sen2 = iCustom(NULL,PERIOD_M5,"span_model",M5_Kijun,M5_Tenkan,M5_Senkou,6,i);

//1時間足MACDルール判定
        if (( H1_MACD_1 - H1_MACD_0 ) > 0)   {        //MACD下降中
            if (( H1_MACD_MA_1 - H1_MACD_MA_0 ) >= 0) {                     //MA下降中
              H1_MACD_Rule = MACD_DOWN;                               //MACDルール下降中と成立
            }
            else  {
               H1_MACD_Rule = MACD_NO;                            //MACDルール下降成立
            }
         }
         else if (( H1_MACD_1 - H1_MACD_0 ) <0 )  {  //MACD上昇中
            if (( H1_MA_1 - H1_MA_0 ) <= 0 ) {                //MAは下降中
               H1_MACD_Rule = MACD_UP;                                     //MACDルール不成立
            }
            else  {
               H1_MACD_Rule = MACD_NO;                                     //MACDルール上昇成立
            }
         }
         else if ((H1_MACD_1 - H1_MACD_0 ) == 0 ) { 
            if ((  H1_MA_1 - H1_MA_0 ) > 0)    {  
               H1_MACD_Rule = MACD_DOWN;                            //MACDルール不成立
            }
            else if (( H1_MACD_MA_1 - H1_MACD_MA_0 ) < 0 ){
               H1_MACD_Rule = MACD_UP;                            //MACDルール不成立
            }
            else  {
               H1_MACD_Rule = MACD_NO;                                     //MACDルール上昇成立
            }

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
//1時間足遅行スパン判定
         if ( iClose(Symbol(),PERIOD_H1,c_1H) > iClose(Symbol(),PERIOD_H1,c_1H+H1_Chiko_Time)) {
            H1_CHIKO = CHIKO_UP;
         }
         else if ( iClose(Symbol(),PERIOD_H1,c_1H) < iClose(Symbol(),PERIOD_H1,c_1H+H1_Chiko_Time)) { 
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
         if ( iClose(Symbol(),PERIOD_M15,c_15m) > iClose(Symbol(),PERIOD_M15,c_15m+25)) {
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
            if (( M5_MACD_MA_1 - M5_MACD_MA_0 ) >= 0) {                     //MA下降中
               M5_MACD_Rule = MACD_DOWN;                               //MACDルール下降中と成立
            }
            else  {
               M5_MACD_Rule = MACD_NO;                            //MACDルール下降成立
            }
         }
         else if (( M5_MACD_1 - M5_MACD_0 ) <0 )   {  //MACD上昇中
            if (( M5_MACD_MA_1 - M5_MACD_MA_0 ) <= 0 ) {                //MAは下降中
               M5_MACD_Rule = MACD_UP;                                     //MACDルール不成立
            }
            else  {
               M5_MACD_Rule = MACD_NO;                                     //MACDルール上昇成立
            }
         }
         else if ((M5_MACD_1 - M5_MACD_0 )  ==0 ) { 
            if ((  M5_MACD_MA_1 - M5_MACD_MA_0 ) >  0)    {  
               M5_MACD_Rule = MACD_DOWN;                            //MACDルール不成立
            }
            else if (( M5_MACD_MA_1 - M5_MACD_MA_0 ) < 0 ){
               M5_MACD_Rule = MACD_UP;                            //MACDルール不成立
            }
            else  {
               M5_MACD_Rule = MACD_NO;                                     //MACDルール上昇成立
           }

         }

//5分足スパンモデル判定
         if ( M5_Sen1 > M5_Sen2 ) {
            M5_SPAN = SPAN_UP;
         }
         else if ( M5_Sen1 < M5_Sen2 ) {            
            M5_SPAN = SPAN_DOWN;
         }
         else  {
            M5_SPAN = SPAN_NO;
         }            
//5分足遅行スパン判定
         if ( iClose(Symbol(),PERIOD_M5,i) > iClose(Symbol(),PERIOD_M5,i+25)) {
            M5_CHIKO = CHIKO_UP;
         }
         else if ( iClose(Symbol(),PERIOD_M5,i) < iClose(Symbol(),PERIOD_M5,i+25)) {
            M5_CHIKO = CHIKO_UP;
         }
         else  {
            M5_CHIKO = CHIKO_NO;
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
         switch( O_BandS ) {
            case NO_POSITION:
               if ( Entry_buy == true ) {
                  UpArrow[i]=Low[i] - Point * Signal_Pos;
                  BandS = BUY_POSITION;
                  Kind = BUY_POSITION;
               }
               else if ( Entry_sell == true ) {
                  DownArrow[i]=High[i] + Point * Signal_Pos;
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
                  DownArrow[i]=High[i] + Point * Signal_Pos;
                  BandS = SELL_POSITION;
                  Kind = SELL_POSITION;
               }
               else {
                  UpKessaiArrow[i] = High[i]  + Point * Signal_Pos;
                  BandS = NO_POSITION;
                  Kind = BUY_KESSAI;
               }
               break;         
            case SELL_POSITION:
               if ( Entry_buy == true ) {
                  UpArrow[i]=Low[i]  - Point * Signal_Pos;
                  BandS = BUY_POSITION;
                  Kind = BUY_POSITION;
               }
               else if ( Exit_sell == true ) {
                  BandS = SELL_POSITION;
                  Kind = 0;
               }
               else {
                  DownKessaiArrow[i] = Low[i]  - Point * Signal_Pos;
                  BandS = NO_POSITION;
                  Kind = SELL_KESSAI;
               }
               break;         
         }
         O_BandS = BandS;
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
//exit チェック
         switch(H1_MACD_Rule) {
         case MACD_NO:
            H1_MACD_Rule_mes = "1時間足MACDルール不成立";
            break;
         case MACD_UP:
            H1_MACD_Rule_mes = "1時間足MACDルール上昇";
            break;
         case MACD_DOWN:
            H1_MACD_Rule_mes = "1時間足MACDルール下降";
            break;
         }    
         switch(H1_MA) {
         case MA_NO:
            H1_MA_mes = "1時間足移動平均線不成立";
            break;
         case MA_UP:
            H1_MA_mes = "1時間足移動平均線上昇";
            break;
         case MA_DOWN:
            H1_MA_mes = "1時間足移動平均線下降";
            break;
         }    
         switch(H1_CHIKO) {
         case CHIKO_NO:
            H1_CHIKO_mes = "1時間足遅行スパン不成立";
            break;
         case CHIKO_UP:
            H1_CHIKO_mes = "1時間足遅行スパン上昇";
            break;
         case CHIKO_DOWN:
            H1_CHIKO_mes = "1時間足遅行スパン下降";
            break;
         }    
         switch(M15_SPAN) {
         case SPAN_NO:
            M15_SPAN_mes = "15分足スパンモデル不成立";
            break;
         case SPAN_UP:
            M15_SPAN_mes = "15分足スパンモデル上昇";
            break;
         case SPAN_DOWN:
            M15_SPAN_mes = "15分足スパンモデル下降";
            break;
         }    
         switch(M15_CHIKO) {
         case CHIKO_NO:
            M15_CHIKO_mes = "15分足遅行スパン不成立";
            break;
         case CHIKO_UP:
            M15_CHIKO_mes = "15分足遅行スパン上昇";
            break;
         case CHIKO_DOWN:
            M15_CHIKO_mes = "15分足遅行スパン下降";
            break;
         }    
         switch(M5_MACD_Rule) {
         case MACD_NO:
            M5_MACD_Rule_mes = "5分足MACDルール不成立";
            break;
         case MACD_UP:
            M5_MACD_Rule_mes = "5分足MACDルール上昇";
            break;
         case MACD_DOWN:
            M5_MACD_Rule_mes = "5分足MACDルール下降";
            break;
         }    
         switch(M5_SPAN) {
         case SPAN_NO:
            M5_SPAN_mes = "5分足スパンモデル不成立";
            break;
         case SPAN_UP:
            M5_SPAN_mes = "5分足スパンモデル上昇";
            break;
         case SPAN_DOWN:
            M5_SPAN_mes = "5分足スパンモデル下降";
            break;
         }    
         switch(M5_CHIKO) {
         case CHIKO_NO:
            M5_CHIKO_mes = "5分足遅行スパン不成立";
            break;
         case CHIKO_UP:
            M5_CHIKO_mes = "5分足遅行スパン上昇";
            break;
         case CHIKO_DOWN:
            M5_CHIKO_mes = "5分足遅行スパン下降";
            break;
         }    
         switch(Kind)   {
            case BUY_POSITION:
               message= "買い Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 

               break;
            case SELL_POSITION:
               message= "売り Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
               break;
            case BUY_KESSAI:
               message= "買い決済 Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
               break;
            case SELL_KESSAI:
               message= "売り決済 Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
               break;
         }
         message = message + "\r\n"+H1_MACD_Rule_mes;
         message = message +  "\r\n"+H1_MA_mes;
         message = message +  "\r\n"+H1_CHIKO_mes;
         message = message +  "\r\n"+M15_SPAN_mes;
         
         message = message +  "\r\n"+M15_CHIKO_mes;
         message = message +  "\r\n"+M5_MACD_Rule_mes;
         message = message +  "\r\n"+M5_SPAN_mes;
         message = message +  "\r\n"+M5_CHIKO_mes;
         if ( Kind != 0 ) SendMail("複合ルール " +"["+Symbol()+"]["+Period()+"]",message);
            Emailflag = false;      
      }
      if (Alertflag== true) {
         switch(Kind)   {
            case BUY_POSITION:
               Alert("Spanmodel BUY Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
            case SELL_POSITION:
               Alert("Spanmodel SELL Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
               break;
            case BUY_KESSAI:
               Alert("Spanmodel BUY Kessai Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
            case SELL_KESSAI:
               Alert("Spanmodel SELl Kessai Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
         }
         Alertflag = false;

      }
   }
   return(0);
}

