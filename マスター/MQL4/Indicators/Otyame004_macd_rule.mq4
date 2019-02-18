//+------------------------------------------------------------------+
//|                                        Macd_rule.mq4(Ver.1.1)    |
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

extern bool AlertON=false;           	//アラート表示　
extern bool EmailON=true;           	//メール送信
extern bool Redraw = false;
extern string _MACD = "MACD";
extern int MACD_Period = 20;           	//MACD 短期
extern int MACD_Method = 3;         	//MACD ＷＭＡ
extern int Signal_MAPeriod = 5;      	//MACD MA期間
extern int Signal_MAMethod = 3;      	//MACD

extern string _MA = "MA";
extern int  MA_Period= 20;
extern int MA_Method = 0;

extern bool JissenKai =true;        //実践会フラグ
extern int Compare_Period = 60;

extern int Signal_Pos = 20;

bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ
bool sell = true;
bool buy = true;

datetime TimeOld = D'1970.01.01 00:00:00';

int MACD_Rule;               // 今回（０：不成立、１：上昇成立、2:下降成立）
int O_MACD_Rule;               // 今回（０：不成立、１：上昇成立、2:下降成立）
int Kind;

int  FastMAPeriod;
int SlowMAPeriod;
int SignalMAPeriod;
int MAPeriod;

double pos_chk;

double chk_pips_MACD;
double chk_pips_MA;
int pos;
int	Chk_candle;
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
   SetIndexBuffer(2,UEndArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,DEndArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
 
//   TimeOld = Time[0];
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
	double MACD_0,MACD_1;
   double MA_0,MA_1;
   double MA_0_J,MA_1_J;

   if ( Time[0] != TimeOld ) {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( limit < 2 ) limit = 2;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      for(i= limit-1;i>=1;i--){
         UpArrow[i] = EMPTY_VALUE;
         DownArrow[i] = EMPTY_VALUE;
         UEndArrow[i] = EMPTY_VALUE;
         DEndArrow[i] = EMPTY_VALUE;
         MACD_0 = iCustom(NULL,0,"MACD++",FastMAPeriod,SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",MACD_Method,SignalMAPeriod,Signal_MAMethod,false,0,1,i);
         MACD_1 = iCustom(NULL,0,"MACD++",FastMAPeriod,SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",MACD_Method,SignalMAPeriod,Signal_MAMethod,false,0,1,i+Chk_candle);
         MA_0 = iMA(NULL,0,MAPeriod,0,MA_Method,PRICE_CLOSE,i);
         MA_1 = iMA(NULL,0,MAPeriod,0,MA_Method,PRICE_CLOSE,i+Chk_candle);
         if ( (Period() == PERIOD_H1) && (JissenKai == True) ) {
            MA_0_J = iMA(NULL,0,480,0,0,PRICE_CLOSE,i);
            MA_1_J = iMA(NULL,0,480,0,0,PRICE_CLOSE,i+Chk_candle);
         }
        if (( MACD_1 - MACD_0 ) > 0)   {        //MACD下降中
            if (( MA_1 - MA_0 ) >= 0) {                     //MA下降中
               MACD_Rule = 2;                               //MACDルール下降中と成立
            }
            else  {
               MACD_Rule = 0;                            //MACDルール下降成立
            }
         }
         else if (( MACD_1 - MACD_0 ) <0 )  {  //MACD上昇中
            if (( MA_1 - MA_0 ) <= 0 ) {                //MAは下降中
               MACD_Rule = 1;                                     //MACDルール不成立
            }
            else  {
               MACD_Rule = 0;                                     //MACDルール上昇成立
            }
         }
         else if ((MACD_1 - MACD_0 ) == 0 ) { 
            if ((  MA_1 - MA_0 ) > 0)    {  
               MACD_Rule = 2;                            //MACDルール不成立
            }
            else if (( MA_1 - MA_0 ) < 0 ){
               MACD_Rule = 1;                            //MACDルール不成立
            }
            else  {
               MACD_Rule = 0;                                     //MACDルール上昇成立
            }

         }
 
         switch(O_MACD_Rule)  {
         case 0:
            switch(MACD_Rule) {
               case 0:
                  Kind = 0;
                  break;
               case 1:
                  UpArrow[i] = Low[i] - Point * Signal_Pos;
                  Kind = 1;
                  break;
               case 2:
                  DownArrow[i] = High[i] + Point * Signal_Pos;
                  Kind = 2;
                  break;
            }
            break;
         case 1:
            switch(MACD_Rule) {
               case 0:
                  UEndArrow[i] = High[i] + Point * Signal_Pos;
                  Kind = 3;                  
                  break;
               case 1:
                  Kind = 0;
                  break;
               case 2:
                  DownArrow[i] = High[i] + Point * Signal_Pos;
                  Kind = 2;
                  break;
            }
            break;
         case 2:
            switch(MACD_Rule) {
               case 0:
                  DEndArrow[i] = Low[i] - Point * Signal_Pos;
                  Kind = 4;
                  break;
               case 1:
                  UpArrow[i] = Low[i] - Point * Signal_Pos;
                  Kind = 1;
                  break;
               case 2:
                  Kind = 0;
                  break;
            }
            break;
         }

         O_MACD_Rule = MACD_Rule;                              

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
            case 1:
               message= "銘柄："+Symbol()+"\r\n"+"時間軸："+Period()+"\r\n" + "トレンド：上昇 \r\n 条件：成立 \r\n 現在価格："+Open[0];
               message = message + " \r\n MACD("+(Chk_candle+1)+"本前,1本前,差） = "+MACD_1+","+MACD_0+","+(MACD_1-MACD_0);
               message = message + " \r\n MA("+(Chk_candle+1)+"本前,1本前,差） = "+MA_1+","+MA_0+","+(MA_1-MA_0);
               break;
            case 2:
               message= "銘柄："+Symbol()+"\r\n"+"時間軸："+Period()+"\r\n" + "トレンド：下降 \r\n 条件：成立 \r\n 現在価格："+Open[0];
               message = message + " \r\n MACD("+(Chk_candle+1)+"本前,1本前,差） = "+MACD_1+","+MACD_0+","+(MACD_1-MACD_0);
               message = message + " \r\n MA("+(Chk_candle+1)+"本前,1本前,差） = "+MA_1+","+MA_0+","+(MA_1-MA_0);
               break;
            case 3:
               message= "銘柄："+Symbol()+"\r\n"+"時間軸："+Period()+"\r\n" + "トレンド：上昇 \r\n 条件：終了 \r\n 現在価格："+Open[0];
               message = message + " \r\n MACD("+(Chk_candle+1)+"本前,1本前,差） = "+MACD_1+","+MACD_0+","+(MACD_1-MACD_0);
               message = message + " \r\n MA("+(Chk_candle+1)+"本前,1本前,差） = "+MA_1+","+MA_0+","+(MA_1-MA_0);
               break;
            case 4:
               message= "銘柄："+Symbol()+"\r\n"+"時間軸："+Period()+"\r\n" + "トレンド：下降 \r\n 条件：終了 \r\n 現在価格："+Open[0];
               message = message + " \r\n MACD("+(Chk_candle+1)+"本前,1本前,差） = "+MACD_1+","+MACD_0+","+(MACD_1-MACD_0);
               message = message + " \r\n MA("+(Chk_candle+1)+"本前,1本前,差） = "+MA_1+","+MA_0+","+(MA_1-MA_0);
               break;
         }
         if ( (Period() ==  PERIOD_H1) && (JissenKai == True) ) {
            if ( Kind == 1 ) {
               if ((MA_1_J - MA_0_J) > 0 ) {
                  message = message + "\r\n" + "日足MAとの関係：逆行（日足ＭＡ下降中）";
                  message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J+","+MA_0_J+","+(MA_1_J-+MA_0_J);

               }
               else if ((MA_1_J - MA_0_J) <= ( -1 * chk_pips_MA) ) {
                  message = message + "\r\n" + "日足MAとの関係：順行（日足ＭＡ上昇中）";
                  message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J+","+MA_0_J+","+(MA_1_J-+MA_0_J);
               }
               else  {              
                  message = message + "\r\n" + "日足MAとの関係：中立（日足ＭＡ中立）";
                  message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J+","+MA_0_J+","+(MA_1_J-MA_0_J);
               }
            }
            else if ( Kind== 2 ) {
               if ((MA_1_J - MA_0_J) >= chk_pips_MA ) {
                  message = message + "\r\n" + "日足MAとの関係：順行（日足ＭＡ下降中）";
                  message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J+","+MA_0_J+","+(MA_1_J-MA_0_J);
               }
               else if ((MA_1_J - MA_0_J) < 0 ) {
                  message = message + "\r\n" + "日足MAとの関係：逆行（日足ＭＡ上昇中）";
                  message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J+","+MA_0_J+","+(MA_0_J-MA_1_J);
               }
               else  {              
                  message = message + "\r\n" + "日足MAとの関係：中立（日足ＭＡ中立）";
                  message = message + "\r\n" + "日足MA("+(Chk_candle+1)+"本前,1本前,差） ="+MA_1_J+","+MA_0_J+","+(MA_0_J-MA_1_J);
               }
            }
         }
         if ( Kind != 0  ) SendMail("MACDルール "+ "["+Symbol()+"]["+Period()+"]",message);
      }
      Emailflag = false;
      if (Alertflag== true) {
         switch(Kind) {
            case 1:
                  Alert("MACD Rule  BUY Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
            case 2:
                  Alert("MACD Rule  SELL Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
            case 3:
                  Alert("MACD Rule  BUY Signal End",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               
               break;
            case 4:
                  Alert("MACD Rule  SELL Signal End",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
         }
      }

      Alertflag = false;
   }
   return(0);
}














   
    
