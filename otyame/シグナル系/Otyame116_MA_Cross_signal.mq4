//+------------------------------------------------------------------+
//|                              Otyame116_MA_Cross_signal.mq4       |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright   "2015,Otyame Trader"
#property description "Otyame116_MA_Cross_signal.mq4"
#property strict

#property indicator_buffers 2

#property indicator_chart_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta

#property indicator_width1 4
#property indicator_width2 4
#define GOLLDEN_CROSS  1
#define DEAD_CROSS   2 


//---- buffers
double UpArrow[];
double DownArrow[];

string message;

extern bool AlertON=false;           //アラート表示　
extern bool EmailON=true;           //メール送信
extern bool Redraw = false;
extern int Sign_pos = 60;
extern string _MA1 = "MA1 Setting";
extern   int MAPeriod1 =  10;
extern   int MAMethod1 =  0;
extern string _MA2 = "MA2 Setting";
extern   int MAPeriod2 =  14;
extern   int MAMethod2 =  0;
extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 0;
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

datetime TimeOld = D'1970.01.01 00:00:00';

int kind[10];

double pos_chk;

int pos[10];
bool symbol_true[10];
int symbol_max;
string symbol_chk[10];
int symbol_cnt;
bool Timeflg = false;
double MA1[10];
double MA2[10];
double MA1_old[10];
double MA2_old[10];

int init()
{

//---- indicators

   int i;

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,UpArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,DownArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
	IndicatorShortName("Otyame116__MA_Cross_signal");
   
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
      for ( symbol_cnt = 0 ; symbol_cnt < symbol_max ; symbol_cnt++) {
         pos[symbol_cnt] = 0;
         symbol_true[symbol_cnt] = true;
         int rtn = 0;
         pos_chk = MarketInfo(symbol_chk[symbol_cnt],MODE_POINT);
         rtn = GetLastError();         
         if ( rtn == ERR_UNKNOWN_SYMBOL ) {
            Print(symbol_chk[symbol_cnt]+"は存在しません。 ERR NO = ",rtn);
            symbol_true[symbol_cnt] = false;
         }
         else {
            for ( i = 0 ; pos_chk < 1 ;i++) {
               pos[symbol_cnt]++;
               pos_chk = pos_chk * 10;
            } 
            pos[symbol_cnt]++;
         }
      } 
   }      
 
//   TimeOld = Time[0];
   return(0);
}
int deinit()
{
   return(0);
}
int start()
{
   int i;
   int cnt;
   int count = 0;
   
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
            MA1[cnt] = iMA(symbol_chk[cnt],0,MAPeriod1,0,MAMethod1,PRICE_CLOSE,i);
            MA2[cnt] = iMA(symbol_chk[cnt],0,MAPeriod2,0,MAMethod2,PRICE_CLOSE,i);
            MA1_old[cnt] = iMA(symbol_chk[cnt],0,MAPeriod1,0,MAMethod1,PRICE_CLOSE,i+1);
            MA2_old[cnt] = iMA(symbol_chk[cnt],0,MAPeriod2,0,MAMethod2,PRICE_CLOSE,i+1);

            UpArrow[i] = EMPTY_VALUE;
            DownArrow[i] = EMPTY_VALUE;
            if (( MA1_old[cnt] <= MA2_old[cnt] ) && ( MA1[cnt] > MA2[cnt] ))   {
               kind[cnt] = GOLLDEN_CROSS;
               if ( Symbol() == symbol_chk[cnt] ) {
                  UpArrow[i] = Low[i] - Point * Sign_pos;
               }
            } 
            else if (( MA1_old[cnt] >= MA2_old[cnt] ) && ( MA2[cnt] > MA1[cnt] ))   {
               kind[cnt] = DEAD_CROSS;
               if ( Symbol() == symbol_chk[cnt] ) {
                  DownArrow[i] = High[i] + Point * Sign_pos;
               }
            } 
            else {
               kind[cnt] = 0;
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
            switch(kind[cnt])   {
               case GOLLDEN_CROSS:
                  message= "MA Cross UP"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES)+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
                  break;
               case DEAD_CROSS:
                  message= "MA Cross Down!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES)+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
                  break;
            }

            if ( kind[cnt] != 0 ) SendMail("MA Croos Signal " +"["+symbol_chk[cnt]+"]["+IntegerToString(Period())+"]",message);
         }      
      }
      Emailflag = false;      
      if (Alertflag== true) {
         for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
 
            if (symbol_true[cnt] == false ) {
               continue;
            }

      
            if (Alertflag== true) {
               switch(kind[cnt])   {
               case GOLLDEN_CROSS:
                  Alert("Trix Cross Line1 UP",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case DEAD_CROSS:
                  Alert("Trix Cross Line1 Down ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               }
            }
         }
      }
      Alertflag = false;
   }
   return(0);
}














   
    
