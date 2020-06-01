
//マジックナンバーの定義
#define MAGIC  1919        

//パラメーターの設定//
extern int RSIPeriod   = 12; //RSIの期間
extern int Long_Point  = 30; //買いエントリーポイント
extern int Short_Point = 60; //売りエントリーポイント
extern int EntryTime   = 6;  //エントリー時間
extern int ExitTime    = 10; //エグジット時間
extern int TP          = 50;  //利益確定ポイント数

extern double Lots     = 1.0;//取引ロット数
extern int Slip        = 10; //許容スリッページ数
extern string Comments = "Hayaoki";//コメント

//変数の設定//
int Ticket_L = 0; //買い注文の結果をキャッチする変数
int Ticket_S = 0; //売り注文の結果をキャッチする変数
int Exit_L   = 0; //買いポジションの決済注文の結果をキャッチする変数
int Exit_S   = 0; //売りポジションの決済注文の結果をキャッチする変数


int start()
  {
    
   //買いポジションの利益確定
   OrderSelect(Ticket_L, SELECT_BY_TICKET);
   
   if(    OrderOpenPrice() + TP * Point <=  Bid
       && ( Ticket_L != 0 && Ticket_L != -1 ) )
    {    
      Exit_L = OrderClose(Ticket_L,Lots,Bid,Slip,Red);
      if( Exit_L ==1 ) {Ticket_L = 0;}
    }       
    
   //売りポジションの利益確定
   OrderSelect(Ticket_S, SELECT_BY_TICKET);
   
   if(    OrderOpenPrice() - TP * Point >=  Ask
       && ( Ticket_S != 0 && Ticket_S != -1 ) )
    {    
      Exit_S = OrderClose(Ticket_S,Lots,Ask,Slip,Blue);
      if( Exit_S ==1 ) {Ticket_S = 0;}
    }     
      
      
   //買いポジションのエグジット
   if(    Hour() == ExitTime
       && ( Ticket_L != 0 && Ticket_L != -1 )  )
    {     
      Exit_L = OrderClose(Ticket_L,Lots,Bid,Slip,Red);
      if( Exit_L ==1 ) {Ticket_L = 0;}
    }    
    
   //売りポジションのエグジット
   if(    Hour() == ExitTime
       && ( Ticket_S != 0 && Ticket_S != -1 ) )
    {     
      Exit_S = OrderClose(Ticket_S,Lots,Ask,Slip,Blue);
      if( Exit_S ==1 ) {Ticket_S = 0;} 
    }   
   
   //買いエントリー
   if(    Hour() == EntryTime && iCustom(NULL,0,"RSI",RSIPeriod,0,1) <= Long_Point 
       && ( Ticket_L == 0 || Ticket_L == -1 ) 
       && ( Ticket_S == 0 || Ticket_S == -1 ))
    {  
      Ticket_L = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
    }
    
   //売りエントリー
   if(    Hour() == EntryTime && iCustom(NULL, 0,"RSI",RSIPeriod,0,1) >= Short_Point 
       && ( Ticket_S == 0 || Ticket_S == -1 )
       && ( Ticket_L == 0 || Ticket_L == -1 ))
    {   
      Ticket_S = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);     
    }
     
   return(0);
  }

