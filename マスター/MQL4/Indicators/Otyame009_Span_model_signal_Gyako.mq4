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
#property indicator_color3 Black
#property indicator_color4 Black
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
extern int Gakou_Candle = 6;			//逆行判定本数
extern int Signal_Pos = 6;			//逆行判定本数
extern bool Span_Chiko_Check = true;
extern int MAPeriod = 21;
extern string _Pips = "Point * Pips";
extern double Pips = 100.0;
extern bool Super_bollin = false;
extern int Keizoku_Time = 3;    //5分足考慮
extern bool Super_Chiko_Check = true;
extern bool Setup_OK = true;


bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

datetime TimeOld= D'1970.01.01 00:00:00';
datetime k1Htime[];              //1時間足格納用

int count_1H ;       //1時間足時間格納
int pos;
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

int O_buy= 0;
int O_sell = 0;
int Kind = 0;

double Sen1_0,Sen2_0;
double Sen1_1,Sen2_1;
double Kijun_Line;
double BandS_Price;
double iBund;
bool B_Start = false;
bool S_Start = false;
bool Buy_Signal = false;
bool Sell_Signal = false;
bool G_buy = false;																							//逆行買い
bool G_sell = false;																						//逆行売り
bool S_buy = false;																							//開始買い
bool S_sell = false;
bool Gakou = false;
int Gakou_cnt =0;																						//開始売り
int BandS = 0;
int O_BandS = 0;
bool Flag = false;
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


    pos_chk = Point;
   pos = 0;
   int i;
    for ( i = 0 ; pos_chk < 1 ;i++) {
      pos++;
      pos_chk = pos_chk * 10;
   }      
   pos++;
 
   Pips = Pips ;
   return(0);
}
int deinit()
{
   return(0);
}
int start()
{
   int i;
   bool buy = true;
   bool sell = true;


   if (Time[0] != TimeOld)                      //時間が更新された場合
   {
   
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      if ( limit < 2 ) limit = 2;
      for(i= limit-1;i>=1;i--){
         Sen1_0 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i);							//先行スパン１（最新）
         Sen1_1 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i+1);						//先行スパン１（1本前）
         Sen2_0 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i);							//先行スパン２（最新）
         Sen2_1 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i+1);						//先行スパン２（１本前）
         Kijun_Line = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,1,i);					//基準線
         buy = false;																							//買い
         sell = false;																							//売り
         G_buy = false;																							//逆行買い
         G_sell = false;																						//逆行売り
         S_buy = false;																							//開始買い
         S_sell = false;																						//開始売り

         Kind = 0;																								//売買種別クリア

//売買シグナル判定処理開始
			Buy_Signal = false;																					//買いシグナル
			Sell_Signal = false;																					//売りシグナル
         if(Sen1_0 > Sen2_0  ) {																				//先行スパン１が先行スパン２より上
            if ( Super_bollin == true ) {
				   Buy_Signal = Supper_Bollin_Chk(1,Time[i]);										   //買いシグナル中
            }
            else {
               Buy_Signal = true;
			   }
            if ( Buy_Signal == true ) {
               if (Span_Chiko_Check == true ) {
                  if ( Close[i+25] >= Close[i]) {
                     Buy_Signal = false;
                  }
               }
            }
	      }																							
			else if (Sen1_0 < Sen2_0  )	{																	//先行スパン１が先行スパン２より下
            if ( Super_bollin == true ) {
				   Sell_Signal = Supper_Bollin_Chk(2,Time[i]);																				//売りシグナル中
            }
            else
              {
				   Sell_Signal = true;																				//売りシグナル中
                  
              }
            if ( Sell_Signal == true ) {
               if (Span_Chiko_Check == true ) {
                  if ( Close[i+25] <= Close[i]) {
                     Sell_Signal = false;
                  }
               }
            }


			}
			else	{																									//先行スパン１と先行スパン２が同値
				Buy_Signal = false;																				//買いシグナル無し
				Sell_Signal = false;																				//売りシグナル無し
			}
//売買シグナル判定処理終了
//売買シグナル開始判定処理
         if(Sen1_0 > Sen2_0 && Sen1_1 <= Sen2_1 ) {													//先行スパン１が２より上で一本前は１が２以下
            if ( Super_bollin == true ) {
				   B_Start = Supper_Bollin_Chk(1,Time[i]);												//買いシグナル開始
            }
            else { 
				   B_Start = true;																					//買いシグナル開始
            }
				S_Start = false;																					//売りシグナル開始は無し
			}
			else if ( (Sen1_0 < Sen2_0 && Sen1_1 >= Sen2_1 ))	{										//先行スパン１が２より下で一本前は１が２以上
				B_Start = false;																					//買いシグナル開始は無し
            if ( Super_bollin == true ) {
				   S_Start = Supper_Bollin_Chk(2,Time[i]);																					//売りシグナル開始
            }
            else {
				   S_Start = true;																					//売りシグナル開始
            }
            
			}
			else {																									//それ以外
				B_Start = false;																					//買いシグナル開始は無し
				S_Start = false;																					//売りシグナル開始は無し
			}
//売買シグナル開始判定処理終了

			if ( Buy_Signal == true ) {																			//if(買いシグナル中)
				S_Start = false;																						//		売り開始終了
				G_sell = false;																							//		逆行買い終了
				sell = false;																							//		売り終了
				if ( B_Start == true ) {																			//		if(買いシグナル開始）	
					if (Close[i] < Sen1_0 ) 	{																	//			if(終値が先行スパン１より下）・・強力な買いシグナル
						Gakou = false;																					//				逆行ではない
						S_buy = true;																					//				開始買い

					}																										//			}
					else  	{																							//			else {
						Gakou_cnt= 1;																					//				逆行カウンタを１とする
						BandS_Price = Close[i];																			//				逆行価格に終値を保存する
						Gakou = true;																					//				逆行判定中
					}																										//			}
					B_Start = false;																					//			買いシグナル開始終了
				}																											//		}
				else {																									//		else	{・・買いシグナル開始でない場合			
					if ( Gakou == true ) {																			//			if(逆行中）
						if ( BandS_Price < Close[i] ) {																//				if(逆行価格が終値より小さい)
							BandS_Price = Close[i];																		//					逆行価格に終値を保存
							Gakou_cnt++;																				//					逆行カウンタを＋１する
							if ( Gakou_cnt >Gakou_Candle ) {														//					if (逆行カウンタ＞逆行判定カウンタ）	{
               			iBund   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,i);	//						ボリンジャーバンド２σを計算
								if ( (Close[i]- Sen1_0) >= Point * Pips || Close[i] >= iBund ) {		//						if(終値と先行スパン１の差が指定Pips以上で２σ以上）	{
									G_buy = true;																		//							逆行売り
                           BandS_Price = Close[i];
								}																							//						}
								Gakou = false;																		//							逆行は終了
							}																								//					}
						}																									//				}
						else {																							//				else	{・・逆行価格が終値以上
               		iBund   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,i);		//					ボリンジャーバンド２σを計算
 						if ( (Close[i]- Sen1_0) >= Point * Pips || Close[i] >= iBund ) {			//					if(終値と先行スパン１の差が指定Pips以上で２σ以上）	{
								G_buy = true;																			//						逆行売り
   						}																								//					}
						   Gakou = false;																			//						逆行は終了
						}																									//				}
					}																										//			}
					else	{																								//			else	{・・逆行中でない
						if ( G_sell == false && B_Start == false &&Close[i] >= Sen1_0 ) 	{			//				if(逆行売りでなく、開始買いでなく終値が先行スパン１以上）
							buy = true;																					//					買い
						}																									//				}
					}																										//			}
				}																											//		}
			}																												//	}
			else if ( Sell_Signal == true ) {																	//	else	if(売りシグナル)
				B_Start = false;																						//		買い開始終了
				G_buy = false;																						//		逆行売り終了
				buy = false;																							//		買い終了
				if ( S_Start == true ) {																			//		if(売りシグナル開始）	
					if (Close[i] > Sen1_0 ) 	{																	//			if(終値が先行スパン１より上）・・強力な売りシグナル
						Gakou = false;																					//				逆行ではない
						S_sell = true;																					//				開始売り
					}																										//			}
					else  	{																							//			else {
						Gakou_cnt= 1;																					//				逆行カウンタを１とする
						BandS_Price = Close[i];																			//				逆行価格に終値を保存する
						Gakou = true;																					//				逆行判定中
					}																										//			}
					S_Start = false;																					//			売りシグナル開始終了
				}																											//		}
				else {																									//		else	{・・買いシグナル開始でない場合			
					if ( Gakou == true ) {																			//			if(逆行中）
						if ( BandS_Price > Close[i] ) {																//				if(逆行価格が終値より大きい)
							BandS_Price = Close[i];																		//					逆行価格に終値を保存
							Gakou_cnt++;																				//					逆行カウンタを＋１する
							if ( Gakou_cnt >Gakou_Candle ) {														//					if (逆行カウンタ＞逆行判定カウンタ）	{
               			iBund   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,i);	//						ボリンジャーバンド－２σを計算
								if ( ( Sen1_0 -Close[i]) >= Point * Pips || Close[i] <= iBund ) {		//						if(先行スパン１と終値の差が指定Pips以上で終値が－２σ以下）	{
									G_sell = true;																		//							逆行買い
								}
							   Gakou = false;																		//							逆行は終了
							}																								//					}
						}																									//				}
						else {																							//				else	{・・逆行価格が終値以下
               		iBund   = iBands(NULL,0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,i);		//					ボリンジャーバンド－２σを計算
							if ( (Sen1_0 -Close[i]) >= Point * Pips || Close[i] <= iBund ) {			//					if(先行スパン１と終値の差が指定Pips以上で終値が－２σ以下）	{
								G_sell = true;
							}																								//					}
							Gakou = false;																			//						逆行は終了
						}																									//				}
					}																										//			}
					else	{																								//			else	{・・逆行中でない
						if ( G_buy == false && S_Start == false && Close[i] <= Sen1_0 ) {			//				if(逆行買いでなく、開始売りでなく終値が先行スパン１以下）
							sell = true;
																												//					売り
						}																									//				}
					}																										//			}
				}																											//		}
			}																												//	}
			BandS = NO_POSITION;																						//	売買をノーポジションとする
			if ( O_BandS == NO_POSITION )	{																		//	if ( 前回売買がノーポジション）	{
				if ( B_Start == true ) {																			//		if (買い開始）
					BandS = BUY_START;																				//			売買を買い開始とする
               BandS_Price = Close[i];
				}																											//		}
				if ( G_buy == true ) {																				//		if (逆行買い）
					BandS = BUY_GYAKKO;																				//			売買を逆行買いとする
               BandS_Price = Close[i];
				}																											//		}
				if ( buy == true ) {																					//		if (買い）
					BandS = BUY_NORMAL;																				//			売買を買いとする
				}																											//		}
				if ( S_Start == true ) {																			//		if (売り開始）
					BandS = SELL_START;																				//			売買を売り開始とする
               BandS_Price = Close[i];
				}																											//		}
				if ( G_sell == true ) {																				//		if (逆行売り）
					BandS = SELL_GYAKKO;																				//			売買を逆行売りとする
               BandS_Price = Close[i];
				}																											//		}
				if ( sell == true ) {																				//		if (買い）
					BandS = SELL_NORMAL;																				//			売買を売りとする
               BandS_Price = Close[i];
				}																											//		}
			}																												//	}
			else	if ( O_BandS == BUY_START ) {																	//	else	if （前回売買が買い開始）	{
				if ( Close[i] > Sen1_0 ) {																			//		if( 終値が先行スパン１を超えた）	｛
					BandS = BUY_NORMAL;																				//			売買を買いとする
				}																											//		}
				else	if ( Sell_Signal == true ) {																//		else if (売りシグナル中）｛
					BandS = BUY_START_KESSAI;																		//			決済を買い開始決済とする
				}
				else  BandS = O_BandS;																											//		}
			}																												//	}
			else if ( O_BandS == BUY_GYAKKO ) {																	//	else if (前回売買が逆行買い）
				if ( Close[i]  > BandS_Price+Point * Pips )	{																		//		if(終値が更に安くなっている）	｛
					BandS = BUY_GYAKKO_KESSAI;																	// 		決済とする
				}																											//		}
				else	if ( Close[i] <= Sen1_0  || Sell_Signal == true) 	{								//		else if (終値が先行スパン１より大きい）
					BandS = BUY_GYAKKO_KESSAI;																	// 		決済とする
				}																											//		}
				else  BandS = O_BandS;																											//		}
			}																												//	}
			else if ( O_BandS == BUY_NORMAL ) {																	//	else if (前回売買が買い）
				if ( Close[i] < Sen1_0 && Sen1_0 < Sen1_1 && (Sen1_0+Sen2_0)/2 > Close[i] )	{																		//		if ( 終値が先行スパン１を下回った）
					BandS = BUY_NORMAL_KESSAI;																	//			決済とする
				}																											//		}
				else  BandS = O_BandS;																											//		}
			}																												//	}
			else	if ( O_BandS == SELL_START ) {																//	else	if （前回売買が買い開始）	{
				if ( Close[i] < Sen1_0 ) {																			//		if( 終値が先行スパン１を超えた）	｛
					BandS = SELL_NORMAL;																				//			売買を買いとする
				}																											//		}
				else	if ( Buy_Signal == true ) {																//		else if (売りシグナル中）｛
					BandS = SELL_START_KESSAI;																	//			決済を買い開始決済とする
				}																											//		}
				else  BandS = O_BandS;																											//		}
			}																												//	}
			else if ( O_BandS == SELL_GYAKKO ) {																	//	else if (前回売買が逆行買い）
				if ( Close[i]  < BandS_Price-Point * Pips)	{																		//		if(終値が更に安くなっている）	｛
					BandS = SELL_GYAKKO_KESSAI;																	// 		決済とする
				}																											//		}
				else	if ( Close[i] >= Sen1_0 || Buy_Signal == true) 	{																//		else if (終値が先行スパン１より大きい）
					BandS = SELL_GYAKKO_KESSAI;																	// 		決済とする
				}																											//		}
				else  BandS = O_BandS;																											//		}
			}																												//	}
			else if ( O_BandS == SELL_NORMAL ) {																//	else if (前回売買が売り）
				if ( Close[i] > Sen1_0 &&  Sen1_0 >= Sen1_1 && (Sen1_0+Sen2_0)/2 < Close[i]  )	{																		//		if ( 終値が先行スパン１を下回った）
					BandS = SELL_NORMAL_KESSAI;																	//			決済とする
				}																											//		}
				else  BandS = O_BandS;																											//		}
			}
			Kind = 0;
         if ( O_BandS != BandS ) {
            switch(BandS)  {
            case BUY_START:
               BuyArrow[i] = Low[i] - Point * Signal_Pos;
               Kind = BUY_START;
               break;               
            case BUY_GYAKKO:
               BuyGyakouArrow[i] = High[i] + Point * Signal_Pos;
               Kind = BUY_GYAKKO;
               break;               
            case BUY_NORMAL:
               if ( O_BandS != BUY_START) {
                  BuyArrow[i] = Low[i] - Point * Signal_Pos;
                  Kind = BUY_NORMAL;
               }
               break;               
            case SELL_START:
               SellArrow[i] = High[i] + Point * Signal_Pos;
               Kind = SELL_START;
               break;               
            case SELL_GYAKKO:
               SellGyakouArrow[i] = Low[i] - Point * Signal_Pos;
               Kind = SELL_GYAKKO;
               break;               
            case SELL_NORMAL:
               if ( O_BandS != SELL_START) {
                  SellArrow[i] = High[i] + Point * Signal_Pos;
                  Kind = SELL_NORMAL;
               }
               break;               
            case BUY_START_KESSAI:
               BuyKessaiArrow[i] = High[i] + Point * Signal_Pos;
               Kind = BUY_START_KESSAI;
               BandS = NO_POSITION;
               break;               
            case BUY_GYAKKO_KESSAI:
               SellGyakouKessaiArrow[i] = Low[i] - Point * Signal_Pos;;
               Kind = BUY_GYAKKO_KESSAI;
               BandS = NO_POSITION;
               break;               
            case BUY_NORMAL_KESSAI:
               BuyKessaiArrow[i] = High[i] + Point * Signal_Pos;
               Kind = BUY_NORMAL_KESSAI;
               BandS = NO_POSITION;
               break;               
            case SELL_START_KESSAI:
               SellKessaiArrow[i] =Low[i] - Point * Signal_Pos;
               Kind = SELL_START_KESSAI;
               BandS = NO_POSITION;
               break;               
            case SELL_GYAKKO_KESSAI:
               SellGyakouKessaiArrow[i] = High[i] + Point * Signal_Pos;
               Kind = SELL_GYAKKO_KESSAI;
                BandS = NO_POSITION;
               break;               
            case SELL_NORMAL_KESSAI:
               SellKessaiArrow[i] = Low[i] - Point * Signal_Pos;;
               Kind = SELL_NORMAL_KESSAI;
                BandS = NO_POSITION;
               break;               
            }           
		      O_BandS = BandS;																						   //	前回売買に今回売買を設定
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
            double chiko;
            chiko =  iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,4,25);           
         switch(Kind)  {
            case BUY_START:
            case BUY_NORMAL:
               message= "スパンモデル買いシグナル"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
            case BUY_GYAKKO:
               message= "スパンモデル逆行売りシグナル"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
            case SELL_START:
            case SELL_NORMAL:
               message= "スパンモデル売りシグナル"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
            case SELL_GYAKKO:
               message= "スパンモデル逆行買いシグナル"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
            case BUY_START_KESSAI:
            case BUY_NORMAL_KESSAI:
               message= "スパンモデル買い決済シグナル"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
            case BUY_GYAKKO_KESSAI:
               message= "スパンモデル逆行売り決済シグナル"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
            case SELL_START_KESSAI:
            case SELL_NORMAL_KESSAI:
               message= "スパンモデル売り決済シグナル"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
            case SELL_GYAKKO_KESSAI:
               message= "スパンモデル逆行買い決済シグナル"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
         }           
         if (Kind !=0 ) SendMail("スパンモデル決済版 "+"["+Symbol()+"]["+Period()+"]",message);
      }
      if (Alertflag== true) {
         if ( buy == true ) {
            Alert("Spanmodel Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
         }
         if ( sell == true ) {
            Alert("Spanmodel  Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
         }
         Alertflag = false;

      }
      Emailflag = false;                      //メール送信設定
      Alertflag = false;                      //アラート出力設定
   }


   return(0);
}
bool Supper_Bollin_Chk(int Func,datetime Time_Current)
{
   string chk_time;
   int Time_Chk;
   datetime H1_Time;
   double array[][6];
   double sigma;
   chk_time = TimeToStr(Time_Current,TIME_MINUTES);
   chk_time = StringSubstr(chk_time,4,2);
   ArrayCopyRates(array,NULL,PERIOD_H1);
   H1_Time = StrToTime(TimeToStr(Time_Current,TIME_DATE) + " " + TimeHour(Time_Current)+":00");
   Time_Chk = iBarShift(NULL,PERIOD_H1,H1_Time,false);
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
            sigma = iBands(NULL,PERIOD_H1,21,1,0,PRICE_CLOSE,MODE_UPPER,Time_Chk + i);
            if ( sigma > array[Time_Chk+i][4] ) {
               Flag = false;
               break;
            }
         }
         break;
         case 2:
         for ( i = 0 ; i < Keizoku_Time ; i++) {
            sigma = iBands(NULL,PERIOD_H1,21,1,0,PRICE_CLOSE,MODE_LOWER,Time_Chk + i);;
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