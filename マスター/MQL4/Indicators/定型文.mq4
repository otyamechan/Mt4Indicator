
//マジックナンバーの定義
#define MAGIC  4649        

//パラメーターの設定//
extern double Lots = 1.0;     //取引ロット数
extern int Slip = 10;         //許容スリッページ数
extern string Comments =  ""; //コメント

//変数の設定//
int Ticket_L = 0; //買い注文の結果をキャッチする変数
int Ticket_S = 0; //売り注文の結果をキャッチする変数
int Exit_L = 0;   //買いポジションの決済注文の結果をキャッチする変数
int Exit_S = 0;   //売りポジションの決済注文の結果をキャッチする変数


int start()
  {
     
   //買いポジションのエグジット
   if(    ■■■■
       && ( Ticket_L != 0 && Ticket_L != -1 ))
    {     
      Exit_L = OrderClose(Ticket_L,Lots,Bid,Slip,Red);
      if( Exit_L ==1 ) {Ticket_L = 0;}
    }    
    
   //売りポジションのエグジット
   if(    □□□□
       && ( Ticket_S != 0 && Ticket_S != -1 ))
    {     
      Exit_S = OrderClose(Ticket_S,Lots,Ask,Slip,Blue);
      if( Exit_S ==1 ) {Ticket_S = 0;} 
    }   
    
   //買いエントリー
   if(    ▲▲▲▲
       && ( Ticket_L == 0 || Ticket_L == -1 ) 
       && ( Ticket_S == 0 || Ticket_S == -1 ))
    {  
      Ticket_L = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
    }
    
   //売りエントリー
   if(    △△△△
       && ( Ticket_S == 0 || Ticket_S == -1 )
       && ( Ticket_L == 0 || Ticket_L == -1 ))
    {   
      Ticket_S = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);     
    } 
    
     
   return(0);
  }

