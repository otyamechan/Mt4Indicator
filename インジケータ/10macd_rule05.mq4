//+------------------------------------------------------------------+
//|                                        Macd_rule.mq4             |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Otyame"
#property link      ""

#property indicator_buffers 4

#property indicator_chart_window

#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Black
#property indicator_color4 Black

//---- buffers
double UpArrow[];
double DownArrow[];
double UEndArrow[];
double DEndArrow[];

string message;

extern bool AlertON=true;        //アラート表示　
extern bool EmailON=true;        //メール送信
extern string _MACD = "MACD";
extern int FastMAPeriod = 20;    //MACD 短期
extern int SlowMAPeriod = 240;    //MACD 長期
extern int MACD_Method = 3;         //MACD ＷＭＡ
extern int SignalMAPeriod = 15;      //MACD MA期間
extern int SignalMAMethod = 3;      //MACD

extern string _MA = "MA";
extern int MAPeriod = 240;
extern int MA_Method = 3;


bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ
bool sell = true;
bool buy = true;

datetime TimeOld;

int MACD_Rule = 0;               // 今回（０：不成立、１：上昇成立、2:下降成立）
int O_MACD_Rule = 0;             // 前回（０：不成立、１：上昇成立、2:下降成立）



int init()
{

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
 
   TimeOld = Time[0];

   return(0);
}
int deinit()
{
   return(0);
}
int start()
{
   int i;
    


   if (Time[0] != TimeOld)                      //時間が更新された場合
   {
      //アラートと、メール処理をセットする
      Emailflag = EmailON;                      //メール送信設定
      Alertflag = AlertON;                      //アラート出力設定
      TimeOld = Time[0];                        //時間を更新
    }
    else {
      Emailflag = false;                        //メール送信設定
      Alertflag = false;                        //アラート表示設定
    }
   double MACD_0,MACD_1;
   double MA_0,MA_1;
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   for(i= limit-1;i>=1;i--){
      MACD_0 = iCustom(NULL,0,"MACD++",FastMAPeriod,SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",MACD_Method,SignalMAPeriod,SignalMAMethod,false,0,1,i);
      MACD_1 = iCustom(NULL,0,"MACD++",FastMAPeriod,SlowMAPeriod,"0:SMA 1:EMA 2:SMMA 3:LWMA",MACD_Method,SignalMAPeriod,SignalMAMethod,false,0,1,i+1);
      MA_0 = iMA(NULL,0,MAPeriod,0,MA_Method,PRICE_CLOSE,i);
      MA_1 = iMA(NULL,0,MAPeriod,0,MA_Method,PRICE_CLOSE,i+1);
      
      
      Print("MACD_0 = ",MACD_0);
      Print("MACD_1 = ",MACD_1);
      Print("MA_0 = ",MA_0);
      Print("MA_1 = ",MA_1);
      
      
      if (( MACD_1 - MACD_0 ) > 0 )   {      //MACD下降中
         if (( MA_1 - MA_0 ) > 0) {          //MA下降中
            MACD_Rule = 2;                   //MACDルール下降で成立
         }
         else  {
            MACD_Rule = 0;                   //MACDルール不成立
         }
      }
      else if (( MACD_1 - MACD_0 ) < 0 )  {  //MACD上昇中
         if (( MA_1 - MA_0 ) < 0) {          //MAは上昇中
            MACD_Rule = 1;                   //MACDルール上昇で成立
         }
         else  {
            MACD_Rule = 0;                   //MACDルール不成立
         }
      }
      else
      {
            MACD_Rule = 0;                   //MACDルール不成立
             
      }
      UpArrow[i] = EMPTY_VALUE;
      DownArrow[i] = EMPTY_VALUE;
      UEndArrow[i] = EMPTY_VALUE;
      DEndArrow[i] = EMPTY_VALUE;
      switch(O_MACD_Rule)  {
         case 0:
            switch(MACD_Rule) {
               case 0:
                  break;
               case 1:
                  UpArrow[i] = Low[i];
                  break;
               case 2:
                  DownArrow[i] = High[i];
                  break;
            }
            break;
         case 1:
            switch(MACD_Rule) {
               case 0:
                  UEndArrow[i] = High[i];
                  break;
               case 1:
                  break;
               case 2:
                  DownArrow[i] = High[i];
                  break;
            }
            break;
         case 2:
            switch(MACD_Rule) {
               case 0:
                  DEndArrow[i] = Low[i];
                  break;
               case 1:
                  UpArrow[i] = Low[i];
                  break;
               case 2:
                  break;
            }
            break;
      }
      O_MACD_Rule = MACD_Rule;                              

   }  
   return(0);
}
