//+------------------------------------------------------------------+
//|                                        Perfect_Order.mq4            |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Otyame"
#property link      ""

#property indicator_buffers 6

#property indicator_chart_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Lime
#property indicator_color4 Lime
#property indicator_color5 Yellow
#property indicator_color6 Blue

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 2
#property indicator_width6 2

#define NO_POSITION  0
#define BUY_POSITION  1 
#define SELL_POSITION  2
#define BUY_KESSAI  11
#define SELL_KESSAI 12




//---- buffers
double UpArrow[];
double DownArrow[];
double UpEndArrow[];
double DownEndArrow[];
double MA0_0[];
double MA1_0[];
double MA0_1;
double MA1_1;

string message;

extern bool AlertON=false;           //アラート表示　
extern bool EmailON=true;           //メール送信
extern bool Redraw = false;
extern int Signal_Pos = 20;
extern bool Katamuki = false; 
extern int Compare_Period = 60;
extern int MA_0_Period = 3;
extern int MA_0_Shift = 3;
extern int MA_1_Period = 25;
extern int MA_1_Shift = 3;
extern bool MACD_Chk = false;


bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ
bool Sell = true;
bool Buy = true;
int   BandS;
int   O_BandS;



datetime TimeOld = D'1970.01.01 00:00:00';

int Kind;

double pos_chk;
int Chk_candle;
int pos;
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
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,234);
   SetIndexBuffer(2,UpEndArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,DownEndArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,MA0_0);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,MA1_0);
   
 
//   TimeOld = Time[0];
   switch(Period())  {
      case PERIOD_M1 :
			Chk_candle = Compare_Period / PERIOD_M1 ;
         break;
      case PERIOD_M5:
         if ( Compare_Period < PERIOD_M5 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_M5 ;
         }      

         break;
      case PERIOD_M15:
          if ( Compare_Period < PERIOD_M15 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_M15 ;
         }      
         break;
      case PERIOD_H1:
          if ( Compare_Period < PERIOD_H1 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_H1 ;
         }      
         break;
      case PERIOD_H4:
         if ( Compare_Period < PERIOD_H4 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_H4 ;
         }      
         break;
        case PERIOD_D1:
         if ( Compare_Period < PERIOD_D1 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_D1 ;
         }      
         break;
      
   }
   pos = 0;
   pos_chk = Point;
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
   
   if ( Time[0] != TimeOld ) {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      if ( limit < 2 ) limit = 2;
      for(i= limit-1;i>=1;i--){
         UpArrow[i] = EMPTY_VALUE;
         DownArrow[i] = EMPTY_VALUE;
         UpEndArrow[i] = EMPTY_VALUE;
         DownEndArrow[i] = EMPTY_VALUE;
         MA0_0[i] = iMA(NULL,0,MA_0_Period,MA_0_Shift,0,PRICE_CLOSE,i);
         MA0_1 = iMA(NULL,0,MA_0_Period,MA_0_Shift,0,PRICE_CLOSE,i+Chk_candle);
         MA1_0[i] = iMA(NULL,0,MA_1_Period,MA_1_Shift,0,PRICE_CLOSE,i);
         MA1_1 = iMA(NULL,0,MA_1_Period,MA_1_Shift,0,PRICE_CLOSE,i+Chk_candle);
         Buy = false;
         Sell = false;
//       買い判断
         switch(O_BandS) {
            case NO_POSITION:
               if ( MA0_0[i] > MA0_1 && Close[i] > MA0_0[i] &&  MA0_0[i] > MA1_0[i]) {
                  BandS = BUY_POSITION;
                  UpArrow[i] = Low[i] - Point * Signal_Pos;
                  Kind = BUY_POSITION;
               }
               if ( MA0_0[i] < MA0_1 && Close[i] < MA0_0[i] && MA0_0[i] < MA1_0[i]) {
                  BandS = SELL_POSITION;
                  DownArrow[i] = High[i] - Point * Signal_Pos;
                  Kind = SELL_POSITION;
               }
               break;
            case BUY_POSITION:
               if ( Close[i] > MA0_0[i] ) {
                  BandS = BUY_POSITION;
                  Kind = 0;
               }
               else {
                  BandS = NO_POSITION;
                  UpEndArrow[i] = High[i] + Point * Signal_Pos;
                  Kind = BUY_KESSAI;
               }
               break;
            case SELL_POSITION:
               if ( Buy == true )   {
                  BandS = BUY_POSITION;
                  UpArrow[i] = Low[i] - Point * Signal_Pos;
                  Kind = BUY_POSITION;
               }
               else if ( Sell == true ) {
                  BandS = SELL_POSITION;
                  Kind = 0;
               }
               else {
                  BandS = NO_POSITION;
                  UpEndArrow[i] = High[i] + Point * Signal_Pos;
                  Kind = SELL_KESSAI;
               }           
               break;
         }

         O_BandS = BandS;                              

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
         switch(Kind) {
            case BUY_POSITION:
               message= "銘柄："+Symbol()+"\r\n"+"時間軸："+Period()+"\r\n" + "Ｍayuhime スイングシグナル 上昇 \r\n 条件：成立 ";
               message= message + "\r\n 現在価格："+DoubleToStr(Open[0],pos-1);
               break;
            case SELL_POSITION:
               message= "銘柄："+Symbol()+"\r\n"+"時間軸："+Period()+"\r\n" + "Ｍayuhime スイングシグナル 下降 \r\n 条件：成立 ";
               message= message + "\r\n 現在価格："+DoubleToStr(Open[0],pos-1);
               break;
            case BUY_KESSAI:
               message= "銘柄："+Symbol()+"\r\n"+"時間軸："+Period()+"\r\n" + "Ｍayuhime スイングシグナル 上昇 \r\n 条件：終了 ";
               message= message + "\r\n 現在価格："+DoubleToStr(Open[0],pos-1);
               break;
            case SELL_KESSAI:
               message= "銘柄："+Symbol()+"\r\n"+"時間軸："+Period()+"\r\n" + "Ｍayuhime スイングシグナル 下降 \r\n 条件：終了 ";
               message= message + "\r\n 現在価格："+DoubleToStr(Open[0],pos-1);
               break;
         }
           if ( Kind != 0  ) SendMail("パーフェクトオーダーシグナル",message);
      }
      Emailflag = false;
      if (Alertflag== true) {
         switch(Kind) {
            case 1:
                  Alert("Perfect Order  BUY Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
            case 2:
                  Alert("Perfect Orde SELL Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
            case 3:
                  Alert("Perfect Orde  BUY Signal End",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               
               break;
            case 4:
                  Alert("Perfect Orde  SELL Signal End",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
         }
      }

      Alertflag = false;
   }

   return(0);
}














   
    
