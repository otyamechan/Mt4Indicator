//+------------------------------------------------------------------+
//|                                       Otyame  No.011             |
//|                                       スーパーボリンジャー　            |
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

#define distance 30

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
double sigma1_Lower1[10];
double sigma1_Uper1[10];
double sigma1_Lower2[10];
double sigma1_Uper2[10];
double sigma2_Lower[10];
double sigma2_Uper[10];
double sigma3_Lower[10];
double sigma3_Uper[10];
double Chikou[10];
double MA[10];
double MA1[10];
double MA2[10];


int pos[10];
int Buy[10];									//(0:なし,1:準備中,2:継続中）
int Sell[10];								//(0:なし,1:準備中,2:継続中）
int O_Buy[10];									//(0:なし,1:準備中,2:継続中）
int O_Sell[10];								//(0:なし,1:準備中,2:継続中）
bool Chk_buy[10];
bool Chk_sell[10];

string message;

extern bool AlertON=false;        //アラート表示　
extern bool EmailON=true;        //メール送信
extern bool Redraw = false;
extern bool Email_Setup_ON = true;
extern int MAPeriod = 21;           //ボリンージャーバンド中心線
extern bool Katamuki = false; 
extern int Compare_Period = 60;
extern bool Chikou_Check = true;		//継続時間
extern int Chikou_Idou = -20;
extern int Keizoku_time = 3;		//継続時間
extern int Signal_Pos = 30;		//継続時間
extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 10;
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
bool Timeflg = false;

int symbol_max;

datetime TimeOld = D'1970.01.01 00:00:00';

int count[2][10];
int	Chk_candle;
int Kind[10];                    // メッセージ要（1:上昇成立、2:下降成立,3:上昇終了、4:下降終了）
double pos_chk;
string symbol_chk[10];
bool symbol_true[10];

bool O_Chk_buy[10];
bool O_Chk_sell[10];
bool Bund_buy[10];
bool Bund_sell[10];

int init()
{

   int i;
   int cnt;
   int rtn;
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
   int y;  
   for ( i = 0 ; i <=1; i++) {
      for ( y = 0;y <= 9 ; y++) {
	      count[i][y] = 0;
      }
   }	
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
   int cnt;
   bool Time_on = false;
   if (Time[0] != TimeOld)        {                 //時間が更新された場合
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
      for ( cnt = 0; cnt < symbol_max ; cnt++ ) {
         if ( symbol_true[cnt] == false ) {
            continue ;
         }
         for(i= limit-1;i>=1;i--){
            sigma1_Lower1[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,1,0,PRICE_CLOSE,MODE_LOWER,i);
            sigma1_Uper1[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,1,0,PRICE_CLOSE,MODE_UPPER,i);
            sigma1_Lower2[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,1,0,PRICE_CLOSE,MODE_LOWER,i+1);
            sigma1_Uper2[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,1,0,PRICE_CLOSE,MODE_UPPER,i+1);
            sigma2_Lower[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,i);
            sigma2_Uper[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,i);
            sigma3_Lower[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,3,0,PRICE_CLOSE,MODE_LOWER,i);
            sigma3_Uper[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,3,0,PRICE_CLOSE,MODE_UPPER,i);
            if ( i + Chikou_Idou < 0) {
               Chikou[cnt] = iClose(symbol_chk[cnt],Period(),0);
            }
            else
            {
   			   Chikou[cnt] = iClose(symbol_chk[cnt],Period(),(-1)*Chikou_Idou+i);
            }

            MA[cnt]   = iMA(symbol_chk[cnt],0,MAPeriod,0,0,PRICE_CLOSE,i);
            MA1[cnt]   = iMA(symbol_chk[cnt],0,MAPeriod,0,0,PRICE_CLOSE,i+Chk_candle);
            MA2[cnt]   = iMA(symbol_chk[cnt],0,MAPeriod,0,0,PRICE_CLOSE,i+1);

			   Chk_buy[cnt] = false;
			   Chk_sell[cnt] = false;
			   Kind[cnt] = 0;
			   if (iClose(symbol_chk[cnt],Period(),i) > MA[cnt]   ) {
				   Chk_buy[cnt] = true;
               if ( iClose(symbol_chk[cnt],Period(),i) >= sigma1_Uper1[cnt]) {
                  Bund_buy[cnt] = true;
               }
               else {
				      Bund_buy[cnt] = false; 
               }
				   Chk_sell[cnt] =  false;
			   }
			   if (iClose(symbol_chk[cnt],Period(),i) < MA[cnt] ){
				   Chk_sell[cnt] =  true;
               if ( iClose(symbol_chk[cnt],Period(),i) <= sigma1_Lower1[cnt]) {
                  Bund_sell[cnt] = true;
               }
               else {
				      Bund_sell[cnt] = false; 
               }
				   Chk_buy[cnt] =  false;
			   }
			   if ( Chikou_Check == true ) {
			      if ( Chikou[cnt] < iClose(symbol_chk[cnt],Period(),(-1)*Chikou_Idou+ i) ) {
			         Chk_buy[cnt] = false;
			      }
			   }
			   if ( Katamuki == true ) {
			      if ( MA1[cnt] > MA[cnt] ) {
			         Chk_buy[cnt] = false ;
			      }
		      }
		      switch(O_Buy[cnt]) {
               case NO_POSITON:
                  if (Chk_buy[cnt] == true ) {
                     Buy[cnt] = BUY_SETUP;
                     count[cnt][0] = 0;
                  }
                  else  Buy[cnt] = NO_POSITON;
                  break;
               case BUY_SETUP:
                  if ( Chk_buy[cnt] == true ) {
                     if ( Bund_buy[cnt] == true ) {
                        count[0][cnt]++;
                        if ( count[0][cnt] >= Keizoku_time ) {
                           Buy[cnt] = BUY_B_WALK;
                        }
                        else {
                           Buy[cnt] = BUY_SETUP;
                        }
                     }
                     else {
                        count[0][cnt] = 0;
                        Buy[cnt] = BUY_SETUP;
                     }
                  }                    
                  else  {
                     Buy[cnt] = BUY_SETUP_CANCEL;
                  }
                  break;
               case BUY_B_WALK:
                  if ( Chk_buy[cnt] == true ) {
                     if ( Bund_buy[cnt] == true ) {
                        Buy[cnt] = BUY_B_WALK;
                        count[0][cnt]++;		         
                     }                    
                     else {
                        Buy[cnt] = BUY_B_WALK_CANCEL;
                        count[0][cnt] = 0;		         
                     }                    
                  }
                  else  {                
                     Buy[cnt] = BUY_B_WALK_CANCEL;
                     count[0][cnt] = 0;		         
                  }
                  break;
            }     
            Kind[cnt] = 0;
            if ( O_Buy[cnt] != Buy[cnt] ) {
			      switch(Buy[cnt])	{
					   case BUY_SETUP:
						   if ( Symbol() == symbol_chk[cnt] ) {
						      UpReadyArrow[i] = Low[i] - (Point * Signal_Pos);
						   }
						   Kind[cnt] = BUY_SETUP;
						   break;
					   case BUY_B_WALK:
						   if ( Symbol() == symbol_chk[cnt] ) {
						      UpStartArrow[i] = Low[i] -(Point * Signal_Pos);
						   }
						   Kind[cnt] = BUY_B_WALK;
						   break;
					   case BUY_SETUP_CANCEL:
						   if ( Symbol() == symbol_chk[cnt] ) {
						      UpCancelArrow[i] = High[i]+ (Point * Signal_Pos);
						   }
						   Kind[cnt] = BUY_SETUP_CANCEL;
                     Buy[cnt] = NO_POSITON;
						   break;
					   case BUY_B_WALK_CANCEL:
						   if ( Symbol() == symbol_chk[cnt] ) {
						      UpEndArrow[i] = High[i] + (Point * Signal_Pos);
						   }
						   Kind[cnt] = BUY_B_WALK_CANCEL;
                     Buy[cnt] = NO_POSITON;
						   break;
				   }
               O_Buy[cnt] = Buy[cnt];
			   }

			   if ( Chikou_Check == true ) {
			      if ( Chikou[cnt] > iClose(symbol_chk[cnt],Period(),(-1) *Chikou_Idou+i) ) {
			         Chk_sell[cnt] = false;
			      }
			   }
			   if ( Katamuki == true ) {
			      if ( MA1[cnt] < MA[cnt] ) {
			         Chk_sell[cnt] = false ;
			      }
		      }
		      switch(O_Sell[cnt]) {
               case NO_POSITON:
                  if (Chk_sell[cnt] == true ) {
                     Sell[cnt] = SELL_SETUP;
                     count[1][cnt] = 0;
                  }
                  else  Sell[cnt] = NO_POSITON;
                  break;
               case SELL_SETUP:
                  if ( Chk_sell[cnt] == true ) {
                     if ( Bund_sell[cnt] == true ) {
                        count[1][cnt]++;
                        if ( count[1][cnt] >= Keizoku_time ) {
                           Sell[cnt] = SELL_B_WALK;
                        }
                     }
                     else {
                        count[1][cnt] = 0;
                        Sell[cnt] = SELL_SETUP;
                     }
                  }                    
                  else  {
                     Sell[cnt] = SELL_SETUP_CANCEL;
                  }
                  break;
               case SELL_B_WALK:
                  if ( Chk_sell[cnt] == true ) {
                     if ( Bund_sell[cnt] == true ) {
                        Sell[cnt] = SELL_B_WALK;
                        count[1][cnt]++;		         
                     }                    
                     else {
                        Sell[cnt] = SELL_B_WALK_CANCEL;
                        count[1][cnt] = 0;		         
                     }                    
                  }
                  else  {                
                     Sell[cnt] = SELL_B_WALK_CANCEL;
                     count[1][cnt] = 0;		         
                  }
                  break;
            }     
            if ( O_Sell[cnt] != Sell[cnt] ) {
			      switch(Sell[cnt])	{
					   case SELL_SETUP:
						   if ( Symbol() == symbol_chk[cnt] ) {
						      DownReadyArrow[i] = High[i] + (Point * Signal_Pos);
						   }
						   Kind[cnt] = SELL_SETUP;
						   break;
					   case SELL_B_WALK:
						   if ( Symbol() == symbol_chk[cnt] ) {
						      DownStartArrow[i] = High[i] + (Point * Signal_Pos);
						   }
						   Kind[cnt] = SELL_B_WALK;
						   break;
					   case SELL_SETUP_CANCEL:
						   if ( Symbol() == symbol_chk[cnt] ) {
						      DownCancelArrow[i] = Low[i] -(Point * Signal_Pos);
						   }
						   Kind[cnt] = SELL_SETUP_CANCEL;
                     Sell[cnt] = NO_POSITON;
						   break;
					   case SELL_B_WALK_CANCEL:
						   if ( Symbol() == symbol_chk[cnt] ) {
						      DownEndArrow[i] = Low[i] -(Point * Signal_Pos);
						   }
						   Kind[cnt] = SELL_B_WALK_CANCEL;
                     Sell[cnt] = NO_POSITON;
						   break;
				   }
               O_Sell[cnt] = Sell[cnt];
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

      for ( cnt = 0; cnt < symbol_max; cnt++ ) {      
         if (symbol_chk[cnt] == false )   {
            continue;
         }
         else
            message = "";              {
            if (Emailflag== true) { 
               switch(Kind[cnt]) {
				      case BUY_SETUP:
				      if ( Email_Setup_ON == true ) {
            	      message= "Super Bollin Buy Infomation"+"\r\n"+"準備開始"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n "+"現在値 = "+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
            	      message = message + "\r\n " + "MA = "+DoubleToStr(MA[cnt],pos[cnt]-1);
               	   message = message + "\r\n " + "+1σ = "+DoubleToStr(sigma1_Uper1[cnt],pos[cnt]-1);
               	   message = message + "\r\n " + "+2σ = "+DoubleToStr(sigma2_Uper[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "+3σ = "+DoubleToStr(sigma3_Uper[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),(-1)*Chikou_Idou),pos[cnt]-1);
					   }
					   break;


				   case BUY_B_WALK:
            	   message= "Super Bollin Buy Infomation"+"\r\n"+"バンドウォーク開始"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"現在値 = "+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
            	   message = message + "\r\n " + "MA = "+DoubleToStr(MA[cnt],pos[cnt]-1);
               	message = message + "\r\n " + "+1σ = "+DoubleToStr(sigma1_Uper1[cnt],pos[cnt]-1);
               	message = message + "\r\n " + "+2σ = "+DoubleToStr(sigma2_Uper[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "+3σ = "+DoubleToStr(sigma3_Uper[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),(-1)*Chikou_Idou),pos[cnt]-1);
					   break;
				   case BUY_SETUP_CANCEL:
				      if ( Email_Setup_ON == true ) {
            	      message= "Super Bollin Buy Infomation"+"\r\n"+"キャンセル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"現在値 = "+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
            	      message = message + "\r\n " + "MA = "+DoubleToStr(MA[cnt],pos[cnt]-1);
               	   message = message + "\r\n " + "+1σ = "+DoubleToStr(sigma1_Uper1[cnt],pos[cnt]-1);
               	   message = message + "\r\n " + "+2σ = "+DoubleToStr(sigma2_Uper[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "+3σ = "+DoubleToStr(sigma3_Uper[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),(-1)*Chikou_Idou),pos[cnt]-1);
					   }
					   break;
				   case BUY_B_WALK_CANCEL:
            	   message= "Super Bollin Buy Infomation"+"\r\n"+"バンドウォーク終了"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"現在値 = "+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
            	   message = message + "\r\n " + "MA = "+DoubleToStr(MA[cnt],pos[cnt]-1);
               	message = message + "\r\n " + "+1σ = "+DoubleToStr(sigma1_Uper1[cnt],pos[cnt]-1);
               	message = message + "\r\n " + "+2σ = "+DoubleToStr(sigma2_Uper[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "+3σ = "+DoubleToStr(sigma3_Uper[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),(-1)*Chikou_Idou),pos[cnt]-1);
					   break;
				   case SELL_SETUP:
				      if ( Email_Setup_ON == true ) {
            	      message= "Super Bollin Sell Infomation"+"\r\n"+"準備開始"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"現在値 = "+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
            	      message = message + "\r\n " + "MA = "+DoubleToStr(MA[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "-1σ = "+DoubleToStr(sigma1_Lower1[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "-2σ = "+DoubleToStr(sigma2_Lower[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "-3σ = "+DoubleToStr(sigma3_Lower[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),(-1)*Chikou_Idou),pos[cnt]-1);
					   }
					   break;
				   case SELL_B_WALK:
            	   message= "Super Bollin Sell Infomation"+"\r\n"+"バンドウォーク開始"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"現在値 = "+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
            	   message = message + "\r\n " + "MA = "+DoubleToStr(MA[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "-1σ = "+DoubleToStr(sigma1_Lower1[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "-2σ = "+DoubleToStr(sigma2_Lower[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "-3σ = "+DoubleToStr(sigma3_Lower[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),(-1)*Chikou_Idou),pos[cnt]-1);
					   break;
				   case SELL_SETUP_CANCEL:
				      if ( Email_Setup_ON == true ) {
            	      message= "Super Bollin Sell Infomation"+"\r\n"+"キャンセル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"現在値 = "+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
            	      message = message + "\r\n " + "MA = "+DoubleToStr(MA[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "-1σ = "+DoubleToStr(sigma1_Lower1[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "-2σ = "+DoubleToStr(sigma2_Lower[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "-3σ = "+DoubleToStr(sigma3_Lower[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),(-1)*Chikou_Idou),pos[cnt]-1);
					   }
					   break;
				   case SELL_B_WALK_CANCEL:
            	   message= "Super Bollin Sell Infomation"+"\r\n"+"バンドウォーク終了"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"現在値 = "+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1);
            	   message = message + "\r\n " + "MA = "+DoubleToStr(MA[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "-1σ = "+DoubleToStr(sigma1_Lower1[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "-2σ = "+DoubleToStr(sigma2_Lower[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "-3σ = "+DoubleToStr(sigma3_Lower[cnt],pos[cnt]-1);
            	   message = message + "\r\n " + "遅行スパン = "+DoubleToStr(Chikou[cnt],pos[cnt]-1);
            	      message = message + "\r\n " + (-1)* Chikou_Idou+ "本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),(-1)*Chikou_Idou),pos[cnt]-1);
					   break;
               }
               if ( Kind[cnt]!= 0 ) SendMail("スーパーボリンジャー "+"["+symbol_chk[cnt]+"]["+Period()+"]",message);
            }        

            if (Alertflag== true) {
 			      switch(Kind[cnt])	{
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
            }
         }
      }
      Alertflag = false;
      Emailflag = false;
      Timeflg = false;
   }

  return(0);
}







