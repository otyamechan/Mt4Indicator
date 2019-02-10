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
double KessaiArrow[];

string message;

extern int Tenkan = 9;           //転換線
extern int Kijun = 26;           //基準線 
extern int Senkou = 52;          //先行スパン 
extern  bool kansi_15m = true;   //15分考慮
extern  bool kansi_1H = true;    //60分考慮
 


extern bool EmailON=true;        //メール


bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

datetime TimeOld;
datetime k15mtime[];
datetime k1Htime[];

int init()
{

//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,UpArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,DownArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,253);
   SetIndexBuffer(2,KessaiArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
 
   TimeOld = Time[0];

   return(0);
}



int deinit()
{
   return(0);
}



int start()
{
   int i;
   int y;
   int z;
   bool buy = true;
   bool sell = true;
   double Sen1_0,Sen1_1,Sen2_0,Sen2_1;
   double Sen1_15m,Sen2_15m,Sen1_1H,Sen2_1H;
   
   
   ArrayCopySeries(k15mtime,MODE_TIME,Symbol(),15);
   ArrayCopySeries(k1Htime,MODE_TIME,Symbol(),60);
    


   if (Time[0] != TimeOld)
   {
      //アラートと、メール処理をセットする
      Emailflag = EmailON;
      TimeOld = Time[0];
    }
    else {
      Emailflag = false;
    }
   
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   int count_15m = ArrayCopySeries(k15mtime,MODE_TIME,Symbol(),15); 
   int count_1H = ArrayCopySeries(k1Htime,MODE_TIME,Symbol(),60); 
    for (y = count_15m -1 ;Time[limit-1] >= k15mtime[y]; y--);
   if (Time[limit-1] > k15mtime[y]) y++;
       
    for (z = count_1H -1 ;Time[limit-1] >= k1Htime[z]; z--);
    if (Time[limit-1] > k1Htime[z]) z++;
   for(i= limit-1;i>=0;i--){
      if (y -1>= 0) {
         if (Time[i] > k15mtime[y-1] ) y--;
      }
      if (z -1>= 0) {
         if (Time[i] > k1Htime[z-1] ) z--;
      }
      
      Sen1_0   = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i);
      Sen1_1   = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i+1);
      Sen2_0 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i);
      Sen2_1 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i+1);
   
      Sen1_15m   = iCustom(NULL,15,"span_model",Kijun,Tenkan,Senkou,5,y);
      Sen2_15m = iCustom(NULL,15,"span_model",Kijun,Tenkan,Senkou,6,y);
      Sen1_1H   = iCustom(NULL,60,"span_model",Kijun,Tenkan,Senkou,5,z);
      Sen2_1H = iCustom(NULL,60,"span_model",Kijun,Tenkan,Senkou,6,z);
      if(Sen1_0 > Sen2_0 && Sen1_1 <= Sen2_1){
            buy = true;
            if( buy == true && kansi_15m == true ) {
               if( Sen1_15m < Sen2_15m ) buy = false;
            }
            if ( buy == true && kansi_1H == true ) {
               if( Sen1_1H < Sen2_1H) buy = false;
            }
         }else if(Sen1_0 < Sen2_0 && Sen1_1 >= Sen2_1){
         sell = true;
         if( sell == true && kansi_15m == true ) {
            if( Sen1_15m > Sen2_15m ) sell = false;
         }
         if ( sell == true && kansi_1H == true ) {
            if( Sen1_1H > Sen2_1H) sell = false;
         }
      }
      if ( buy == true ) {
         UpArrow[i]=Sen1_1;
      }
      else {
         UpArrow[i]  = EMPTY_VALUE;
      }      
      if ( sell == true ) {
         DownArrow[i]=Sen1_1;
      }
      else {
         DownArrow[i]  = EMPTY_VALUE;
      }
      if (Emailflag== true) {
         if ( buy == true ) {
            message= "Buy Chancel["+Symbol()+"]"+"["+Period()+"]"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+Symbol()+","+Period()+"\r\n 現在値="+DoubleToStr(Close[0],4); 
  
         }
          if ( sell == true ) {
            message= "Sell Chancel["+Symbol()+"]"+"["+Period()+"]"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+Symbol()+","+Period()+"\r\n 現在値="+DoubleToStr(Close[0],4); 
  
         }
          if ( buy == true || sell == true ) SendMail("Span model signal",message);

     }
 //     EmailON=false;




      buy = false;
      sell = false;      
  }
                  

 //  if (crossing < 0 && EmailON){
 //     SendMail("MA Cross Alert["+Symbol()+"]"+"["+Period()+"]","LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+Symbol()+","+Period()+"\r\n FastEMA="+DoubleToStr(Buffer1[1],4)+","+DoubleToStr(Buffer1[0],4)+"\r\n SlowEMA="+DoubleToStr(Buffer2[1],4)+","+DoubleToStr(Buffer2[0],4));
 //     EmailON=false;
 
   
   return(0);
}

