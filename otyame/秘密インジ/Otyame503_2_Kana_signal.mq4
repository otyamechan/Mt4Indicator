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

#property indicator_buffers 6


#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Red
#property indicator_color6 Black

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 4
#property indicator_width5 4
#property indicator_width6 4


//---- buffers
double UpArrow[];
double DownArrow[];
double KessaiArrow[];
double MA[];
double sigma2_Lower[];
double sigma2_Uper[];



double Uwahige;
double Sitahige;
double Jittai;
bool insen;
bool yousen;
double pos_chk;
int pos;

int O_BandS;
int BandS;


string message;

extern bool AlertON=false;        //アラート表示　
extern bool EmailON=true;        //メール送信
extern bool Redraw = false;
extern string _Bollinger = "Center Line";
extern int MAPeriod = 20;           //ボリンージャーバンド中心線
extern int Signal_Pos = 20; 
extern string _Stochastic = "Stochsstic set";
extern int KPeriod = 8;
extern int DPeriod = 4;
extern int SlowDPeriod = 4;
extern int MAMethod = 3;
extern string _Price = "0:Low/High 1:Close/Close";
extern int Price = 1;
extern double Uper = 80.0;
extern double Lower = 20.0;

bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

double ST;
double ST_MAIN;
double ST_SIGNAL;


datetime TimeOld = D'1970.01.01 00:00:00';

int init()
{

   int i;
//---- indicators
   IndicatorBuffers(6);
   SetIndexBuffer(0,MA);
   SetIndexStyle(0,DRAW_LINE);               //中心線
   SetIndexBuffer(1,sigma2_Lower);
   SetIndexStyle(1,DRAW_LINE);               //１σ
   SetIndexBuffer(2,sigma2_Uper);
   SetIndexStyle(2,DRAW_LINE);               //2σ
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,241);
   SetIndexBuffer(3,UpArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,242);
   SetIndexBuffer(4,DownArrow);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,253);
   SetIndexBuffer(5,KessaiArrow);
   SetIndexEmptyValue(5,EMPTY_VALUE);
 
 
    pos_chk = Point;
   pos = 0;
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
   bool Time_on = false;
   if (Time[0] != TimeOld)        {                 //時間が更新された場合
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( limit < 2 ) limit = 2;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      for(i= limit-1;i>=1;i--){
         MA[i]   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_MAIN,i);
         sigma2_Lower[i]   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,i);
         sigma2_Uper[i]   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,i);
         ST_MAIN = iStochastic(NULL,0,KPeriod,DPeriod,SlowDPeriod,MAMethod,Price,MODE_MAIN,i); 
         ST_SIGNAL = iStochastic(NULL,0,KPeriod,DPeriod,SlowDPeriod,MAMethod,Price,MODE_SIGNAL,i); 
         buy= false;
         sell = false;
         if(High[i] > sigma2_Uper[i]) {
            UpArrow[i] = EMPTY_VALUE;
            if ( Close[i] - Open[i] >= 0) {
               yousen = true;
            }
            else {
            yousen = false;
            }
            if ( yousen == true ) {
               Uwahige = High[i] - Close[i];
               Sitahige = Open[i] - Low[i];
               Jittai = Close[i] - Open[i];
               if (Uwahige > Sitahige && Jittai < Uwahige ) {
                  sell = true;
               }
               else {
                  DownArrow[i] = EMPTY_VALUE;
               }
            }
            else    {
               Uwahige = High[i] - Open[i];
               Sitahige = Close[i] - Low[i];
               Jittai = Open[i] - Close[i];
               if (Uwahige > Sitahige && Jittai < Uwahige ) {
                  sell = true;
               }
               else {
                  DownArrow[i] = EMPTY_VALUE;
               }
            }
         }
         else if(Low[i] < sigma2_Lower[i]) {
            DownArrow[i] = EMPTY_VALUE;
            sell = false;
            if ( Close[i] -  Open[i] >= 0) {
            yousen = true;
            }
            else {
               yousen = false;
            }
            if ( yousen == true ) {
               Uwahige = High[i] - Close[i];
               Sitahige = Open[i] - Low[i];
               Jittai = Close[i] - Open[i];
               if (Uwahige < Sitahige && Jittai < Sitahige ) {
                  buy = true;
               }
               else    {
                  UpArrow[i] = EMPTY_VALUE;
               }
            }
            else  {
               Uwahige = High[i] - Open[i];
               Sitahige = Close[i] - Low[i];
               Jittai = Open[i] - Close[i];
               if (Uwahige < Sitahige && Jittai < Sitahige ) {
                  buy = true;
               }
               else    {
                  UpArrow[i] = EMPTY_VALUE;
               }
            }
         }
 //        Print("Time=",TimeToStr(Time[i],TIME_DATE | TIME_MINUTES));
 //        Print("ST = ",ST);
         
 //        Print("O_buy,buy=",O_buy,buy);
         if ( buy == true )   {
            if ( ST_MAIN >=  ST_SIGNAL || ST_MAIN >= Uper ) {
               buy = ture;
               }
            else  {
               buy = false;
            }
         }
         if ( sell == true )   {
            if ( ST_MAIN <=  ST_SIGNAL || ST_MAIN <= Lower ) {
               sell = ture;
            }
            else  {
               sell = false;
            }
         }
         switch(O_BandS)   {
            case NO_POSITON:
               if ( buy ==　true ) {
                  UpArrow[i] = Low[i] - Point * Signal_Pos;
                  Kind = BUY_POSITION;
                  BandS = BUY_POSITION;
               }
               else if ( sell == true ) {
                  DownArrow[i] = High[i] + Point * Signal_Pos;
                  Kind = SELL_POSITION;
                  BandS = SELL_POSITION;
               }
               break;   
            case:BUY_POSITON:
            

         
        
         if ( O_sell == true ) {
            if ( ST < Uper )   {
               sell = true;
               O_sell = false;
            }
         }
         else {
            if ( sell == true ) {
               if (ST < Uper ) {
                  sell = false;
               }
               else {
                  O_sell = true;
                  sell = false;
               }
            }     
         }          
         if ( O_buy == true ) {
            if ( ST > Lower )   {
               buy = true;
               UpArrow[i] = Low[i] - Point * Signal_Pos;
               O_buy = false;
            }
         }
         else {
            if ( buy == true ) {
               if (ST > Lower ) {
                  buy = false;
               }
               else {
                  O_buy = true;
                  buy = false;
               }
            }     
         }          

      }
   }
      //アラートと、メール処理をセットする
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
         if ( buy == true ) {
            message= "Buy Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値 = "+DoubleToStr(Open[0],pos-1); 
            message = message + "\r\n " + "高値 = "+DoubleToStr(High[1],pos-1);
            message = message + "\r\n " + "安値 = "+DoubleToStr(Low[1],pos-1);
            message = message + "\r\n " + "始値 = "+DoubleToStr(Open[1],pos-1);
            message = message + "\r\n " + "終値 = "+DoubleToStr(Close[1],pos-1);
            message = message + "\r\n "+"-2σライン = "+DoubleToStr(sigma2_Lower[1],pos);


         }
         if ( sell == true ) {
            message= "Sell Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値="+DoubleToStr(Open[0],pos-1); 
            message = message + "\r\n " + "高値 = "+DoubleToStr(High[1],pos-1);
            message = message + "\r\n " + "安値 = "+DoubleToStr(Low[1],pos-1);
            message = message + "\r\n " + "始値 = "+DoubleToStr(Open[1],pos-1);
            message = message + "\r\n " + "終値 = "+DoubleToStr(Close[1],pos-1);
            message = message + "\r\n "+"+2σライン = "+DoubleToStr(sigma2_Uper[1],pos);
  
         }
         if ( buy== true || sell== true ) SendMail("KANA Signal",message);
         Emailflag = false;

      }
      if (Alertflag== true) {
         if ( buy == true ) {
               Alert("KANA BUY Signal ",Symbol(),Period(),DoubleToStr(Open[0],4));
         }
         if ( sell == true ) {
               Alert("KANA SELL Signal ",Symbol(),Period(),DoubleToStr(Open[0],4));
  
         }
         Alertflag = false;
      }
   }

  return(0);
}