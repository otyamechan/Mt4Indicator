//+---------------------------------------------------------------------------+
//|                                       Otyame  No.101                      |
//|                                       Otyame101_span_model_signal_symbol  |
//|                                       2014.05.20                          |
//+---------------------------------------------------------------------------+
#property copyright   "2015,Otyame Trader"
#property description "Otyame101_Span_model_signal"
#property strict

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

//---- buffers
double UpArrow[];
double DownArrow[];
double UpKessaiArrow[];
double DownKessaiArrow[];

string message;
extern bool AlertON=false;					//アラート表示　
extern bool EmailON=true;       			//メール送信
extern  bool Redraw = false;    			//再描画
extern  int  Signal_Pos = 20;   			//シグナル位置

extern int Tenkan = 9;          			//転換線
extern int Kijun = 25;           		//基準線 
extern int Senkou = 52;          		//先行スパン
extern int Bar_Shift = 0;              //バーシフト 


extern  bool Span_chiko_Check = false;	//遅行スパン			
extern  bool kansi_5m = false;    		//5分足考慮
extern  bool kansi_15m = false;   		//15分足考慮
extern  bool kansi_30m = false;   		//30分足考慮
extern  bool kansi_1H = false;    		//1時間足考慮
extern  bool kansi_4H = false;    		//4時間足考慮
extern  bool kansi_1D = false;    		//日足考慮
 

extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 7;
extern string symbol1 = "USDJPY";
extern string symbol2 = "EURJPY";
extern string symbol3 = "EURUSD";
extern string symbol4 = "GBPJPY";
extern string symbol5 = "GBPUSD";
extern string symbol6 = "EURGBP";
extern string symbol7 = "AUDUSD";
extern string symbol8 = "";
extern string symbol9 = "";
extern string symbol10 = "";


bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

datetime TimeOld = D'1970.01.01 00:00:00';
datetime k5mtime[];              //5分足格納用
datetime k15mtime[];             //15分足格納用
datetime k30mtime[];             //30分足格納用
datetime k1Htime[];              //1時間足格納用
datetime k4Htime[];              //4時間足格納用
datetime k1Dtime[];              //日足格納用

int count_5m ;        	               //5分足時間格納
int count_15m ;     	                  //15分足時間格納
int count_30m ;                        //30分足時間格納
int count_1H ;                         //1時間足時間格納
int count_4H ;                         //4時間足時間格納
int count_1D ;                         //日足時間格納

int O_BandS[10];                           //前回売買
int BandS[10];                             //今回売買
int Kind[10];                              //種類

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
double Sen1_0[10];
double Sen1_1[10];
double Sen2_0[10];
double Sen2_1[10];          //クロスチェック用

      double Sen1_5m,Sen2_5m,Sen1_15m,Sen2_15m;      //上位足確認用
      double Sen1_30m,Sen2_30m,Sen1_1H,Sen2_1H;    
      double Sen1_4H,Sen2_4H,Sen1_1D,Sen2_1D;    

int c_5m,c_15m,c_30m,c_1H,c_4H,c_1D;         //時間位置

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
	IndicatorShortName("Otyame101_span_model_signal");
 

   int i;

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
      count_5m = ArrayCopySeries(k5mtime,MODE_TIME,Symbol(),PERIOD_M5);        //5分足時間格納
      count_15m = ArrayCopySeries(k15mtime,MODE_TIME,Symbol(),PERIOD_M15);     //15分足時間格納
      count_30m = ArrayCopySeries(k30mtime,MODE_TIME,Symbol(),PERIOD_M30);     //30分足時間格納
      count_1H = ArrayCopySeries(k1Htime,MODE_TIME,Symbol(),PERIOD_H1);       //1時間足時間格納
      count_4H = ArrayCopySeries(k4Htime,MODE_TIME,Symbol(),PERIOD_H4);      //4時間足時間格納
      count_1D = ArrayCopySeries(k1Dtime,MODE_TIME,Symbol(),PERIOD_D1);     //日足時間格納
    
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars--;

      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      if ( limit < 2 ) limit = 2;
      for (  cnt = 0 ; cnt < symbol_max ; cnt++) {  
         if ( symbol_true[cnt] == false ) {
            continue;
         }
         buy[cnt] = true;
         sell[cnt] = true;
         for(i= limit-1;i>=1;i--){
         switch(Period())
         {
            case PERIOD_M1 : 
               c_5m = iBarShift(NULL,PERIOD_M5,Time[i],true);
               if ( k5mtime[c_5m] > Time[i] ) {
                  c_5m++;
               }            
            case PERIOD_M5 :
               c_15m = iBarShift(NULL,PERIOD_M15,Time[i],true);
               if ( k15mtime[c_15m] > Time[i] ) {
                  c_15m++;
               }            
            case PERIOD_M15 :
               c_30m = iBarShift(NULL,PERIOD_M30,Time[i],true);
               if ( k30mtime[c_30m] > Time[i] ) {
                  c_30m++;
               }            
            case PERIOD_M30 :
               c_1H = iBarShift(NULL,PERIOD_H1,Time[i],true);
               if ( k1Htime[c_1H] > Time[i] ) {
                  c_1H++;
               }            
            case PERIOD_H1 :
               c_4H = iBarShift(NULL,PERIOD_H4,Time[i],true);
               if ( k4Htime[c_4H] > Time[i] ) {
                  c_4H++;
               }            
            case PERIOD_H4 :
               c_1D = iBarShift(NULL,PERIOD_D1,Time[i],true);
               if ( k1Dtime[c_1D] > Time[i] ) {
                  c_1D++;
               }            
         }
         if (c_1H == 0 ) c_1H++;
         if (c_15m == 0 ) c_15m++;
         if (c_30m == 0 ) c_30m++;
         if (c_1H == 0 ) c_1H++;
         if (c_4H == 0 ) c_4H++;
         if (c_1D == 0 ) c_1D++;
         switch(Period())
            {
            case PERIOD_M1: 
               if ( kansi_5m == true ) {
                  Sen1_5m = iCustom(symbol_chk[cnt],5,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,5,c_5m);
                  Sen2_5m = iCustom(symbol_chk[cnt],5,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,6,c_5m);

               }
            case PERIOD_M5 :
               if ( kansi_15m == true ) {
                  Sen1_15m = iCustom(symbol_chk[cnt],15,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,5,c_15m);
                  Sen2_15m = iCustom(symbol_chk[cnt],15,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,6,c_15m);
               }
            case PERIOD_M15 :
               if ( kansi_30m == true ) {
                  Sen1_30m = iCustom(symbol_chk[cnt],30,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,5,c_30m);
                  Sen2_30m = iCustom(symbol_chk[cnt],30,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,6,c_30m);
               }
            case PERIOD_M30 :
               if ( kansi_1H == true ) {
                  Sen1_1H = iCustom(symbol_chk[cnt],60,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,5,c_1H);
                  Sen2_1H = iCustom(symbol_chk[cnt],60,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,6,c_1H);
               }
            case PERIOD_H1 :
               if ( kansi_4H == true ) {
                  Sen1_4H = iCustom(symbol_chk[cnt],240,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,5,c_4H);
                  Sen2_4H = iCustom(symbol_chk[cnt],240,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,6,c_4H);
               }

            case PERIOD_H4 :
               if ( kansi_1D == true ) {
                  Sen1_1D = iCustom(symbol_chk[cnt],1440,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,5,c_1D);
                  Sen2_1D = iCustom(symbol_chk[cnt],1440,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,6,c_1D);
               }
            }
            Sen1_0[cnt] = iCustom(symbol_chk[cnt],0,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,5,i);
            Sen1_1[cnt] = iCustom(symbol_chk[cnt],0,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,5,i+1);
            Sen2_0[cnt] = iCustom(symbol_chk[cnt],0,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,6,i);
            Sen2_1[cnt] = iCustom(symbol_chk[cnt],0,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,Bar_Shift,6,i+1);
            buy[cnt] = false;
            sell[cnt] = false;
            if(Sen1_0[cnt] > Sen2_0[cnt] ){
               buy[cnt] = true;
               if ( Period() == PERIOD_M1 ) {
                  if ( kansi_5m == true ) {   
                     if ( Sen1_5m <= Sen2_5m )  buy[cnt] = false;
                  }
                  if ( kansi_15m == true && buy[cnt] == true ) {   
                     if ( Sen1_15m <= Sen2_15m )  buy[cnt] = false;
                  }
                  if ( kansi_30m == true && buy[cnt] == true ) {   
                     if ( Sen1_30m <= Sen2_30m )  buy[cnt] = false;
                  }
                  if ( kansi_1H == true && buy[cnt] == true ) {   
                     if ( Sen1_1H <= Sen2_1H )  buy[cnt] = false;
                  }
                  if ( kansi_4H == true && buy[cnt] == true ) {   
                     if ( Sen1_4H <= Sen2_4H )  buy[cnt] = false;
                  }
                  if ( kansi_1D == true && buy[cnt] == true ) {   
                     if ( Sen1_1D <= Sen2_1D )  buy[cnt] = false;

                  }
                  if ( Span_chiko_Check == true && buy[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) < iClose(symbol_chk[cnt],Period(),i+25) ) buy[cnt] = false;
                  }
               }
               else if ( Period() == PERIOD_M5) {
                  if ( kansi_15m == true && buy[cnt] == true ) {   
                     if ( Sen1_15m <= Sen2_15m )  buy[cnt] = false;
                  }
                  if ( kansi_30m == true && buy[cnt] == true ) {   
                     if ( Sen1_30m <= Sen2_30m )  buy[cnt] = false;
                  }
                  if ( kansi_1H == true && buy[cnt] == true ) {   
                     if ( Sen1_1H <= Sen2_1H )  buy[cnt] = false;
                  }
                  if ( kansi_4H == true && buy[cnt] == true ) {   
                     if ( Sen1_4H <= Sen2_4H )  buy[cnt] = false;
                  }
                  if ( kansi_1D == true && buy[cnt] == true ) {   
                     if ( Sen1_1D <= Sen2_1D )  buy[cnt] = false;

                  }
                  if ( Span_chiko_Check == true && buy[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) < iClose(symbol_chk[cnt],Period(),i+25) ) buy[cnt] = false;
                  }
               }
               else if ( Period() == PERIOD_M15) {
                  if ( kansi_30m == true && buy[cnt] == true ) {   
                     if ( Sen1_30m <= Sen2_30m )  buy[cnt] = false;
                  }
                  if ( kansi_1H == true && buy[cnt] == true ) {   
                     if ( Sen1_1H <= Sen2_1H )  buy[cnt] = false;
                  }
                  if ( kansi_4H == true && buy[cnt] == true ) {   
                     if ( Sen1_4H <= Sen2_4H )  buy[cnt] = false;
                  }
                  if ( kansi_1D == true && buy[cnt] == true ) {   
                     if ( Sen1_1D <= Sen2_1D )  buy[cnt] = false;

                  }
                  if ( Span_chiko_Check == true && buy[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) < iClose(symbol_chk[cnt],Period(),i+25) ) buy[cnt] = false;
                  }
               }

               else if ( Period() == PERIOD_M30) {
                  if ( kansi_1H == true && buy[cnt] == true ) {   
                     if ( Sen1_1H <= Sen2_1H )  buy[cnt] = false;
                  }
                  if ( kansi_4H == true && buy[cnt] == true ) {   
                     if ( Sen1_4H <= Sen2_4H )  buy[cnt] = false;
                  }
                  if ( kansi_1D == true && buy[cnt] == true ) {   
                     if ( Sen1_1D <= Sen2_1D )  buy[cnt] = false;

                  }
                  if ( Span_chiko_Check == true && buy[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) < iClose(symbol_chk[cnt],Period(),i+25) ) buy[cnt] = false;               
                  }
               }
               else if ( Period() == PERIOD_H1) {
                  if ( kansi_4H == true && buy[cnt] == true ) {   
                     if ( Sen1_4H <= Sen2_4H )  buy[cnt] = false;
                  }
                  if ( kansi_1D == true && buy[cnt] == true ) {   
                     if ( Sen1_1D <= Sen2_1D )  buy[cnt] = false;

                  }
                  if ( Span_chiko_Check == true && buy[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) < iClose(symbol_chk[cnt],Period(),i+25) ) buy[cnt] = false;
                  }
               }
               else if ( Period() == PERIOD_H4) {
                  if ( kansi_1D == true && buy[cnt] == true ) {   
                     if ( Sen1_1D <= Sen2_1D )  buy[cnt] = false;

                  }  
                  if ( Span_chiko_Check == true && buy[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) < iClose(symbol_chk[cnt],Period(),i+25) ) buy[cnt] = false;
                  }
               }

            }
            else if(Sen1_0[cnt] < Sen2_0[cnt] ){
               sell[cnt] = true;
               if ( Period() == PERIOD_M1 ) {
                  if ( kansi_5m == true ) {   
                     if ( Sen1_5m >= Sen2_5m )  sell[cnt] = false;
                  }
                  if ( kansi_15m == true && sell[cnt] == true ) {   
                     if ( Sen1_15m >= Sen2_15m )  sell[cnt] = false;
                  }
                  if ( kansi_30m == true && sell[cnt] == true ) {   
                     if ( Sen1_30m >= Sen2_30m )  sell[cnt] = false;
                  }
                  if ( kansi_1H == true && sell[cnt] == true ) {   
                     if ( Sen1_1H >= Sen2_1H )  sell[cnt] = false;
                  }
                  if ( kansi_4H == true && sell[cnt] == true ) {   
                     if ( Sen1_4H >= Sen2_4H )  sell[cnt] = false;
                  }
                  if ( kansi_1D == true && sell[cnt] == true ) {   
                     if ( Sen1_1D >= Sen2_1D )  sell[cnt] = false;

                  }
                  if ( Span_chiko_Check == true && sell[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) > iClose(symbol_chk[cnt],Period(),i+25) ) sell[cnt] = false;
                  }
               }
               else if ( Period() == PERIOD_M5) {
                  if ( kansi_15m == true && sell[cnt] == true ) {   
                     if ( Sen1_15m >= Sen2_15m )  sell[cnt] = false;
                  }
                  if ( kansi_30m == true && sell[cnt] == true ) {   
                     if ( Sen1_30m >= Sen2_30m )  sell[cnt] = false;
                  }
                  if ( kansi_1H == true && sell[cnt] == true ) {   
                     if ( Sen1_1H >= Sen2_1H )  sell[cnt] = false;
                  }
                  if ( kansi_4H == true && sell[cnt] == true ) {   
                     if ( Sen1_4H >= Sen2_4H )  sell[cnt] = false;
                  }
                  if ( kansi_1D == true && sell[cnt] == true ) {   
                     if ( Sen1_1D >= Sen2_1D )  sell[cnt] = false;

                  }
                  if ( Span_chiko_Check == true && sell[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) > iClose(symbol_chk[cnt],Period(),i+25) ) sell[cnt] = false;
                  }
               }                                            
               else if ( Period() == PERIOD_M15) {
                  if ( kansi_30m == true && sell[cnt] == true ) {   
                     if ( Sen1_30m >= Sen2_30m )  sell[cnt] = false;
                  }
                  if ( kansi_1H == true && sell[cnt] == true ) {   
                     if ( Sen1_1H >= Sen2_1H )  sell[cnt] = false;
                  }
                  if ( kansi_4H == true && sell[cnt] == true ) {   
                     if ( Sen1_4H >= Sen2_4H )  sell[cnt] = false;
                  }
                  if ( kansi_1D == true && sell[cnt] == true ) {   
                     if ( Sen1_1D >= Sen2_1D )  sell[cnt] = false;

                  }
                  if ( Span_chiko_Check == true && sell[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) > iClose(symbol_chk[cnt],Period(),i+25) ) sell[cnt] = false;
                  }
               }
               else if ( Period() == PERIOD_M30) {
                  if ( kansi_1H == true && sell[cnt] == true ) {   
                     if ( Sen1_1H >= Sen2_1H )  sell[cnt] = false;
                  }
                  if ( kansi_4H == true && sell[cnt] == true ) {   
                     if ( Sen1_4H >= Sen2_4H )  sell[cnt] = false;
                  }
                  if ( kansi_1D == true && sell[cnt] == true ) {   
                     if ( Sen1_1D >= Sen2_1D )  sell[cnt] = false;
   
                  }
                  if ( Span_chiko_Check == true && sell[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) > iClose(symbol_chk[cnt],Period(),i+25) ) sell[cnt] = false;
                  }
               }
               else if ( Period() == PERIOD_H1) {
                  if ( kansi_4H == true && sell[cnt] == true ) {   
                     if ( Sen1_4H >= Sen2_4H )  sell[cnt] = false;
                  }
                  if ( kansi_1D == true && sell[cnt] == true ) {   
                     if ( Sen1_1D >= Sen2_1D )  sell[cnt] = false;

                  }
                  if ( Span_chiko_Check == true && sell[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) > iClose(symbol_chk[cnt],Period(),i+25) ) sell[cnt] = false;
                  }
               }
               else if ( Period() == PERIOD_H4) {
                  if ( kansi_1D == true && sell[cnt] == true ) {   
                     if ( Sen1_1D >= Sen2_1D )  sell[cnt] = false;

                  }  
                  if ( Span_chiko_Check == true && sell[cnt] == true) {
                     if ( iClose(symbol_chk[cnt],Period(),i) > iClose(symbol_chk[cnt],Period(),i+25) ) sell[cnt] = false;
                  }
               }        
            }
         	switch( O_BandS[cnt] ) {
            case NO_POSITION:
               if ( buy[cnt] == true ) {
						if ( Symbol() == symbol_chk[cnt] ) {
                  	UpArrow[i]=Sen1_1[cnt] - Point * Signal_Pos;
                  }
						BandS[cnt] = BUY_POSITION;
                  Kind[cnt] = BUY_POSITION;
               }
               else if ( sell[cnt] == true ) {
						if ( Symbol() == symbol_chk[cnt] ) {
                     DownArrow[i]=Sen1_1[cnt] + Point * Signal_Pos;
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
               if ( buy[cnt] == true ) {
                  BandS[cnt] = BUY_POSITION;
                  Kind[cnt] = 0;
               }
               else if ( sell[cnt] == true ) {
						if ( Symbol() == symbol_chk[cnt] ) {
                     DownArrow[i]=Sen1_1[cnt] + Point * Signal_Pos;
                  }
                  BandS[cnt] = SELL_POSITION;
                  Kind[cnt] = SELL_POSITION;
               }
               else {
						if ( Symbol() == symbol_chk[cnt] ) {
                     UpKessaiArrow[i] = Sen1_1[cnt] + Point * Signal_Pos;
                  }
                  BandS[cnt] = NO_POSITION;
                  Kind[cnt] = BUY_KESSAI;
               }
               break;         
            case SELL_POSITION:
               if ( buy[cnt] == true ) {
						if ( Symbol() == symbol_chk[cnt] ) {
                     UpArrow[i]=Sen1_1[cnt] - Point * Signal_Pos;
                  }
                  BandS[cnt] = BUY_POSITION;
                  Kind[cnt] = BUY_POSITION;
               }
               else if ( sell[cnt] == true ) {
                  BandS[cnt] = SELL_POSITION;
                  Kind[cnt] = 0;
               }
               else {
						if ( Symbol() == symbol_chk[cnt] ) {
                     DownKessaiArrow[i] = Sen1_1[cnt] - Point * Signal_Pos;
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
            double chiko;
            chiko =  iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,4,25);           
            switch(Kind[cnt])   {
            case BUY_POSITION:
               message= "買い Chance!!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+DoubleToStr(Sen1_1[cnt])+","+DoubleToStr(Sen1_0[cnt]);
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+DoubleToStr(Sen2_1[cnt])+","+DoubleToStr(Sen2_0[cnt]);
               message = message + " \r\n 遅行スパン = "+DoubleToStr(chiko);
               message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],0,25),pos[cnt]-1);
               break;
            case SELL_POSITION:
               message= "売り Chance!!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+DoubleToStr(Sen1_1[cnt])+","+DoubleToStr(Sen1_0[cnt]);
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+DoubleToStr(Sen2_1[cnt])+","+DoubleToStr(Sen2_0[cnt]);
               message = message + " \r\n 遅行スパン = "+DoubleToStr(chiko);
               message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],0,25),pos[cnt]-1);
               break;
            case BUY_KESSAI:
               message= "買い決済"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+DoubleToStr(Sen1_1[cnt])+","+DoubleToStr(Sen1_0[cnt]);
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+DoubleToStr(Sen2_1[cnt])+","+DoubleToStr(Sen2_0[cnt]);
               message = message + " \r\n 遅行スパン = "+DoubleToStr(chiko);
               message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],0,25),pos[cnt]-1);
               break;
            case SELL_KESSAI:
               message= "売り決済"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+DoubleToStr(Sen1_1[cnt])+","+DoubleToStr(Sen1_0[cnt]);
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+DoubleToStr(Sen2_1[cnt])+","+DoubleToStr(Sen2_0[cnt]);
               message = message + " \r\n 遅行スパン = "+DoubleToStr(chiko);
               message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],0,25),pos[cnt]-1);
               break;
            }
            if ( Kind[cnt] != 0 ) SendMail("スパンモデル " +"["+symbol_chk[cnt]+"]["+IntegerToString(Period())+"]",message);
         }
      }
      Emailflag = false;      
      if (Alertflag== true) {
         for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
 
            if (symbol_true[cnt] == false ) {
               continue;
            }

            switch(Kind[cnt])   {
            case BUY_POSITION:
                  Alert("Spanmodel BUY Signal ",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
                  break;
            case SELL_POSITION:
                  Alert("Spanmodel SELL Signal ",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
                  break;
            case BUY_KESSAI:
               Alert("Spanmodel BUY Kessai Signal ",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
               break;
            case SELL_KESSAI:
               Alert("Spanmodel SELl Kessai Signal ",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[cnt],0,0),pos[cnt]-1));
               break;
            }
         }
      }   
      Alertflag = false;      
   }
   Timeflg = false;
   return(0);
}
