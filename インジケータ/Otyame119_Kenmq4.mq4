//+------------------------------------------------------------------+
//|                              Otyame119_Ken.mq4  |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright   "2017,Otyame Trader"
#property description "Otyame119_Ken.mq4"
#property strict

#property indicator_buffers 4

#property indicator_chart_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Lime
#property indicator_color4 Lime

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4


//---- buffers
double UpArrow[];
double DownArrow[];
double UEndArrow[];
double DEndArrow[];

string message;

extern bool AlertON=false;           //アラート表示　
extern bool EmailON=true;           //メール送信
extern bool Redraw = false;
extern bool Katamuki_Check = true;
extern int Signal_Pos = 60;
extern string _MA = "ascending order";
extern   bool P1_Check1 = false;
extern   int P1_Period =   60;
extern   int P1_MAPeriod1 =  24;
extern   int P1_MAMethod1 =  0;
extern   int P1_MAPeriod2 =  6;
extern   int P1_MAMethod2 =  0;
extern int P1_Compare_Period = 60;
extern bool P1_Katamuki_Check = true;

//
extern   bool P2_Check1 = true;
extern   int P2_Period =   30;
extern   int P2_MAPeriod1 =  24;
extern   int P2_MAMethod1 =  0;
extern   int P2_MAPeriod2 =  6;
extern   int P2_MAMethod2 =  0;
extern int P2_Compare_Period = 60;
extern bool P2_Katamuki_Check = true;
//
extern   bool P3_Check1 = true;
extern   int P3_Period =   15;
extern   int P3_MAPeriod1 =  24;
extern   int P3_MAMethod1 =  0;
extern   int P3_MAPeriod2 =  6;
extern   int P3_MAMethod2 =  0;
extern int P3_Compare_Period = 60;
extern bool P3_Katamuki_Check = true;
//
extern   bool P4_Check1 = true;
extern   int P4_Period =   5;
extern   int P4_MAPeriod1 =  24;
extern   int P4_MAMethod1 =  0;
extern   int P4_MAPeriod2 =  6;
extern   int P4_MAMethod2 =  0;
extern int P4_Compare_Period = 60;
extern bool P4_Katamuki_Check = true;

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


bool Cross_Check[4];
int MAPeriod[4];
int MAPeriod1[4];
int MAPeriod2[4];
int MAMethod1[4];
int MAMethod2[4];
int MAPerid_Time[4];
bool Katamuki_Check[4];
int Compare_Period[4];

datetime TimeOld = D'1970.01.01 00:00:00';

int Perfect_order[10];               // 今回（０：不成立、１：上昇成立、2:下降成立）
int O_Perfect_order[10];               // 今回（０：不成立、１：上昇成立、2:下降成立）
int Kind[10];

double pos_chk;

int pos[10];
bool symbol_true[10];
int symbol_max;
string symbol_chk[10];
int symbol_cnt;
bool Timeflg = false;
double MA_0[10][4];
double MA_1[10][4];
bool up[10];
bool down[10];
int Chk_candle[4];

int init()
{

//---- indicators

   int i;

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,241);
   SetIndexBuffer(0,UpArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,242);
   SetIndexBuffer(1,DownArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,242);
   SetIndexBuffer(2,UEndArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,241);
   SetIndexBuffer(3,DEndArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
	IndicatorShortName("Otyame119_Ken.mq4");
   
   MA_Check[0] = P1_Check1;
   MAPeriod[0] = P1_Period;
   MAPeriod1[0] = P1_MAPeriod1;
   MAMethod1[0] = P1_MAMethod1;
   MAPeriod2[0] = P1_MAPeriod2;
   MAMethod2[0] = P1_MAMethod2;
   Compare_Period[0] = P1_Compare_Period;
   Katamuki_Check[0] = P1_Katamuki_Check;

   MA_Check[1] = P2_Check1;
   MAPeriod[1] = P2_Period;
   MAPeriod1[1] = P2_MAPeriod1;
   MAMethod1[1] = P2_MAMethod1;
   MAPeriod2[1] = P2_MAPeriod2;
   MAMethod2[1] = P2_MAMethod2;
   Compare_Period[1] = P2_Compare_Period;
   Katamuki_Check[1] = P2_Katamuki_Check;

    MA_Check[2] = P3_Check1;
   MAPeriod[2] = P3_Period;
   MAPeriod1[2] = P3_MAPeriod1;
   MAMethod1[2] = P3_MAMethod1;
   MAPeriod2[2] = P3_MAPeriod2;
   MAMethod2[2] = P3_MAMethod2;
   Compare_Period[2] = P3_Compare_Period;
   Katamuki_Check[2] = P3_Katamuki_Check;

   MA_Check[3] = P4_Check1;
   MAPeriod[3] = P4_Period;
   MAPeriod1[3] = P4_MAPeriod1;
   MAMethod1[3] = P4_MAMethod1;
   MAPeriod2[3] = P4_MAPeriod2;
   MAMethod2[3] = P4_MAMethod2;
   Compare_Period[3] = P4_Compare_Period;
   Katamuki_Check[3] = P4_Katamuki_Check;

  
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
   for ( i = 0 ; i < 4 ; i++ )   {
      if ( MA_Check[i] == true ) {
         if ( Katamuki_Check[i] == true ) {
            Chk_candle[i] = Compare_Period[i] / MAPeriod[i];
         }
           







   switch(Period())  {
      case PERIOD_M5 :
			Chk_candle = Compare_Period / PERIOD_M1 ;
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( PO_Check[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_M5 ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_M15 ;
                     break;
                  case 3:
                     MAPerid_Time[i]= MAPeriod[i] * PERIOD_H1 ;
                     break;
                  case 4:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H4 ;
                     break;
                  case 5:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 ;
                     break;
                  case 6:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 ;
                     break;
                  case 7:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4 ;
                     break;
                  case 8:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4 * 12 ;
                     break;
                  default:
                     PO_Check[i] = false;
                     break;
               }
            }
         }
 
         break;
      case PERIOD_M5:
         if ( Compare_Period < PERIOD_M5 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_M5 ;
         }      
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( PO_Check[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_M15 / Period() ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H1 / Period()  ;
                     break;
                  case 3:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H4 / Period()  ;
                     break;
                  case 4:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 / Period()  ;
                     break;
                  case 5:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 / Period()  ;
                     break;
                  case 6:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4/ Period()  ;
                     break;
                  case 7:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4 * 12/ Period() ;
                     break;
                  default:
                     PO_Check[i] = false;
                     break;
               }
            }
         }
         break;
      case PERIOD_M15:
          if ( Compare_Period < PERIOD_M15 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_M15 ;
         }      
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( PO_Check[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H1 / Period()  ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H4 / Period()  ;
                     break;
                  case 3:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 / Period()  ;
                     break;
                  case 4:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 / Period()  ;
                     break;
                  case 5:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4/ Period()  ;
                     break;
                  case 6:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4* 12/ Period() ;
                     break;
                  default:
                     PO_Check[i] = false;
                     break;
               }
            }
         }
         break;
      case PERIOD_H1:
          if ( Compare_Period < PERIOD_H1 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_H1 ;
         }      
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( PO_Check[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H4 / Period()  ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 / Period()  ;
                     break;
                  case 3:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 / Period()  ;
                     break;
                  case 4:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4/ Period()  ;
                     break;
                  case 5:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4* 12/ Period() ;
                     break;
                  default:
                     PO_Check[i] = false;
                     break;
               }
            }
         }
         break;
      case PERIOD_H4:
         if ( Compare_Period < PERIOD_H4 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_H4 ;
         }      
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( PO_Check[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 / Period()  ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 / Period()  ;
                     break;
                  case 3:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4/ Period()  ;
                     break;
                  case 4:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4* 12/ Period() ;
                     break;
                  default:
                     PO_Check[i] = false;
                     break;
               }
            }
         }
         break;
        case PERIOD_D1:
         if ( Compare_Period < PERIOD_D1 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_D1 ;
         }      
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( PO_Check[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 / Period()  ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4/ Period()  ;
                     break;
                  case 3:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4* 12/ Period() ;
                     break;
                  default:
                     PO_Check[i] = false;
                     break;
               }
            }
         }
         break;
      default:
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( PO_Check[i] == true ) {
              PO_Check[i] = false;
            }
         }
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
   int cnt1;
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
       
      int start = 0;   
      for ( cnt = 0 ;cnt < 8 ; cnt ++) {
         if (PO_Check[cnt] == false ) {
            start++;
         }
         else break;
      } 
         count = 0;   
      for ( cnt = 0 ;cnt < 8 ; cnt ++) {
         if (PO_Check[cnt] == true ) {
            count++;
         }
     }    
      for ( symbol_cnt = 0; symbol_cnt < symbol_max ; symbol_cnt++ ) {
         if ( symbol_true[symbol_cnt] == false ) {
            continue ;
         }
         for(i= limit-1;i>=1;i--){
            for ( cnt = 0; cnt < 8 ; cnt++) {
               if ( PO_Check[cnt] == true ) {
                  MA_0[symbol_cnt][cnt] = NormalizeDouble(iMA(symbol_chk[symbol_cnt],0,MAPerid_Time[cnt],0,MAMethod[cnt],PRICE_CLOSE,i),pos[symbol_cnt]);
                  MA_1[symbol_cnt][cnt] = NormalizeDouble(iMA(symbol_chk[symbol_cnt],0,MAPerid_Time[cnt],0,MAMethod[cnt],PRICE_CLOSE,i+Chk_candle),pos[symbol_cnt]);
               }
            }
            if ( start == 7 || count < 2) {
               Perfect_order[symbol_cnt] = 0;
               up[symbol_cnt] = false;
               down[symbol_cnt] = false;
            }
            else  { 
               up[symbol_cnt] = true;            
               for ( cnt1 = start; cnt1 < 7 ; cnt1++) {
                  for( cnt = cnt1+1 ; cnt < 8 ;cnt++) {
                     if ( PO_Check[cnt] == true ) {
                        if ( MA_0[symbol_cnt][cnt1] <= MA_0[symbol_cnt][cnt] ) {
                        
                           up[symbol_cnt]= false;
                           break;
                        }
                     }            
                  }
                  if ( up[symbol_cnt] == false )  break; 
               }
               down[symbol_cnt] = true;            
               for ( cnt1 = start; cnt1 < 7 ; cnt1++) {
                  for( cnt = cnt1+1 ; cnt < 8 ;cnt++) {
                     if ( PO_Check[cnt] == true ) {
                        if ( MA_0[symbol_cnt][cnt1] >= MA_0[symbol_cnt][cnt] ) {
                           down[symbol_cnt]= false;
                           break;
                        }
                     }            
                  }
                  if ( down[symbol_cnt] == false )  break; 
               }
               int y;
               if ( Katamuki_Check == true ) {
						if ( up[symbol_cnt] == true ) {
                  	for ( y = 0 ; y < 8 ; y++) {
                     	if (PO_Check[y] == true ) {
                        	if ( MA_1[symbol_cnt][y] > MA_0[symbol_cnt][y] ) {
                           	up[symbol_cnt] = false;
                       	 		break;
                        	}
                     	}
                  	}
						}
						if ( down[symbol_cnt] == true ) {
                  	for ( y = 0 ; y < 8 ; y++) {
                     	if (PO_Check[y] == true ) {
                        	if ( MA_1[symbol_cnt][y] < MA_0[symbol_cnt][y] ) {
                           	down[symbol_cnt] = false;
                           	break;
                        	}
                     	}
                  	}
               	}                      
					}
               Perfect_order[symbol_cnt] = 0;
               if ( up[symbol_cnt] == true ) { 
                  Perfect_order[symbol_cnt] = 1;                            //MACDルール不成立
               }
               else  if ( down[symbol_cnt] == true)  {
                  Perfect_order[symbol_cnt] = 2;                            //MACDルール下降成立
               }
            
            }
            switch(O_Perfect_order[symbol_cnt])  {
            case 0:
               switch(Perfect_order[symbol_cnt]) {
                  case 0:
                     Kind[symbol_cnt] = 0;
                     break;
                  case 1:
                     if ( symbol_chk[symbol_cnt] == Symbol()) {
                        UpArrow[i] = Low[i] - Point * Signal_Pos;
                     }
                     Kind[symbol_cnt] = 1;
                     break;
                  case 2:
                     if ( symbol_chk[symbol_cnt] == Symbol()) {
                        DownArrow[i] = High[i] + Point * Signal_Pos;
                     }
                     Kind[symbol_cnt] = 2;
                     break;
               }
               break;
            case 1:
               switch(Perfect_order[symbol_cnt]) {
                  case 0:
                     if ( symbol_chk[symbol_cnt] == Symbol()) {
                        UEndArrow[i] = High[i] + Point * Signal_Pos;
                     }
                     Kind[symbol_cnt] = 3;                  
                     break;
                  case 1:
                        Kind[symbol_cnt] = 0;
                     break;
                  case 2:
                     if ( symbol_chk[symbol_cnt] == Symbol()) {
                        DownArrow[i] = High[i] + Point * Signal_Pos;
                     }
                     Kind[symbol_cnt] = 2;
                     break;
               }
               break;
            case 2:
               switch(Perfect_order[symbol_cnt]) {
                  case 0:
                     if ( symbol_chk[symbol_cnt] == Symbol()) {
                        DEndArrow[i] = Low[i] - Point * Signal_Pos;
                     }
                     Kind[symbol_cnt] = 4;
                     break;
                  case 1:
                     if ( symbol_chk[symbol_cnt] == Symbol()) {
                        UpArrow[i] = Low[i] - Point * Signal_Pos;
                     }
                     Kind[symbol_cnt] = 1;
                     break;
                  case 2:
                     Kind[symbol_cnt] = 0;
                     break;
               }
               break;
            }
            
//            Print("TIme=",TimeToStr(Time[i],TIME_DATE| TIME_MINUTES));
//            Print("symbol = ",symbol_chk[symbol_cnt]);
//            Print("Kind = ",Kind[symbol_cnt]);
//            Print("O_P = ",O_Perfect_order[symbol_cnt]);
//            Print("Kind = ",Perfect_order[symbol_cnt]);
                        
 
            O_Perfect_order[symbol_cnt] = Perfect_order[symbol_cnt];                              
         
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
         for ( symbol_cnt = 0; symbol_cnt < symbol_max ; symbol_cnt++ ) {
            if ( symbol_true[symbol_cnt] == false ) {
               continue ;
            }
            if (Emailflag== true) {
               switch(Kind[symbol_cnt]) {
                  case 1:
                     message= "銘柄："+symbol_chk[symbol_cnt]+"\r\n"+"時間軸："+IntegerToString(Period())+"\r\n" + "パーフェクトオーダー：上昇 \r\n 条件：成立 \r\n 現在価格："+DoubleToStr(iOpen(symbol_chk[symbol_cnt],Period(),0),pos[symbol_cnt]-1);
                     break;
                  case 2:
                     message= "銘柄："+symbol_chk[symbol_cnt]+"\r\n"+"時間軸："+IntegerToString(Period())+"\r\n" + "パーフェクトオーダー：：下降 \r\n 条件：成立 \r\n 現在価格："+DoubleToStr(iOpen(symbol_chk[symbol_cnt],Period(),0),pos[symbol_cnt]-1);
                     break;
                  case 3:
                     message= "銘柄："+symbol_chk[symbol_cnt]+"\r\n"+"時間軸："+IntegerToString(Period())+"\r\n" + "パーフェクトオーダー：上昇 \r\n 条件：終了 \r\n 現在価格："+DoubleToStr(iOpen(symbol_chk[symbol_cnt],Period(),0),pos[symbol_cnt]-1);
                     break;
                  case 4:
                     message= "銘柄："+symbol_chk[symbol_cnt]+"\r\n"+"時間軸："+IntegerToString(Period())+"\r\n" + "パーフェクトオーダー：下降 \r\n 条件：終了 \r\n 現在価格："+DoubleToStr(iOpen(symbol_chk[symbol_cnt],Period(),0),pos[symbol_cnt]-1);
                     break;
               }
               string mes;
               for ( cnt = 0 ; cnt < 8 ; cnt++) {
                  if ( PO_Check[cnt] == true ) {
                     switch(MAMethod[cnt]) {
                        case 0:
                           mes = "SMA";
                           break;
                        case 1:
                           mes = "EMA";
                           break;
                        case 2:
                           mes = "SMMA";
                           break;
                        case 3:
                           mes = "WMA";
                           break;
                     }
                     if ( Katamuki_Check == true ) {
                        message = message +  "\r\n" + IntegerToString(MAPerid_Time[cnt]) + mes +" = " + DoubleToStr(MA_1[symbol_cnt][cnt])+","+DoubleToStr(MA_0[symbol_cnt][cnt]); 
                     }
                     else
                     {
                        message = message +  "\r\n" + IntegerToString(MAPerid_Time[cnt]) + mes +" = " + DoubleToStr(MA_0[symbol_cnt][cnt]); 
                     }
                  }

               }
               if ( Kind[symbol_cnt] != 0  ) SendMail("パーフェクトオーダー "+"["+symbol_chk[symbol_cnt]+"]["+IntegerToString(Period())+"]",message);
            }
            if (Alertflag== true) {
               switch(Kind[symbol_cnt]) {
                  case 1:
                     Alert("Perfect Order  BUY Signal ",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[symbol_cnt],Period(),0),pos[symbol_cnt]-1));
                     break;
                  case 2:
                     Alert("Perfect Orde SELL Signal ",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[symbol_cnt],Period(),0),pos[symbol_cnt]-1));
                     break;
                  case 3:
                     Alert("Perfect Orde  BUY Signal End",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[symbol_cnt],Period(),0),pos[symbol_cnt]-1));
                     break;
                  case 4:
                     Alert("Perfect Orde  SELL Signal End",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk[symbol_cnt],Period(),0),pos[symbol_cnt]-1));
               }
   
            }
   
         }
   }
   Alertflag = false;
   Emailflag = false;
     Timeflg = false;

   return(0);
}














   
    
