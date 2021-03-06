//+---------------------------------------------------------------------------+
//|                                       Otyame  No.118                      |
//|                                       Otyame118_A_Chart                   |
//|                                       2016.08.27                          |
//+---------------------------------------------------------------------------+
#property copyright   "2016,Otyame Trader"
#property description "Otyame118_A_Chart"
#property strict

#property indicator_buffers 2

#property indicator_chart_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta

#property indicator_width1 4
#property indicator_width2 4

#define H1_NO_TRADE  0
#define H1_NO_CHECK  1 
#define H1_BUY_TRADE  2
#define H1_SELL_TRADE  3

#define M5_NO_TRADE  10
#define M5_NO_CHECK  11 
#define M5_BUY_TRADE  12
#define M5_SELL_TRADE  13
#define M5_BUY_KEIZOKU  14
#define M5_SELL_KEIZOKU  15



//---- buffers
double UpArrow[];
double DownArrow[];

string message;
extern bool AlertON=false;					//アラート表示　
extern bool EmailON=true;       			//メール送信
extern  bool Redraw = false;    			//再描画
extern  int  Signal_Pos = 20;   			//シグナル位置

extern  bool kansi_1H = true;    		//1時間足考慮
 

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
datetime k1Htime[];              //1時間足格納用

int count_5m ;        	               //5分足時間格納
int count_1H ;                         //1時間足時間格納

int O_BandS[10];                           //前回売買
int BandS[10];                             //今回売買
int Kind[10];                              //種類

bool symbol_true[10];
int symbol_max;
string symbol_chk[10];
int cnt;
int rtn;
int pos[10];
int M5_Check,H1_Check;
bool Timeflg = false;
double pos_chk;

bool buy[10];
bool sell[10];
double Blue_5m,Red_5m;
double Blue_Belt_5m,Red_Belt_5m;      //上位足確認用
double Blue_Belt_5m_o,Red_Belt_5m_o;      //上位足確認用
double Blue_1H,Red_1H;    

int c_5m,c_1H;         //時間位置

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
	IndicatorShortName("Otyame118_A_Chart");
 

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
      count_1H = ArrayCopySeries(k1Htime,MODE_TIME,Symbol(),PERIOD_H1);       //1時間足時間格納
    
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
            if ( Period() == PERIOD_M5 ) {
               c_1H = iBarShift(NULL,PERIOD_H1,Time[i],true);
               if ( k1Htime[c_1H] > Time[i] ) {
                  c_1H++;
               }            
               if (c_1H == 0 ) c_1H++;
            }
            else continue;
            if ( kansi_1H == true ) {
               Blue_1H = iCustom(symbol_chk[cnt],60,"AT2016",5,c_1H);
               Red_1H = iCustom(symbol_chk[cnt],60,"AT2016",6,c_1H);
               if ( Blue_1H >= Red_1H ) {
                  if ( iClose(symbol_chk[cnt],60,c_1H) > Blue_1H ) {
                      H1_Check = H1_BUY_TRADE;
                  }
                  else     H1_Check = H1_NO_TRADE;
               }
               if ( Red_1H >= Blue_1H ) {
                  if ( iClose(symbol_chk[cnt],60,c_1H) < Red_1H ) {
                      H1_Check = H1_SELL_TRADE;
                  }
                  else     H1_Check = H1_NO_TRADE;
               }
            }
            else H1_Check = H1_NO_CHECK;
            Blue_5m = iCustom(symbol_chk[cnt],0,"AT2016",5,i);
            Red_5m = iCustom(symbol_chk[cnt],0,"AT2016",6,i);
            Blue_Belt_5m = iCustom(symbol_chk[cnt],0,"BELT",5,i);
            Red_Belt_5m = iCustom(symbol_chk[cnt],0,"BELT",6,i);
            Blue_Belt_5m_o = iCustom(symbol_chk[cnt],0,"BELT",5,i+1);
            Red_Belt_5m_o = iCustom(symbol_chk[cnt],0,"BELT",6,i+1);
            if (( Blue_5m >= Red_5m ) && ( iClose(symbol_chk[cnt],0,i+1) >= Blue_5m )) {
               if (( Blue_Belt_5m_o == EMPTY_VALUE ) && ( Red_Belt_5m == EMPTY_VALUE )) {
                  M5_Check = M5_BUY_TRADE;
               }
               else if (( Red_Belt_5m_o == EMPTY_VALUE ) && ( Red_Belt_5m == EMPTY_VALUE )) {
                  M5_Check = M5_BUY_KEIZOKU;
               }
               else {
                   M5_Check = M5_NO_TRADE;
               }
            }
            else if ((Blue_5m <= Red_5m ) && ( iClose(symbol_chk[cnt],0,i+1) <= Blue_5m )) {
               if (( Red_Belt_5m_o == EMPTY_VALUE ) && ( Blue_Belt_5m == EMPTY_VALUE )) {
                  M5_Check = M5_SELL_TRADE;
               }
               else if (( Red_Belt_5m_o == EMPTY_VALUE ) && ( Red_Belt_5m == EMPTY_VALUE )) {
                  M5_Check = M5_SELL_KEIZOKU;
               }
               else {
                   M5_Check = M5_NO_TRADE;
               }
            }
            else {
               M5_Check = M5_NO_TRADE;
            }
            switch( H1_Check ) {
            case H1_NO_CHECK:
            
            
            
            
            
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
