
// マジックナンバーの定義
#define MAGIC 1835

// パラメーターの設定//
extern int BandsPeriod = 20; // ボリンジャーバンドの期間設定
extern int BandsShift = 0; // ボリンジャーバンドを右にシフトする設定
extern double BandsDeviations = 2.0;// 標準偏差の設定
extern int RSIPeriod = 12; //RSI の期間設定

extern double Lots = 1.0; // 取引ロット数
extern int Slip = 10; // 許容スリッページ数
extern string Comments = " "; // コメント

// 変数の設定//
int Ticket_L = 0; // 買い注文の結果をキャッチする変数
int Ticket_S = 0; // 売り注文の結果をキャッチする変数
int Exit_L = 0; // 買いポジションの決済注文の結果をキャッチする変数
int Exit_S = 0; // 売りポジションの決済注文の結果をキャッチする変数

double BB_Upper_2 = 0; /*2 本前のバーの上バンドに変身したiCustom 関数
                       を代入する変数*/
double BB_Lower_2 = 0; /*2 本前のバーの下バンドに変身したiCustom 関数
                       を代入する変数*/
double BB_Upper_1 = 0; /*1 本前のバーの上バンドに変身したiCustom 関数
                       を代入する変数*/
double BB_Lower_1 = 0; /*1 本前のバーの下バンドに変身したiCustom 関数
                       を代入する変数*/
double RSI_2 = 0; /*2 本前のバーのRSI に変身したiCustom 関数を代入する
                  変数*/
double RSI_1 = 0; /*1 本前のバーのRSI に変身したiCustom 関数を代入する
                  変数*/

int start()
{

   BB_Upper_2 = iCustom(NULL,0,"Bands",BandsPeriod,
                            BandsShift,BandsDeviations,1,2);
   BB_Lower_2 = iCustom(NULL,0,"Bands",BandsPeriod,
                            BandsShift,BandsDeviations,2,2);
   BB_Upper_1 = iCustom(NULL,0,"Bands",BandsPeriod,
                            BandsShift,BandsDeviations,1,1);
   BB_Lower_1 = iCustom(NULL,0,"Bands",BandsPeriod,
                            BandsShift,BandsDeviations,2,1);
                            
   RSI_2 = iCustom(NULL,0,"RSI",RSIPeriod,0,2);
   RSI_1 = iCustom(NULL,0,"RSI",RSIPeriod,0,1);
   
   
   // 買いポジションのエグジット
   if(   ( BB_Upper_1 < Close[1] && RSI_2 < 70 && RSI_1 >= 70 )
      || ( BB_Upper_2 >= Close[2] && BB_Upper_1 < Close[1] && RSI_1 >= 70)
      && ( Ticket_L != 0 && Ticket_L != -1 ))
      {
         Exit_L = OrderClose(Ticket_L,Lots,Bid,Slip,Red);
         if( Exit_L == 1 ) {Ticket_L = 0;}
      }
      
   // 売りポジションのエグジット
   if(   ( BB_Lower_1 > Close[1] && RSI_2 > 30 && RSI_1 <= 30 )
      || ( BB_Lower_2 <= Close[2] && BB_Lower_1 > Close[1] && RSI_1 <= 30)
      && ( Ticket_S != 0 && Ticket_S != -1 ))
      {
         Exit_S = OrderClose(Ticket_S,Lots,Ask,Slip,Blue);
         if( Exit_S == 1 ) {Ticket_S = 0;}
      }
      
   // 買いエントリー
   if(   ( BB_Lower_1 > Close[1] && RSI_2 > 30 && RSI_1 <= 30 )
      || ( BB_Lower_2 <= Close[2] && BB_Lower_1 > Close[1] && RSI_1 <= 30)
      && ( Ticket_L == 0 || Ticket_L == -1 )
      && ( Ticket_S == 0 || Ticket_S == -1 ))
      {
         Ticket_L = OrderSend(Symbol(),OP_BUY,
         Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   // 売りエントリー
   if(   ( BB_Upper_1 < Close[1] && RSI_2 < 70 && RSI_1 >= 70 )
      || ( BB_Upper_2 >= Close[2] && BB_Upper_1 < Close[1] && RSI_1 >= 70)
      && ( Ticket_S == 0 || Ticket_S == -1 )
      && ( Ticket_L == 0 || Ticket_L == -1 ))
      {
         Ticket_S = OrderSend(Symbol(),OP_SELL,
         Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
   
return(0);
}