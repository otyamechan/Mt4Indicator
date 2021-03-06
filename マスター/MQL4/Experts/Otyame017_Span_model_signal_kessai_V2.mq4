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
#define MAGIC  4649        

#property copyright "Otyame"
#property link      ""



//売買方式
#define	NO_POSITION	0
#define	BUY_NORMAL	1
#define	SELL_NORMAL 2

//決済方式
#define	BUY_NORMAL_KESSAI		13
#define	SELL_NORMAL_KESSAI	16
#define	BUY_TO_SELL	21
#define	SELL_TO_BUY	22

#define UP_DOWN 0
#define UP  1
#define DOWN  2



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
extern int Tenkan = 9;           	//転換線
extern int Kijun = 25;           	//基準線 
extern int Senkou = 52;         	 	//先行スパン 
extern int Signal_Pos = 6;			//逆行判定本数
extern string _Stochastic1 = "Stochsstic set";
extern int KPeriod1 = 20;
extern int DPeriod1 = 5;
extern int SlowDPeriod1 = 10;
extern int MAMethod1 = 3;
extern string _Price1 = "0:Low/High 1:Close/Close";
extern int Price1 = 1;
extern double Uper1 = 80.0;
extern double Lower1 = 20.0;
extern string _Stochastic2 = "Stochsstic set";
extern int KPeriod2 = 8;
extern int DPeriod2 = 4;
extern int SlowDPeriod2= 4;
extern int MAMethod2 = 3;
extern string _Price2 = "0:Low/High 1:Close/Close";
extern int Price2 = 1;
extern double Uper2 = 70.0;
extern double Lower2 = 30.0;

//パラメーターの設定//
extern double Lots = 1.0;     //取引ロット数
extern int Slip = 10;         //許容スリッページ数
extern string Comments =  ""; //コメント


bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

datetime TimeOld= D'1970.01.01 00:00:00';
datetime k1Htime[];              //1時間足格納用

int count_1H ;       //1時間足時間格納
int pos;
double pos_chk;
//変数の設定//
int Ticket_L = 0; //買い注文の結果をキャッチする変数
int Ticket_S = 0; //売り注文の結果をキャッチする変数
int Exit_L = 0;   //買いポジションの決済注文の結果をキャッチする変数
int Exit_S = 0;   //売りポジションの決済注文の結果をキャッチする変数


int Sen1_direct;
int Sen2_direct;

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
double ST_MAIN1,ST_SIGNAL1;
double ST_MAIN2,ST_SIGNAL2;
int start()
{
   int i;


   
         Sen1_0 = iCustom(NULL,0,"span_A",Kijun,Tenkan,Senkou,5,1);							//先行スパン１（最新）
         Sen1_1 = iCustom(NULL,0,"span_A",Kijun,Tenkan,Senkou,5,2);						//先行スパン１（1本前）
         Sen2_0 = iCustom(NULL,0,"span_A",Kijun,Tenkan,Senkou,6,1);							//先行スパン２（最新）
         Sen2_1 = iCustom(NULL,0,"span_A",Kijun,Tenkan,Senkou,6,2);						//先行スパン２（１本前）
         ST_MAIN1 = iStochastic(NULL,0,KPeriod1,DPeriod1,SlowDPeriod1,MAMethod1,Price1,MODE_MAIN,1); 
         ST_SIGNAL1 = iStochastic(NULL,0,KPeriod1,DPeriod1,SlowDPeriod1,MAMethod1,Price1,MODE_SIGNAL,1); 
         ST_MAIN2 = iStochastic(NULL,0,KPeriod2,DPeriod2,SlowDPeriod2,MAMethod2,Price2,MODE_MAIN,1); 
         ST_SIGNAL2 = iStochastic(NULL,0,KPeriod2,DPeriod2,SlowDPeriod2,MAMethod2,Price2,MODE_SIGNAL,1); 


         Kind = 0;																								//売買種別クリア

//売買シグナル判定処理開始
			Buy_Signal = false;																					//買いシグナル
			Sell_Signal = false;																					//売りシグナル
         if(Sen1_0 > Sen2_0  ) {																				//先行スパン１が先行スパン２より上
			   Buy_Signal = true;																					//買いシグナル
	      }																							
			else if (Sen1_0 < Sen2_0  )	{																	//先行スパン１が先行スパン２より下
				Sell_Signal = true;																				//売りシグナル無し
			}
			else	{																									//先行スパン１と先行スパン２が同値
				Buy_Signal = false;																				//買いシグナル無し
				Sell_Signal = false;																				//売りシグナル無し
			}
//売買シグナル判定処理終了
//売買シグナル開始判定処理
         if ( Buy_Signal == true )   {
            if ( (ST_MAIN1 >=  ST_SIGNAL1 || ST_MAIN1 >= Uper1) && ( ST_MAIN2 >= ST_SIGNAL2 || ST_MAIN2 >= Uper2)  ) {
               if (MathAbs( Close[1] - Sen1_0 ) <= 100 ) { 
                  Buy_Signal = true;
                  }
               else  {
                  Buy_Signal = false;
               }
            }
         }
         if ( Sell_Signal == true )   {
            if ( (ST_MAIN1 <=  ST_SIGNAL1 || ST_MAIN1 <= Lower1) && ( ST_MAIN2 <= ST_SIGNAL2 || ST_MAIN2 <= Lower2)  ) {
               if (MathAbs( Close[1] - Sen1_0 ) <= 100 ) { 
                  Sell_Signal = true;
                  }
               else  {
                  Sell_Signal = false;
               }
            }
         }
         switch(O_BandS)   {
            case NO_POSITION:
               if ( Buy_Signal == true )  {
                  BuyArrow[i] = Low[i] - Point * Signal_Pos;
                  BandS = BUY_NORMAL;
                  Kind =  BUY_NORMAL;
               }
               else if ( Sell_Signal == true )  {
                  SellArrow[i] = High[i] + Point * Signal_Pos;
                  BandS = SELL_NORMAL;
                  Kind =  SELL_NORMAL;
               }
               else {
                  BandS = NO_POSITION;
                  Kind = 0;
               }
               break;
            case BUY_NORMAL:
               if ( Buy_Signal == true ) {
                  BandS = BUY_NORMAL;
                  Kind =  0;
               }                  
               else if ( Sell_Signal == true )  {
                  SellArrow[i] = High[i] + Point * Signal_Pos;
                  BandS = SELL_NORMAL;
                  Kind =  BUY_TO_SELL;
               }
               else {
                  BandS = NO_POSITION;
                  BuyKessaiArrow[i] = High[i] + Point * Signal_Pos;
                  Kind = BUY_NORMAL_KESSAI;
               }
               break;
            case SELL_NORMAL:
               if ( Buy_Signal == true ) {
                  BuyArrow[i] = Low[i] - Point * Signal_Pos;
                  BandS = BUY_NORMAL;
                  Kind =  SELL_TO_BUY;
               }                  
               else if ( Sell_Signal == true )  {
                  BandS = SELL_NORMAL;
                  Kind =  0;
               }
               else {
                  BandS = NO_POSITION;
                  SellKessaiArrow[i] = Low[i] - Point * Signal_Pos;
                  Kind = SELL_NORMAL_KESSAI;
               }
               break;
         }
         O_BandS = BandS;   
 
   //買いポジションのエグジット
   if(   (Kind == BUY_NORMAL_KESSAI || Kind ==BUY_TO_SELL)
       && ( Ticket_L != 0 && Ticket_L != -1 ))
    {     
      Exit_L = OrderClose(Ticket_L,Lots,Bid,Slip,Red);
      if( Exit_L ==1 ) {Ticket_L = 0;}
    }    
    
   //売りポジションのエグジット
   if(  (Kind == SELL_NORMAL_KESSAI || Kind == SELL_TO_BUY)
       && ( Ticket_S != 0 && Ticket_S != -1 ))
    {     
      Exit_S = OrderClose(Ticket_S,Lots,Ask,Slip,Blue);
      if( Exit_S ==1 ) {Ticket_S = 0;} 
    }   
    
   //買いエントリー
   if(    (Kind == BUY_NORMAL || Kind == SELL_TO_BUY)
       && ( Ticket_L == 0 || Ticket_L == -1 ) 
       && ( Ticket_S == 0 || Ticket_S == -1 ))
    {  
      Ticket_L = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
    }
    
   //売りエントリー
   if(    (Kind == SELL_NORMAL || Kind == BUY_TO_SELL)
       && ( Ticket_S == 0 || Ticket_S == -1 )
       && ( Ticket_L == 0 || Ticket_L == -1 ))
    {   
      Ticket_S = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);     
    } 



   return(0);
}
