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

#property indicator_buffers 8

#property indicator_chart_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Red

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 4
#property indicator_width6 4
#property indicator_width7 4
#property indicator_width8 4

#define NO_POSITION  0
#define BUY_POSITION  1 
#define SELL_POSITION  2
#define BUY_KESSAI  11
#define SELL_KESSAI 12


//---- buffers
double UpArrow[];
double DownArrow[];
double CheckPoint[];
double BollinPoint[];
double Sen1UpArrow[];
double Sen1DownArrow[];
double Sen2UpArrow[];
double Sen2DownArrow[];


string message;
extern bool AlertON=false;        //アラート表示　
extern bool EmailON=true;        //メール送信
extern  bool Redraw = false;    //5分足考慮
extern  int  Signal_Pos = 20;    //5分足考慮

extern bool M5_Chiko_21_ = true;
extern bool M5_Chiko_26_ = true;
extern bool M15_Chiko_21_ = true;
extern bool M15_Chiko_26_ = true;
extern bool M30_Chiko_21_ = true;
extern bool M30_Chiko_26_ = true;
extern bool H1_Chiko_21_ = true;
extern bool H1_Chiko_26_ = true;
extern bool H4_Chiko_21_ = true;
extern bool H4_Chiko_26_ = true;
extern bool D1_Chiko_21_ = true;
extern bool D1_Chiko_26_ = true;
extern bool W1_Chiko_21_ = true;
extern bool W1_Chiko_26_ = true;


extern bool bCrossArert = false;
extern bool bUseSpanAIn = false;
extern bool bUseSpanAOut = false;
extern bool bUseSpanBIn = false;
extern bool bUseSpanBOut = false;
extern bool bUseChikoCross = false;
extern bool bUseBandOut = true;
extern bool bSenSpanADirect = false;
extern bool bSenSpanBDirect = false;


extern int Tenkan = 9;           //転換線
extern int Kijun = 25;           //基準線 
extern int Senkou = 52;          //先行スパン 

extern  string _SuperBollin_Setting = "Super Bollinger Setting";
extern  bool kansi_5m = false;    //5分足考慮
extern  bool kansi_15m = false;   //15分足考慮
extern  bool kansi_30m = false;   //30分足考慮
extern  bool kansi_1H = false;    //1時間足考慮
extern  bool kansi_4H = true;    //4時間足考慮
extern  bool kansi_1D = false;    //日足考慮
extern  int  MAPeriod = 21;
extern  int  MAMethod = 0;

extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 7;
extern string symbol1 = "USDJPY";
extern string symbol2 = "EURJPY";
extern string symbol3 = "EURUSD";
extern string symbol4 = "GBPJPY";
extern string symbol5 = "AUDJPY";
extern string symbol6 = "AUDUSD";
extern string symbol7 = "GBPUSD";
extern string symbol8 = "";
extern string symbol9 = "";
extern string symbol10 = "";

bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

double Bollin_P3sigma,Bollin_P2sigma,Bollin_P1sigma;
double Bollin_Center;
double Bollin_M3sigma,Bollin_M2sigma,Bollin_M1sigma;

double Before_Sen1[10],Before_Sen2[10];



datetime TimeOld= D'1970.01.01 00:00:00';
datetime k1mtime[];              //5分足格納用
datetime k5mtime[];              //5分足格納用
datetime k15mtime[];             //15分足格納用
datetime k30mtime[];             //30分足格納用
datetime k1Htime[];              //1時間足格納用
datetime k4Htime[];              //4時間足格納用
datetime k1Dtime[];              //日足格納用

int count_5m ;        //5分足時間格納
int count_15m ;     //15分足時間格納
int count_30m ;     //30分足時間格納
int count_1H ;       //1時間足時間格納
int count_4H ;      //4時間足時間格納
int count_1D ;     //日足時間格納




double Sen1_0[10],Sen1_1[10],Sen2_0[10],Sen2_1[10];          //クロスチェック用
double Sen1_5m[10],Sen2_5m[10],Sen1_15m[10],Sen2_15m[10];      //上位足確認用
double Sen1_30m[10],Sen2_30m[10],Sen1_1H[10],Sen2_1H[10];    
double Sen1_4H[10],Sen2_4H[10],Sen1_1D[10],Sen2_1D[10];    

bool SellCrossSignal[10],BuyCrossSignal[10],CrossSignal[10];
bool SellSignal[10],BuySignal[10];
bool SpanAInSignal[10],SpanAOutSignal[10];
bool SpanBInSignal[10],SpanBOutSignal[10];
bool BollinSignal[10];
bool Sen1DirectSignal[10],Sen2DirectSignal[10];
bool ChikoSignal[10];

int B_Bollin_Lank[10],Bollin_Lank[10];
double B_Bollin_Pos[10],Bollin_Pos[10];
bool B_Sen1_Direct[10],B_Sen2_Direct[10];
bool Sen1_Direct[10],Sen2_Direct[10];

bool Mail_Send_Flag;
int pos[10];
double pos_chk;

int c_1m,c_5m,c_15m,c_30m,c_1H,c_4H,c_1D;         //時間位置

string mes;
string mes_Bollin[10];
bool symbol_true[10];
int symbol_max;
string symbol_chk[10];
int cnt;
int rtn;

bool Timeflg = false;

int init()
{
   int i;
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
   SetIndexArrow(2,252);
   SetIndexBuffer(2,CheckPoint);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,117);
   SetIndexBuffer(3,BollinPoint);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,228);
   SetIndexBuffer(4,Sen1UpArrow);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,230);
   SetIndexBuffer(5,Sen1DownArrow);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,246);
   SetIndexBuffer(6,Sen2UpArrow);
   SetIndexEmptyValue(6,EMPTY_VALUE);
   SetIndexStyle(7,DRAW_ARROW);
   SetIndexArrow(7,248);
   SetIndexBuffer(7,Sen2DownArrow);
   SetIndexEmptyValue(7,EMPTY_VALUE);


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
      count_5m = ArrayCopySeries(k1mtime,MODE_TIME,Symbol(),5);        //5分足時間格納
      count_5m = ArrayCopySeries(k5mtime,MODE_TIME,Symbol(),5);        //5分足時間格納
      count_15m = ArrayCopySeries(k15mtime,MODE_TIME,Symbol(),15);     //15分足時間格納
      count_30m = ArrayCopySeries(k30mtime,MODE_TIME,Symbol(),30);     //30分足時間格納
      count_1H = ArrayCopySeries(k1Htime,MODE_TIME,Symbol(),60);       //1時間足時間格納
      count_4H = ArrayCopySeries(k4Htime,MODE_TIME,Symbol(),240);      //4時間足時間格納
      count_1D = ArrayCopySeries(k1Dtime,MODE_TIME,Symbol(),1440);     //日足時間格納
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      if ( limit < 2 ) limit = 2;
      for (  cnt = 0 ; cnt < symbol_max ; cnt++) {  
         if ( symbol_true[cnt] == false ) {
            continue;
         }
         for(i= limit-1;i>=1;i--) {
            switch(Period())
               {
               case PERIOD_M1 : 
                  c_1m = iBarShift(NULL,PERIOD_M1,Time[i],true);
                  if ( k5mtime[c_1m] > Time[i] ) {
                     c_1m++;
                  }            
               case PERIOD_M5 : 
                  c_5m = iBarShift(NULL,PERIOD_M1,Time[i],true);
                  if ( k5mtime[c_5m] > Time[i] ) {
                     c_5m++;
                  }            
               case PERIOD_M15 :
                  c_15m = iBarShift(NULL,PERIOD_M15,Time[i],true);
                  if ( k15mtime[c_15m] > Time[i] ) {
                     c_15m++;
                  }            
               case PERIOD_M30 :
               c_30m = iBarShift(NULL,PERIOD_M30,Time[i],true);
                  if ( k30mtime[c_30m] > Time[i] ) {
                     c_30m++;
                  }            
               case PERIOD_H1 :
                  c_1H = iBarShift(NULL,PERIOD_H1,Time[i],true);
                  if ( k1Htime[c_1H] > Time[i] ) {
                     c_1H++;
                  }            
               case PERIOD_H4 :
                  c_4H = iBarShift(NULL,PERIOD_H4,Time[i],true);
                  if ( k4Htime[c_4H] > Time[i] ) {
                     c_4H++;
                  }            
               case PERIOD_D1 :
                  c_1D = iBarShift(NULL,PERIOD_D1,Time[i],true);
                  if ( k1Dtime[c_1D] > Time[i] ) {
                     c_1D++;
                  }            
            }
            if (c_1m == 0 ) c_1m++;
            if (c_5m == 0 ) c_5m++;
            if (c_15m == 0 ) c_15m++;
            if (c_30m == 0 ) c_30m++;
            if (c_1H == 0 ) c_1H++;
            if (c_4H == 0 ) c_4H++;
            if (c_1D == 0 ) c_1D++;
            if ( kansi_5m == true ) {
               Sen1_5m[cnt] = iCustom(symbol_chk[cnt],PERIOD_M5,"span_model",Kijun,Tenkan,Senkou,5,c_5m);
               Sen2_5m[cnt] = iCustom(symbol_chk[cnt],PERIOD_M5,"span_model",Kijun,Tenkan,Senkou,6,c_5m);
               Bollin_Pos[cnt] = Bollin_Sigma_Chk(Time[i],iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_M5,MAPeriod,MAMethod,PRICE_CLOSE,c_5m);
            }
            else if ( kansi_15m == true ) {
               Sen1_15m[cnt] = iCustom(symbol_chk[cnt],PERIOD_M15,"span_model",Kijun,Tenkan,Senkou,5,c_15m);
               Sen2_15m[cnt] = iCustom(symbol_chk[cnt],PERIOD_M15,"span_model",Kijun,Tenkan,Senkou,6,c_15m);
               Bollin_Pos[cnt] = Bollin_Sigma_Chk(Time[i],iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_M15,MAPeriod,MAMethod,PRICE_CLOSE,c_15m);
            }
            else  if ( kansi_30m == true ) {
               Sen1_30m[cnt] = iCustom(symbol_chk[cnt],30,"span_model",Kijun,Tenkan,Senkou,5,c_30m);
               Sen2_30m[cnt] = iCustom(symbol_chk[cnt],30,"span_model",Kijun,Tenkan,Senkou,6,c_30m);
               Bollin_Pos[cnt] = Bollin_Sigma_Chk(Time[i],iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_M30,MAPeriod,MAMethod,PRICE_CLOSE,c_30m);
            }
            else if ( kansi_1H == true ) {
               Sen1_1H[cnt] = iCustom(symbol_chk[cnt],60,"span_model",Kijun,Tenkan,Senkou,5,c_1H);
               Sen2_1H[cnt] = iCustom(symbol_chk[cnt],60,"span_model",Kijun,Tenkan,Senkou,6,c_1H);
               Bollin_Pos[cnt] = Bollin_Sigma_Chk(Time[i],iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_H1,MAPeriod,MAMethod,PRICE_CLOSE,c_1H);
            }
            else if ( kansi_4H == true ) {
               Sen1_4H[cnt] = iCustom(symbol_chk[cnt],240,"span_model",Kijun,Tenkan,Senkou,5,c_4H);
               Sen2_4H[cnt] = iCustom(symbol_chk[cnt],240,"span_model",Kijun,Tenkan,Senkou,6,c_4H);
               Bollin_Pos[cnt] = Bollin_Sigma_Chk(Time[i],iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_H4,MAPeriod,MAMethod,PRICE_CLOSE,c_4H);
            }
            else if ( kansi_1D == true ) {
               Sen1_1D[cnt] = iCustom(symbol_chk[cnt],1440,"span_model",Kijun,Tenkan,Senkou,5,c_1D);
               Sen2_1D[cnt] = iCustom(symbol_chk[cnt],1440,"span_model",Kijun,Tenkan,Senkou,6,c_1D);
               Bollin_Pos[cnt] = Bollin_Sigma_Chk(Time[i],iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_D1,MAPeriod,MAMethod,PRICE_CLOSE,c_1D);
            }
            Sen1_0[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,5,i);
            Sen1_1[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,5,i+1);
            Sen2_0[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,6,i);
            Sen2_1[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,6,i+1);
//先行スパン１、２のクロスチェック       
            if (( Sen1_1[cnt] >= Sen2_1[cnt] ) && ( Sen1_0[cnt] < Sen2_0[cnt] )) {
               SellCrossSignal[cnt] = true;
               BuyCrossSignal[cnt] = false;
               CrossSignal[cnt] = true;
            }
            else if (( Sen1_1[cnt] <= Sen2_1[cnt] ) && ( Sen1_0[cnt] > Sen2_0[cnt] )) {
               SellCrossSignal[cnt] = false;
               BuyCrossSignal[cnt] = true;
               CrossSignal[cnt] = true;
            }
            else {
               SellCrossSignal[cnt] = true;
               BuyCrossSignal[cnt] = false;
               CrossSignal[cnt] = false;
            }
//売買シグナルチェック       
            if ( Sen1_0[cnt] < Sen2_0[cnt] ) {
               SellSignal[cnt] = true;
               BuySignal[cnt] = false;
            }
            else if ( Sen1_0[cnt] > Sen2_0[cnt] ) {
               SellSignal[cnt] = false;
               BuySignal[cnt] = true;
            }
            else {
               SellSignal[cnt] = false;
               BuySignal[cnt] = false;
            }
//SpanAを網の外からクロスした場合（bUseSpanAIn）
            SpanAInSignal[cnt] = false;
            if ( BuySignal[cnt] == true ) {
               if (( iClose(symbol_chk[cnt],0,i+1) > Sen1_1[cnt] ) && ( iClose(symbol_chk[cnt],0,i) <= Sen1_0[cnt] )) {
                  SpanAInSignal[cnt] = true;
               }
            }
            if ( SellSignal[cnt] == true ) {
               if (( iClose(symbol_chk[cnt],0,i+1) < Sen1_1[cnt] ) && ( iClose(symbol_chk[cnt],0,i) >= Sen1_0[cnt] )) {
                  SpanAInSignal[cnt] = true;
               }
            }
//SpanAを網の内からクロスした場合（bUseSpanAOut）
            SpanAOutSignal[cnt] = false;
            if ( BuySignal[cnt] == true ) {
               if (( iClose(symbol_chk[cnt],0,i+1) < Sen1_1[cnt] ) && ( iClose(symbol_chk[cnt],0,i) >= Sen1_0[cnt] )) {
                  SpanAOutSignal[cnt] = true;
               }
            }
            if ( SellSignal[cnt] == true ) {
               if (( iClose(symbol_chk[cnt],0,i+1) > Sen1_1[cnt] ) && ( iClose(symbol_chk[cnt],0,i) <= Sen1_0[cnt] )) {
                  SpanAOutSignal[cnt] = true;
               }
            }
//SpanBを網の外からクロスした場合（bUseSpanBIn)
            SpanBInSignal[cnt] = false;
            if ( BuySignal[cnt] == true ) {
               if (( iClose(symbol_chk[cnt],0,i+1) < Sen2_1[cnt] ) && ( iClose(symbol_chk[cnt],0,i) >= Sen2_0[cnt] )) {
                  SpanBInSignal[cnt] = true;
               }
            }
            if ( SellSignal[cnt] == true ) {
               if (( iClose(symbol_chk[cnt],0,i+1)> Sen2_1[cnt] ) && ( iClose(symbol_chk[cnt],0,i) <= Sen2_0[cnt] )) {
                  SpanBInSignal[cnt] = true;
               }
            }
//SpanBを網の外からクロスした場合（bUseSpanBIn)
            SpanBOutSignal[cnt] = false;
            if ( BuySignal[cnt] == true ) {
               if( ( iClose(symbol_chk[cnt],0,i+1) > Sen2_1[cnt] ) && ( iClose(symbol_chk[cnt],0,i) <= Sen2_0[cnt] )) {
                  SpanBOutSignal[cnt] = true;
               }
            }
            if ( SellSignal[cnt] == true ) {
               if (( iClose(symbol_chk[cnt],0,i+1) < Sen2_1[cnt] ) && ( iClose(symbol_chk[cnt],0,i) >= Sen2_0[cnt] )) {
                  SpanBOutSignal[cnt] = true;
               }
            }  
 //ボリンジャーバンドの位置
            Bollin_Lank[cnt] = Bollin_Lank_Chk(Bollin_Pos[cnt]);
            if ( B_Bollin_Lank[cnt] != Bollin_Lank[cnt] ) {
               BollinSignal[cnt] = true;
            }
            else {
               BollinSignal[cnt] = false;
            }
 //           Print(TimeToStr(Time[i],TIME_DATE|TIME_MINUTES)," BollinSignal = ",BollinSignal[cnt]," B_Bollin_Pos = ",B_Bollin_Pos[cnt]," Bollin_Pos = ",Bollin_Pos[cnt]," B_Bollin_Lank= ",B_Bollin_Lank[cnt]," Bollin_Lank = ",Bollin_Lank[cnt]);
            B_Bollin_Lank[cnt] = Bollin_Lank[cnt];
            mes_Bollin[cnt]=B_Bollin_Pos[cnt] + "σ　→　" + Bollin_Pos[cnt]+"σ";
//            Print(mes_Bollin[cnt]);
            B_Bollin_Pos[cnt] = Bollin_Pos[cnt];
            
//先行スパン１傾きチェック         
            Sen1DirectSignal[cnt] = false;
            if ( Before_Sen1[cnt] != Sen1_0[cnt] ) {
               if ( Before_Sen1[cnt] > Sen1_0[cnt] ) {
                  Sen1_Direct[cnt] = false;
               }
               else if ( Before_Sen1[cnt] < Sen1_0[cnt] ) {
                  Sen1_Direct[cnt] = true;
               }
               Before_Sen1[cnt] = Sen1_0[cnt];
               if (( B_Sen1_Direct[cnt] == true ) && ( Sen1_Direct[cnt] == false )) {
                  Sen1DirectSignal[cnt] = true;
               }
               else if (( B_Sen1_Direct[cnt] == false ) && ( Sen1_Direct[cnt] == true )) {
                  Sen1DirectSignal[cnt] = true;
               }
               else {
                  Sen1DirectSignal[cnt] = false;
               }         
               B_Sen1_Direct[cnt] = Sen1_Direct[cnt];
            }
//先行スパン2傾きチェック         
            Sen2DirectSignal[cnt] = false;
            if ( Before_Sen2[cnt] != Sen2_0[cnt] ) {
               if ( Before_Sen2[cnt] > Sen2_0[cnt] ) {
                  Sen2_Direct[cnt] = false;
               }
               else if ( Before_Sen2[cnt] < Sen2_0[cnt] ) {
                  Sen2_Direct[cnt] = true;
               }
               Before_Sen2[cnt] = Sen2_0[cnt];
               if (( B_Sen2_Direct[cnt] == true ) && ( Sen2_Direct[cnt] == false )) {
                  Sen2DirectSignal[cnt] = true;
               }
               else if (( B_Sen2_Direct[cnt] == false ) && ( Sen2_Direct[cnt] == true )) {
                  Sen2DirectSignal[cnt] = true;
               }
               else {
                  Sen2DirectSignal[cnt] = false;
               }         
               B_Sen2_Direct[cnt] = Sen2_Direct[cnt];
            }
//遅行スパンクロスチェック         
            ChikoSignal[cnt] = false;
            if (( iClose(symbol_chk[cnt],0,i+1) > iHigh(symbol_chk[cnt],0,i+26) ) && (iClose(symbol_chk[cnt],0,i) <=  iHigh(symbol_chk[cnt],0,i+25) )) {
               ChikoSignal[cnt] = true;
            }
            else if (( iClose(symbol_chk[cnt],0,i+1) <  iLow(symbol_chk[cnt],0,i+26) ) && (iClose(symbol_chk[cnt],0,i) >= iLow(symbol_chk[cnt],0,i+25) )) {
               ChikoSignal[cnt] = true;
            }
            else if ((( iClose(symbol_chk[cnt],0,i+1) >= iLow(symbol_chk[cnt],0,i+26) ) && (iClose(symbol_chk[cnt],0,i+1) <= iHigh(symbol_chk[cnt],0,i+26) )) && (iClose(symbol_chk[cnt],0,i) > iHigh(symbol_chk[cnt],0,i+25))) {
               ChikoSignal[cnt] = true;
            }
            else if ((( iClose(symbol_chk[cnt],0,i+1) >= iLow(symbol_chk[cnt],0,i+26) ) && (iClose(symbol_chk[cnt],0,i+1) <= iHigh(symbol_chk[cnt],0,i+26) )) && (iClose(symbol_chk[cnt],0,i) < iLow(symbol_chk[cnt],0,i+25))) {
               ChikoSignal[cnt] = true;
            }
//シグナル 
            if (bCrossArert == true ) {
               if ( CrossSignal[cnt] == true ) {
                  if ( BuyCrossSignal[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpArrow[i]=Low[i] - Point * Signal_Pos;
                     }
                  }
                  if ( SellCrossSignal[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownArrow[i]=High[i] + Point * Signal_Pos;
                     }
                  }
               }   
            }
            if (bUseSpanAIn == true ) {
               if ( SpanAInSignal[cnt] == true ) {
                  if ( BuySignal[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpArrow[i]=Low[i] - Point * Signal_Pos;
                     }
                  }
                  if ( SellSignal[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownArrow[i]=High[i] + Point * Signal_Pos;
                     }
                  }
               }
            }   
            if (bUseSpanAOut == true ) {
               if ( SpanAOutSignal[cnt] == true ) {
                  if ( BuySignal[cnt] == true)   {
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpArrow[i]=Low[i] - Point * Signal_Pos;
                     }
                  }
                  if ( SellSignal[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownArrow[i]=High[i] + Point * Signal_Pos;
                     }
                  }
               }
            }   
            if (bUseSpanBIn == true ) {
               if ( SpanBInSignal[cnt] == true ) {
                  if ( BuySignal[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpArrow[i]=Low[i] - Point * Signal_Pos;
                     }
                  }
                  if ( SellSignal[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownArrow[i]=High[i] + Point * Signal_Pos;
                     }
                  }
               }
            }   
            if (bUseSpanBOut == true ) {
               if ( SpanBOutSignal[cnt] == true ) {
                  if ( BuySignal[cnt] == true  ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownArrow[i]=High[i] + Point * Signal_Pos;
                     }
                  }
                  if ( SellSignal[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpArrow[i]=Low[i] - Point * Signal_Pos;
                     }
                  }
               }
            }   
            if (bUseChikoCross == true ) {
               if ( ChikoSignal[cnt] == true ) {
                  if ( BuySignal[cnt] == true  ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        CheckPoint[i]=High[i] + Point * Signal_Pos;
                     }
                  }
                  if ( SellSignal[cnt] == true ) {
                     CheckPoint[i]=Low[i] - Point * Signal_Pos;
                  }
               }
            }   
            if (bUseBandOut == true ) {
               if ( BollinSignal[cnt] == true ) {
                  if ( BuySignal[cnt] == true  ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        BollinPoint[i]=High[i] + Point * Signal_Pos;
                     }
                  }
                  if ( SellSignal[cnt] == true ) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        BollinPoint[i]=Low[i] - Point * Signal_Pos;
                     }
                  }
               }
            }   
            if (bSenSpanADirect == true ) {
               if ( Sen1DirectSignal[cnt] == true ) {
                  if ( BuySignal[cnt] == true  ) {
                     if ( Sen1_Direct[cnt] == true ) {
                        if ( symbol_chk[cnt] == Symbol()) {
                           Sen1UpArrow[i]=Sen1_0[cnt] + Point * Signal_Pos;
                        }
                     }
                     else {
                        if ( symbol_chk[cnt] == Symbol()) {
                           Sen1DownArrow[i]=Sen1_0[cnt] + Point * Signal_Pos;
                        }
                     }
                  }                  
                  if ( SellSignal[cnt] == true ) {
                     if ( Sen1_Direct[cnt] == true ) {
                        if ( symbol_chk[cnt] == Symbol()) {
                           Sen1UpArrow[i]=Sen1_0[cnt] - Point * Signal_Pos;
                        }
                     }
                     else {
                        if ( symbol_chk[cnt] == Symbol()) {
                           Sen1DownArrow[i]=Sen1_0[cnt] - Point * Signal_Pos;
                        }
                     }
                  }
               }
            }   
            if (bSenSpanBDirect == true ) {
               if ( Sen2DirectSignal[cnt] == true ) {
                  if ( BuySignal[cnt] == true  ) {
                     if ( Sen2_Direct[cnt] == true ) {
                        if ( symbol_chk[cnt] == Symbol()) {
                           Sen2UpArrow[i]=Sen2_0[cnt] -Point * Signal_Pos;
                        }
                     }
                     else {
                        if ( symbol_chk[cnt] == Symbol()) {
                           Sen2DownArrow[i]=Sen2_0[cnt] - Point * Signal_Pos;
                        }
                     }
                  }                  
                  if ( SellSignal[cnt] == true ) {
                     if ( Sen2_Direct[cnt] == true ) {
                        if ( symbol_chk[cnt] == Symbol()) {
                           Sen2UpArrow[i] = Sen2_0[cnt] + Point * Signal_Pos;
                        }
                     }
                     else {
                        if ( symbol_chk[cnt] == Symbol()) {
                           Sen2DownArrow[i]=Sen2_0[cnt] + Point * Signal_Pos;
                        }
                     }
                  }
               }
            }   
 
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
            double chiko;
            chiko =  iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,4,25);           
            if (Emailflag== true) {
               Mail_Send_Flag = false;
               message= "スパンモデル情報"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],0,25),pos[cnt]-1);
               if ( kansi_5m == true ) {
                  mes = "5分足";
               }
               else if ( kansi_15m == true ) {
                  mes = "15分足";
               }
               else if ( kansi_30m == true ) {
                  mes = "30分足";
               }
               else if ( kansi_1H == true ) {
                  mes = "１時間足";
               }
               else if ( kansi_4H == true ) {
                  mes = "４時間足";
               }
               else if ( kansi_1D == true ) {
                  mes = "日足";
               }
               message = message + " \r\n ボリンジャーバンド "+ mes + " "+mes_Bollin[cnt];
               if ( BuySignal[cnt] == true ) {
                  message = message + " \r\n 買いシグナル中";
               }
               else if ( SellSignal[cnt] == true ) {
                  message = message + " \r\n 売りシグナル中";
               }
               else if ( SellSignal[cnt] == true ) {
                  message = message + " \r\n 売買シグナル無";
               }
               if ( Sen1_Direct[cnt] == true ) {
                  message = message + " \r\n 先行スパン１上昇中";
               }
               else {
                  message = message + " \r\n 先行スパン１下降中";
               }               
               if ( Sen2_Direct[cnt] == true ) {
                  message = message + " \r\n 先行スパン２上昇中";
               }
               else {
                  message = message + " \r\n 先行スパン２下降中";
               }               
               
               
               if ( bCrossArert == true ) {
                  if ( CrossSignal[cnt] == true ) {
                     Mail_Send_Flag = true;
                     if ( BuyCrossSignal[cnt] == true ) {
                        message = message + " \r\n 買いシグナル発生";
                     }
                     else if ( SellCrossSignal[cnt] == true ) {
                        message = message + " \r\n 売りシグナル発生";
                     }
                  }
               }                          
               if (bUseSpanAIn == true ) {
                  if ( SpanAInSignal[cnt] == true) {
                     Mail_Send_Flag = true;
                     message = message +  " \r\n 先行スパン１インクロスアラート";        
                  }
               }
               if (bUseSpanAOut == true ) {
                  if ( SpanAOutSignal[cnt] == true) {
                     Mail_Send_Flag = true;
                     message = message +  " \r\n 先行スパン１アウトクロスアラート";        
                  }
               }
               if (bUseSpanBIn == true ) {
                  if ( SpanBInSignal[cnt] == true) {
                     Mail_Send_Flag = true;
                     message = message +  " \r\n 先行スパン２インクロスアラート";        
                  }
               }
               if (bUseSpanBOut == true ) {
                  if ( SpanBOutSignal[cnt] == true) {
                     Mail_Send_Flag = true;
                     message = message +  " \r\n 先行スパン２アウトクロスアラート";        
                  }
               }
               if (bUseChikoCross == true ) {
                  if ( ChikoSignal[cnt] == true) {
                     Mail_Send_Flag = true;
                     message = message +  " \r\n 遅行スパンクロスアラート";        
                  }
               }
               if (bUseBandOut == true ) {            
                  if ( BollinSignal[cnt] == true) {
                     Mail_Send_Flag = true;
                     message = message +  " \r\n ボリンジャーバンドランク変更アラート";        
                  }
               }
               if (bSenSpanADirect == true ) {
                  if ( Sen1DirectSignal[cnt] == true) {
                     Mail_Send_Flag = true;
                     if ( Sen1_Direct[cnt] == true ) {
                        message = message +  " \r\n 先行スパン１上昇変化";        
                     }
                     else {
                        message = message +  " \r\n 先行スパン１下降変化";        
               
                     }
                  }
               }
               if (bSenSpanBDirect == true ) {
                  if ( Sen2DirectSignal[cnt] == true) {
                     Mail_Send_Flag = true;
                     if ( Sen2_Direct[cnt] == true ) {
                        message = message +  " \r\n 先行スパン2上昇変化";        
                     }
                     else {
                        message = message +  " \r\n 先行スパン2下降変化";        
                     }
                  }
               }
               if (Mail_Send_Flag ==  true ) {
                  SendMail("スパンモデルインフォメーション " +"["+symbol_chk[cnt]+"]["+Period()+"]",message);
               }
            }
         }
      }                        
      Emailflag = false;      
      if (Alertflag== true) {
         for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
            if (symbol_true[cnt] == false ) {
               continue;
            }
            if ( bCrossArert == true ) {
               if ( CrossSignal[cnt] == true ) {
                  if ( BuyCrossSignal[cnt] == true ) {
                     Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
                  }
                  else if ( SellCrossSignal[cnt] == true ) {
                     Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
                  }
               }
            }                          
            if (bUseSpanAIn == true ) {
               if ( SpanAInSignal[cnt] == true) {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
               }
            }
            if (bUseSpanAOut == true ) {
               if ( SpanAOutSignal[cnt] == true) {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
               }
            }
            if (bUseSpanBIn == true ) {
               if ( SpanBInSignal[cnt] == true) {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
               }
            }
            if (bUseSpanBOut == true ) {
               if ( SpanBOutSignal[cnt] == true) {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
               }
            }
            if (bUseChikoCross == true ) {
               if ( ChikoSignal[cnt] == true) {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
               }
            }
            if (bUseBandOut == true ) {            
               if ( BollinSignal[cnt] == true) {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
               }
            }
            if (bSenSpanADirect == true ) {
               if ( Sen1DirectSignal[cnt] == true) {
                  if ( Sen1_Direct[cnt] == true ) {
                     Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
                  }
                  else {
                     Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
                  }
               }
            }
            if (bSenSpanBDirect == true ) {
               if ( Sen2DirectSignal[cnt] == true) {
                  if ( Sen2_Direct[cnt] == true ) {
                     Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos[cnt]-1));
                  }
                  else {
                     Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos[cnt]-1));
                  }
               }
            }
         }
      } 
      Alertflag = false;      
   }
   Timeflg = false;
   return(0);
}


double Bollin_Sigma_Chk(datetime date,double data,string Chk_symbol,int Chk_Period,int Chk_MAPeriod,int Chk_MAMethod,int Chk_Price,int position)
{
   int i;
   double Chk_data[2];
   double ret;
   Chk_data[0] = iMA(Chk_symbol,Chk_Period,Chk_MAPeriod,0,Chk_MAMethod,Chk_Price,position);
   
   if ( data > Chk_data[0] ) {
      i = 1;
      while(1) {
         Chk_data[1]   = iBands(Chk_symbol,Chk_Period,Chk_MAPeriod,i,0,Chk_Price,MODE_UPPER,position);
         if  ( data > Chk_data[1] ) {
            Chk_data[0] = Chk_data[1];
         }
         else {
            ret = (data- Chk_data[0])/(Chk_data[1] - Chk_data[0])+ i -1;
            break;
         }
         i++;
         if ( i > 4 ) break;
      }         
   }
   else if ( data < Chk_data[0] ) {
      i = 1;
      while(1) {
         Chk_data[1]   = iBands(Chk_symbol,Chk_Period,Chk_MAPeriod,i,0,Chk_Price,MODE_LOWER,position);
         if  ( data < Chk_data[1] ) {
            Chk_data[0] = Chk_data[1];
         }
         else {
            ret = (-1) * (data- Chk_data[0])/(Chk_data[1] - Chk_data[0])  - i +1;
            break;
         }
         i++;
         if ( i > 4 ) break;
      }         
   }
   else {
      ret = 0.00;
   }
   ret = NormalizeDouble(ret,2);

   return(ret);
}   
int  Bollin_Lank_Chk(double data)
{
   int ret;
   if ( data <= -3.0 ) {
      ret = -4;
   }
   else if (( data <= -2.0 ) && ( data > -3.0 )) {
      ret = -3;
   }         
   else if (( data <= -1.0 ) && ( data > -2.0 )) {
      ret = -2;
   }         
   else if (( data <= 0.0 ) && ( data > -1.0 )) {
      ret = -1;
   }         
   else if (( data <= 1.0 ) && ( data > 0.0 )) {
      ret = 1;
   }         
   else if (( data <= 2.0 ) && ( data > 1.0 )) {
      ret = 2;
   }         
   else if (( data <= 3.0 ) && ( data > 2.0 )) {
      ret = 3;
   }         
   else if ( data > 3.0 )  {
      ret = 4;
   }         
   return(ret);
}
