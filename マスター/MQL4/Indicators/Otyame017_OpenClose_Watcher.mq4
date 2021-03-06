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

#property copyright "Otyame"
#property link      ""

#property indicator_buffers 1

#property indicator_chart_window

#property indicator_color1 Aqua

#property indicator_width1 4



//---- buffers

int Before_Ticket[1];
int After_Ticket[1];
int Before_OrderTotal = 0;
int After_OrderTotal = 0;

extern int Server_Time = 7;
extern int Watch_Cycle = 15;

datetime TimeOld= D'1970.01.01 10:00:00';
int ticket;
int i,y;
string MailHeader;
string message;
bool Search_Flag ;

int init()
{
   return(0);
}
int deinit()
{
   return(0);
}
int start()
{

   if (TimeCurrent() >=  TimeOld+Watch_Cycle)    {                     //時間が更新された場合
      After_OrderTotal = OrdersTotal();
      if ( Before_OrderTotal == 0 ) {
         ArrayResize(Before_Ticket,1);
         if ( After_OrderTotal != 0 ) {
            Before_OrderTotal = 0;
            for ( ticket = 0; ticket<OrdersTotal(); ticket++ ) {
               if ( OrderSelect(ticket ,SELECT_BY_POS) == false ) break;
               if ( Before_OrderTotal == 0) {
                  Before_Ticket[0] = OrderTicket();
               }
               else {
                  ArrayPushBack(Before_Ticket,OrderTicket());
               }     
               MailHeader = "新規注文情報 "+"["+OrderSymbol()+"]";
               message = "*** 新規注文 ***";
               message = message +"\r\n通貨ペア:"+OrderSymbol();
               if ( OrderType() == OP_BUY ) {
                  message = message + " \r\n 注文種類:"+"BUY";
               }
               else if ( OrderType() == OP_SELL)  {
                  message = message + " \r\n注文種類:"+"SELL";
               }
               message = message + " \r\n注文数量:"+OrderLots();
               message = message + " \r\nレート:"+OrderOpenPrice();
               message = message + " \r\nストップ:"+OrderStopLoss();
               message = message + " \r\nリミット:"+OrderTakeProfit();
               message = message + " \r\n含み損益:"+OrderProfit();
               message = message + " \r\nマジックNo．:"+OrderMagicNumber();
               message = message + " \r\nオープン日時:"+TimeToStr(+OrderOpenTime()+Server_Time*3600,TIME_DATE| TIME_MINUTES);
               message = message + " \r\n注文番号:"+OrderTicket();
 
               message = message + " \r\n*** 口座情報 ***";
               message = message + " \r\n口座残高:"+AccountBalance();
               message = message + " \r\n必要証拠金:"+AccountMargin();
               message = message + " \r\n損益合計:"+AccountProfit();
               SendMail(MailHeader,message);
               Before_OrderTotal++;
            }              
         }
      }
      else {
         if ( After_OrderTotal == 0 ) {
            for ( i = 0; i <  Before_OrderTotal ; i++ ) {
               if ( OrderSelect(Before_Ticket[i],SELECT_BY_TICKET) == true ) {
                  MailHeader = "決済情報 "+"["+OrderSymbol()+"]";
                  message = "*** 決済 ***";
                  message = message +"\r\n通貨ペア:"+OrderSymbol();
                  if ( OrderType() == OP_BUY ) {
                     message = message + " \r\n 注文種類:"+"BUY";
                  }
                  else if ( OrderType() == OP_SELL)  {
                     message = message + " \r\n注文種類:"+"SELL";
                  }
                  message = message + " \r\n注文数量:"+OrderLots();
                  message = message + " \r\nオープン:"+OrderOpenPrice();
                  message = message + " \r\nクローズ:"+OrderClosePrice();
                  message = message + " \r\n損益:"+OrderProfit();
                  message = message + " \r\nスワップ:"+OrderSwap();
                  message = message + " \r\nマジックNo．:"+OrderMagicNumber();
                  message = message + " \r\nオープン日時:"+TimeToStr(+OrderOpenTime()+Server_Time*3600,TIME_DATE| TIME_MINUTES);
                  message = message + " \r\nクローズ日時:"+TimeToStr(+OrderCloseTime()+Server_Time*3600,TIME_DATE| TIME_MINUTES);
                  message = message + " \r\n注文番号:"+OrderTicket();
                  message = message + " \r\n*** 口座情報 ***";
                  message = message + " \r\n口座残高:"+AccountBalance();
                  message = message + " \r\n必要証拠金:"+AccountMargin();
                  message = message + " \r\n損益合計:"+AccountProfit();
                  SendMail(MailHeader,message);
               }
            }  
            Before_OrderTotal = 0;
         }
         else {
            ArrayResize(After_Ticket,1);
            for ( ticket = 0; ticket<OrdersTotal(); ticket++ ) {
               After_OrderTotal = 0;
               if ( OrderSelect(ticket ,SELECT_BY_POS) == false ) break;
               if ( After_OrderTotal == 0) {
                  After_Ticket[0] = OrderTicket();
               }
               else {
                  ArrayPushBack(After_Ticket,OrderTicket());
               }
               After_OrderTotal++;     
            }
            for ( i = 0 ; i < Before_OrderTotal ;i++) {
               Search_Flag = false;
               for ( y = 0 ; y < After_OrderTotal ;y++) {
                  if (  Before_Ticket[i] == After_Ticket[y] ) {
                     Search_Flag = true;
                     break;
                  }
               }
               if ( Search_Flag == false ) {
                  if ( OrderSelect(Before_Ticket[i],SELECT_BY_TICKET) == true ) {
                     MailHeader = "決済情報 "+"["+OrderSymbol()+"]";
                     message = "*** 決済 ***";
                     message = message +"\r\n通貨ペア:"+OrderSymbol();
                     if ( OrderType() == OP_BUY ) {
                        message = message + " \r\n 注文種類:"+"BUY";
                     }
                     else if ( OrderType() == OP_SELL)  {
                        message = message + " \r\n注文種類:"+"SELL";
                     }
                     message = message + " \r\n注文数量:"+OrderLots();
                     message = message + " \r\nオープン:"+OrderOpenPrice();
                     message = message + " \r\nクローズ:"+OrderClosePrice();
                     message = message + " \r\n損益:"+OrderProfit();
                     message = message + " \r\nスワップ:"+OrderSwap();
                     message = message + " \r\nマジックNo．:"+OrderMagicNumber();
                     message = message + " \r\nオープン日時:"+TimeToStr(+OrderOpenTime()+Server_Time*3600,TIME_DATE| TIME_MINUTES);
                     message = message + " \r\nクローズ日時:"+TimeToStr(+OrderCloseTime()+Server_Time*3600,TIME_DATE| TIME_MINUTES);
                     message = message + " \r\n注文番号:"+OrderTicket();
                     message = message + " \r\n*** 口座情報 ***";
                     message = message + " \r\n口座残高:"+AccountBalance();
                     message = message + " \r\n必要証拠金:"+AccountMargin();
                     message = message + " \r\n損益合計:"+AccountProfit();
                     SendMail(MailHeader,message);
                  }
               }
            }                 
            for ( i = 0 ; i < After_OrderTotal ;i++) {
               Search_Flag = false;
               for ( y = 0 ; y < Before_OrderTotal ;y++) {
                  if (  Before_Ticket[y] == After_Ticket[i] ) {
                     Search_Flag = true;
                     break;
                  }
               }
               if ( Search_Flag == false ) {
                  if ( OrderSelect(After_Ticket[i],SELECT_BY_TICKET) == true ) {
                     MailHeader = "新規注文情報 "+"["+OrderSymbol()+"]";
                     message = "*** 新規注文 ***";
                     message = message +"\r\n通貨ペア:"+OrderSymbol();
                     if ( OrderType() == OP_BUY ) {
                        message = message + " \r\n 注文種類:"+"BUY";
                     }
                     else if ( OrderType() == OP_SELL)  {
                        message = message + " \r\n注文種類:"+"SELL";
                     }
                     message = message + " \r\n注文数量:"+OrderLots();
                     message = message + " \r\nレート:"+OrderOpenPrice();
                     message = message + " \r\nストップ:"+OrderStopLoss();
                     message = message + " \r\nリミット:"+OrderTakeProfit();
                     message = message + " \r\n含み損益:"+OrderProfit();
                     message = message + " \r\nマジックNo．:"+OrderMagicNumber();
                     message = message + " \r\nオープン日時:"+TimeToStr(+OrderOpenTime(),TIME_DATE| TIME_MINUTES);
                     message = message + " \r\n注文番号:"+OrderTicket();
 
                     message = message + " \r\n*** 口座情報 ***";
                     message = message + " \r\n口座残高:"+AccountBalance();
                     message = message + " \r\n必要証拠金:"+AccountMargin();
                     message = message + " \r\n損益合計:"+AccountProfit();
                     SendMail(MailHeader,message);
                  }
               }
            } 
                
            ArrayResize(Before_Ticket,After_OrderTotal);
            for ( i = 0; i < After_OrderTotal; i++ ) {
               Before_Ticket[i] = After_Ticket[i];
            }
            Before_OrderTotal = After_OrderTotal;
         }
      }
      TimeOld = TimeCurrent();
   }
   return(0);
}

int ArrayPushBack(int& vals[],int val )
{
   int len = ArraySize(vals);
   ArrayResize(vals,len+1);
   vals[len] = val;
   return(len+1);
}

