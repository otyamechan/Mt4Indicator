//+------------------------------------------------------------------+
//|                                    Otyame114_Trix_ZeroCross.mq4  |
//+------------------------------------------------------------------+
#property copyright "Otyame　Trader"
#property description "Otyame114_Trix_ZeroCross"
//#property strict


#property indicator_buffers 4

#property indicator_separate_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Aqua
#property indicator_color4 Magenta
//#property indicator_color5 Black
//#property indicator_color6 Black

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
//#property indicator_width5 2
//#property indicator_width6 2


#define GOLLDEN_CROSS  1
#define DEAD_CROSS   2 


//---- buffers
double UpArrow1[];
double DownArrow1[];
double UpArrow2[];
double DownArrow2[];

string message;

extern bool AlertON=false;             //アラート表示　
extern bool EmailON=true;              //メール送信
extern  bool Redraw = false;           //再描画
extern string _Signal_Setting = "--Signal Setting--";
extern bool Line1 = true;
extern bool Line2 = true;
extern double Sign_pos = 0.0001; 
 
string P01 = "===Trix level colors===";
color P02 = FireBrick;
color P03 = DimGray;
color P04 = DarkGreen;
int P05 = 2;
string P06 = "===Cobra Label colors===";
color P07 = C'0x77,0x77,0x00';
color P08 = C'0x77,0x77,0x00';
color P09 = Green;
int P10 = 10;
int P11 = 50;
string P12 = "===== Alert Settings =====";
bool P13 = FALSE;
bool P14 = FALSE;
bool P15 = FALSE;
bool P16 = FALSE;
bool P17 = FALSE;
bool P18 = FALSE;
string P19 = "===Soundfiles user defined===";
string P20 = "analyze exit.wav";
string P21 = "analyze buy.wav";
string P22 = "analyze sell.wav";
string P23 = "trixcross.wav";
string P24 = "=Where to place the alarm labels=";
int P25 = 0;
int P26 = 1;
bool P27 = FALSE;
string P28 = "Box Parameters";
string P29 = "=How many bars in history=";
extern int Fast_Trix_Period = 30;
extern int Slow_Trix_Period = 42;
extern int Trixnum_bars = 7500;
string P30 = "*** Divergence Settings ***";
extern int NumberOfDivergenceBars = 7500;
bool P31 = FALSE;
bool P32 = FALSE;
bool P33 = FALSE;
string P34 = "--- Divergence Alert Settings ---";
bool P35 = FALSE;
string P36 = "";
string P37 = "------------------------------------";
string P38 = "SoundAlertOnDivergence only works";
string P39 = "when EnableAlerts is true.";
string P40 = "";
string P41 = "If SoundAlertOnDivergence is true,";
string P42 = "then sound alert will be generated,";
string P43 = "otherwise a pop-up alert will be";
string P44 = "generated.";
string P45 = "------------------------------------";
string P46 = "";
bool P47 = FALSE;
bool P48 = FALSE;
string P49 = "--- Divergence Color Settings ---";
color P50 = DodgerBlue;
color P51 = FireBrick;
string P52 = "--- Divergence Sound Files ---";
string P53 = "CBullishDiv.wav";
string P54 = "RBullishDiv.wav";
string P55 = "CBearishDiv.wav";
string P56 = "RBearishDiv.wav";
 
extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 0;
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


int kind1[10],kind2[10];
bool symbol_true[10];
int symbol_max;
string symbol_chk[10];
int cnt;
int rtn;
int pos[10];
bool Timeflg = false;
double pos_chk[10];
double pos_UP[10];
double Trix01[10],Trix02[10];
double Trix01_old[10],Trix02_old[10];
double Trix01_1[10],Trix02_1[10];
double Trix01_old_1[10],Trix02_old_1[10];
//double Trix1[],Trix2[];



int init()
{

//---- indicators
   IndicatorShortName("Otyame114_Trix_ZeroCross");

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,UpArrow1);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,DownArrow1);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,UpArrow2);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,DownArrow2);
   SetIndexEmptyValue(3,EMPTY_VALUE);
/*
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Trix1);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Trix2);
   IndicatorDigits(Digits + 2);
*/
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
            Trix01[cnt] = iCustom(symbol_chk[cnt],0,"Otyame115_Trix_V6.01", Fast_Trix_Period,Slow_Trix_Period,Trixnum_bars,NumberOfDivergenceBars,0,i);
            Trix02[cnt] = iCustom(symbol_chk[cnt],0,"Otyame115_Trix_V6.01", Fast_Trix_Period,Slow_Trix_Period,Trixnum_bars,NumberOfDivergenceBars,2,i);
            Trix01_old[cnt] = iCustom(symbol_chk[cnt],0,"Otyame115_Trix_V6.01", Fast_Trix_Period,Slow_Trix_Period,Trixnum_bars,NumberOfDivergenceBars,0,i+1);
            Trix02_old[cnt] = iCustom(symbol_chk[cnt],0,"Otyame115_Trix_V6.01", Fast_Trix_Period,Slow_Trix_Period,Trixnum_bars,NumberOfDivergenceBars,2,i+1);
            Trix01_1[cnt] = Trix01[cnt] * 10000;
            Trix02_1[cnt] = Trix02[cnt] * 10000;
            Trix01_old_1[cnt] = Trix01_old[cnt] * 10000;
            Trix02_old_1[cnt] = Trix02_old[cnt] * 10000;
//            if ( cnt == 0 ) {
//               Trix1[i] = Trix01[cnt];
//               Trix2[i] = Trix02[cnt];
//            }

//          Print(TimeToStr(Time[i],TIME_DATE|TIME_MINUTES)," "," Trix01= ",Trix01_1[0]," Trix02= ",Trix02_1[0]);

            UpArrow1[i] = EMPTY_VALUE;
            DownArrow1[i] = EMPTY_VALUE;
            UpArrow2[i] = EMPTY_VALUE;
            DownArrow2[i] = EMPTY_VALUE;
            if ( Line1 == true ) {
               if (( Trix01_old_1[cnt] <= 0.0 ) && ( Trix01_1[cnt] > 0.0 ))   {
                  kind1[cnt] = GOLLDEN_CROSS;
                  if ( Symbol() == symbol_chk[cnt] ) {
                     UpArrow1[i] = (-1)* Sign_pos;
                  }
               } 
               else if (( Trix01_old_1[cnt] >= 0.0 ) && ( Trix01_1[cnt] < 0.0 )) {
                  kind1[cnt] = DEAD_CROSS;
                  if ( Symbol() == symbol_chk[cnt] ) {
                     DownArrow1[i] =Sign_pos;
                  }
               } 
               else {
                  kind1[cnt] = 0;
               }
            }
            else kind1[cnt] = 0;

            if ( Line2 == true ) {
               if( ( Trix02_old_1[cnt] <= 0.0 ) && ( Trix02_1[cnt] > 0.0 ))   {
                  kind2[cnt] = GOLLDEN_CROSS;
                  if ( Symbol() == symbol_chk[cnt] ) {
                     UpArrow2[i] = (-1)* Sign_pos;
                  }
               } 
               else if (( Trix02_old_1[cnt] >= 0.0 ) && ( Trix02_1[cnt] < 0.0 ))  { 
            
                  kind2[cnt] = DEAD_CROSS;
                  if ( Symbol() == symbol_chk[cnt] ) {
                     DownArrow2[i] = Sign_pos;
                  }
               } 
               else {
                  kind2[cnt] = 0;
               }
            }
            else kind2[cnt] = 0;

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
            switch(kind1[cnt])   {
               case GOLLDEN_CROSS:
                  message= "Trix Cross UP"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
                  break;
               case DEAD_CROSS:
                  message= "Trix Cross Down!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
                  break;
            }

            if ( kind1[cnt] != 0 ) SendMail("Trix Zero Croos Line1 Signal " +"["+symbol_chk[cnt]+"]["+Period()+"]",message);
            switch(kind2[cnt])   {
               case GOLLDEN_CROSS:
                  message= "Trix Cross UP"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
                  break;
               case DEAD_CROSS:
                  message= "Trix Cross Down!"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
                  break;
            }

            if ( kind2[cnt] != 0 ) SendMail("Trix Zero Croos +Line2 Signal " +"["+symbol_chk[cnt]+"]["+Period()+"]",message);
         }      
      }
      Emailflag = false;      
      if (Alertflag== true) {
         for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
 
            if (symbol_true[cnt] == false ) {
               continue;
            }

      
            if (Alertflag== true) {
               switch(kind1[cnt])   {
               case GOLLDEN_CROSS:
                  Alert("Trix Cross Line1 UP",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case DEAD_CROSS:
                  Alert("Trix Cross Line1 Down ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               }
               switch(kind2[cnt])   {
               case GOLLDEN_CROSS:
                  Alert("Trix Cross Line2 UP",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case DEAD_CROSS:
                  Alert("Trix Cross Line2 Down ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               }
            }
         }
      }
      Alertflag = false;
   }
   return(0);
}

