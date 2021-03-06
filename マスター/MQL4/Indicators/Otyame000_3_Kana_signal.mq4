//+------------------------------------------------------------------+
//|                                       Otyame  No.000             |
//|                                       加奈式シンプルFXトレード　 |
//|                                       2014.05.20                 |
//+------------------------------------------------------------------+
/*
  加奈式シンプルトレードのシグナル配信版 
   パラメータ
      Kikan = 20;           //ボリンージャーバンド中心線
      AlertON=true;        //アラート表示　
      EmailON=true;        //メール送信

   色
      ボリンジャーバンド　中心線
      ボリンジャーバンド　２σ下線
      ボリンジャーバンド　２σ上線
      買い矢印
      売り矢印
      決済矢印（未使用）


*/


#property copyright "Otyame"


#property indicator_chart_window

#property indicator_buffers 3


#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Black

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 1

#define distance 0

//---- buffers
double UpArrow[];
double DownArrow[];
double KessaiArrow[];



double Uwahige;
double Sitahige;
double Jittai;
bool insen;
bool yousen;
bool buy[10];
bool sell[10];
bool O_buy[10];
bool O_sell[10];


string message;

extern bool AlertON=false;        //アラート表示　
extern bool EmailON=true;        //メール送信
extern int Kikan = 20;           //ボリンージャーバンド中心線
extern string _Stochastic = "Stochsstic set";
extern int KPeriod = 20;
extern int DPeriod = 5;
extern int SlowDPeriod = 10;
extern int MAMethod = 3;
extern string _Price = "0:Low/High 1:Close/Close";
extern int Price = 1;
extern double Uper = 80.0;
extern double Lower = 20.0;
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

bool symbol_true[10];
int symbol_max;
string symbol_chk[10];
int pos[10];
int cnt;
double pos_chk;
double sigma2_Lower[10];
double sigma2_Uper[10];
double ST[10];

bool Timeflg = false;
int init()
{
   int rtn;
   int i;
   

//---- indicators
   IndicatorBuffers(3);
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
         if ( rtn != ERR_NO_ERROR ) {
            Print(symbol_chk[cnt]+"はチェックできません");
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
   
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( limit < 2 ) limit = 2;

      for ( cnt = 0; cnt < symbol_max ; cnt++ ) {
         if ( symbol_true[cnt] == false ) {
            continue ;
         }

         for(i= limit-1;i>=1;i--){
            buy[cnt] = false;
            sell[cnt] = false;
            sigma2_Lower[cnt]   = iBands(symbol_chk[cnt],0,Kikan,2,0,PRICE_CLOSE,MODE_LOWER,i);
            sigma2_Uper[cnt]   = iBands(symbol_chk[cnt],0,Kikan,2,0,PRICE_CLOSE,MODE_UPPER,i);
            ST[cnt] = iStochastic(symbol_chk[cnt],0,KPeriod,DPeriod,SlowDPeriod,MAMethod,Price,MODE_MAIN,i); 

            if(iHigh(symbol_chk[cnt],Period(),i) > sigma2_Uper[cnt]) {
               if ( iClose(symbol_chk[cnt],Period(),i) - iOpen(symbol_chk[cnt],Period(),i)>= 0) {
                  yousen = true;
               }
               else {
                  yousen = false;
               }
               if ( yousen == true ) {
                  Uwahige = iHigh(symbol_chk[cnt],Period(),i) - iClose(symbol_chk[cnt],Period(),i);
                  Sitahige = iOpen(symbol_chk[cnt],Period(),i) - iLow(symbol_chk[cnt],Period(),i);
                  Jittai = iClose(symbol_chk[cnt],Period(),i) - iOpen(symbol_chk[cnt],Period(),i);
                  if (Uwahige > Sitahige &&  Jittai< Uwahige ) {
                     sell[cnt] = true;
                  }
               }
               else    {
                  Uwahige = iHigh(symbol_chk[cnt],Period(),i) - iOpen(symbol_chk[cnt],Period(),i);
                  Sitahige = iClose(symbol_chk[cnt],Period(),i) - iLow(symbol_chk[cnt],Period(),i);
                  Jittai = iOpen(symbol_chk[cnt],Period(),i) - iClose(symbol_chk[cnt],Period(),i);
                  if (Uwahige > Sitahige && Jittai < Uwahige ) {
                        sell[cnt] = true;
                     }
                  }
               }
               else if(iLow(symbol_chk[cnt],Period(),i) < sigma2_Lower[cnt]) {
                  sell[cnt] = false;
                  if ( iClose(symbol_chk[cnt],Period(),i) -  iOpen(symbol_chk[cnt],Period(),i) >= 0) {
                     yousen = true;
                  }
                  else {
                     yousen = false;
                  }
                  if ( yousen == true ) {
                     Uwahige = iHigh(symbol_chk[cnt],Period(),i) - iClose(symbol_chk[cnt],Period(),i);
                     Sitahige = iOpen(symbol_chk[cnt],Period(),i) - iLow(symbol_chk[cnt],Period(),i);
                     Jittai = iClose(symbol_chk[cnt],Period(),i) - iOpen(symbol_chk[cnt],Period(),i);
                     if (Uwahige < Sitahige && Jittai < Sitahige ) {
                        buy[cnt] = true;
                     }
                  }
                  else  {
                     Uwahige = iHigh(symbol_chk[cnt],Period(),i) - iOpen(symbol_chk[cnt],Period(),i);
                     Sitahige = iClose(symbol_chk[cnt],Period(),i) - iLow(symbol_chk[cnt],Period(),i);
                     Jittai = iOpen(symbol_chk[cnt],Period(),i) - iClose(symbol_chk[cnt],Period(),i);
                     if (Uwahige < Sitahige && Jittai < Sitahige ) {
                        buy[cnt] = true;
                     }
                  }
               }
               if ( O_sell[cnt] == true ) {
                  if ( ST[cnt] < Uper )   {
                     sell[cnt] = true;
                  if ( Symbol() == symbol_chk[cnt] ) {
                        DownArrow[i] = High[i] + Point * distance;
                     }
                     O_sell[cnt] = false;
                  }
               }
               else {
                  if ( sell[cnt] == true ) {
                     if (ST[cnt] < Uper ) {
                        sell[cnt] = false;
                     }
                     else {
                        O_sell[cnt] = true;
                        sell[cnt] = false;
                     }
                  }     
               }          
               if ( O_buy[cnt] == true ) {
                  if ( ST[cnt] > Lower )   {
                     buy[cnt] = true;
                     if ( Symbol() == symbol_chk[cnt] ) {
                        UpArrow[i] = Low[i] - Point * distance;
                     }
                     O_buy[cnt] = false;
                  }
               }
               else {
                  if ( buy[cnt] == true ) {
                     if (ST[cnt] > Lower ) {
                        buy[cnt] = false;
                     }
                     else {
                        O_buy[cnt] = true;
                        buy[cnt] = false;
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
         for ( cnt = 0; cnt < symbol_max ; cnt++ ) {
            if ( symbol_true[cnt] == false ) {
               continue ;
            }
            if (Emailflag== true) {
               if ( buy[cnt] == true ) {
                  message= "Buy Chance!!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
                  message = message + "\r\n " + "高値 = "+DoubleToStr(iHigh(symbol_chk[cnt],Period(),1),pos[cnt]-1);
                  message = message + "\r\n " + "安値 = "+DoubleToStr(iLow(symbol_chk[cnt],Period(),1),pos[cnt]-1);
                  message = message + "\r\n " + "始値 = "+DoubleToStr(iOpen(symbol_chk[cnt],Period(),1),pos[cnt]-1);
                  message = message + "\r\n " + "終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),1),pos[cnt]-1);
                  message = message + "\r\n "+"-2σライン = "+DoubleToStr(sigma2_Lower[cnt],pos[cnt]);
               }
               if ( sell[cnt] == true ) {
                  message= "Sell Chance!!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
                  message = message + "\r\n " + "高値 = "+DoubleToStr(iHigh(symbol_chk[cnt],Period(),1),pos[cnt]-1);
                  message = message + "\r\n " + "安値 = "+DoubleToStr(iLow(symbol_chk[cnt],Period(),1),pos[cnt]-1);
                  message = message + "\r\n " + "始値 = "+DoubleToStr(iOpen(symbol_chk[cnt],Period(),1),pos[cnt]-1);
                  message = message + "\r\n " + "終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),1),pos[cnt]-1);
                  message = message + "\r\n "+"+2σライン = "+DoubleToStr(sigma2_Uper[cnt],pos[cnt]);
   
               }
               if ( buy[cnt] == true || sell[cnt] == true ) SendMail("KANA symbol Signal",message);
            }
            if (Alertflag== true) {
               if ( buy[cnt] == true ) {
                  Alert("KANA symbol BUY Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
               }
               if ( sell[cnt] == true ) {
                  Alert("KANA symbol SELL Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
               }
            }
         }
         Emailflag = false;
         Alertflag = false;
      }
  Timeflg = false;
  return(0);
}
