//+------------------------------------------------------------------+
//|                                       Otyame  No.001             |
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

   色
      買い矢印
      売り矢印
      決済矢印（未使用）


*/

#property copyright "Otyame"
#property link      ""

#property indicator_buffers 8

#property indicator_chart_window
#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Lime
#property indicator_color4 Lime
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Black
#property indicator_color8 Black

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 4
#property indicator_width6 4
#property indicator_width7 4
#property indicator_width8 4


//売買方式
#define	NO_POSITION	0
#define	BUY_START	1
#define	BUY_GYAKKO	2
#define	BUY_NORMAL	3
#define	SELL_START	4
#define	SELL_GYAKKO	5
#define	SELL_NORMAL	6

//決済方式
#define	BUY_START_KESSAI		11
#define	BUY_GYAKKO_KESSAI		12
#define	BUY_NORMAL_KESSAI		13
#define	SELL_START_KESSAI		14
#define	SELL_GYAKKO_KESSAI	15
#define	SELL_NORMAL_KESSAI	16

//---- buffers
double BuyArrow[];
double SellArrow[];
double BuyKessaiArrow[];
double SellKessaiArrow[];
double BuyGyakouArrow[];
double SellGyakouArrow[];
double BuyGyakouKessaiArrow[];
double SellGyakouKessaiArrow[];

string message;
extern bool AlertON=false;        	//アラート表示　
extern bool EmailON=true;        	//メール送信

extern int Tenkan = 9;           	//転換線
extern int Kijun = 25;           	//基準線 
extern int Senkou = 52;         	 	//先行スパン 
extern bool Redraw = false;    		//5分足考慮
extern int Signal_Pos = 20;			//逆行判定本数
extern int Gakou_Candle = 6;			//逆行判定本数
extern bool Span_Chiko_Check = true;
extern string _Super ="Super Bollinger Setting";
extern bool Super_bollin = false;
extern int MAPeriod = 21;
extern string _Pips = "Point * Pips";
extern double Pips = 100.0;
extern int Keizoku_Time = 3;    //5分足考慮
extern bool Super_Chiko_Check = true;
extern bool Setup_OK = true;

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

datetime TimeOld= D'1970.01.01 00:00:00';
datetime k1Htime[];              //1時間足格納用

int count_1H ;       //1時間足時間格納
int pos[10];
double pos_chk;

//O_buy: -1:決済済み
//O_buy: 0:買いシグナルなし
//O_buy  1:買いシグナル開始（先行スパン2より下）
//O_buy  2:買いシグナル開始（先行スパン1より下）
//O_buy  3:買いシグナル中（先行スパン１より上）
//O_buy  4:買いシグナル中（先行スパン１より下先行スパンより２より上）

//O_sell: 0:売りシグナルなし
//O_sell  1:売りシグナル開始（先行スパン2より上）
//O_sell  2:売りシグナル開始（先行スパン1より上）
//O_sell  3:売りシグナル中（先行スパン１より下）
//O_sell  4:売りシグナル中（先行スパン１より上先行スパンより２より下）

int Kind[10];

double Sen1_0[10],Sen2_0[10];
double Sen1_1[10],Sen2_1[10];
double Kijun_Line[10];
double BandS_Price[10];
double iBund[10];
bool B_Start[10];;
bool S_Start[10];
bool Buy_Signal[10];
bool Sell_Signal[10];
bool G_buy[10];																							//逆行買い
bool G_sell[10];																						//逆行売り
bool S_buy[10];																							//開始買い
bool S_sell[10];
bool Gakou[10];
int Gakou_cnt[10];																						//開始売り
int BandS[10];
int O_BandS[10];
bool Flag = false;
bool buy[10];
bool sell[10];
int symbol_max;
string symbol_chk[10];
bool symbol_true[10];
int cnt;
bool Timeflg;
double symbol_pips[10];
int init()
{
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,BuyArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,SellArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,234);
   SetIndexBuffer(2,BuyKessaiArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,SellKessaiArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,251);
   SetIndexBuffer(4,BuyGyakouArrow);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,251);
   SetIndexBuffer(5,SellGyakouArrow);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,252);
   SetIndexBuffer(6,BuyGyakouKessaiArrow);
   SetIndexEmptyValue(6,EMPTY_VALUE);
   SetIndexStyle(7,DRAW_ARROW);
   SetIndexArrow(7,252);
   SetIndexBuffer(7,SellGyakouKessaiArrow);
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
   int rtn;
   int i;
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
   return(0);
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
         symbol_pips[cnt] = Pips * MarketInfo(symbol_chk[cnt],MODE_POINT);

         if ( symbol_true[cnt] == false ) {
            continue ;
         }
         for(i= limit-1;i>=1;i--){
            Sen1_0[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,5,i);							//先行スパン１（最新）
            Sen1_1[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,5,i+1);						//先行スパン１（1本前）
            Sen2_0[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,6,i);							//先行スパン２（最新）
            Sen2_1[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,6,i+1);						//先行スパン２（１本前）
            Kijun_Line[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,1,i);					//基準線
            buy[cnt] = false;																							//買い
            sell[cnt] = false;																							//売り
            G_buy[cnt]= false;																							//逆行買い
            G_sell[cnt] = false;																						//逆行売り
            S_buy[cnt]= false;																							//開始買い
            S_sell[cnt]= false;																						//開始売り

            Kind[cnt] = 0;																								//売買種別クリア

//売買シグナル判定処理開始
			   Buy_Signal[cnt] = false;																					//買いシグナル
			   Sell_Signal[cnt] = false;																					//売りシグナル
            if(Sen1_0[cnt] > Sen2_0[cnt]  ) {																				//先行スパン１が先行スパン２より上
               if ( Super_bollin == true ) {
				      Buy_Signal[cnt] = Supper_Bollin_Chk(1,Time[i],symbol_chk[cnt]);										   //買いシグナル中
               }
               else {
                  Buy_Signal[cnt] = true;
			      }
               if ( Buy_Signal[cnt] == true ) {
                  if (Span_Chiko_Check == true ) {
                     if ( iClose(symbol_chk[cnt],Period(),i+25) >= iClose(symbol_chk[cnt],Period(),i)) {
                        Buy_Signal[cnt] = false;
                     }
                  }
               }
	         }																							
			   else if (Sen1_0[cnt] < Sen2_0[cnt]  )	{																	//先行スパン１が先行スパン２より下
               if ( Super_bollin == true ) {
				      Sell_Signal[cnt] = true;																				//売りシグナル中
               }
               else
               {
				      Sell_Signal[cnt] = Supper_Bollin_Chk(2,Time[i],symbol_chk[cnt]);																				//売りシグナル中
                  
               }
               if ( Sell_Signal[cnt] == true ) {
                  if (Span_Chiko_Check == true ) {
                     if ( iClose(symbol_chk[cnt],Period(),i+25) <= iClose(symbol_chk[cnt],Period(),i)) {
                        Sell_Signal[cnt] = false;
                     }
                  }
               }
			   }
			   else	{																									//先行スパン１と先行スパン２が同値
				   Buy_Signal[cnt] = false;																				//買いシグナル無し
				   Sell_Signal[cnt] = false;																				//売りシグナル無し
			   }
//売買シグナル判定処理終了
//売買シグナル開始判定処理
            if(Sen1_0[cnt] > Sen2_0[cnt] && Sen1_1[cnt] <= Sen2_1[cnt] ) {													//先行スパン１が２より上で一本前は１が２以下
               if ( Super_bollin == true ) {
				      B_Start[cnt] = Supper_Bollin_Chk(1,Time[i],symbol_chk[cnt]);												//買いシグナル開始
               }
               else { 
				      B_Start[cnt] = true;																					//買いシグナル開始
               }
				   S_Start[cnt] = false;																					//売りシグナル開始は無し
			   }
		   	else if ( (Sen1_0[cnt] < Sen2_0[cnt] && Sen1_1[cnt] >= Sen2_1[cnt] ))	{										//先行スパン１が２より下で一本前は１が２以上
				   B_Start[cnt] = false;																					//買いシグナル開始は無し
               if ( Super_bollin == true ) {
				      S_Start[cnt] = Supper_Bollin_Chk(2,Time[i],symbol_chk[cnt]);																					//売りシグナル開始
               }
               else {
				      S_Start[cnt] = true;																					//売りシグナル開始
               }
            
			   }
			else {																									//それ以外
				   B_Start[cnt] = false;																					//買いシグナル開始は無し
				   S_Start[cnt] = false;																					//売りシグナル開始は無し
			   }
//売買シグナル開始判定処理終了

			   if ( Buy_Signal[cnt] == true ) {																			//if(買いシグナル中)
				   S_Start[cnt] = false;																						//		売り開始終了
				   G_sell[cnt] = false;																							//		逆行買い終了
				   sell[cnt] = false;																							//		売り終了
				   if ( B_Start[cnt] == true ) {																			//		if(買いシグナル開始）	
					   if (iClose(symbol_chk[cnt],Period(),i) < Sen1_0[cnt] ) 	{																	//			if(終値が先行スパン１より下）・・強力な買いシグナル
						   Gakou[cnt] = false;																					//				逆行ではない
						   S_buy[cnt] = true;																					//				開始買い

					   }																										//			}
					   else  	{																							//			else {
						   Gakou_cnt[cnt]= 1;																					//				逆行カウンタを１とする
						   BandS_Price[cnt] = iClose(symbol_chk[cnt],Period(),i);																			//				逆行価格に終値を保存する
						   Gakou[cnt] = true;																					//				逆行判定中
					   }																										//			}
					   B_Start[cnt] = false;																					//			買いシグナル開始終了
				   }																											//		}
				   else {																									//		else	{・・買いシグナル開始でない場合			
					   if ( Gakou[cnt] == true ) {																			//			if(逆行中）
						   if ( BandS_Price[cnt] < iClose(symbol_chk[cnt],Period(),i) ) {																//				if(逆行価格が終値より小さい)
					         BandS_Price[cnt] = iClose(symbol_chk[cnt],Period(),i);																		//					逆行価格に終値を保存
							   Gakou_cnt[cnt]++;																				//					逆行カウンタを＋１する
							   if ( Gakou_cnt[cnt] >Gakou_Candle ) {														//					if (逆行カウンタ＞逆行判定カウンタ）	{
               			   iBund[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,i);	//						ボリンジャーバンド２σを計算/
								   if ( (iClose(symbol_chk[cnt],Period(),i)- Sen1_0[cnt]) >= symbol_pips[cnt] ||iClose(symbol_chk[cnt],Period(),i) >= iBund[cnt] ) {		//						if(終値と先行スパン１の差が指定Pips以上で２σ以上）	{
									   G_buy[cnt] = true;																		//							逆行売り
                              BandS_Price[cnt] = iClose(symbol_chk[cnt],Period(),i);
								   }																							//						}
								   Gakou[cnt] = false;																		//							逆行は終了
							   }																								//					}
						   }																									//				}
						   else {																							//				else	{・・逆行価格が終値以上
               		   iBund[cnt] = iBands(symbol_chk[cnt],0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,i);		//					ボリンジャーバンド２σを計算
						      if ((iClose(symbol_chk[cnt],Period(),i)- Sen1_0[cnt]) >= symbol_pips[cnt] || iClose(symbol_chk[cnt],Period(),i) >= iBund[cnt] ) {			//					if(終値と先行スパン１の差が指定Pips以上で２σ以上）	{
								   G_buy[cnt] = true;																			//						逆行売り
  						      }																								//					}
						      Gakou[cnt] = false;																			//						逆行は終了
						   }																									//				}
					   }																										//			}
					   else	{																								//			else	{・・逆行中でない
						   if ( G_sell[cnt] == false && B_Start[cnt] == false &&iClose(symbol_chk[cnt],Period(),i) >= Sen1_0[cnt] ) 	{			//				if(逆行売りでなく、開始買いでなく終値が先行スパン１以上）
							   buy[cnt] = true;																					//					買い
						   }																									//				}
					   }																										//			}
				   }																											//		}
			   }																												//	}
			   else if ( Sell_Signal[cnt] == true ) {																	//	else	if(売りシグナル)
				   B_Start[cnt] = false;																						//		買い開始終了
				   G_buy[cnt] = false;																						//		逆行売り終了
				   buy[cnt] = false;																							//		買い終了
				   if ( S_Start[cnt] == true ) {																			//		if(売りシグナル開始）	
					   if (iClose(symbol_chk[cnt],Period(),i) > Sen1_0[cnt] ) 	{																	//			if(終値が先行スパン１より上）・・強力な売りシグナル
						   Gakou[cnt] = false;																					//				逆行ではない
						   S_sell[cnt] = true;																					//				開始売り
					   }																										//			}
					   else  	{																							//			else {
						   Gakou_cnt[cnt]= 1;																					//				逆行カウンタを１とする
						   BandS_Price[cnt] = iClose(symbol_chk[cnt],Period(),i);																			//				逆行価格に終値を保存する
						   Gakou[cnt] = true;																					//				逆行判定中
					   }																										//			}
					   S_Start[cnt] = false;																					//			売りシグナル開始終了
				   }																											//		}
				   else {																									//		else	{・・買いシグナル開始でない場合			
					   if ( Gakou[cnt] == true ) {																			//			if(逆行中）
						   if ( BandS_Price[cnt] > iClose(symbol_chk[cnt],Period(),i) ) {																//				if(逆行価格が終値より大きい)
							   BandS_Price[cnt] = iClose(symbol_chk[cnt],Period(),i);																		//					逆行価格に終値を保存
							   Gakou_cnt[cnt]++;																				//					逆行カウンタを＋１する
							   if ( Gakou_cnt[cnt] >Gakou_Candle ) {														//					if (逆行カウンタ＞逆行判定カウンタ）	{
               			   iBund[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,i);	//						ボリンジャーバンド－２σを計算
								   if ( ( Sen1_0[cnt] -iClose(symbol_chk[cnt],Period(),i)) >= symbol_pips[cnt] || iClose(symbol_chk[cnt],Period(),i) <= iBund[cnt] ) {		//						if(先行スパン１と終値の差が指定Pips以上で終値が－２σ以下）	{
									   G_sell[cnt] = true;																		//							逆行買い
								   }
							      Gakou[cnt] = false;																		//							逆行は終了
						   	}																								//					}
						   }																									//				}
						   else {																							//				else	{・・逆行価格が終値以下
               		   iBund[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,i);		//					ボリンジャーバンド－２σを計算
							   if ( (Sen1_0[cnt] -iClose(symbol_chk[cnt],Period(),i)) >= symbol_pips[cnt] || iClose(symbol_chk[cnt],Period(),i) <= iBund[cnt] ) {			//					if(先行スパン１と終値の差が指定Pips以上で終値が－２σ以下）	{
								   G_sell[cnt] = true;
							   }																								//					}
							   Gakou[cnt] = false;																			//						逆行は終了
						   }																									//				}
					   }																										//			}
					   else	{																								//			else	{・・逆行中でない
						   if ( G_buy[cnt] == false && S_Start[cnt] == false && iClose(symbol_chk[cnt],Period(),i) <= Sen1_0[cnt] ) {			//				if(逆行買いでなく、開始売りでなく終値が先行スパン１以下）
							   sell[cnt] = true;
																												//					売り
						   }																									//				}
					   }																										//			}
				   }																											//		}
			   }																												//	}
			   BandS[cnt] = NO_POSITION;																						//	売買をノーポジションとする
			   if ( O_BandS[cnt] == NO_POSITION )	{																		//	if ( 前回売買がノーポジション）	{
				   if ( B_Start[cnt] == true ) {																			//		if (買い開始）
					   BandS[cnt] = BUY_START;																				//			売買を買い開始とする
                  BandS_Price[cnt] = iClose(symbol_chk[cnt],Period(),i);
				   }																											//		}
				   if ( G_buy[cnt] == true ) {																				//		if (逆行買い）
					   BandS[cnt] = BUY_GYAKKO;																				//			売買を逆行買いとする
                  BandS_Price[cnt] = iClose(symbol_chk[cnt],Period(),i);
				   }																											//		}
				   if ( buy[cnt] == true ) {																					//		if (買い）
					   BandS[cnt] = BUY_NORMAL;																				//			売買を買いとする
				   }																											//		}
				   if ( S_Start[cnt] == true ) {																			//		if (売り開始）
					   BandS[cnt] = SELL_START;																				//			売買を売り開始とする
                  BandS_Price[cnt] = iClose(symbol_chk[cnt],Period(),i);
				   }																											//		}
				   if ( G_sell[cnt] == true ) {																				//		if (逆行売り）
					   BandS[cnt] = SELL_GYAKKO;																				//			売買を逆行売りとする
                  BandS_Price[cnt] = iClose(symbol_chk[cnt],Period(),i);
				   }																											//		}
				   if ( sell[cnt] == true ) {																				//		if (買い）
					   BandS[cnt] = SELL_NORMAL;																				//			売買を売りとする
                  BandS_Price[cnt] = iClose(symbol_chk[cnt],Period(),i);
				   }																											//		}
			   }																												//	}
			   else	if ( O_BandS[cnt] == BUY_START ) {																	//	else	if （前回売買が買い開始）	{
				   if ( iClose(symbol_chk[cnt],Period(),i) > Sen1_0[cnt] ) {																			//		if( 終値が先行スパン１を超えた）	｛
					   BandS[cnt] = BUY_NORMAL;																				//			売買を買いとする
				   }																											//		}
				   else	if ( Sell_Signal[cnt] == true ) {																//		else if (売りシグナル中）｛
					   BandS[cnt] = BUY_START_KESSAI;																		//			決済を買い開始決済とする
				   }
				   else  BandS[cnt] = O_BandS[cnt];																											//		}
			   }																												//	}
			   else if ( O_BandS[cnt] == BUY_GYAKKO ) {																	//	else if (前回売買が逆行買い）
				   if ( iClose(symbol_chk[cnt],Period(),i)  > BandS_Price[cnt]+symbol_pips[cnt] )	{																		//		if(終値が更に安くなっている）	｛
					   BandS[cnt] = BUY_GYAKKO_KESSAI;																	// 		決済とする
				   }																											//		}
				   else	if ( iClose(symbol_chk[cnt],Period(),i) <= Sen1_0[cnt]  || Sell_Signal[cnt] == true) 	{								//		else if (終値が先行スパン１より大きい）
					   BandS[cnt] = BUY_GYAKKO_KESSAI;																	// 		決済とする
				   }																											//		}
				   else  BandS[cnt] = O_BandS[cnt];																											//		}
			   }																												//	}
			   else if ( O_BandS[cnt] == BUY_NORMAL ) {																	//	else if (前回売買が買い）
				   if ( iClose(symbol_chk[cnt],Period(),i) < Sen1_0[cnt] && Sen1_0[cnt] < Sen1_1[cnt] && (Sen1_0[cnt]+Sen2_0[cnt])/2 > iClose(symbol_chk[cnt],Period(),i) )	{																		//		if ( 終値が先行スパン１を下回った）
					   BandS[cnt] = BUY_NORMAL_KESSAI;																	//			決済とする
				   }																											//		}
				   else  BandS[cnt] = O_BandS[cnt];																											//		}
			   }																												//	}
			   else	if ( O_BandS[cnt] == SELL_START ) {																//	else	if （前回売買が買い開始）	{
				   if ( iClose(symbol_chk[cnt],Period(),i) < Sen1_0[cnt] ) {																			//		if( 終値が先行スパン１を超えた）	｛
					   BandS[cnt] = SELL_NORMAL;																				//			売買を買いとする
				   }																											//		}
				   else	if ( Buy_Signal[cnt] == true ) {																//		else if (売りシグナル中）｛
					   BandS[cnt] = SELL_START_KESSAI;																	//			決済を買い開始決済とする
				   }																											//		}
				   else  BandS[cnt] = O_BandS[cnt];																											//		}
			   }																												//	}
			   else if ( O_BandS[cnt] == SELL_GYAKKO ) {																	//	else if (前回売買が逆行買い）
				   if ( iClose(symbol_chk[cnt],Period(),i)  < BandS_Price[cnt]-symbol_pips[cnt])	{																		//		if(終値が更に安くなっている）	｛
					   BandS[cnt] = SELL_GYAKKO_KESSAI;																	// 		決済とする
				   }																											//		}
				   else	if ( iClose(symbol_chk[cnt],Period(),i) >= Sen1_0[cnt] || Buy_Signal[cnt] == true) 	{																//		else if (終値が先行スパン１より大きい）
					   BandS[cnt] = SELL_GYAKKO_KESSAI;																	// 		決済とする
				   }																											//		}
				   else  BandS[cnt] = O_BandS[cnt];																											//		}
			   }																												//	}
			   else if ( O_BandS[cnt] == SELL_NORMAL ) {																//	else if (前回売買が売り）
				   if ( iClose(symbol_chk[cnt],Period(),i) > Sen1_0[cnt] &&  Sen1_0[cnt] >= Sen1_1[cnt] && (Sen1_0[cnt]+Sen2_0[cnt])/2 < iClose(symbol_chk[cnt],Period(),i)  )	{																		//		if ( 終値が先行スパン１を下回った）
					   BandS[cnt] = SELL_NORMAL_KESSAI;																	//			決済とする
				   }																											//		}
				   else  BandS[cnt] = O_BandS[cnt];																											//		}
			   }
			   Kind[cnt] = 0;
            if ( O_BandS[cnt] != BandS[cnt] ) {
               switch(BandS[cnt])  {
               case BUY_START:
                  if ( symbol_chk[cnt] == Symbol()) {
                     BuyArrow[i] = Low[i] - Point * Signal_Pos;
                  }
                  Kind[cnt] = BUY_START;
                  break;               
               case BUY_GYAKKO:
                  if ( symbol_chk[cnt] == Symbol()) {
                     BuyGyakouArrow[i] = High[i] + Point * Signal_Pos;
                  }
                  Kind[cnt] = BUY_GYAKKO;
                  break;               
               case BUY_NORMAL:
                  if ( O_BandS[cnt] != BUY_START) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        BuyArrow[i] = Low[i] - Point * Signal_Pos;
                     }
                     Kind[cnt] = BUY_NORMAL;
                  }
                  break;               
               case SELL_START:
                  if ( symbol_chk[cnt] == Symbol()) {
                     SellArrow[i] = High[i] + Point * Signal_Pos;
                  }
                  Kind[cnt] = SELL_START;
                  break;               
               case SELL_GYAKKO:
                  if ( symbol_chk[cnt] == Symbol()) {
                     SellGyakouArrow[i] = Low[i] - Point * Signal_Pos;
                  }
                  Kind[cnt] = SELL_GYAKKO;
                  break;               
               case SELL_NORMAL:
                  if ( O_BandS[cnt] != SELL_START) {
                     if ( symbol_chk[cnt] == Symbol()) {
                        SellArrow[i] = High[i] + Point * Signal_Pos;
                     }
                     Kind[cnt] = SELL_NORMAL;
                  }
                  break;               
               case BUY_START_KESSAI:
                  if ( symbol_chk[cnt] == Symbol()) {
                     BuyKessaiArrow[i] = High[i] + Point * Signal_Pos;
                  }
                  Kind[cnt] = BUY_START_KESSAI;
                  BandS[cnt] = NO_POSITION;
                  break;               
               case BUY_GYAKKO_KESSAI:
                  if ( symbol_chk[cnt] == Symbol()) {
                     SellGyakouKessaiArrow[i] = Low[i] - Point * Signal_Pos;;
                  }
                  Kind[cnt] = BUY_GYAKKO_KESSAI;
                  BandS[cnt] = NO_POSITION;
                  break;               
               case BUY_NORMAL_KESSAI:
                  if ( symbol_chk[cnt] == Symbol()) {
                     BuyKessaiArrow[i] = High[i] + Point * Signal_Pos;
                  }
                  Kind[cnt] = BUY_NORMAL_KESSAI;
                  BandS[cnt] = NO_POSITION;
                  break;               
               case SELL_START_KESSAI:
                  if ( symbol_chk[cnt] == Symbol()) {
                     SellKessaiArrow[i] =Low[i] - Point * Signal_Pos;
                  }
                  Kind[cnt] = SELL_START_KESSAI;
                  BandS[cnt] = NO_POSITION;
                  break;               
               case SELL_GYAKKO_KESSAI:
                  if ( symbol_chk[cnt] == Symbol()) {
                     SellGyakouKessaiArrow[i] = High[i] + Point * Signal_Pos;
                  }
                  Kind[cnt] = SELL_GYAKKO_KESSAI;
                  BandS[cnt] = NO_POSITION;
                  break;               
               case SELL_NORMAL_KESSAI:
                  if ( symbol_chk[cnt] == Symbol()) {
                     SellKessaiArrow[i] = Low[i] - Point * Signal_Pos;;
                  }
                  Kind[cnt] = SELL_NORMAL_KESSAI;
                  BandS[cnt] = NO_POSITION;
                  break;               
               }           
		         O_BandS[cnt] = BandS[cnt];																						   //	前回売買に今回売買を設定
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
         double chiko[10];
         for ( cnt = 0; cnt < symbol_max ; cnt++ ) {
            chiko[cnt] =  iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,4,25);           
            switch(Kind[cnt])  {
               case BUY_START:
               case BUY_NORMAL:
                  message= "スパンモデル買いシグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
                  message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
                  message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
                  message = message + " \r\n 遅行スパン = "+chiko[cnt];
                  message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),25),pos[cnt]-1);
                  break;
               case BUY_GYAKKO:
                  message= "スパンモデル逆行売りシグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
                  message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
                  message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
                  message = message + " \r\n 遅行スパン = "+chiko[cnt];
                  message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),25),pos[cnt]-1);
                  break;
               case SELL_START:
               case SELL_NORMAL:
                  message= "スパンモデル売りシグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
                  message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
                  message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
                  message = message + " \r\n 遅行スパン = "+chiko[cnt];
                  message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),25),pos[cnt]-1);
                  break;
               case SELL_GYAKKO:
                  message= "スパンモデル逆行買いシグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
                  message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
                  message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
                  message = message + " \r\n 遅行スパン = "+chiko[cnt];
                  message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),25),pos[cnt]-1);
                  break;
               case BUY_START_KESSAI:
               case BUY_NORMAL_KESSAI:
                  message= "スパンモデル買い決済シグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
                  message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
                  message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
                  message = message + " \r\n 遅行スパン = "+chiko[cnt];
                  message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),25),pos[cnt]-1);
                  break;
               case BUY_GYAKKO_KESSAI:
                  message= "スパンモデル逆行売り決済シグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1); 
                  message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
                  message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
                  message = message + " \r\n 遅行スパン = "+chiko[cnt];
                  message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),25),pos[cnt]-1);
                  break;
               case SELL_START_KESSAI:
               case SELL_NORMAL_KESSAI:
                  message= "スパンモデル売り決済シグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos[cnt]-1); 
                  message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
                  message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
                  message = message + " \r\n 遅行スパン = "+chiko[cnt];
                  message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),25),pos[cnt]-1);
                  break;
               case SELL_GYAKKO_KESSAI:
                  message= "スパンモデル逆行買い決済シグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos[cnt]-1); 
                  message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
                  message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
                  message = message + " \r\n 遅行スパン = "+chiko[cnt];
                  message = message + " \r\n 26本前終値 = "+DoubleToStr(iClose(symbol_chk[cnt],Period(),25),pos[cnt]-1);
                  break;
            }           
            if (Kind[cnt] !=0 ) SendMail("スパンモデル決済版 "+"["+symbol_chk[cnt]+"]["+Period()+"]",message);
         }
      }
      if (Alertflag== true) {
         for ( cnt = 0; cnt < symbol_max ; cnt++ ) {
            if ( buy[cnt] == true ) {
               Alert("Spanmodel Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
            }
            if ( sell[cnt] == true ) {
               Alert("Spanmodel  Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
            }
            Alertflag = false;

         }
      }
      Emailflag = false;                      //メール送信設定
      Alertflag = false;                      //アラート出力設定
   }


   return(0);
}
bool Supper_Bollin_Chk(int Func,datetime Time_Current,string Sym)
{
   string chk_time;
   int Time_Chk;
   datetime H1_Time;
   double array[][6];
   double sigma;
   chk_time = TimeToStr(Time_Current,TIME_MINUTES);
   chk_time = StringSubstr(chk_time,4,2);
   ArrayCopyRates(array,Sym,PERIOD_H1);
   H1_Time = StrToTime(TimeToStr(Time_Current,TIME_DATE) + " " + TimeHour(Time_Current)+":00");
   Time_Chk = iBarShift(Sym,PERIOD_H1,H1_Time,false);
   if( Time_Chk == -1 ) {
      Flag = false;
   }
   else
   {
      int i;
      Flag = true;
      switch(Func)   {
         case 1:
         for ( i = 0 ; i < Keizoku_Time ; i++) {
            sigma = iBands(Sym,PERIOD_H1,21,1,0,PRICE_CLOSE,MODE_UPPER,Time_Chk + i);
            if ( sigma > array[Time_Chk+i][4] ) {
               Flag = false;
               break;
            }
         }
         break;
         case 2:
         for ( i = 0 ; i < Keizoku_Time ; i++) {
            sigma = iBands(Sym,PERIOD_H1,21,1,0,PRICE_CLOSE,MODE_LOWER,Time_Chk + i);;
            if ( sigma < array[Time_Chk][4] ) {
               Flag = false;
               break;
            }
         }
         break;
      }
   }
   return(Flag);
 }