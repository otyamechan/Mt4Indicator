//+------------------------------------------------------------------+
//|                                       Otyame  No.117             |
//|                                    Otyame117_TrendStrike.mq4     |
//|                                       2016.02.14                |
//+------------------------------------------------------------------+

#property copyright   "2016,Otyame Trader"
#property description "Otyame117_Trend_Strike"
//#property strict

#property indicator_buffers 4

#property indicator_chart_window


#property indicator_color1 Aqua
#property indicator_color2 Black
#property indicator_color3 Magenta
#property indicator_color4 Black

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4


#define NO 0
#define UP 1
#define DOWN 2
#define UP_K 3
#define DOWN_K 4
#define UP_KESSAI 11
#define DOWN_KESSAI 12


//---- buffers
double UpArrow[];
double UpKessaiArrow[];
double DownArrow[];
double DownKessaiArrow[];

double MA1[10];
double MA2[10];
double MA3[10];
double MA4[10];
double SAR[10];

string message;
extern bool AlertON=false;					//アラート表示　
extern bool EmailON=true;       			//メール送信
extern bool Keizoku_Email_ON = true;   //継続メール送信
extern  bool Redraw = true;    			//再描画
extern  int  Signal_Pos = 20;   			//シグナル位置

extern string _MA1 = "MA1設定";
extern int MA1Period = 5;            //中心期間
extern   string _MA1Method = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int MA1Method = 0;            //中心線用MA Method

extern string _MA2 = "MA2設定";
extern int MA2Period = 25;            //中心期間
extern   string _MA2Method = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int MA2Method = 0;            //中心線用MA Method

extern string _MA3 = "MA3設定";
extern int MA3Period = 50;            //中心期間
extern   string _MA3Method = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int MA3Method = 0;            //中心線用MA Method

extern string _MA4 = "MA4設定";
extern int MA4Period = 75;            //中心期間
extern   string _MA4Method = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int MA4Method = 0;            //中心線用MA Method

extern string _SAR = "パラボリック設定";
extern double SARStep = 0.02;            //中心期間
extern double SARMax = 0.1;            //中心線用MA Method




extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 0;
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

int cnt;
int symbol_max;
double pos_chk;
string symbol_chk[10];
string mes;
bool symbol_true[10];
bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ
int rtn;
int pos[10];
bool Timeflg = false;
bool buy[10];
bool sell[10];
int BandS[10];
int O_BandS[10];
int Kind[10];
string TimeFrameStr,shortname;

datetime TimeOld= D'1970.01.01 00:00:00';
int init()
{

//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,UpArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,UpKessaiArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,234);
   SetIndexBuffer(2,DownArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,DownKessaiArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   shortname = "Otyame117_Trend_Strike";
   IndicatorShortName(shortname);
	
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
         symbol_true[cnt] = true;
         pos_chk = MarketInfo(symbol_chk[cnt],MODE_POINT);
         rtn = GetLastError();         
         if ( rtn == ERR_UNKNOWN_SYMBOL ) {
            Print(symbol_chk[cnt]+"は存在しません。 ERR NO = ",rtn);
            symbol_true[cnt] = false;
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
      for (  cnt = 0 ; cnt < symbol_max ; cnt++) {  
         if ( symbol_true[cnt] == false ) {
            continue;
         }
         if ( limit < 2 ) limit = 2;
         for(i= limit-1;i>=1;i--){
            MA1[cnt]   = iMA(symbol_chk[cnt],0,MA1Period,0,MA1Method,PRICE_CLOSE,i);
            MA2[cnt]   = iMA(symbol_chk[cnt],0,MA2Period,0,MA2Method,PRICE_CLOSE,i);
            MA3[cnt]   = iMA(symbol_chk[cnt],0,MA3Period,0,MA3Method,PRICE_CLOSE,i);
            MA4[cnt]   = iMA(symbol_chk[cnt],0,MA4Period,0,MA4Method,PRICE_CLOSE,i);
            SAR[cnt]   = iSAR(symbol_chk[cnt],0,SARStep,SARMax,i);
            buy[cnt] = false;
            sell[cnt] = false;
            if (( MA1[cnt] >= MA2[cnt] ) && ( MA2[cnt] >= MA3[cnt] ) && ( MA3[cnt] >= MA4[cnt] ) && iClose(symbol_chk[cnt],0,i) >= SAR[cnt] ) {
               buy[cnt] = true;
            }
            else if (( MA1[cnt] <= MA2[cnt] ) && ( MA2[cnt] <= MA3[cnt] ) && ( MA3[cnt] <= MA4[cnt] ) && iClose(symbol_chk[cnt],0,i) <= SAR[cnt] ) { 
              sell[cnt] = true;
            }
            if ( symbol_chk[cnt] == Symbol()){
                  Print(TimeToStr(Time[i],TIME_DATE|TIME_MINUTES),"buy = ",buy[cnt]," sell = ",sell[cnt]," O_BandS[cnt]",O_BandS[cnt]) ;
            }
            switch ( O_BandS[cnt] ) {
            case NO:
               if (buy[cnt] == true ) {
                  BandS[cnt] = UP;
                  if ( symbol_chk[cnt] == Symbol()) {
                     UpArrow[i]=Low[i]  - Point * Signal_Pos;
                  }  
                  Kind[cnt] = UP;
               }
               else if (sell[cnt] == true ) {
                  BandS[cnt] = DOWN;
                  if ( symbol_chk[cnt] == Symbol()) {
                     DownArrow[i]=High[i]  + Point * Signal_Pos;
                  }  
                  Kind[cnt] = DOWN;
               }
               else {
                  BandS[cnt] = NO;
               }
               break;
            case UP:
               if( iClose(symbol_chk[cnt],0,i) >= SAR[cnt]  ) {
                  buy[cnt] = true;
               }
               break;
            case DOWN:
               if( iClose(symbol_chk[cnt],0,i) <= SAR[cnt]  ) {
                  sell[cnt] = true;
               }
               break;
            }
            switch( O_BandS[cnt]) {
            case NO:
               if (buy[cnt] == true ) {
                  BandS[cnt] = UP;
                  if ( symbol_chk[cnt] == Symbol()) {
                     UpArrow[i]=Low[i]  - Point * Signal_Pos;
                  }  
                  Kind[cnt] = UP;
               }
               else if (sell[cnt] == true ) {
                  BandS[cnt] = DOWN;
                  if ( symbol_chk[cnt] == Symbol()) {
                     DownArrow[i]=High[i]  + Point * Signal_Pos;
                  }  
                  Kind[cnt] = DOWN;
               }
               else {
                  BandS[cnt] = NO;
               }
               break;
            case UP:
            case UP_K:
               if (buy[cnt] == true ) {
                  BandS[cnt] = UP_K;
                  Kind[cnt] = UP_K;
               }
               else if (sell[cnt] == true ) {
                  BandS[cnt] = DOWN;
                  if ( symbol_chk[cnt] == Symbol()) {
                     DownArrow[i]=High[i]  + Point * Signal_Pos;
                  }  
                  Kind[cnt] = DOWN;
               }
               else {
                  BandS[cnt] = NO;
                  Kind[cnt] = UP_KESSAI;
                  if ( symbol_chk[cnt] == Symbol()) {
                     UpKessaiArrow[i]=High[i]  + Point * Signal_Pos;
                  }  
               }
               break;
            case DOWN:
            case DOWN_K:
               BandS[cnt] = UP;
               Kind[cnt] = UP;
               if ( symbol_chk[cnt] == Symbol()) {
                  UpArrow[i]=Low[i]  - Point * Signal_Pos;
               }  
               else if (sell[cnt] == true ) {
                  BandS[cnt] = DOWN_K;
                  Kind[cnt] = DOWN_K;
               }
               else {
                  BandS[cnt] = NO;
                  Kind[cnt] = UP_KESSAI;
                  if ( symbol_chk[cnt] == Symbol()) {
                     DownKessaiArrow[i]=Low[i]  - Point * Signal_Pos;
                  }  
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
            switch(Kind[cnt])   {
            case UP:
               message= "トレンドストライク買いシグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n 現在値="+DoubleToString(iOpen(symbol_chk[cnt],Period(),0));
               break;
            case DOWN:
               message= "トレンドストライク売りシグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n 現在値="+DoubleToString(iOpen(symbol_chk[cnt],Period(),0));
               break;
            case UP_KESSAI:
               message= "トレンドストライク買い決済"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n 現在値="+DoubleToString(iOpen(symbol_chk[cnt],Period(),0));
               break;
            case DOWN_KESSAI:
               message= "トレンドストライク売り決済"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n 現在値="+DoubleToString(iOpen(symbol_chk[cnt],Period(),0));
               break;
            case UP_K:
               if ( Keizoku_Email_ON == true ) {
                  message= "トレンドストライク買い継続"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n 現在値="+DoubleToString(iOpen(symbol_chk[cnt],Period(),0));
                  break;
               }
               else {
                  Kind[cnt] = 0;
               }
               break;
            case DOWN_K:
               if ( Keizoku_Email_ON == true ) {
                  message= "トレンドストライク売り継続"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n 現在値="+DoubleToString(iOpen(symbol_chk[cnt],Period(),0));
                  break;
               }
               else {
                  Kind[cnt] = 0;
               }
               break;
            }
            message = message + "\r\n"+"MA1="+DoubleToString(MA1[cnt]);
            message = message + "\r\n"+"MA2="+DoubleToString(MA1[cnt]);
            message = message + "\r\n"+"MA3="+DoubleToString(MA1[cnt]);
            message = message + "\r\n"+"MA4="+DoubleToString(MA1[cnt]);
            message = message + "\r\n"+"SAR= "+DoubleToString(SAR[cnt]);

            if ( Kind[cnt] != 0 ) SendMail("トレンドストライク " +"["+symbol_chk[cnt]+"]["+IntegerToString(Period())+"]",message);
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
               case UP:
                  Alert("Trend　Strike BUY Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case DOWN:
                  Alert("CTrend　Strike SELL Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case UP_KESSAI:
                  Alert("Trend　Strike BUY Kessai Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case DOWN_KESSAI:
                  Alert("CTrend　Strike SELL Kessai Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               }
            }
         }
      }
      Alertflag = false;
   }
   return(0);
}











   

