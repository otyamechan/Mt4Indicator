//+------------------------------------------------------------------+
//|                                                     Leverage.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_chart_window


extern int Leverage = 20;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {

   string symbol = StringSubstr(Symbol(), 0, 3) + AccountCurrency();
   if( StringLen(Symbol())>6 )symbol = symbol + StringSubstr(Symbol(), 6);
   double value1 = iClose(symbol, 0, 0);
   if(value1 == 0) value1 = 1;
   
   double lots = Leverage * AccountFreeMargin() / MarketInfo(Symbol(),MODE_LOTSIZE) / value1;

   double minlots = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlots = MarketInfo(Symbol(), MODE_MAXLOT);
   lots = NormalizeDouble(lots,2);
   if(lots < minlots) lots = minlots;
   if(lots > maxlots) lots = maxlots;
   
   Comment("Lots >>> ",lots,"       (Leverage",Leverage,")");

   

   return(0);
  } 
  
int start()
  {
  
   string symbol = StringSubstr(Symbol(), 0, 3) + AccountCurrency();
   if( StringLen(Symbol())>6 )symbol = symbol + StringSubstr(Symbol(), 6);
   double value1 = iClose(symbol, 0, 0);
   if(value1 == 0) value1 = 1;
   
   double lots = Leverage * AccountFreeMargin() / MarketInfo(Symbol(),MODE_LOTSIZE) / value1;

   double minlots = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlots = MarketInfo(Symbol(), MODE_MAXLOT);
   if(lots < minlots) lots = minlots;
   if(lots > maxlots) lots = maxlots;
   lots = NormalizeDouble(lots,2);
   Comment("Lots >>> ",lots,"       (Leverage",Leverage,")");

     
   return(0);
  }
//+------------------------------------------------------------------+