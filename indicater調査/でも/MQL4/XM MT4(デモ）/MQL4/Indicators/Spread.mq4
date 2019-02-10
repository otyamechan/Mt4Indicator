//+------------------------------------------------------------------+
//|                                                     Leverage.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_minimum 0

//指標バッファ
double Buf0[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{
   
   SetIndexBuffer(0,Buf0);
   Buf0[0] = MarketInfo(Symbol(),MODE_SPREAD);

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+  

int start()
{
      
   if( Buf0[0] != EMPTY_VALUE ) return(0);
   Buf0[0] = MarketInfo(Symbol(),MODE_SPREAD);
   
   return(0);
}
//+------------------------------------------------------------------+