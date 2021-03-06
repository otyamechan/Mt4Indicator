//+------------------------------------------------------------------+
//|                       Otyame007_Macd_rule_symbol.mq4(V1.1)       |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Otyame"
#property link      ""

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
extern string _MACD = "MACD";
extern int MACD_Period = 20;              //MACD 短期
extern int MACD_Method = 3;         //MACD ＷＭＡ
extern int Signal_MAPeriod = 5;      //MACD MA期間
extern int Signal_MAMethod = 3;      //MACD

extern string _MA = "MA";
extern int  MA_Period= 20;
extern int MA_Method = 0;

extern bool JissenKai =true;        //実践会フラグ
extern int Compare_Period = 60;
extern int Signal_Pos = 20;
extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 10;
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
bool sell = true;
bool buy = true;



int  FastMAPeriod;
int SlowMAPeriod;
int SignalMAPeriod;
int MAPeriod;

int MACD_Rule[10];               // 今回（０：不成立、１：上昇成立、2:下降成立）
int O_MACD_Rule[10];               // 今回（０：不成立、１：上昇成立、2:下降成立）
bool symbol_true[10];
int symbol_max;
string symbol_chk[10];
double chk_pips_MACD[10];
double chk_pips_MA[10];
int pos[10];
int	Chk_candle;
int Kind[10];                    // メッセージ要（1:上昇成立、2:下降成立,3:上昇終了、4:下降終了）

bool Timeflg = false;
datetime TimeOld;

int init()
{
   int cnt = 0;
   int i = 0;
   int rtn = 0;
   double pos_chk;
//---- indicators
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
   SetIndexBuffer(2,UEndArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,DEndArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);

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
   switch(Period())  {
      case PERIOD_M1:
			Chk_candle = Compare_Period / PERIOD_M1 ;
         FastMAPeriod = MACD_Period * PERIOD_M5 /Period();
         SlowMAPeriod = MACD_Period * PERIOD_M15 / Period();
         SignalMAPeriod =Signal_MAPeriod * PERIOD_M5 /Period();
         MAPeriod = MA_Period * PERIOD_M15 / Period();
         break;
      case PERIOD_M5:
         if ( Compare_Period < PERIOD_M5 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_M5 ;
         }      
         FastMAPeriod = MACD_Period * PERIOD_M15 /Period();
         SlowMAPeriod = MACD_Period * PERIOD_H1 / Period();
         SignalMAPeriod =Signal_MAPeriod * PERIOD_M15 /Period();
         MAPeriod = MA_Period * PERIOD_H1 / Period();
         
         break;
      case PERIOD_M15:
         if ( Compare_Period < PERIOD_M15 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_M15 ;
         }      
         FastMAPeriod = MACD_Period * PERIOD_H1 /Period();
         SlowMAPeriod = MACD_Period * PERIOD_H4 / Period();
         SignalMAPeriod =Signal_MAPeriod * PERIOD_H1 /Period();
         MAPeriod = MA_Period * PERIOD_H4 / Period();
         break;
      case PERIOD_H1:
         if ( Compare_Period < PERIOD_H1 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_H1 ;
         }      
         if ( JissenKai == false ) {
            FastMAPeriod = MACD_Period * PERIOD_H4 / Period();
            SlowMAPeriod = MACD_Period * PERIOD_D1 / Period();
            SignalMAPeriod = Signal_MAPeriod * PERIOD_H4 /Period();
            MAPeriod = MA_Period * PERIOD_D1 / Period();
         }
         else  {
               FastMAPeriod = MACD_Period;
               SlowMAPeriod = MACD_Period * PERIOD_H4 /Period();
               SignalMAPeriod= 8;
               MAPeriod = 52;
               MA_Method = 3;
         }                  
         break;
      case PERIOD_H4:
         if ( Compare_Period < PERIOD_H4 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_H4 ;
         }      
         FastMAPeriod = MACD_Period * PERIOD_D1 / Period();
         SlowMAPeriod = MACD_Period * (PERIOD_D1*5) / Period();
         SignalMAPeriod =Signal_MAPeriod * PERIOD_D1 / Period();
         MAPeriod = MA_Period * PERIOD_D1 / Period();
         break;
      case PERIOD_D1:
         if ( Compare_Period < PERIOD_D1 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_D1 ;
         }      
         FastMAPeriod = MACD_Period * (PERIOD_D1*5) / Period();
         SlowMAPeriod = MACD_Period * (PERIOD_D1*5*4) / Period();
         SignalMAPeriod =Signal_MAPeriod * (PERIOD_D1*5) / Period();
         MAPeriod = MA_Period * (PERIOD_D1*5*4) / Period();
         break;
      case PERIOD_W1:
         if ( Compare_Period < PERIOD_W1 ) {
			   Chk_candle = 1;
         }
         else  {
			   Chk_candle = Compare_Period / PERIOD_W1 ;
         }      
         FastMAPeriod = MACD_Period * 4;
         SlowMAPeriod =MACD_Period * 48;
         SignalMAPeriod =Signal_MAPeriod * 4;
         MAPeriod = MA_Period * 48;
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
    int rtn = 0;
   double MACD_0[10],MACD_1[10];
   double MA_0[10],MA_1[10];
   double MA_0_J[10],MA_1_J[10];
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
//      if (counted_bars > 0) counted_bars--;
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

            MACD_0[cnt] = iCustom(symbol_chk[cnt],0,"MACD++",FastMAPeriod,SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",MACD_Method,SignalMAPeriod,Signal_MAMethod,false,0,1,i);
            MACD_1[cnt] = iCustom(symbol_chk[cnt],0,"MACD++",FastMAPeriod,SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",MACD_Method,SignalMAPeriod,Signal_MAMethod,false,0,1,i+Chk_candle);
            MA_0[cnt] = iMA(symbol_chk[cnt],0,MAPeriod,0,MA_Method,PRICE_CLOSE,i);
            MA_1[cnt] = iMA(symbol_chk[cnt],0,MAPeriod,0,MA_Method,PRICE_CLOSE,i+Chk_candle);
            if ( (Period() == PERIOD_H1) && (JissenKai == True) ) {
               MA_0_J[cnt] = iMA(symbol_chk[cnt],0,480,0,0,PRICE_CLOSE,i);
               MA_1_J[cnt] = iMA(symbol_chk[cnt],0,480,0,0,PRICE_CLOSE,i+Chk_candle);
            }
         if (( MACD_1[cnt] - MACD_0[cnt] ) > 0)   {        //MACD下降中
            if (( MA_1[cnt] - MA_0[cnt] ) >= 0) {                     //MA下降中
               MACD_Rule[cnt] = 2;                               //MACDルール下降中と成立
            }
            else  {
               MACD_Rule[cnt] = 0;                            //MACDルール下降成立
            }
         }
         else if (( MACD_1[cnt] - MACD_0[cnt] ) < 0 )  {  //MACD上昇中
            if (( MA_1[cnt] - MA_0[cnt] ) <= 0 ) {                //MAは下降中
               MACD_Rule[cnt] = 1;                                     //MACDルール不成立
            }
            else  {
               MACD_Rule[cnt] = 0;                                     //MACDルール上昇成立
            }
         }
         else if ((MACD_1[cnt] - MACD_0[cnt] ) ==0 ) { 
            if ((  MA_1[cnt] - MA_0[cnt] ) > 0)    {  
               MACD_Rule[cnt] = 2;                            //MACDルール不成立
            }
            else if (( MA_1[cnt] - MA_0[cnt] ) < 0 ){
               MACD_Rule[cnt] = 1;                            //MACDルール不成立
            }
            else  {
               MACD_Rule[cnt] = 0;                                     //MACDルール上昇成立
            }

         }

            switch(O_MACD_Rule[cnt])  {
               case 0:
                  switch(MACD_Rule[cnt]) {
                     case 0:
                        Kind[cnt] = 0;
                        break;
                     case 1:
                        Kind[cnt] = 1;
                        break;
                     case 2:
                        Kind[cnt] = 2;
                        break;
                     }
                     break;
               case 1:
                     switch(MACD_Rule[cnt]) {
                     case 0:
                        Kind[cnt] = 3;                  
                        break;
                     case 1:
                        Kind[cnt] = 0;
                        break;
                     case 2:
                           Kind[cnt] = 2;
                           break;
                     }
                     break;
                case 2:
                   switch(MACD_Rule[cnt]) {
                     case 0:
                        Kind[cnt] = 4;
                        break;
                     case 1:
                        Kind[cnt] = 1;
                        break;
                     case 2:
                        Kind[cnt] = 0;
                        break;
                  }
                  break;
            }
            if ( Symbol() == symbol_chk[cnt] ) {
               switch(O_MACD_Rule[cnt])  {
                  case 0:
                     switch(MACD_Rule[cnt]) {
                        case 1:
                           UpArrow[i] = iLow(symbol_chk[cnt],Period(),i) - Point * Signal_Pos;
                           break;
                        case 2:
                           DownArrow[i] = iHigh(symbol_chk[cnt],Period(),i) + Point * Signal_Pos;
                           break;
                     }    
                     break;
                 case 1:
                     switch(MACD_Rule[cnt]) {
                        case 0:
                           UEndArrow[i] = iHigh(symbol_chk[cnt],Period(),i) + Point * Signal_Pos;
                           break;
                        case 2:
                           DownArrow[i] =iHigh(symbol_chk[cnt],Period(),i) + Point * Signal_Pos;
                           break;
                     }
                     break;
                  case 2:
                     switch(MACD_Rule[cnt]) {
                        case 0:
                           DEndArrow[i] = iLow(symbol_chk[cnt],Period(),i) - Point * Signal_Pos;
                           break;
                        case 1:
                           UpArrow[i] = iLow(symbol_chk[cnt],Period(),i) - Point * Signal_Pos;
                           break;
                     }
                     break;
                }
            }
            O_MACD_Rule[cnt] = MACD_Rule[cnt];                              
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
         for ( cnt = 0 ; cnt < symbol_max ; cnt++) {
            if ( symbol_true[cnt] == false ) {
               continue;
            }
            switch(Kind[cnt]) {
               case 1:
                  message= "銘柄："+symbol_chk[cnt]+"\r\n"+"時間軸："+Period()+"\r\n" + "トレンド：上昇 \r\n 条件：成立 \r\n 現在価格："+iOpen(symbol_chk[cnt],Period(),0);
                  message = message + " \r\n MACD("+(Chk_candle+1)+"本前,1本前,差） = "+MACD_1[cnt]+","+MACD_0[cnt]+","+(MACD_0[cnt]-MACD_1[cnt]);
                  message = message + " \r\n MA("+(Chk_candle+1)+"本前,1本前,差） = "+MA_1[cnt]+","+MA_0[cnt]+","+(MA_0[cnt]-MA_1[cnt]);
                  break;
               case 2:
                  message= "銘柄："+symbol_chk[cnt]+"\r\n"+"時間軸："+Period()+"\r\n" + "トレンド：下降 \r\n 条件：成立 \r\n 現在価格："+iOpen(symbol_chk[cnt],Period(),0);
                  message = message + " \r\n MACD("+(Chk_candle+1)+"本前,1本前,差） = "+MACD_1[cnt]+","+MACD_0[cnt]+","+(MACD_0[cnt]-MACD_1[cnt]);
                  message = message + " \r\n MA("+(Chk_candle+1)+"本前,1本前,差） = "+MA_1[cnt]+","+MA_0[cnt]+","+(MA_0[cnt]-MA_1[cnt]);
                  break;
               case 3:
                  message= "銘柄："+symbol_chk[cnt]+"\r\n"+"時間軸："+Period()+"\r\n" + "トレンド：上昇 \r\n 条件：終了 \r\n 現在価格："+iOpen(symbol_chk[cnt],Period(),0);
                  message = message + " \r\n MACD("+(Chk_candle+1)+"本前,1本前,差） = "+MACD_1[cnt]+","+MACD_0[cnt]+","+(MACD_0[cnt]-MACD_1[cnt]);
                  message = message + " \r\n MA("+(Chk_candle+1)+"本前,1本前,差） = "+MA_1[cnt]+","+MA_0[cnt]+","+(MA_0[cnt]-MA_1[cnt]);
                  break;
               case 4:
                  message= "銘柄："+symbol_chk[cnt]+"\r\n"+"時間軸："+Period()+"\r\n" + "トレンド：下降 \r\n 条件：終了 \r\n 現在価格："+iOpen(symbol_chk[cnt],Period(),0);
                  message = message + " \r\n MACD("+(Chk_candle+1)+"本前,1本前,差） = "+MACD_1[cnt]+","+MACD_0[cnt]+","+(MACD_0[cnt]-MACD_1[cnt]);
                  message = message + " \r\n MA("+(Chk_candle+1)+"本前,1本前,差） = "+MA_1[cnt]+","+MA_0[cnt]+","+(MA_0[cnt]-MA_1[cnt]);
                  break;
            }
            if ( (Period() ==  PERIOD_H1) && (JissenKai == True) ) {
               if ( Kind[cnt] == 1 ) {
               if ((MA_1_J[cnt] - MA_0_J[cnt]) > 0 ) {
                     message = message + "\r\n" + "日足MAとの関係：逆行（日足ＭＡ下降中）";
                     message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J[cnt]+","+MA_0_J[cnt]+","+(MA_0_J[cnt]-MA_1_J[cnt]);

                  }
               else if ((MA_1_J[cnt] - MA_0_J[cnt]) <= ( -1 * chk_pips_MA[cnt]) ) {
                     message = message + "\r\n" + "日足MAとの関係：順行（日足ＭＡ上昇中）";
                     message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J[cnt]+","+MA_0_J[cnt]+","+(MA_0_J[cnt]-MA_1_J[cnt]);
                  }
                  else  {              
                     message = message + "\r\n" + "日足MAとの関係：中立（日足ＭＡ中立）";
                     message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J[cnt]+","+MA_0_J[cnt]+","+(MA_0_J[cnt]-MA_1_J[cnt]);
                  }
               }
               else if ( Kind[cnt] == 2 ) {
               if ((MA_1_J[cnt] - MA_0_J[cnt]) >= chk_pips_MA[cnt] ) {
                     message = message + "\r\n" + "日足MAとの関係：順行（日足ＭＡ下降中）";
                     message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J[cnt]+","+MA_0_J[cnt]+","+(MA_0_J[cnt]-MA_1_J[cnt]);
                  }
               else if ((MA_1_J[cnt] - MA_0_J[cnt]) < 0 ) {
                     message = message + "\r\n" + "日足MAとの関係：逆行（日足ＭＡ上昇中）";
                     message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J[cnt]+","+MA_0_J[cnt]+","+(MA_0_J[cnt]-MA_1_J[cnt]);
                  }
                  else  {              
                     message = message + "\r\n" + "日足MAとの関係：中立（日足ＭＡ中立）";
                     message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J[cnt]+","+MA_0_J[cnt]+","+(MA_0_J[cnt]-MA_1_J[cnt]);
                  }
               }
            }
            if ( Kind[cnt] != 0  ) SendMail("MACDルール "+"["+symbol_chk[cnt]+"]["+Period()+"]",message);
         }
      }
      Emailflag = false;
 
      if (Alertflag== true) {

         for ( cnt = 0 ; cnt < symbol_max ; cnt++) {

            if ( symbol_true[cnt] == false ) {
               continue;
            }

            switch(Kind[cnt]) {
               case 1:
                     Alert("MACD Rule  BUY Signal ",symbol_chk[cnt],Period(),DoubleToStr(iClose(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case 2:
                     Alert("MACD Rule  SELL Signal ",symbol_chk[cnt],Period(),DoubleToStr(iClose(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case 3:
                     Alert("MACD Rule  BUY Signal End",Symbol(),Period(),DoubleToStr(iClose(symbol_chk[cnt],Period(),0),pos[cnt]-1));
               
                  break;
               case 4:
                     Alert("MACD Rule  SELL Signal End",Symbol(),Period(),DoubleToStr(iClose(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
            }
         }
      }
      Alertflag = false;

   }
      Timeflg = false;

    return(0);
}













   
    
