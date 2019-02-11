//+------------------------------------------------------------------+
//|                                       Otyame  No.0022            |
//|                                       スパンモデル            　 |
//|                                       2014.05.20                 |
//+------------------------------------------------------------------+
/*
  スパンモデルシグナル配信版 
 説明：上位足のスパンモデルのシグナルと売買が一致した時にシグナルを発信する
 　　　時刻を変更しても、対応。下位足のシグナルについては無視する
 
   パラメータ
      Tenkan = 9;          //転換線
      Kijun = 26;          //基準線 
      Senkou = 52;         //先行スパン 
      kansi_5m = true;     //5分足考慮
      kansi_15m = true;    //15分足考慮
      kansi_30m = true;    //30分足考慮
      kansi_1H = true;     //1時間足考慮
      kansi_4H = true;     //4時間足考慮
      kansi_1D = true;     //日足考慮
      AlertON=true;        //アラート表示　
      EmailON=true;        //メール送信

   色
      買い矢印
      売り矢印
      決済矢印（未使用）


*/
// マジックナンバーの定義

#include <stdlib.mqh> 
#property copyright "Otyame"
#property link      ""


#define Method_MAX 10

//---- buffers

extern bool Test_flag = true;
extern datetime test_time = D'2016.01.07 13:30';
extern int BUY_SELL = 2; 


extern string sALL_Setting  = "0：すべての設定に影響する";
extern bool spread_set = false;
extern int MAGIC = 1234;
extern bool EmailON=true;        //メール送信
extern bool AlertON = false;
extern double NO_Change_Pips = 3.0;       //損切り位置からまたは損切り設定の際は建値に対してこれ以上離れていないと設定しないPips数
extern double Betwwen_Change_Pips = 7.0;  //価格からこれ以上離れていないとストップ位置を変更しない
extern bool Close_flag = false;                //終値で判断するか、現在値で判断するか設定
extern int Server_Time = 7;


extern string sLostPoss = "1:損切り位置設定";
extern string sMA_Use = "1-1：移動平均線使用";
extern bool MA_Use = false;                //移動平均線を使用するかしないか
extern int MA_Period = 5;                 //移動平均線期間
extern int MA_Method = 0;                 //移動平均線種類
extern int MA_TimeFrame = 0;              //移動平均線のタイムフレーム
extern double MA_Pips = 3.0;              //移動平均線より離すPips数
extern int MA_MAX_Candle = 60;            //移動平均線で探すときの最大のローソク本数

extern string sSwingHL_Use = "1-2：直近高値安値使用";
extern bool SwingHL_Use = true;              //直近高値安値を使用するかしないか
extern int SwingHL_TimeFrame = 0;            //直近高値を見つけるためのタイムフレーム
extern int SwingHL_Candle = 3;               //直近高値を見つけるための前後の本数
extern double SwingHL_Pips = 3.0;              //移動平均線より離すPips数
extern int SwingHL_MAX_Candle = 60;          //直近高値安値で探すときの最大のローソク本数


extern string sSpan_Use = "1-3：スパンモデル使用";
extern bool Span_Use = true;              //直近高値安値を使用するかしないか
extern bool Span_A_Use = true;            // 現在値より近い方
extern bool Span_B_Use = false;            // 現在値より近い方
 
extern int Span_TimeFrame=0;
extern int Span_InpTenkan=9;   // Tenkan-sen
extern int Span_InpKijun=25;   // Kijun-sen
extern int Span_InpSenkou=52;  // Senkou Span B
extern int Span_Bar_Shift = 0;
extern double Span_Pips = 3.0;              //移動平均線より離すPips数
extern int Span_MAX_Candle = 60;            //移動平均線で探すときの最大のローソク本数


extern string sFixed_Value_Use = "1-4：固定値";     
extern double Fixed_Value = 30.0;                 //固定値で、最大の損切り幅

extern string sBreakEven = "2:ブレークイーブン設定";
extern bool BreakEven_Use = true;            //　ブレークイーブンを使用するかしないか
extern double BE_Pips = 20.0;                // ブレークイーブンにする時の含み益Pips
extern double BE_Margin = 2.0;               // ブレークイーブンにする時のマージン

extern string sTrailling_Method = "3:トレーリング手法";
extern string sTrailling_SwingHL = "3-1直近高値安値使用";
extern bool Trail_SwingHL_Use = true;              //直近高値安値を使用するかしないか
extern int Trail_SwingHL_TimeFrame = 0;            //直近高値を見つけるためのタイムフレーム
extern int Trail_SwingHL_Candle = 3;               //直近高値を見つけるための前後の本数
extern double Trail_SwingHL_Pips = 3.0;              //直近高値安値より離すPips数
extern int Trail_SwingHL_MAX_Candle = 60;          //直近高値安値で探すときの最大のローソク本数

extern string sTrailling_Spanmodel = "3-2スパンモデル使用";
extern bool Trail_Span_Use = false;              //直近高値安値を使用するかしないか
extern bool Trail_Span_A_Use = true;            // 現在値より近い方
extern bool Trail_Span_B_Use = false;            // 現在値より近い方
extern int Trail_Span_TimeFrame = 0;            //直近高値を見つけるためのタイムフレーム
extern int Trail_Span_InpTenkan=9;   // Tenkan-sen
extern int Trail_Span_InpKijun=25;   // Kijun-sen
extern int Trail_Span_InpSenkou=52;  // Senkou Span B
extern int Trail_Span_Bar_Shift = 0;
extern double Trail_Span_Pips = 3.0;             //直近高値安値より離すPips数
extern int Trail_Span_MAX_Candle = 60;          //直近高値安値で探すときの最大のローソク本数


extern string sJanping_Setting = "4：強トレンドトレール設定";
extern bool Janpping_Use =true;                       // 強トレンドトレールを使用する。
extern double  Janpping_Pips = 10.0;                  // 強トレンドトレールを使用する。
extern string sJanpping_Method  ="4:ジャンピング手法";
extern string sJanpping_HL_Band = "4-1：HLバンド";
extern bool Janpping_HL_Band_Use =true;              //HLバンドを使用するかしないか
extern int Janpping_HL_Band_TimeFrame = 0;            //HLバンドを見つけるためのタイムフレーム
extern int Janpping_HL_BandPeriod = 3;
extern int Janpping_HL_BandPriceField = 0;
extern bool Janpping_HL_Band_Center = true;              //HLバンドを使用するかしないか
extern double Janpping_HL_Band_Pips = 3.0;              //HLバンドをより離すPips数
extern string sJanpping_MA = "4-2：MA";
extern bool Janpping_MA_Use = true;                   //HLバンドを使用するかしないか
extern int Janpping_MA_Period = 8;                    //移動平均線期間
extern int Janpping_MA_Method = 0;                    //移動平均線種類
extern int Janpping_MA_TimeFrame = 0;                 //移動平均線のタイムフレーム
extern double Janpping_MA_Pips = 3.0;                 //移動平均線より離すPips数
extern string sJanpping_Candle = "4-3：Candle";
extern bool Janpping_Candle_Use = false;                   //HLバンドを使用するかしないか
extern int Janpping_Candle_TimeFrame = 0;                 //移動平均線のタイムフレーム
extern int Janpping_Candle_Old = 2;                 //移動平均線のタイムフレーム
extern double Janpping_Candle_Pips = 3.0;                 //移動平均線より離すPips数

extern string sKessai_Setting = "5：強制決済設定";
extern bool Kessai_Use =true;                       // 強トレンドトレールを使用する。
extern string sKessai_Method  ="5:決済手法";
extern string sKessai_MA = "5-1：MA";
extern bool Kessai_MA_Use = true;                   //HLバンドを使用するかしないか
extern int Kessai_MA_Period = 21;                    //移動平均線期間
extern int Kessai_MA_Method = 0;                    //移動平均線種類
extern int Kessai_MA_TimeFrame = 0;                 //移動平均線のタイムフレーム
extern string sKessai_Spanmodel = "5-2スパンモデル使用";
extern bool Kessai_Span_Use = true;              //直近高値安値を使用するかしないか
extern bool Kessai_Span_A_Use = false;            // 現在値より近い方
extern bool Kessai_Span_B_Use = true;            // 現在値より近い方
extern int Kessai_Span_TimeFrame = 0;            //直近高値を見つけるためのタイムフレーム
extern int Kessai_Span_InpTenkan=9;   // Tenkan-sen
extern int Kessai_Span_InpKijun=25;   // Kijun-sen
extern int Kessai_Span_InpSenkou=52;  // Senkou Span B
extern int Kessai_Span_Bar_Shift = 0;
extern double Kessai_Pips = 20.0;
extern int Kessai_Retry = 2;
extern double Kessai_Slip = 2.0;



//extern double Kessai_Candle_Pips = 3.0;                 //移動平均線より離すPips数
extern string sLimit_Setting = "6:リミットのPip数"; 
extern double Limit_Pips = 100.0;                      //移動平均線より離すPips数




//パラメーターの設定//
double Lots = 1.0;     //取引ロット数
int Slip = 10;         //許容スリッページ数
string Comments =  ""; //コメント


bool Loss_Set_Flag = false;
int SB_Type;
double BidPrice,AskPrice,Limit_Price;
double Spread;
double StopLoss;
double Stop_Loss_Data[Method_MAX];
datetime OrderTime;
datetime time1;
bool TimeFlag = false;
datetime TimeOld;
double Before_HL_Band_Price,Before_MA_Loss;
double Chkdata[1];
double Span_Chkdata[1];
bool Janpping_Mode;
bool Kessai_MA_MODE = false;
bool Kessai_MA_Pro_MODE = false;
bool Kessai_Span_MODE = false;
bool Kessai_Span_Pro_MODE = false;
bool Execute_flag = false;
double LossPrice;
double Kessai_Data[3];
double Kessai_Price;
int count;
int Error_NO;
//変数

// 変数の設定//
int Ticket_L = 0; // 買い注文の結果をキャッチする変数
int Ticket_S = 0; // 売り注文の結果をキャッチする変数
int Exit_L = 0; // 買いポジションの決済注文の結果をキャッチする変数
int Exit_S = 0; // 売りポジションの決済注文の結果をキャッチする変数

int Logic_No;
string Logic_mes;

int start()
{
   bool ret = false; 
   int ticket,cnt,y; 
   double MA_LossPrice,HL_LossPrice,Span_LossPrice;
   double MA_Loss,HL_Loss,Candle_Loss;
   double OpenPrice;
   double Trail_HL_LossPrice,Trail_Span_LossPrice,Trail_LossPrice;
   double Stop_Loss_MAX,Stop_Loss_MIN;
   double HL_Band_Price;
   datetime HL_Time;
   double Span_A;
   double Span_B;
   double sa;
   bool Check;
   double array1[10];
   datetime array2[10];
   datetime  array1_T[10];
   datetime TimeArray_MA[];
   bool Check_flag = true;
   double Lossdata[4],Trail_Lossdata[2];
   int i;
   double Span_Loss;

   
   if ( TimeOld != Time[0] ) {
      TimeFlag = true;
      TimeOld = Time[0];
   }
   else  {
      TimeFlag = false;
   }
   
   for ( i  = 0 ; i < Method_MAX;i++ ) {
      Stop_Loss_Data[i] = -1.0;   
   } 
   
   if ( Test_flag == true) {

      if ( Time[0] == test_time ) { 
         if (( Ticket_L == 0 ) && (Ticket_S==0)) {
            if ( BUY_SELL == 1 ) {
               Ticket_L = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
            }
            else if ( BUY_SELL == 2) {
               Ticket_S = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);     
            }
         }
      }
   }    
   if ( Close_flag == true ) {   
      BidPrice = Close[1];   
      AskPrice = Close[1];
   }
   else  {
      BidPrice = MarketInfo(NULL,MODE_BID);
      AskPrice = MarketInfo(NULL,MODE_ASK);
   }
   Spread = MarketInfo(NULL,MODE_SPREAD); 
   
   for ( ticket = 0; ticket<OrdersTotal(); ticket++ ) {
      if ( OrderSelect(ticket ,SELECT_BY_POS) == false ) break;
      if(OrderSymbol() != Symbol()) continue;
      SB_Type = OrderType();
      StopLoss = OrderStopLoss();
      OrderTime = OrderOpenTime();
      OpenPrice = OrderOpenPrice();
      if ( (SB_Type == OP_BUY) || (SB_Type == OP_SELL  ) )  {
         if ( StopLoss == 0.0 ) {
//損切り位置計算処理
            if ( MA_Use == true ) {              
               for ( cnt = 0; cnt < MA_MAX_Candle;cnt++ ) {
                  MA_Loss = iMA(NULL,MA_TimeFrame,MA_Period,0,MA_Method,PRICE_CLOSE,1+cnt) ;
                  if ( SB_Type == OP_BUY ) {
                     if ( NormalizeDouble(MA_Loss,Digits) < NormalizeDouble(OpenPrice,Digits) ) {
                        sa = (OpenPrice - MA_Loss) + MA_Pips *(Point *10);
                        if (( NormalizeDouble(sa,Digits) >= NormalizeDouble(NO_Change_Pips * (Point *10),Digits)) && ( NormalizeDouble(sa,Digits) <= NormalizeDouble((Fixed_Value * ( Point * 10)),Digits))) {
                           if (( NormalizeDouble(BidPrice,Digits) - NormalizeDouble(MA_Loss,Digits) ) > NormalizeDouble(Betwwen_Change_Pips * (Point * 10),Digits)){ 
                              MA_LossPrice = OpenPrice - sa;
                              break;
                           }
                        }
                     }
                  }
                  else if ( SB_Type == OP_SELL ) {
                     if ( NormalizeDouble(MA_Loss,Digits) > NormalizeDouble(OpenPrice,Digits) ) {
                        sa = (MA_Loss - OpenPrice) + MA_Pips *(Point *10);
                        if ( NormalizeDouble(sa,Digits) >= NormalizeDouble(NO_Change_Pips * (Point *10),Digits) && ( NormalizeDouble(sa,Digits) <= NormalizeDouble(Fixed_Value * ( Point * 10),Digits))) {
                           if (( NormalizeDouble(MA_Loss,Digits) - NormalizeDouble(AskPrice,Digits)) > NormalizeDouble(Betwwen_Change_Pips * (Point * 10),Digits)){ 
                              MA_LossPrice = OpenPrice + sa;
                              break;
                           }
                        }
                     }
                  }
               }               
            }
            if ( SwingHL_Use == true ) {
               ArrayResize(array1,SwingHL_Candle*2+1);
               for ( cnt = 1; cnt < SwingHL_MAX_Candle;cnt++ ) {
                  if ( SB_Type == OP_BUY ) {
                     for ( y = 0;y <SwingHL_Candle*2+1;y++) {
                        array1[y] = iLow(NULL,SwingHL_TimeFrame,y+cnt);
                        array1_T[y] = iTime(NULL,SwingHL_TimeFrame,y+cnt);
                     }   
                     Check_flag = true;
                     for ( y = 0;y <SwingHL_Candle*2+1;y++) {
                        if ( y < SwingHL_Candle ) {
                           if ( NormalizeDouble(array1[y],Digits) < NormalizeDouble(array1[SwingHL_Candle],Digits)) {
                              Check_flag = false;
                              break;
                           }
                        }
                        else if ( y > SwingHL_Candle ) { 
                           if ( NormalizeDouble(array1[y],Digits) < NormalizeDouble(array1[SwingHL_Candle],Digits)) {
                              Check_flag = false;
                              break;
                           }
                        }
                     }
                     if ( Check_flag == true ) {
                        HL_Loss = array1[SwingHL_Candle];
                        HL_Time = array1_T[SwingHL_Candle];
                        if ( NormalizeDouble(HL_Loss,Digits) < NormalizeDouble(OpenPrice,Digits) ) {
                           sa = (OpenPrice - HL_Loss) + SwingHL_Pips *(Point *10);
                           if (( NormalizeDouble(sa,Digits) >= NormalizeDouble(NO_Change_Pips * (Point *10),Digits)) && ( NormalizeDouble(sa,Digits) <= NormalizeDouble(Fixed_Value * ( Point * 10),Digits))) {
                              if (( NormalizeDouble(BidPrice,Digits) - NormalizeDouble(HL_Loss,Digits) ) > NormalizeDouble(Betwwen_Change_Pips * (Point * 10),Digits)){ 
                                 HL_LossPrice = OpenPrice - sa;
                                 break;
                              }
                           }
                        }
                     }
                  }
                  else if ( SB_Type == OP_SELL ) {
                     for ( y = 0;y <SwingHL_Candle*2+1;y++) {
                        array1[y] = iHigh(NULL,SwingHL_TimeFrame,y+cnt);
                        array1_T[y] = iTime(NULL,SwingHL_TimeFrame,y+cnt);
                     }   
                     Check_flag = true;
                     for ( y = 0;y <SwingHL_Candle*2+1;y++) {
                        if ( y < SwingHL_Candle ) {
                           if ( NormalizeDouble(array1[y],Digits) > NormalizeDouble(array1[SwingHL_Candle],Digits)) {
                              Check_flag = false;
                              break;
                           }
                        }
                        else if ( y > SwingHL_Candle ) { 
                           if ( NormalizeDouble(array1[y],Digits) > NormalizeDouble(array1[SwingHL_Candle],Digits)) {
                              Check_flag = false;
                              break;
                           }
                        }
                     }
                     if ( Check_flag == true ) {
                        HL_Loss = array1[SwingHL_Candle];
                        HL_Time = array1_T[SwingHL_Candle];
                        if ( NormalizeDouble(HL_Loss,Digits) > NormalizeDouble(OpenPrice,Digits) ) {
                           sa = (HL_Loss - OpenPrice) + SwingHL_Pips *(Point *10);
                           if (( NormalizeDouble(sa,Digits) >= NormalizeDouble(NO_Change_Pips * (Point *10),Digits)) && ( NormalizeDouble(sa,Digits) <= NormalizeDouble(Fixed_Value * ( Point * 10),Digits))) {
                              if (( NormalizeDouble(HL_Loss,Digits) - NormalizeDouble(AskPrice,Digits)) > NormalizeDouble(Betwwen_Change_Pips * (Point * 10),Digits)){ 
                                 HL_LossPrice = OpenPrice + sa;
                                 break;
                              }
                           }
                        }
                     }
                  }
               }               
            }
            
            if ( Span_Use == true ) {
               for ( cnt = 0; cnt < Span_MAX_Candle;cnt++ ) {
                  Span_A = iCustom(NULL,Span_TimeFrame,"Otyame001_Ichimoku_Shift",Span_InpTenkan,Span_InpKijun,Span_InpSenkou,Span_Bar_Shift,5,1+cnt);
                  Span_B = iCustom(NULL,Span_TimeFrame,"Otyame001_Ichimoku_Shift",Span_InpTenkan,Span_InpKijun,Span_InpSenkou,Span_Bar_Shift,6,1+cnt);
                  if ( Span_A_Use == true ) {
                     Span_Loss = Span_A;
                  }
                  else if ( Span_B_Use == true ) {
                     Span_Loss = Span_B;
                  }                     
                  if ( SB_Type == OP_BUY ) {
                     if ( NormalizeDouble(Span_Loss,Digits) < NormalizeDouble(OpenPrice,Digits) ) {
                        sa = (OpenPrice - Span_Loss) + Span_Pips *(Point *10);
                        if (( NormalizeDouble(sa,Digits) >= NormalizeDouble(NO_Change_Pips * (Point *10),Digits)) && ( NormalizeDouble(sa,Digits) <= NormalizeDouble((Fixed_Value * ( Point * 10)),Digits))) {
                           if (( NormalizeDouble(BidPrice,Digits) - NormalizeDouble(Span_Loss,Digits) ) > NormalizeDouble(Betwwen_Change_Pips * (Point * 10),Digits)){ 
                              Span_LossPrice = OpenPrice - sa;
                              break;
                           }
                        }
                     }
                     
                  }
                  else if ( SB_Type == OP_SELL ) {
                     if ( NormalizeDouble(Span_Loss,Digits) > NormalizeDouble(OpenPrice,Digits) ) {
                        sa = (Span_Loss - OpenPrice) + MA_Pips *(Point *10);
                        if ( NormalizeDouble(sa,Digits) >= NormalizeDouble(NO_Change_Pips * (Point *10),Digits) && ( NormalizeDouble(sa,Digits) <= NormalizeDouble(Fixed_Value * ( Point * 10),Digits))) {
                           if (( NormalizeDouble(Span_Loss,Digits) - NormalizeDouble(AskPrice,Digits)) > NormalizeDouble(Betwwen_Change_Pips * (Point * 10),Digits)){ 
                              Span_LossPrice = OpenPrice + sa;
                              break;
                           }
                        }
                     }
                     
                  }
               }               
            }
            
//損切り位置設定
            if ( SB_Type == OP_BUY ) {
               LossPrice = OpenPrice - Fixed_Value * (Point * 10);
               for ( y = 0; y < 4; y++) {
                  Lossdata[y] = -999;
               }
            }
            else {
               LossPrice = OpenPrice + Fixed_Value * (Point * 10);
               for ( y = 0; y < 4; y++) {
                  Lossdata[y] = 999;
              }
            }
            if ( NormalizeDouble(MA_LossPrice,Digits) != 0.0 ) {
               Lossdata[0] = MA_LossPrice;
            }
            if ( NormalizeDouble(HL_LossPrice,Digits) != 0.0 ) {
               Lossdata[1] = HL_LossPrice;
            }
            if ( NormalizeDouble(Span_LossPrice,Digits) != 0.0 ) {
               Lossdata[2] = Span_LossPrice;
            }
            Lossdata[3] = LossPrice;
            if ( SB_Type == OP_BUY ) {
               Logic_No = ArrayMaximum(Lossdata);
               LossPrice = Lossdata[Logic_No];
               if ( NormalizeDouble(OrderStopLoss(),Digits) == 0 ) {
                  if ( NormalizeDouble(OrderStopLoss(),Digits) < NormalizeDouble(LossPrice,Digits) ) {
                     Janpping_Mode = false;
                     Check =OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(LossPrice,Digits),OrderTakeProfit(),0,Green);
                     if ( Check == true ) {
                        ret = OrderSelect(ticket ,SELECT_BY_POS);
                        StopLoss = OrderStopLoss();
                        switch(Logic_No)
                        {
                           case 0:
                              Logic_mes = "移動平均線";
                              break;
                           case 1:
                              Logic_mes = "直近安値";
                              break;
                           case 2:
                              Logic_mes = "スパンモデル";
                              break;
                           case 3:
                              Logic_mes = "固定値";
                              break;
                        }
                        Message_SendMail("損切りロジック",Logic_mes,LossPrice,OrderTakeProfit());
                     }
                  }
               }
            }
            else if ( SB_Type == OP_SELL ) {
               Logic_No = ArrayMinimum(Lossdata);    
               LossPrice = Lossdata[Logic_No];   
               if (( NormalizeDouble(OrderStopLoss(),Digits) > NormalizeDouble(LossPrice,Digits) ) || (NormalizeDouble(OrderStopLoss(),Digits) == 0.0)){
                  Janpping_Mode = false;
                  Check =OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(LossPrice,Digits),OrderTakeProfit(),0,Green);
                  if ( Check == true ) {
                     ret = OrderSelect(ticket ,SELECT_BY_POS);
                     StopLoss = OrderStopLoss();
                     switch(Logic_No)
                     {
                        case 0:
                           Logic_mes = "移動平均線";
                           break;
                        case 1:
                           Logic_mes = "直近高値";
                           break;
                        case 2:
                           Logic_mes = "スパンモデル";
                           break;
                        case 3:
                           Logic_mes = "固定値";
                           break;
                     }
                     Message_SendMail("損切りロジック",Logic_mes,LossPrice,OrderTakeProfit());
                  }
               }
            }          
 // limitの設定
            if ( NormalizeDouble(Limit_Pips,Digits) != 0 ) {
               if ( SB_Type == OP_BUY ) {
                  Limit_Price = OpenPrice + Limit_Pips * ( Point * 10 );
               }
               else if ( SB_Type == OP_SELL ) {
                  Limit_Price = OpenPrice - Limit_Pips * ( Point * 10 );
               }            
               if ( NormalizeDouble(OrderTakeProfit(),Digits) == 0 ) {
                  Check =OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(Limit_Price,Digits),0,Green);
                  if ( Check == true ) {
                     ret = OrderSelect(ticket ,SELECT_BY_POS);
                     StopLoss = OrderStopLoss();
                     Message_SendMail("リミット設定","固定値",OrderStopLoss(),Limit_Price);
                  }

               }
            }
         }
   



//損切り設定でない場合         
         else           {
//ブレークイーブン機能
            if (( BreakEven_Use == true ) && ( NormalizeDouble(BE_Pips,Digits) != 0.0))  {
               double BE_Price;
               BE_Price = 0.0;
               if ( SB_Type == OP_BUY ) {
                  if ( NormalizeDouble((BidPrice - OpenPrice),Digits)  >=  NormalizeDouble((BE_Pips * (Point * 10)),Digits)) {
                     
                     if (( NormalizeDouble(OpenPrice + BE_Margin * (Point * 10),Digits)) > NormalizeDouble(StopLoss,Digits)) {
                        BE_Price =  OpenPrice + BE_Margin * (Point * 10);
                     }
                  }
               }
               else if ( SB_Type == OP_SELL ) {
                  if ( NormalizeDouble((OpenPrice - AskPrice),Digits)  >=  (NormalizeDouble(BE_Pips * (Point * 10),Digits))) {
                     if (NormalizeDouble(( OpenPrice - BE_Margin * (Point * 10)),Digits) < NormalizeDouble(StopLoss,Digits)) {
                        BE_Price =  OpenPrice - BE_Margin * (Point * 10);
                     }
                  }
               }
               if ( BE_Price != 0.0 ) {
                  if ( SB_Type == OP_BUY ) {
                     if ( NormalizeDouble(OrderStopLoss(),Digits) < NormalizeDouble(BE_Price,Digits) ) {
                        Check =OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(BE_Price,Digits),OrderTakeProfit(),0,Green);
                        if ( Check == true ) {
                           ret = OrderSelect(ticket ,SELECT_BY_POS);
                           StopLoss = OrderStopLoss();
                           Message_SendMail("ブレークイーブン設定","固定値",BE_Price,OrderTakeProfit());
                        }
                     }
                  }
                  else if ( SB_Type == OP_SELL )  {
                     if ( NormalizeDouble(OrderStopLoss(),Digits) > NormalizeDouble(BE_Price,Digits) ) {
                        Janpping_Mode = false;
                        Check =OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(BE_Price,Digits),OrderTakeProfit(),0,Green);
                        if ( Check == true ) {
                           ret = OrderSelect(ticket ,SELECT_BY_POS);
                           StopLoss = OrderStopLoss();
                           Message_SendMail("ブレークイーブン設定","固定値",BE_Price,OrderTakeProfit());
                        }
                     }
                  }   
               }
            }

//トレール機能（直近安値高値）
            if ( Trail_SwingHL_Use == true ) {
               Trail_Span_LossPrice =0.0;
               ArrayResize(array1,Trail_SwingHL_Candle*2+1);
               ArrayResize(array1_T,Trail_SwingHL_Candle*2+1);
               Check_flag = false;
               if ( SB_Type == OP_BUY ) {
                  for ( cnt = 1; cnt < Trail_SwingHL_MAX_Candle;cnt++ ) {
                     if ( OrderTime > Time[cnt]) {
                        break;
                     }
                     Check_flag = true;
                     for ( y = 0;y <Trail_SwingHL_Candle*2+1;y++) {
                        array1[y] = iLow(NULL,Trail_SwingHL_TimeFrame,y+cnt);
                        array1_T[y] = iTime(NULL,Trail_SwingHL_TimeFrame,y+cnt);
                     }   
                     for ( y = 0;y <Trail_SwingHL_Candle*2+1;y++) {
                        if ( y < Trail_SwingHL_Candle ) {
                           if ( NormalizeDouble(array1[y],Digits) < NormalizeDouble(array1[Trail_SwingHL_Candle],Digits)) {
                              Check_flag = false;
                              break;
                           }
                        }
                        else if ( y > Trail_SwingHL_Candle ) { 
                           if ( NormalizeDouble(array1[y],Digits) < NormalizeDouble(array1[Trail_SwingHL_Candle],Digits)) {
                              Check_flag = false;
                              break;
                           }
                        }
                     }
                     if ( Check_flag == true ) {
                        break;
                     }
                  }       
                  if ( Check_flag == true ) {
                     Chkdata[0] = array1[Trail_SwingHL_Candle];
                     Trail_HL_LossPrice = StopLoss_Calc(OP_BUY,Chkdata,StopLoss,BidPrice,Trail_SwingHL_Pips,NO_Change_Pips,Betwwen_Change_Pips) ;
                  }
               }
               else if ( SB_Type == OP_SELL ) {
                  for ( cnt = 1; cnt < Trail_SwingHL_MAX_Candle;cnt++ ) {
                     if ( OrderTime > Time[cnt]) {
                        break;
                     }
                     Check_flag = true;
                     for ( y = 0;y <Trail_SwingHL_Candle*2+1;y++) {
                        array1[y] = iHigh(NULL,Trail_SwingHL_TimeFrame,y+cnt);
                        array2[y] = iTime(NULL,Trail_SwingHL_TimeFrame,y+cnt);
                     }   
                     for ( y = 0;y <Trail_SwingHL_Candle*2+1;y++) {
                        if ( y < Trail_SwingHL_Candle ) {
                           if ( NormalizeDouble(array1[y],Digits) > NormalizeDouble(array1[Trail_SwingHL_Candle],Digits)) {
                              Check_flag = false;
                              break;
                           }
                        }
                        else if ( y > Trail_SwingHL_Candle ) { 
                           if ( NormalizeDouble(array1[y],Digits) > NormalizeDouble(array1[Trail_SwingHL_Candle],Digits)) {
                              Check_flag = false;
                              break;
                           }
                        }
                     }
                     if ( Check_flag == true ) {
                     
                        break;
                     }
                  }       
                  if ( Check_flag == true ) {
                     Chkdata[0] = array1[Trail_SwingHL_Candle];
//                     Print("time = ",TimeToStr(array2[Trail_SwingHL_Candle],TIME_DATE|TIME_MINUTES)," data = ",array1[Trail_SwingHL_Candle]);
                     Trail_HL_LossPrice = StopLoss_Calc(OP_SELL,Chkdata,OrderStopLoss(),AskPrice,Trail_SwingHL_Pips,NO_Change_Pips,Betwwen_Change_Pips) ;
                  }
               }
            }
            if ( Trail_Span_Use == true ) {
               Trail_Span_LossPrice = 0.0;
               for ( cnt = 1; cnt < Trail_Span_MAX_Candle;cnt++ ) {
                  if ( OrderTime > Time[cnt]) {
                     break;
                  }
                  Span_A = iCustom(NULL,Trail_Span_TimeFrame,"Otyame001_Ichimoku_Shift",Trail_Span_InpTenkan,Trail_Span_InpKijun,Trail_Span_InpSenkou,Trail_Span_Bar_Shift,5,1+cnt);
                  Span_B = iCustom(NULL,Trail_Span_TimeFrame,"Otyame001_Ichimoku_Shift",Trail_Span_InpTenkan,Trail_Span_InpKijun,Trail_Span_InpSenkou,Trail_Span_Bar_Shift,6,1+cnt);
                  if ( Trail_Span_A_Use == true ) {
                     Span_Chkdata[0]= Span_A;
                  }
                  else if ( Trail_Span_B_Use == true ) {
                     Span_Chkdata[0] = Span_B;
                  }                     
                  if ( SB_Type == OP_BUY ) {
                     Trail_Span_LossPrice = StopLoss_Calc(OP_BUY,Span_Chkdata,OrderStopLoss(),BidPrice,Trail_Span_Pips,NO_Change_Pips,Betwwen_Change_Pips) ;
                  }
                  else if ( SB_Type == OP_SELL ) {
                     Trail_Span_LossPrice = StopLoss_Calc(OP_SELL,Span_Chkdata,OrderStopLoss(),AskPrice,Trail_Span_Pips,NO_Change_Pips,Betwwen_Change_Pips) ;
                  }
                  if ( Trail_Span_LossPrice != 0.0 ) {
                     break;
                  }
 
               }
            }    
                            
             if ( SB_Type == OP_BUY ) {
               for ( y = 0; y < 2; y++) {
                  Trail_Lossdata[y] = -999;
               }
            }
            else {
               for ( y = 0; y < 2; y++) {
                  Trail_Lossdata[y] = 999;
              }
            }
            if ( ( NormalizeDouble(Trail_HL_LossPrice,Digits) != 0.0 ) || ( NormalizeDouble(Trail_Span_LossPrice,Digits) != 0.0 )) {
               if ( NormalizeDouble(Trail_HL_LossPrice,Digits) != 0.0 ) {
                  Trail_Lossdata[0] = Trail_HL_LossPrice;
               }
               if ( NormalizeDouble(Trail_Span_LossPrice,Digits) != 0.0 ) {
                  Trail_Lossdata[1] = Trail_Span_LossPrice;
               }
               if ( SB_Type == OP_BUY ) {
                  Logic_No = ArrayMaximum(Trail_Lossdata);
                  Trail_LossPrice = Trail_Lossdata[Logic_No];
                  Janpping_Mode = false;
                  Check =OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Trail_LossPrice,Digits),OrderTakeProfit(),0,Green);
                  if ( Check == true ) {
                     ret = OrderSelect(ticket ,SELECT_BY_POS);
                     StopLoss = OrderStopLoss();
                     switch(Logic_No)
                     {
                        case 0:
                           Logic_mes = "直近安値";
                           break;
                        case 1:
                           Logic_mes = "スパンモデル";
                           break;
                     }
                     Message_SendMail("トレールロジック",Logic_mes,Trail_LossPrice,OrderTakeProfit());
                  }
               }
               else if ( SB_Type == OP_SELL ) {
                  Logic_No = ArrayMinimum(Trail_Lossdata);    
//                  Print("Logic_No = ",Logic_No);
                  Trail_LossPrice = Trail_Lossdata[Logic_No];
                  Janpping_Mode = false;
                  Check =OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Trail_LossPrice,Digits),OrderTakeProfit(),0,Green);
                  if ( Check == true ) {
                     ret = OrderSelect(ticket ,SELECT_BY_POS);
                     StopLoss = OrderStopLoss();
                     switch(Logic_No)
                     {
                        case 0:
                           Logic_mes = "直近高値";
                           break;
                        case 1:
                           Logic_mes = "スパンモデル";
                           break;
                     }
                     Message_SendMail("トレールロジック",Logic_mes,Trail_LossPrice,OrderTakeProfit());
                  }
               }
            }
//強トレンド手法
            if ( Janpping_Use == true ) {
               if (Janpping_Mode == false ) {
                  if ((( SB_Type == OP_BUY ) && (NormalizeDouble((BidPrice  - StopLoss ),Digits) > NormalizeDouble(Janpping_Pips * (Point * 10 ),Digits) )) || (( SB_Type == OP_SELL ) && (NormalizeDouble(( StopLoss - AskPrice ),Digits) > NormalizeDouble(Janpping_Pips* (Point * 10 ),Digits) ))) {
                     Janpping_Mode = true;
                  }
               }
//強トレンドの各手法を記載
               if ( Janpping_Mode == true ) {
                  if ( Janpping_HL_Band_Use == true ) {
                     ArrayResize(Chkdata,1);
                     Stop_Loss_Data[0] = 0.0;
                     if ( SB_Type == OP_BUY ) {
                        if ( TimeFlag == true ) {
                           cnt = 0;
                           time1 = iTime(NULL,Janpping_HL_Band_TimeFrame,1);
                           while(OrderTime <= time1) {
                              if ( Janpping_HL_Band_Center == true ) {
                                 HL_Band_Price = iCustom(NULL,Janpping_HL_Band_TimeFrame,"Otyame009_HLBand",Janpping_HL_BandPeriod,Janpping_HL_BandPriceField,0,1+cnt);
                              }
                              else {
                                 HL_Band_Price = iCustom(NULL,Janpping_HL_Band_TimeFrame,"Otyame009_HLBand",Janpping_HL_BandPeriod,Janpping_HL_BandPriceField,2,1+cnt);
                              }
                              if ( cnt > 0 ) {
                                 if (NormalizeDouble(Chkdata[cnt-1],Digits) < NormalizeDouble(HL_Band_Price,Digits) ) {
                                    break;
                                 }
                                 else if ( NormalizeDouble(HL_Band_Price,Digits) < NormalizeDouble(StopLoss,Digits)) {
                                    break;
                                 }
                                 else {
                                    ArrayPushBack(Chkdata,HL_Band_Price);
                                 }
                              }
                              else {
                                 Chkdata[cnt] = HL_Band_Price;
                              }     
                              cnt++;
                              time1 = iTime(NULL,Janpping_HL_Band_TimeFrame,1+cnt);
                           }
                           
                           Stop_Loss_Data[0] = StopLoss_Calc(OP_BUY,Chkdata,StopLoss,BidPrice,Janpping_HL_Band_Pips,NO_Change_Pips,Betwwen_Change_Pips) ;
                        }
                     }
                     else if ( SB_Type == OP_SELL ) {
                        if ( TimeFlag == true ) {
                           cnt = 0;
                           time1 = iTime(NULL,Janpping_HL_Band_TimeFrame,1);
                           while(OrderTime <= time1) {
                              if ( Janpping_HL_Band_Center == true ) {
                                 HL_Band_Price = iCustom(NULL,Janpping_HL_Band_TimeFrame,"Otyame009_HLBand",Janpping_HL_BandPeriod,Janpping_HL_BandPriceField,0,1+cnt);
                              }
                              else {
                                 HL_Band_Price = iCustom(NULL,Janpping_HL_Band_TimeFrame,"Otyame009_HLBand",Janpping_HL_BandPeriod,Janpping_HL_BandPriceField,1,1+cnt);
                              }
                              if ( cnt > 0 ) {
                                 if (NormalizeDouble(Chkdata[cnt-1],Digits) >
                                 
                                  NormalizeDouble(HL_Band_Price ,Digits)) {
                                    break;
                                 }
                                 else if ( NormalizeDouble(HL_Band_Price,Digits) > NormalizeDouble(StopLoss,Digits)) {
                                    break;
                                 }
                                 else {
                                    ArrayPushBack(Chkdata,HL_Band_Price);
                                 }
                              }
                              else {
                                 Chkdata[cnt] = HL_Band_Price;
                              }     
                              cnt++;
                              time1 = iTime(NULL,Janpping_HL_Band_TimeFrame,1+cnt);
                           }
                           Stop_Loss_Data[0] = StopLoss_Calc(OP_SELL,Chkdata,StopLoss,AskPrice,Janpping_HL_Band_Pips,NO_Change_Pips,Betwwen_Change_Pips) ;
                        }
                  
                     }
                  }
                  if ( Janpping_MA_Use == true ) {
                     ArrayResize(Chkdata,1);
                     Stop_Loss_Data[1] = 0.0;
                     if ( SB_Type == OP_BUY ) {
                        if ( TimeFlag == true ) {
                           cnt = 0;
                           time1 = iTime(NULL,Janpping_MA_TimeFrame,1);
                           while(OrderTime <= time1) {
                              MA_Loss = iMA(NULL,Janpping_MA_TimeFrame,Janpping_MA_Period,0,Janpping_MA_Method,PRICE_CLOSE,1+cnt) ;
                              if ( cnt > 0 ) {
                                 if (NormalizeDouble(Chkdata[cnt-1],Digits) < NormalizeDouble(MA_Loss,Digits) ) {
                                    break;
                                 }
                                 else if ( NormalizeDouble(MA_Loss,Digits) < NormalizeDouble(StopLoss,Digits)) {
                                    break;
                                 }
                                 else {
                                    ArrayPushBack(Chkdata,MA_Loss);
                                 }
                              }
                              else {
                                 Chkdata[cnt] = MA_Loss;
                              }     
                              cnt++;
                              time1 = iTime(NULL,Janpping_MA_TimeFrame,1+cnt);
                           }
                           Stop_Loss_Data[1] = StopLoss_Calc(OP_BUY,Chkdata,StopLoss,BidPrice,Janpping_MA_Pips,NO_Change_Pips,Betwwen_Change_Pips) ;
                        }
                     }
                     else if ( SB_Type == OP_SELL ) {
                        if ( TimeFlag == true ) {
                           cnt = 0;
                           time1 = iTime(NULL,Janpping_HL_Band_TimeFrame,1);
                           while(OrderTime <= time1) {
                              MA_Loss = iMA(NULL,Janpping_MA_TimeFrame,Janpping_MA_Period,0,Janpping_MA_Method,PRICE_CLOSE,1+cnt) ;
                              if ( cnt > 0 ) {
                                 if (NormalizeDouble(Chkdata[cnt-1],Digits) > NormalizeDouble(MA_Loss,Digits) ) {
                                    break;
                                 }
                                 else if ( NormalizeDouble(MA_Loss,Digits) > NormalizeDouble(StopLoss,Digits)) {
                                    break;
                                 }
                                 else {
                                    ArrayPushBack(Chkdata,MA_Loss);
                                 }
                              }
                              else {
                                 Chkdata[cnt] = MA_Loss;
                              }     
                              cnt++;
                              time1 = iTime(NULL,Janpping_HL_Band_TimeFrame,1+cnt);
                           }
                           Stop_Loss_Data[1] = StopLoss_Calc(OP_SELL,Chkdata,StopLoss,AskPrice,Janpping_MA_Pips,NO_Change_Pips,Betwwen_Change_Pips) ;
                        }
                  
                     }
                  }
                  if ( Janpping_Candle_Use == true ) {
                     ArrayResize(Chkdata,1);
                     if ( SB_Type == OP_BUY ) {
                        Stop_Loss_Data[2] = 0.0;
                        if ( TimeFlag == true ) {
                           Candle_Loss = iLow(NULL,Janpping_Candle_TimeFrame,Janpping_Candle_Old);
                           Chkdata[0] = Candle_Loss;
                           Stop_Loss_Data[2] = StopLoss_Calc(OP_BUY,Chkdata,StopLoss,BidPrice,Janpping_Candle_Pips,NO_Change_Pips,Betwwen_Change_Pips) ;
                        }
                        else if ( SB_Type == OP_SELL ) {
                           Candle_Loss = iHigh(NULL,Janpping_Candle_TimeFrame,Janpping_Candle_Old);
                           Chkdata[0] = Candle_Loss;
                           Stop_Loss_Data[2] = StopLoss_Calc(OP_SELL,Chkdata,StopLoss,AskPrice,Janpping_Candle_Pips,NO_Change_Pips,Betwwen_Change_Pips) ;
                        }
                     }
                  }
               }
               Stop_Loss_MAX = 0.0;                      
               Stop_Loss_MIN = 0.0;
               Logic_No = 0;                      
               if ( SB_Type == OP_BUY ) {
                  for ( i = 0; i < Method_MAX ; i++ ) {
                     if ( NormalizeDouble(Stop_Loss_Data[i],Digits) > 0.0 ) {
                        if ( NormalizeDouble(Stop_Loss_MAX,Digits) <= NormalizeDouble(Stop_Loss_Data[i],Digits)) {
                           Stop_Loss_MAX =  Stop_Loss_Data[i];
                           Logic_No = i+1;
                        }
                     }
                  }
               }                          
               else if ( SB_Type == OP_SELL ) {
                  for ( i = 0; i < Method_MAX ; i++ ) {
                     if ( NormalizeDouble(Stop_Loss_Data[i],Digits)> 0.0 ) {
                        if ( NormalizeDouble(Stop_Loss_MIN,Digits) >= NormalizeDouble(Stop_Loss_Data[i],Digits)) {
                           Stop_Loss_MIN =  Stop_Loss_Data[i];
                           Logic_No = i+1;
                        }
                     }
                  }
               }                          

               if ( NormalizeDouble(Stop_Loss_MAX,Digits) > 0.0 ) {
                  if (OrderStopLoss() <  Stop_Loss_MAX ) {
                     Check =OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Stop_Loss_MAX,Digits),OrderTakeProfit(),0,Green);
                     if ( Check == true ) {
                        ret = OrderSelect(ticket ,SELECT_BY_POS);
                        StopLoss = OrderStopLoss();
                        switch(Logic_No)
                        {
                           case 1:
                              Logic_mes = "HLバンド";
                              break;
                           case 2:
                              Logic_mes = "移動平均線";
                              break;
                           case 3:
                              Logic_mes = "ローソク足";
                              break;
                        }
                        Message_SendMail("強トレンド機能",Logic_mes,Stop_Loss_MAX,OrderTakeProfit());
                     }
                  }
               }
               else if ( Stop_Loss_MIN > 0.0 ) {
                  if (OrderStopLoss() >  Stop_Loss_MIN ) {
                     Check =OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Stop_Loss_MIN,Digits),OrderTakeProfit(),0,Green);
                     if ( Check == true ) {
                        ret = OrderSelect(ticket ,SELECT_BY_POS);
                        StopLoss = OrderStopLoss();
                        switch(Logic_No)
                        {
                           case 1:
                              Logic_mes = "HLバンド";
                              break;
                           case 2:
                              Logic_mes = "移動平均線";
                              break;
                           case 3:
                              Logic_mes = "ローソク足";
                              break;
                        }
                        Message_SendMail("強トレンド機能",Logic_mes,Stop_Loss_MIN,OrderTakeProfit());
                     }
                  }
               }

            }            
//強制決済手法
            if ( Kessai_Use == true ) {
               if ( Kessai_MA_Use == true ) {
                  Kessai_Data[1] = 0.0;
                  if ( TimeFlag == true ) {
                     Kessai_Data[1] = iMA(NULL,Kessai_MA_TimeFrame,Kessai_MA_Period,0,Kessai_MA_Method,PRICE_CLOSE,1) ;
                     if ( SB_Type == OP_BUY ) {
                        if ( Kessai_MA_MODE == false ) {
                           if ( Kessai_Data[1] < Close[1] ) {
                              Kessai_MA_MODE = true;
                              Kessai_MA_Pro_MODE = false;
                           }
                           else {
                              Kessai_MA_MODE = false;
                              Kessai_MA_Pro_MODE = false;
                           }
                        }
                        else {
                           if ( Kessai_Data[1] > Close[1] ) {
                              Kessai_MA_MODE = false;
                              Kessai_MA_Pro_MODE = true;
                           }
                           else if ( Kessai_Data[1] == Close[1]) {
                              Kessai_MA_MODE = false;
                              Kessai_MA_Pro_MODE = true;
                           }
                           else {
                              Kessai_MA_MODE = true;
                              Kessai_MA_Pro_MODE = false;
                           }                           
                        }
 
                     }
                     else if ( SB_Type == OP_SELL ) {
                        if ( Kessai_MA_MODE == false ) {
                           if ( Kessai_Data[1] > Close[1] ) {
                              Kessai_MA_MODE = true;
                              Kessai_MA_Pro_MODE = false;
                           }
                           else {
                              Kessai_MA_MODE = false;
                              Kessai_MA_Pro_MODE = false;
                           }
                        }
                        else {
                           if ( Kessai_Data[1] < Close[1] ) {
                              Kessai_MA_MODE = false;
                              Kessai_MA_Pro_MODE = true;
                           }
                           else if ( Kessai_Data[1] == Close[1]) {
                              Kessai_MA_MODE = false;
                              Kessai_MA_Pro_MODE = true;
                           }
                           else {
                              Kessai_MA_MODE = true;
                              Kessai_MA_Pro_MODE = false;
                           }                           
                        }
                      }
                  }
               }
               if ( Kessai_Span_Use == true ) {
                  Kessai_Data[2] = 0.0;
                  if ( TimeFlag == true ) {
                     if ( Kessai_Span_A_Use == true ) {
                        Kessai_Data[2] = iCustom(NULL,Kessai_Span_TimeFrame,"Otyame001_Ichimoku_Shift",Kessai_Span_InpTenkan,Kessai_Span_InpKijun,Kessai_Span_InpSenkou,Kessai_Span_Bar_Shift,5,1);
                     }
                     else if ( Kessai_Span_B_Use == true ) {
                        Kessai_Data[2] = iCustom(NULL,Kessai_Span_TimeFrame,"Otyame001_Ichimoku_Shift",Kessai_Span_InpTenkan,Kessai_Span_InpKijun,Kessai_Span_InpSenkou,Kessai_Span_Bar_Shift,6,1);
                     }
                     if ( SB_Type == OP_BUY ) {
                        if ( Kessai_Span_MODE == false ) {
                           if ( Kessai_Data[2] < Close[1] ) {
                              Kessai_Span_MODE = true;
                              Kessai_Span_Pro_MODE = false;
                           }
                           else {
                              Kessai_Span_MODE = false;
                              Kessai_Span_Pro_MODE = false;
                           }
                        }
                        else {
                           if ( Kessai_Data[2] > Close[1] ) {
                              Kessai_Span_MODE = false;
                              Kessai_Span_Pro_MODE = true;
                           }
                           else if ( Kessai_Data[2] == Close[1]) {
                              Kessai_Span_MODE = false;
                              Kessai_Span_Pro_MODE = true;
                           }
                           else {
                              Kessai_Span_MODE = true;
                              Kessai_Span_Pro_MODE = false;
                           }                           
                        }
                    }
                     else if ( SB_Type == OP_SELL ) {
                        if ( Kessai_Span_MODE == false ) {
                           if ( Kessai_Data[2] > Close[1] ) {
                              Kessai_Span_MODE = true;
                              Kessai_Span_Pro_MODE = false;
                           }
                           else {
                              Kessai_Span_MODE = false;
                              Kessai_Span_Pro_MODE = false;
                           }
                        }
                        else {
                           if ( Kessai_Data[2] < Close[1] ) {
                              Kessai_Span_MODE = false;
                              Kessai_Span_Pro_MODE = true;
                           }
                           else if ( Kessai_Data[2] == Close[1]) {
                              Kessai_Span_MODE = false;
                              Kessai_Span_Pro_MODE = true;
                           }
                           else {
                              Kessai_Span_MODE = true;
                              Kessai_Span_Pro_MODE = false;
                           }                           
                        }
                      }
                  }
               }
               if (( Kessai_MA_Pro_MODE == true ) || ( Kessai_Span_Pro_MODE == true )) {
                  Execute_flag = false;
                  if ( SB_Type == OP_BUY ) {
                     if ( (Close[1]-OpenPrice) >= Kessai_Pips * (Point * 10) ) {
                        Execute_flag = true;
                        Kessai_Price = Bid;
                     }
                     else {
                        Kessai_MA_Pro_MODE = false;
                        Kessai_Span_Pro_MODE = false;
                     }
                  }
                  else if ( SB_Type == OP_SELL ) {
                     if ( (OpenPrice-Close[1]) >= Kessai_Pips  * (Point * 10)) {
                        Execute_flag = true;
                        Kessai_Price = Ask;
                     }
                     else {
                        Kessai_MA_Pro_MODE = false;
                        Kessai_Span_Pro_MODE = false;
                     }
                  }

                  if ( Execute_flag == true ) {
                     if ( Kessai_MA_Pro_MODE == true ) {
                        Logic_mes = "移動平均線";
                     }
                     else if ( Kessai_Span_Pro_MODE == true ) {
                        Logic_mes = "スパンモデル";
                     }
                     count = 0;
                     while(1) {
                        Check = OrderClose(OrderTicket(),OrderLots(),Kessai_Price,Green);
                        Error_NO = GetLastError();
                        if ( Check == true ) {
                           Message_SendMail1("強制決済",Logic_mes,IntegerToString(Error_NO),"正常終了");
                           if ( Error_NO == ERR_NO_ERROR ) {
                              Kessai_MA_MODE = false;
                              Kessai_Span_MODE = false;
                              Kessai_MA_Pro_MODE = false;
                              Kessai_Span_Pro_MODE = false;
                           }
                           break;
                        }
                        count = count + 1;
                        if ( count > Kessai_Retry ) {
                           Message_SendMail1("強制決済失敗",Logic_mes,IntegerToString(Error_NO),ErrorDescription(Error_NO));
                           Kessai_MA_Pro_MODE = false;
                           Kessai_Span_Pro_MODE = false;
                           break;
                        }                          
                     }
                     
                  }
               }

            }            

         }
           
      }
   }      
   return(0);
}
//
//変更するストップロス位置を計算する
// 戻り値（０の場合、ただし位置ではない、それ以外は正しい位置）
// 引数
// int 売買方向(BUY_SELL)  1:BUY,2:SELL
// double 現在のストップロス位置（SL)
// double 現在の価格(Cur_Price)
// double 計算されたストップロス位置（Calc_SL）
// douboe 計算された位置から離すPips(Between_Pips)
// double 現在のストップロス位置から離さなければいけないPips(SL_sa)
// double 現在の値から離さなければいけないPips(Current_sa)
// datetime 購入した時間(time1)
// datetime 計算されたストップロスの時間(time2)


double StopLoss_Calc(int SB,double &data[],double SL,double Cur_Price,double Pips1,double Pips2,double Pips3)
{
   double ret;
   int i;
   int len = ArraySize(data);
   if ( SB == OP_BUY ) {
      for ( i = 0 ; i < len ; i++ ) {
         if ( spread_set == true ) {
            ret = data[i] - Pips1 * ( Point * 10 ) - (MarketInfo(NULL,MODE_SPREAD) * Point);
         }
         else {
            ret = data[i] - Pips1 * ( Point * 10 );
         }         
         if ( NormalizeDouble(ret,Digits) > NormalizeDouble(SL,Digits) ) {
            if ((NormalizeDouble(( ret - SL),Digits) >= NormalizeDouble(Pips2 * (Point * 10),Digits) ) && (NormalizeDouble(( Cur_Price - ret ),Digits) >= NormalizeDouble(Pips3* (Point * 10),Digits))) {
               break;                     
            }
            else {
               ret = 0.0;
            }
         }
         else {
            ret = 0.0;
         }
      }
   }
   else if ( SB == OP_SELL ) {
      for ( i = 0 ; i < len ; i++ ) {
         if ( spread_set == true ) {
            ret = data[i] + Pips1 * ( Point * 10 ) + (MarketInfo(NULL,MODE_SPREAD) * Point);
         }
         else {
            ret = data[i] + Pips1 * ( Point * 10 );
         }
         if ( NormalizeDouble(ret,Digits) < NormalizeDouble(SL,Digits) ) {
            if ((NormalizeDouble(( SL - ret),Digits) >= Pips2 * (Point * 10) ) && ( NormalizeDouble(( ret - Cur_Price),Digits) >= NormalizeDouble(Pips3* (Point * 10),Digits))) {
               break;                     
            }
            else {
               ret = 0.0;
            }
         }
         else {
            ret = 0.0;
         }
      }
   }
 
   return(ret);
}
int ArrayPushBack(double& vals[],double val )
{
   int len = ArraySize(vals);
   ArrayResize(vals,len+1);
   vals[len] = val;
   return(len+1);
}
int Message_SendMail1(string mes1,string mes2,string mes3,string mes4)
{
   string Header;
   string message;
   if ( EmailON == true ) {

      Header = "注文変更情報 "+"["+OrderSymbol()+"]";
      message = "*** 注文変更情報 ***";
      message = message +"\r\n通貨ペア:"+OrderSymbol();
      if ( OrderType() == OP_BUY ) {
         message = message + " \r\n 注文種類:"+"BUY";
      }
      else if ( OrderType() == OP_SELL)  {
         message = message + " \r\n注文種類:"+"SELL";
      }
      message = message + " \r\nロジック:"+mes1;
      message = message + " \r\n方法:"+mes2;
      message = message + " \r\n注文数量:"+OrderLots();
      message = message + " \r\nレート:"+OrderOpenPrice();
      message = message + " \r\nエラー番号:"+mes3;
      message = message + " \r\nエラー内容:"+mes4;
      message = message + " \r\n損益:"+OrderProfit();
      message = message + " \r\nマジックNo．:"+OrderMagicNumber();
      message = message + " \r\nオープン日時(JST):"+TimeToStr(OrderOpenTime()+Server_Time*3600,TIME_DATE| TIME_MINUTES);
      message = message + " \r\nオープン日時:"+TimeToStr(OrderOpenTime(),TIME_DATE| TIME_MINUTES);
      message = message + " \r\n注文番号:"+OrderTicket();
 
      message = message + " \r\n*** 口座情報 ***:";
      message = message + " \r\n口座残高:"+AccountBalance();
      message = message + " \r\n必要証拠金:"+AccountMargin();
      message = message + " \r\n損益合計:"+AccountProfit();
      SendMail(Header,message);
   }
   if ( AlertON == true ) {
      message ="Kessai"  ;
      Alert(message);
   }

   return(0);
 }
int Message_SendMail(string mes1,string mes2,double data1,double data2)
{
   string Header;
   string message;
   if ( EmailON == true ) {

      Header = "注文変更情報 "+"["+OrderSymbol()+"]";
      message = "*** 注文変更情報 ***";
      message = message +"\r\n通貨ペア:"+OrderSymbol();
      if ( OrderType() == OP_BUY ) {
         message = message + " \r\n 注文種類:"+"BUY";
      }
      else if ( OrderType() == OP_SELL)  {
         message = message + " \r\n注文種類:"+"SELL";
      }
      message = message + " \r\nロジック:"+mes1;
      message = message + " \r\n方法:"+mes2;
      message = message + " \r\n注文数量:"+OrderLots();
      message = message + " \r\nレート:"+OrderOpenPrice();
      message = message + " \r\nストップ:"+data1;
      if ( OrderType() == OP_BUY ) {
         message = message + " \r\n レートとの差："+(data1 - OrderOpenPrice());
      }
      else if ( OrderType() == OP_SELL)  {
         message = message + " \r\n レートとの差："+ (OrderOpenPrice() - data1);
      }
      message = message + " \r\nリミット:"+data2;
      message = message + " \r\n含み損益:"+OrderProfit();
      message = message + " \r\nマジックNo．:"+OrderMagicNumber();
      message = message + " \r\nオープン日時(JST):"+TimeToStr(OrderOpenTime()+Server_Time*3600,TIME_DATE| TIME_MINUTES);
      message = message + " \r\nオープン日時:"+TimeToStr(OrderOpenTime(),TIME_DATE| TIME_MINUTES);
      message = message + " \r\n注文番号:"+OrderTicket();
 
      message = message + " \r\n*** 口座情報 ***:";
      message = message + " \r\n口座残高:"+AccountBalance();
      message = message + " \r\n必要証拠金:"+AccountMargin();
      message = message + " \r\n損益合計:"+AccountProfit();
      SendMail(Header,message);
   }
   if ( AlertON == true ) {
      message ="Change"  ;
      message = message + " StopLoss:"+data1;
      message = message + " Limit:"+data2;
      Alert(message);
   }

   return(0);
 }
    