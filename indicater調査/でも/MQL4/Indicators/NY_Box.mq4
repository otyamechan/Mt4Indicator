//+------------------------------------------------------------------+
//|                                                       NY_Box.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int Start_Hour =10;
extern int End_Hour   =17;

//指標バッファ
double Buf0[];
double Buf1[];

double HH  = 0;
double LL  = 999999;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{
 
   SetIndexBuffer(0,Buf0);
   SetIndexBuffer(1,Buf1);
   SetIndexLabel(0,"HighestHigh");
   SetIndexLabel(1,"LowestLow");

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
{
   
   int limit = Bars-IndicatorCounted();
   if(limit==1) return(0);
 
   for(int i=limit-2; i>=0; i--)
    {        
      if(    (Start_Hour <  End_Hour &&  TimeHour(iTime(NULL,0,i+1)) >= Start_Hour && TimeHour(iTime(NULL,0,i+1)) < End_Hour )
          || (Start_Hour >  End_Hour && (TimeHour(iTime(NULL,0,i+1)) >= Start_Hour || TimeHour(iTime(NULL,0,i+1)) < End_Hour )) 
          ||  Start_Hour == End_Hour )
       {         
         if( HH < High[i+1] )
          {
            HH = High[i+1];             
          }
                     
         if( LL > Low[i+1] )
          {
            LL = Low[i+1];             
          }
       }
       
        
      if( TimeHour(iTime(NULL,0,i+1)) != End_Hour && TimeHour(iTime(NULL,0,i)) == End_Hour )
       {
         Buf0[i] = HH; 
         Buf1[i] = LL; 
         HH = 0;
         LL = 999999; 
       }  
      else
       {
         Buf0[i]= Buf0[i+1]; 
         Buf1[i]= Buf1[i+1];      
       }
       
   }

   return(0);
}
//+----------------------------