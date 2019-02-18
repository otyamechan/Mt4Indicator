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

#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Black

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4

#define distance 30

//---- buffers
double UpArrow[];
double DownArrow[];
double KessaiArrow[];

string message;
extern bool AlertON=false;        //アラート表示　
extern bool EmailON=true;        //メール送信

extern int Tenkan = 9;           //転換線
extern int Kijun = 26;           //基準線 
extern int Senkou = 52;          //先行スパン 
extern  bool kansi_5m = true;    //5分足考慮
extern  bool kansi_15m = false;   //15分足考慮
extern  bool kansi_30m = false;   //30分足考慮
extern  bool kansi_1H = true;    //1時間足考慮
extern  bool kansi_4H = false;    //4時間足考慮
extern  bool kansi_1D = false;    //日足考慮
 

extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 10;
extern string symbol1 = "USDJPY";
extern string symbol2 = "EURJPY";
extern string symbol3 = "EURUSD";
extern string symbol4 = "GBPJPY";
extern string symbol5 = "AUDJPY";
extern string symbol6 = "AUDUSD";
extern string symbol7 = "GBPUSD";
extern string symbol8 = "NZDJPY";
extern string symbol9 = "EURGBP";
extern string symbol10 = "CADJPY";



bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

datetime TimeOld = D'1970.01.01 00:00:00';
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


int c_5m,c_15m,c_30m,c_1H,c_4H,c_1D;         //時間位置

int init()
{

//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,241);
   SetIndexBuffer(0,UpArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,242);
   SetIndexBuffer(1,DownArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,253);
   SetIndexBuffer(2,KessaiArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
 

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
      count_5m = ArrayCopySeries(k5mtime,MODE_TIME,Symbol(),5);        //5分足時間格納
      count_15m = ArrayCopySeries(k15mtime,MODE_TIME,Symbol(),15);     //15分足時間格納
      count_30m = ArrayCopySeries(k30mtime,MODE_TIME,Symbol(),30);     //30分足時間格納
      count_1H = ArrayCopySeries(k1Htime,MODE_TIME,Symbol(),60);       //1時間足時間格納
      count_4H = ArrayCopySeries(k4Htime,MODE_TIME,Symbol(),240);      //4時間足時間格納
      count_1D = ArrayCopySeries(k1Dtime,MODE_TIME,Symbol(),1440);     //日足時間格納
      double Sen1_5m,Sen2_5m,Sen1_15m,Sen2_15m;      //上位足確認用
      double Sen1_30m,Sen2_30m,Sen1_1H,Sen2_1H;    
      double Sen1_4H,Sen2_4H,Sen1_1D,Sen2_1D;    
    
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
      if (counted_bars > 0) counted_bars--;

      int limit = Bars - counted_bars;
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
                  for (c_5m = 0 ;c_5m < count_5m ; c_5m++ ) {
                     if ( Time[i] >= k5mtime[c_5m])   {
                        break;
                     }     
                  }     
               case PERIOD_M5 :
                  for (c_15m = 0 ;c_15m < count_15m ; c_15m++ ) {
                     if ( Time[i] >= k15mtime[c_15m])   {
                        break;
                     }     
                  }     
            case PERIOD_M15 :
                  for (c_30m = 0 ;c_30m < count_30m ; c_30m++ ) {
                     if ( Time[i] >= k30mtime[c_30m])   {
                        break;
                     }     
                  }     
            case PERIOD_M30 :
                  for (c_1H = 0 ;c_1H < count_1H ; c_1H++ ) {
                     if ( Time[i] >= k1Htime[c_1H])   {
                        break;
                     }     
                  }     
            case PERIOD_H1 :
                  for (c_4H = 0 ;c_4H < count_4H ; c_4H++ ) {
                     if ( Time[i] >= k4Htime[c_4H])   {
                        break;
                     }     
                  }     
            case PERIOD_H4 :
                  for (c_1D = 0 ;c_1D < count_1D ; c_1D++ ) {
                     if ( Time[i] >= k1Dtime[c_1D])   {
                        break;
                     }     
                  }     
            }
            switch(Period())
         
            {
            case PERIOD_M1: 
               if ( kansi_5m == true ) {
                  Sen1_5m = iCustom(symbol_chk[cnt],5,"span_model",Kijun,Tenkan,Senkou,5,c_5m);
                  Sen2_5m = iCustom(symbol_chk[cnt],5,"span_model",Kijun,Tenkan,Senkou,6,c_5m);

               }
            case PERIOD_M5 :
               if ( kansi_15m == true ) {
                  Sen1_15m = iCustom(symbol_chk[cnt],15,"span_model",Kijun,Tenkan,Senkou,5,c_15m);
                  Sen2_15m = iCustom(symbol_chk[cnt],15,"span_model",Kijun,Tenkan,Senkou,6,c_15m);
               }
            case PERIOD_M15 :
               if ( kansi_30m == true ) {
                  Sen1_30m = iCustom(symbol_chk[cnt],30,"span_model",Kijun,Tenkan,Senkou,5,c_30m);
                  Sen2_30m = iCustom(symbol_chk[cnt],30,"span_model",Kijun,Tenkan,Senkou,6,c_30m);
               }
            case PERIOD_M30 :
               if ( kansi_1H == true ) {
                  Sen1_1H = iCustom(symbol_chk[cnt],60,"span_model",Kijun,Tenkan,Senkou,5,c_1H);
                  Sen2_1H = iCustom(symbol_chk[cnt],60,"span_model",Kijun,Tenkan,Senkou,6,c_1H);
 //              Print("時間",TimeToStr(k1Htime[c_1H],TIME_DATE)+TimeToStr(k1Htime[c_1H],TIME_MINUTES));
//               Print("Sen1_1H=",Sen1_1H);
//               Print("Sen2_1H=",Sen2_1H);
               }
            case PERIOD_H1 :
               if ( kansi_4H == true ) {
                  Sen1_4H = iCustom(symbol_chk[cnt],240,"span_model",Kijun,Tenkan,Senkou,5,c_4H);
                  Sen2_4H = iCustom(symbol_chk[cnt],240,"span_model",Kijun,Tenkan,Senkou,6,c_4H);
               }

            case PERIOD_H4 :
               if ( kansi_1D == true ) {
                  Sen1_1D = iCustom(symbol_chk[cnt],1440,"span_model",Kijun,Tenkan,Senkou,5,c_1D);
                  Sen2_1D = iCustom(symbol_chk[cnt],1440,"span_model",Kijun,Tenkan,Senkou,6,c_1D);
               }
            }
            Sen1_0[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,5,i);
            Sen1_1[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,5,i+1);
            Sen2_0[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,6,i);
            Sen2_1[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,6,i+1);
            buy[cnt] = false;
            sell[cnt] = false;
            if(Sen1_0[cnt] > Sen2_0[cnt] && Sen1_1[cnt] <= Sen2_1[cnt]){
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
               }
               else if ( Period() == PERIOD_H1) {
                  if ( kansi_4H == true && buy[cnt] == true ) {   
                     if ( Sen1_4H <= Sen2_4H )  buy[cnt] = false;
                  }
                  if ( kansi_1D == true && buy[cnt] == true ) {   
                     if ( Sen1_1D <= Sen2_1D )  buy[cnt] = false;

                  }
               }
               else if ( Period() == PERIOD_H4) {
                  if ( kansi_1D == true && buy[cnt] == true ) {   
                     if ( Sen1_1D <= Sen2_1D )  buy[cnt] = false;

                  }  
               }

            }
            else if(Sen1_0[cnt] < Sen2_0[cnt] && Sen1_1[cnt] >= Sen2_1[cnt]){
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
               }
               else if ( Period() == PERIOD_H1) {
                  if ( kansi_4H == true && sell[cnt] == true ) {   
                     if ( Sen1_4H >= Sen2_4H )  sell[cnt] = false;
                  }
                  if ( kansi_1D == true && sell[cnt] == true ) {   
                     if ( Sen1_1D >= Sen2_1D )  sell[cnt] = false;

                  }
               }
               else if ( Period() == PERIOD_H4) {
                  if ( kansi_1D == true && sell[cnt] == true ) {   
                     if ( Sen1_1D >= Sen2_1D )  sell[cnt] = false;

                  }  
               }        
            }
            if ( buy[cnt] == true ) {
               if ( symbol_chk[cnt] == Symbol()) {
                  UpArrow[i]=Sen1_1[cnt] - Point * distance;;
               }
            }
            if ( sell[cnt] == true ) {
               if ( symbol_chk[cnt] == Symbol()) {
                  DownArrow[i]=Sen1_1[cnt] + Point * distance;;
               }
            } 

         }
      }      datetime a = D'1970.01.01 00:00:00'; 
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
            if    ( buy[cnt] == true ) {
               message= "Buy Chance!!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),25),pos[cnt]-1);

            }
            if ( sell[cnt] == true ) {
               message= "Sell Chance!!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),25),pos[cnt]-1);
            }
            if ( buy[cnt] == true || sell[cnt] == true ) SendMail("Span model symbol signal",message);
         }
      }
      Emailflag = false;      
      if (Alertflag== true) {
         for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
 
            if (symbol_true[cnt] == false ) {
               continue;
            }

            if ( buy[cnt] == true ) {
               Alert("Spanmodel symbol BUY Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
            }
            if ( sell[cnt] == true ) {
               Alert("Spanmodel symbol SELL Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
            }
            Alertflag = false;

         }
      }   
      Alertflag = false;      
   }
   Timeflg = false;
   return(0);
}
