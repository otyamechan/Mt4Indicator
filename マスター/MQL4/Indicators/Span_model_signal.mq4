//+------------------------------------------------------------------+
//|                                        a_MA_CrossAlert_Email.mq4 |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "anchan"
#property link      "http://anchan.jp"

#property indicator_buffers 2

#property indicator_chart_window

#property indicator_color1 Blue
#property indicator_color2 Red

//---- buffers
double UpArrow[];
double DownArrow[];


extern int Tenkan = 9;           //転換線
extern int Kijun = 26;           //基準線 
extern int Senkou = 52;          //先行スパン 


extern bool AlertOn=false;       //アラート
extern bool EmailON=true;        //メール


int maxLines;

datetime TimeOld;

int init()
{

//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,UpArrow);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,DownArrow);
   SetIndexEmptyValue(1,0.0);
   maxLines = WindowBarsPerChart();
   TimeOld = Time[0];

   return(0);
}



int deinit()
{
   return(0);
}



int start()
{

   if (Time[0] != TimeOld)
   {
      //アラートと、メール処理をセットする
      AlertOn = true;
      EmailON = true;
      TimeOld = Time[0];
    }
   double Sen1_0,Sen1_1,Sen2_0,Sen2_1;
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   for(int i= limit-1;i>=0;i--){
      Sen1_0   = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i);
      Sen1_1   = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i+1);
      Sen2_0 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i);
      Sen2_1 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i+1);

      if(Sen1_0 >= Sen2_0 && Sen1_1 < Sen2_1){
         UpArrow[i]=Close[i];//Low[i];
      }else if(Sen1_0 <= Sen2_0 && Sen1_1 > Sen2_1){
         DownArrow[i]=Close[i];//High[i];
      }else{
         UpArrow[i]  = EMPTY_VALUE;
         DownArrow[i]= EMPTY_VALUE;
      }
   }




                  
 //  double crossing=(Buffer2[0]-Buffer1[0])*(Buffer2[1]-Buffer1[1]);
 //  if (crossing < 0 && AlertOn){
 //     Alert("EMA cross on ", Symbol(), " ", Period());
 //     AlertOn=false;
 //  }

 //  if (crossing < 0 && EmailON){
 //     SendMail("MA Cross Alert["+Symbol()+"]"+"["+Period()+"]","LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+Symbol()+","+Period()+"\r\n FastEMA="+DoubleToStr(Buffer1[1],4)+","+DoubleToStr(Buffer1[0],4)+"\r\n SlowEMA="+DoubleToStr(Buffer2[1],4)+","+DoubleToStr(Buffer2[0],4));
 //     EmailON=false;
 
   
   return(0);
}

//+------------------------------------------------------------------+