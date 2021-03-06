//+------------------------------------------------------------------+
//|                               Otyame301_Span_Auto_signal.mq4     |
//+------------------------------------------------------------------+

#property copyright   "2020,Otyame Trader"
#property description "Otyame301_Span_Auto_signal"
#property strict

#property indicator_buffers 4

#property indicator_chart_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Red
#property indicator_color4 Blue

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4

#define BUy_Cross  1 
#define SELL_Cross  2
#define BUY_Up  3 
#define SELL_Down 4


//---- buffers
double UpArrow[];
double DownArrow[];
double BuyUpArrow[];
double SellDownArrow[];
double chiko;

string message;
extern bool AlertON=false;                //アラート表示　
extern bool EmailON=true;                 //メール送信
extern  bool Redraw = false;              //再描画
extern int Tenkan = 9;                    //転換線
extern int Kijun = 25;                    //基準線 
extern int Senkou = 52;                   //先行スパン 
extern bool bCrossArert =true;            //クロスシグナル
extern int CrossBuySingalFigure = 233;   //クロス買いシグナルキャラクタ
extern int CrossSellSingalFigure = 234;  //クロス売りシグナルキャラクタ
extern  int  Cross_Signal_Pos = 40;       //クロスシグナル位置
extern bool bBSpanDirect = true;          //赤色スパン方向
extern bool bASpan_ON = true;             //青色スパン方向考慮
extern int BSpanBuySingalFigure = 246;   //赤色スパン買いシグナルキャラクタ
extern int BSPanSellSingalFigure = 248;  //赤色スパン売りシグナルキャラクタ
extern  int BSpan_Signal_Pos = 20;       //赤色スパンシグナル位置



bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ


double ASpan_0,ASpan_1;
double BSpan_0,BSpan_1;


datetime TimeOld= D'1970.01.01 00:00:00';

bool SellCrossSignal,BuyCrossSignal,CrossSignal;
bool BSpanBuySignal,BSpanSellSignal;
bool Before_BSpanBuySignal,Before_BSpanSellSignal;
bool BSpanDirectSignal;
bool ASpanBuySignal,ASpanSellSignal;
bool Before_ASpanBuySignal,Before_ASpanSellSignal;
bool bBSpanSell,bBSpanBuy;
bool Before_bBSpanSell,Before_bBSpanBuy;

bool Mail_Send_Flag;

string mes;
bool symbol_true;
int symbol_max;
string symbol_chk;
int cnt;
int rtn;


bool Timeflg = false;

void init()
{
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,CrossBuySingalFigure);
   SetIndexBuffer(0,UpArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,CrossSellSingalFigure);
   SetIndexBuffer(1,DownArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,BSpanBuySingalFigure);
   SetIndexBuffer(2,BuyUpArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,BSPanSellSingalFigure);
   SetIndexBuffer(3,SellDownArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   IndicatorShortName("Otyame301_Span_Auto_signal");
   symbol_max = 1;
   symbol_true = true;
   symbol_chk = Symbol();
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
   }
   if ( Timeflg == true ) {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      if ( limit < 2 ) limit = 2;
      for(i= limit-1;i>=1;i--) {
         ASpan_0 = iCustom(symbol_chk,0,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,0,5,i);
         ASpan_1 = iCustom(symbol_chk,0,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,0,5,i+1);
         BSpan_0 = iCustom(symbol_chk,0,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,0,6,i);
         BSpan_1 = iCustom(symbol_chk,0,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,0,6,i+1);
//先行スパン１、２のクロスチェック       
         if (( ASpan_1 > BSpan_1 ) && ( ASpan_0<= BSpan_0 )) {
            SellCrossSignal = true;
            BuyCrossSignal = false;
            CrossSignal = true;
         }
         else if (( ASpan_1 < BSpan_1 ) && ( ASpan_0 >= BSpan_0 )) {
            SellCrossSignal = false;
            BuyCrossSignal = true;
            CrossSignal = true;
         }
         else {
            SellCrossSignal = true;
            BuyCrossSignal = false;
            CrossSignal = false;
         }
         if ( ASpan_0!= ASpan_1 ) {
            if ( ASpan_1 > ASpan_0 ) {
               ASpanSellSignal = true;
               ASpanBuySignal = false;
            }
            else if ( ASpan_1 < ASpan_0 ) {
               ASpanSellSignal = false;
               ASpanBuySignal = true;
            }
         }
         else {
            ASpanSellSignal =Before_ASpanSellSignal;
            ASpanBuySignal = Before_ASpanBuySignal;
         }               
         Before_ASpanSellSignal = ASpanSellSignal;
         Before_ASpanBuySignal = ASpanBuySignal;
            
         
//先行スパン2傾きチェック         
         if ( BSpan_0!= BSpan_1 ) {
            if ( BSpan_1 > BSpan_0 ) {
               BSpanSellSignal = true;
               BSpanBuySignal = false;
            }
            else if ( BSpan_1 < BSpan_0 ) {
               BSpanSellSignal = false;
               BSpanBuySignal = true;
            }
         }
         else {
            BSpanSellSignal = Before_BSpanSellSignal;
            BSpanBuySignal = Before_BSpanBuySignal;
         }
         Before_BSpanSellSignal = BSpanSellSignal;
         Before_BSpanBuySignal = BSpanBuySignal;
        
         if ( bASpan_ON == true ) {
            if (Before_bBSpanBuy == true ) {
               if  ((BSpanSellSignal == true ) && ( ASpanSellSignal == true )) {
                  bBSpanBuy = false;
                  bBSpanSell= true; 
               }
               else {
                  bBSpanBuy = true;
                  bBSpanSell= false; 
               }
            }
            else if ( Before_bBSpanSell == true ) {
               if ( (BSpanBuySignal == true ) && ( ASpanBuySignal == true )) {
                  bBSpanBuy = true;
                  bBSpanSell = false; 
               }
               else {
                  bBSpanBuy = false;
                  bBSpanSell= true; 
               }
            }
            else {
               bBSpanBuy = BSpanBuySignal;
               bBSpanSell = BSpanSellSignal;
            }
         }
         else {
            bBSpanBuy = BSpanBuySignal;
            bBSpanSell = BSpanSellSignal;
         }
         if ( ( Before_bBSpanBuy == false ) && ( bBSpanBuy == true )) {
            BSpanDirectSignal = true ;
         }
         else if  (( Before_bBSpanSell == false ) && ( bBSpanSell == true  )){
            BSpanDirectSignal = true ;
         }
         else           {
            BSpanDirectSignal = false ;
         }
         Before_bBSpanSell = bBSpanSell;
         Before_bBSpanBuy = bBSpanBuy;
         if (bCrossArert == true ) {
            if ( CrossSignal == true ) {
               if ( BuyCrossSignal == true ) {
                  UpArrow[i]=Low[i] - Point * Cross_Signal_Pos;
               }
               if ( SellCrossSignal == true ) {
                  DownArrow[i]=High[i] + Point * Cross_Signal_Pos;
               }
            }   
         }
         if (bBSpanDirect == true ) {
            if ( BSpanDirectSignal == true ) {
               if ( bBSpanBuy == true  ) {
                  BuyUpArrow[i]=BSpan_0 - Point * BSpan_Signal_Pos;
               }
               if ( bBSpanSell == true ) {
                  SellDownArrow[i] =BSpan_0  + Point * BSpan_Signal_Pos;
               }
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
          Mail_Send_Flag = false;
         chiko =  iCustom(symbol_chk,0,"Otyame001_Ichimoku_Shift",Kijun,Tenkan,Senkou,4,25);           
          message= "スパンモデル情報"+"\r\n"+"["+symbol_chk+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk,0,0),Digits); 
          message = message + " \r\n 先行スパン１(1本前,0本前） = "+DoubleToStr(ASpan_1)+","+DoubleToStr(ASpan_0);
          message = message + " \r\n 先行スパン２(1本前,0本前） = "+DoubleToStr(BSpan_1)+","+DoubleToStr(BSpan_0);
          message = message + " \r\n 遅行スパン = "+DoubleToStr(chiko);
          message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk,0,25),Digits);
          if ( bCrossArert == true ) {
             if ( CrossSignal == true ) {
                Mail_Send_Flag = true;
                if ( BuyCrossSignal == true ) {
                   message = message + " \r\n 買いシグナル発生";
                }
                else if ( SellCrossSignal == true ) {
                   message = message + " \r\n 売りシグナル発生";
                }
             }
          }                          
          if (bBSpanDirect == true ) {
              if ( BSpanDirectSignal == true) {
                 Mail_Send_Flag = true;
                 if ( BSpanBuySignal == true ) {
                    message = message +  " \r\n 先行スパン2上昇変化";        
                 }
                 else {
                    message = message +  " \r\n 先行スパン2下降変化";        
                 }
             }
          }
          if (Mail_Send_Flag ==  true ) {
              SendMail("スパンモデルインフォメーション " +"["+symbol_chk+"]["+IntegerToString(Period())+"]",message);
          }
      }                        
      Emailflag = false;      
      if (Alertflag== true) {
         for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
            if (symbol_true == false ) {
               continue;
            }
            if ( bCrossArert == true ) {
               if ( CrossSignal == true ) {
                  if ( BuyCrossSignal == true ) {
                     Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk,0,0),Digits));
                  }
                  else if ( SellCrossSignal == true ) {
                     Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(iOpen(symbol_chk,0,0),Digits));
                  }
               }
            }                          
            if (bBSpanDirect == true ) {
               if ( BSpanDirectSignal == true) {
                     Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],Digits));
                  }
                  else {
                     Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],Digits));
                  }
               }
            }
         }
      
      Alertflag = false;      
   }
   Timeflg = false;
   return(0);
}
