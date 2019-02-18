//+------------------------------------------------------------------+
//|                                       Otyame  No.011             |
//|                                       スーパーボリンジャー　 |
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

#property indicator_buffers 8


#property indicator_color1 Blue
#property indicator_color2 Black
#property indicator_color3 Aqua
#property indicator_color4 Black
#property indicator_color5 Red
#property indicator_color6 Lime
#property indicator_color7 Magenta
#property indicator_color8 Lime

#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 3
#property indicator_width6 3
#property indicator_width7 3
#property indicator_width8 3


#define NO_POSITON         0
#define BUY_SETUP          1
#define BUY_SETUP_CANCEL   2
#define BUY_B_WALK         3
#define BUY_B_WALK_CANCEL  4
#define SELL_SETUP         5
#define SELL_SETUP_CANCEL  6
#define SELL_B_WALK        7 
#define SELL_B_WALK_CANCEL 8 

//---- buffers
double UpReadyArrow[];
double UpCancelArrow[];
double UpStartArrow[];
double UpEndArrow[];
double DownReadyArrow[];
double DownCancelArrow[];
double DownStartArrow[];
double DownEndArrow[];
double sigma1_Lower1;
double sigma1_Uper1;
double sigma1_Lower2;
double sigma1_Uper2;
double sigma2_Lower;
double sigma2_Uper;
double sigma3_Lower;
double sigma3_Uper;
double Chikou;
double MA;
double MA1;
double MA2;



int pos;
int O_Buy;								//前回用
int O_Sell;								//前回用
bool Chk_buy;
bool Chk_sell;
int Buy;								//前回用
int Sell;								//前回用
bool Bund_buy;
bool Bund_sell;



string message;

extern bool AlertON=false;        //アラート表示　
extern bool EmailON=true;        //メール送信
extern bool Email_Setup_ON = true;
extern bool Redraw = false;
extern int MAPeriod = 21;           //ボリンージャーバンド中心線
extern bool Katamuki = false; 
extern int Compare_Period = 60;
extern bool Chiko_Check = false; 
extern int Chikou_Idou = -20;
extern int Keizoku_time = 3;		//継続時間
extern int Signal_Pos = 30;		//継続時間

bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ
bool Timeflg = false;

datetime TimeOld = D'1970.01.01 00:00:00';

int count[2];
int Kind;
double pos_chk;
int Chk_candle;


int init()
{

   int i;
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,241);
   SetIndexBuffer(0,UpReadyArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
//
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,242);
   SetIndexBuffer(1,UpCancelArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
//
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,UpStartArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
//
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,UpEndArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
//
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,242);
   SetIndexBuffer(4,DownReadyArrow);
   SetIndexEmptyValue(4,EMPTY_VALUE);
//
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,241);
   SetIndexBuffer(5,DownCancelArrow);
   SetIndexEmptyValue(5,EMPTY_VALUE);
//
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,234);
   SetIndexBuffer(6,DownStartArrow);
   SetIndexEmptyValue(6,EMPTY_VALUE);
//
   SetIndexStyle(7,DRAW_ARROW);
   SetIndexArrow(7,233);
   SetIndexBuffer(7,DownEndArrow);
   SetIndexEmptyValue(7,EMPTY_VALUE);
 
 
    pos_chk = Point;
   pos = 0;
    for ( i = 0 ; pos_chk < 1 ;i++) {
      pos++;
      pos_chk = pos_chk * 10;
   }      
   pos++;
  
	count[0] = 0;
	count[1] = 0;
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
      default:
			Chk_candle = 1;
         break;
      
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
   bool Time_on = false;
   if (Time[0] != TimeOld)        {                 //時間が更新された場合
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      if ( limit < 2 ) limit = 2;

      for(i= limit-1;i>=1;i--){
         sigma1_Lower1   = iBands(NULL,0,MAPeriod,1,0,PRICE_CLOSE,MODE_LOWER,i);
         sigma1_Uper1   = iBands(NULL,0,MAPeriod,1,0,PRICE_CLOSE,MODE_UPPER,i);
         sigma1_Lower2   = iBands(NULL,0,MAPeriod,1,0,PRICE_CLOSE,MODE_LOWER,i+1);
         sigma1_Uper2   = iBands(NULL,0,MAPeriod,1,0,PRICE_CLOSE,MODE_UPPER,i+1);
         sigma2_Lower   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,i);
         sigma2_Uper   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,i);
         sigma3_Lower   = iBands(NULL,0,MAPeriod,3,0,PRICE_CLOSE,MODE_LOWER,i);
         sigma3_Uper   = iBands(NULL,0,MAPeriod,3,0,PRICE_CLOSE,MODE_UPPER,i);
         if ( i + Chikou_Idou < 0) {
            Chikou = Close[0];
         }
         else
           {
   			   Chikou = Close[i+(-1)*Chikou_Idou];
            
           }
         MA   = iMA(NULL,0,MAPeriod,0,0,PRICE_CLOSE,i);
         MA1   = iMA(NULL,0,MAPeriod,0,0,PRICE_CLOSE,i+Chk_candle);
         MA2   = iMA(NULL,0,MAPeriod,0,0,PRICE_CLOSE,i+1);

			Chk_buy = false;
			Chk_sell = false;
			if (Close[i] > MA  ) {
				Chk_buy =  true;
            if ( Close[i] >= sigma1_Uper1) {
               Bund_buy = true;
            }
            else {
				   Bund_buy = false; 
            }
            
				Chk_sell =  false;
			}
			if (Close[i] < MA ){
				Chk_sell =  true;
            if ( Close[i] <= sigma1_Lower1) {
               Bund_sell = true;
            }
            else {
				   Bund_sell = false; 
            }
			}
			Kind = 0;
			if ( Chiko_Check == true ) {
			   if ( Chikou < Close[(-1)*Chikou_Idou+i] ) {
			      Chk_buy = false ;
			   }
		   }
			if ( Katamuki == true ) {
			   if ( MA1 > MA ) {
			      Chk_buy = false ;
			   }
		   }
		   switch(O_Buy) {
            case NO_POSITON:
               if (Chk_buy == true ) {
                  Buy = BUY_SETUP;
                  count[0] = 0;
               }
               else  Buy = NO_POSITON;
               break;
            case BUY_SETUP:
               if ( Chk_buy == true ) {
                  if ( Bund_buy == true ) {
                     count[0]++;
                     if ( count[0] >= Keizoku_time ) {
                        Buy = BUY_B_WALK;
                     }
                     else {
                        Buy = BUY_SETUP;
                     }
                  }
                  else {
                     count[0] = 0;
                     Buy = BUY_SETUP;
                  }
               }                    
               else  {
                  Buy = BUY_SETUP_CANCEL;
               }
               break;
            case BUY_B_WALK:
               if ( Chk_buy == true ) {
                  if ( Bund_buy == true ) {
                     Buy = BUY_B_WALK;
                     count[0]++;		         
                  }                    
                  else {
                     Buy = BUY_B_WALK_CANCEL;
                     count[0] = 0;		         
                  }                    
               }
               else  {                
                  Buy = BUY_B_WALK_CANCEL;
                  count[0] = 0;		         
               }
               break;
         }     
         Kind = 0;
         if ( O_Buy != Buy ) {
			   switch(Buy)	{
					case BUY_SETUP:
						UpReadyArrow[i] = Low[i] - (Point * Signal_Pos);
						Kind = BUY_SETUP;
						break;
					case BUY_B_WALK:
						UpStartArrow[i] = Low[i] -(Point * Signal_Pos);
						Kind = BUY_B_WALK;
						break;
					case BUY_SETUP_CANCEL:
						UpCancelArrow[i] = High[i]+ (Point * Signal_Pos);
						Kind = BUY_SETUP_CANCEL;
                  Buy = NO_POSITON;
						break;
					case BUY_B_WALK_CANCEL:
						UpEndArrow[i] = High[i] + (Point * Signal_Pos);
						Kind = BUY_B_WALK_CANCEL;
                  Buy = NO_POSITON;
						break;
				}
            O_Buy = Buy;
			}
			if ( Chiko_Check == true ) {
			   if ( Chikou > Close[(-1)*Chikou_Idou+i] ) {
			      Chk_sell = false ;
			   }
		   }
			if ( Katamuki == true ) {
			   if ( MA1 < MA ) {
			      Chk_sell = false ;
			   }
		   }
		   switch(O_Sell) {
            case NO_POSITON:
               if (Chk_sell == true ) {
                  Sell = SELL_SETUP;
                  count[1] = 0;
               }
               else  Sell = NO_POSITON;
               break;
            case SELL_SETUP:
               if ( Chk_sell == true ) {
                  if ( Bund_sell == true ) {
                     count[1]++;
                     if ( count[1] >= Keizoku_time ) {
                        Sell = SELL_B_WALK;
                     }
                  }
                  else {
                     count[1] = 0;
                     Sell = SELL_SETUP;
                  }
               }                    
               else  {
                  Sell = SELL_SETUP_CANCEL;
               }
               break;
            case SELL_B_WALK:
               if ( Chk_sell == true ) {
                  if ( Bund_sell == true ) {
                     Sell = SELL_B_WALK;
                     count[1]++;		         
                  }                    
                  else {
                     Sell = SELL_B_WALK_CANCEL;
                     count[1] = 0;		         
                  }                    
               }
               else  {                
                  Sell = SELL_B_WALK_CANCEL;
                  count[1] = 0;		         
               }
               break;
         }     
         if ( O_Sell != Sell ) {
			   switch(Sell)	{
					case SELL_SETUP:
						DownReadyArrow[i] = High[i] + (Point * Signal_Pos);
						Kind = SELL_SETUP;
						break;
					case SELL_B_WALK:
						DownStartArrow[i] = High[i] + (Point * Signal_Pos);
						Kind = SELL_B_WALK;
						break;
					case SELL_SETUP_CANCEL:
						DownCancelArrow[i] = Low[i] -(Point * Signal_Pos);
						Kind = SELL_SETUP_CANCEL;
                  Sell = NO_POSITON;
						break;
					case SELL_B_WALK_CANCEL:
						DownEndArrow[i] = Low[i] -(Point * Signal_Pos);
						Kind = SELL_B_WALK_CANCEL;
                  Sell = NO_POSITON;
						break;
				}
            O_Sell = Sell;
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
			switch(Kind) {
				case BUY_SETUP:
				   if ( Email_Setup_ON == true ) {
            	   message= "Super Bollin Buy Infomation"+"\r\n"+"準備開始"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値 = "+DoubleToStr(Open[0],pos-1); 
            	   message = message + "\r\n " + "MA = "+DoubleToStr(MA,pos-1);
            	   message = message + "\r\n " + "+1σ = "+DoubleToStr(sigma1_Uper1,pos-1);
            	   message = message + "\r\n " + "+2σ = "+DoubleToStr(sigma2_Uper,pos-1);
            	   message = message + "\r\n " + "+3σ = "+DoubleToStr(sigma3_Uper,pos-1);
            	   message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou,pos-1);
            	   message = message + "\r\n " + "21本前終値 = "+DoubleToStr(Close[(-1)*Chikou_Idou],pos-1);
					}
					break;


				case BUY_B_WALK:
            	message= "Super Bollin Buy Infomation"+"\r\n"+"バンドウォーク開始"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値 = "+DoubleToStr(Open[0],pos-1); 
            	message = message + "\r\n " + "MA = "+DoubleToStr(MA,pos-1);
            	message = message + "\r\n " + "+1σ = "+DoubleToStr(sigma1_Uper1,pos-1);
            	message = message + "\r\n " + "+2σ = "+DoubleToStr(sigma2_Uper,pos-1);
            	message = message + "\r\n " + "+3σ = "+DoubleToStr(sigma3_Uper,pos-1);
            	message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou,pos-1);
            	message = message + "\r\n " + "21本前終値 = "+DoubleToStr(Close[(-1)*Chikou_Idou],pos-1);
					break;
				case BUY_SETUP_CANCEL:
				   if ( Email_Setup_ON == true ) {
            	   message= "Super Bollin Buy Infomation"+"\r\n"+"キャンセル"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値 = "+DoubleToStr(Open[0],pos-1); 
            	   message = message + "\r\n " + "MA = "+DoubleToStr(MA,pos-1);
            	   message = message + "\r\n " + "+1σ = "+DoubleToStr(sigma1_Uper1,pos-1);
            	   message = message + "\r\n " + "+2σ = "+DoubleToStr(sigma2_Uper,pos-1);
            	   message = message + "\r\n " + "+3σ = "+DoubleToStr(sigma3_Uper,pos-1);
            	   message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou,pos-1);
            	   message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(Close[(-1)*Chikou_Idou],pos-1);
					}
					break;
				case BUY_B_WALK_CANCEL:
            	message= "Super Bollin Buy Infomation"+"\r\n"+"バンドウォーク終了"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値 = "+DoubleToStr(Open[0],pos-1); 
            	message = message + "\r\n " + "MA = "+DoubleToStr(MA,pos-1);
            	message = message + "\r\n " + "+1σ = "+DoubleToStr(sigma1_Uper1,pos-1);
            	message = message + "\r\n " + "+2σ = "+DoubleToStr(sigma2_Uper,pos-1);
            	message = message + "\r\n " + "+3σ = "+DoubleToStr(sigma3_Uper,pos-1);
            	message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou,pos-1);
            	message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(Close[(-1)*Chikou_Idou],pos-1);
					break;
				case SELL_SETUP:
				   if ( Email_Setup_ON == true ) {
            	   message= "Super Bollin Buy Infomation"+"\r\n"+"準備開始"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値 = "+DoubleToStr(Open[0],pos-1); 
            	   message = message + "\r\n " + "MA = "+DoubleToStr(MA,pos-1);
            	   message = message + "\r\n " + "-1σ = "+DoubleToStr(sigma1_Lower1,pos-1);
            	   message = message + "\r\n " + "-2σ = "+DoubleToStr(sigma2_Lower,pos-1);
            	   message = message + "\r\n " + "-3σ = "+DoubleToStr(sigma3_Lower,pos-1);
            	   message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou,pos-1);
            	   message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(Close[(-1)*Chikou_Idou],pos-1);
					}
					break;
				case SELL_B_WALK:
            	   message= "Super Bollin Buy Infomation"+"\r\n"+"バンドウォーク開始"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値 = "+DoubleToStr(Open[0],pos-1); 
            	   message = message + "\r\n " + "MA = "+DoubleToStr(MA,pos-1);
            	   message = message + "\r\n " + "-1σ = "+DoubleToStr(sigma1_Lower1,pos-1);
            	   message = message + "\r\n " + "-2σ = "+DoubleToStr(sigma2_Lower,pos-1);
            	   message = message + "\r\n " + "-3σ = "+DoubleToStr(sigma3_Lower,pos-1);
            	   message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou,pos-1);
            	   message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(Close[(-1)*Chikou_Idou],pos-1);
					break;
				case SELL_SETUP_CANCEL:
				   if ( Email_Setup_ON == true ) {
            	   message= "Super Bollin Buy Infomation"+"\r\n"+"キャンセル"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値 = "+DoubleToStr(Open[0],pos-1); 
            	   message = message + "\r\n " + "MA = "+DoubleToStr(MA,pos-1);
            	   message = message + "\r\n " + "-1σ = "+DoubleToStr(sigma1_Lower1,pos-1);
            	   message = message + "\r\n " + "-2σ = "+DoubleToStr(sigma2_Lower,pos-1);
            	   message = message + "\r\n " + "-3σ = "+DoubleToStr(sigma3_Lower,pos-1);
            	   message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou,pos-1);
            	   message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(Close[(-1)*Chikou_Idou],pos-1);
					}
					break;
				case SELL_B_WALK_CANCEL:
            	message= "Super Bollin Buy Infomation"+"\r\n"+"バンドウォーク終了"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"現在値 = "+DoubleToStr(Open[0],pos-1); 
            	message = message + "\r\n " + "MA = "+DoubleToStr(MA,pos-1);
            	message = message + "\r\n " + "-1σ = "+DoubleToStr(sigma1_Lower1,pos-1);
            	message = message + "\r\n " + "-2σ = "+DoubleToStr(sigma2_Lower,pos-1);
            	message = message + "\r\n " + "-3σ = "+DoubleToStr(sigma3_Lower,pos-1);
            	message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou,pos-1);
            	message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(Close[(-1)*Chikou_Idou],pos-1);
					break;
         }
         if ( Kind != 0 ) SendMail("スーパーボリンジャー "+"["+Symbol()+"]["+Period()+"]",message);
         Emailflag = false;

      }
      if (Alertflag== true) {
 			switch(Kind)	{
				case BUY_SETUP:
               Alert("Super Bollinger Buy Signal ","Ready",Symbol(),Period(),DoubleToStr(Open[0],4));
					break;
				case BUY_B_WALK:
               Alert("Super Bollinger Buy Signal ","Start",Symbol(),Period(),DoubleToStr(Open[0],4));
					break;
				case BUY_SETUP_CANCEL:
               Alert("Super Bollinger Buy Signal ","Cancel",Symbol(),Period(),DoubleToStr(Open[0],4));
					break;
				case BUY_B_WALK_CANCEL:
               Alert("Super Bollinger Buy Signal ","End",Symbol(),Period(),DoubleToStr(Open[0],4));
					break;
				case SELL_SETUP:
               Alert("Super Bollinger Sell Signal ","Ready",Symbol(),Period(),DoubleToStr(Open[0],4));
					break;
				case SELL_B_WALK:
               Alert("Super Bollinger Sell Signal ","Start",Symbol(),Period(),DoubleToStr(Open[0],4));
					break;
				case SELL_SETUP_CANCEL:
               Alert("Super Bollinger Sell Signal ","Cancel",Symbol(),Period(),DoubleToStr(Open[0],4));
					break;
				case SELL_B_WALK_CANCEL:
               Alert("Super Bollinger Sell Signal ","End",Symbol(),Period(),DoubleToStr(Open[0],4));
					break;
			}
         Alertflag = false;
      }
   }

  return(0);
}







