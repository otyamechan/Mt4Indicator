//+------------------------------------------------------------------+
//|                                        a_MA_CrossAlert_Email.mq4 |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Otyame"
#property link      ""

#property indicator_buffers 3

#property indicator_chart_window

#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Black

//---- buffers
double UpArrow[];
double DownArrow[];
double KessaiArrow[];

string message;

extern int Tenkan = 9;           //転換線
extern int Kijun = 26;           //基準線 
extern int Senkou = 52;          //先行スパン 
extern  bool kansi_5m = true;    //5分足考慮
extern  bool kansi_15m = true;   //15分足考慮
extern  bool kansi_30m = true;   //30分足考慮
extern  bool kansi_1H = true;    //1時間足考慮
extern  bool kansi_4H = true;    //4時間足考慮
extern  bool kansi_1D = true;    //日足考慮
 
extern bool AlertON=true;        //アラート表示　
extern bool EmailON=true;        //メール送信

bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

datetime TimeOld;
datetime k5mtime[];              //5分足格納用
datetime k15mtime[];             //15分足格納用
datetime k30mtime[];             //30分足格納用
datetime k1Htime[];              //1時間足格納用
datetime k4Htime[];              //4時間足格納用
datetime k1Dtime[];              //日足格納用


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
   int c_5m,c_15m,c_30m,c_1H,c_4H,c_1D;         //時間位置
   bool buy = true;
   bool sell = true;
   double Sen1_0,Sen1_1,Sen2_0,Sen2_1;          //クロスチェック用
   double Sen1_5m,Sen2_5m,Sen1_15m,Sen2_15m;      //上位足確認用
   double Sen1_30m,Sen2_30m,Sen1_1H,Sen2_1H;    
   double Sen1_4H,Sen2_4H,Sen1_1D,Sen2_1D;    
   int count_5m = ArrayCopySeries(k5mtime,MODE_TIME,Symbol(),5);        //5分足時間格納
   int count_15m = ArrayCopySeries(k15mtime,MODE_TIME,Symbol(),15);     //15分足時間格納
   int count_30m = ArrayCopySeries(k30mtime,MODE_TIME,Symbol(),30);     //30分足時間格納
   int count_1H = ArrayCopySeries(k1Htime,MODE_TIME,Symbol(),60);       //1時間足時間格納
   int count_4H = ArrayCopySeries(k4Htime,MODE_TIME,Symbol(),240);      //4時間足時間格納
   int count_1D = ArrayCopySeries(k1Dtime,MODE_TIME,Symbol(),1440);     //日足時間格納
    


   if (Time[0] != TimeOld)                      //時間が更新された場合
   {
      //アラートと、メール処理をセットする
      Emailflag = EmailON;                      //メール送信設定
      Alertflag = AlertON;                      //アラート出力設定
      TimeOld = Time[0];                        //時間を更新
    }
    else {
      Emailflag = false;                        //メール送信設定
      Alertflag = false;                        //アラート表示設定
    }
   
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   switch(Period())
   {
      case 1 : 
        for (c_5m = 0 ;Time[limit-1] <= k5mtime[c_5m]; c_5m++);
      case 5 :
        for (c_15m = 0 ;Time[limit-1] <= k15mtime[c_15m]; c_15m++);
      case 15 :
        for (c_30m = 0 ;Time[limit-1] <= k30mtime[c_30m]; c_30m++);
      case 30 :
        for (c_1H = 0 ;Time[limit-1] <= k1Htime[c_1H]; c_1H++);
      case 60 :
        for (c_4H = 0 ;Time[limit-1] <= k4Htime[c_4H]; c_4H++);
      case 240 :
        for (c_1D = 0 ;Time[limit-1] <= k1Dtime[c_1D]; c_1D++);
   }
   for(i= limit-1;i>=1;i--){
      switch(Period())
      {
      case 1: 
         if ( c_5m -1 >= 0) {
            if (Time[i] == k5mtime[c_5m-1]) c_5m--;
         }
         if ( kansi_5m == true ) {
           Sen1_5m = iCustom(NULL,5,"span_model",Kijun,Tenkan,Senkou,5,c_5m);
           Sen2_5m = iCustom(NULL,5,"span_model",Kijun,Tenkan,Senkou,6,c_5m);

         }
      case 5 :
            if ( c_15m -1 >= 0) {
               if (Time[i] == k15mtime[c_15m-1]) c_15m--;
            }
            if ( kansi_15m == true ) {
               Sen1_15m = iCustom(NULL,15,"span_model",Kijun,Tenkan,Senkou,5,c_15m);
               Sen2_15m = iCustom(NULL,15,"span_model",Kijun,Tenkan,Senkou,6,c_15m);
            }
      case 15 :
            if ( c_30m -1 >= 0) {
               if (Time[i] == k30mtime[c_30m-1]) c_30m--;
            }
             if ( kansi_30m == true ) {
               Sen1_30m = iCustom(NULL,30,"span_model",Kijun,Tenkan,Senkou,5,c_30m);
               Sen2_30m = iCustom(NULL,30,"span_model",Kijun,Tenkan,Senkou,6,c_30m);
            }
     case 30 :
            if ( c_1H-1 >= 0) {
               if (Time[i] == k1Htime[c_1H-1]) c_1H--;
            }
            if ( kansi_1H == true ) {
               Sen1_1H = iCustom(NULL,60,"span_model",Kijun,Tenkan,Senkou,5,c_1H);
               Sen2_1H = iCustom(NULL,60,"span_model",Kijun,Tenkan,Senkou,6,c_1H);
            }
      case 60 :
            if ( c_4H -1 >= 0) {
               if (Time[i] == k4Htime[c_4H-1]) c_4H--;
            }
            if ( kansi_4H == true ) {
               Sen1_4H = iCustom(NULL,240,"span_model",Kijun,Tenkan,Senkou,5,c_4H);
               Sen2_4H = iCustom(NULL,240,"span_model",Kijun,Tenkan,Senkou,6,c_4H);
            }

      case 240 :
            if ( c_1D -1 >= 0) {
               if (Time[i] == k1Dtime[c_1D-1]) c_1D--;
            }
            if ( kansi_1D == true ) {
               Sen1_1D = iCustom(NULL,1440,"span_model",Kijun,Tenkan,Senkou,5,c_1D);
               Sen2_1D = iCustom(NULL,1440,"span_model",Kijun,Tenkan,Senkou,6,c_1D);
            }
      }
      Sen1_0 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i);
      Sen1_1 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i+1);
      Sen2_0 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i);
      Sen2_1 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i+1);
      buy = false;
      sell = false;
      if(Sen1_0 > Sen2_0 && Sen1_1 <= Sen2_1){
         buy = true;
         if ( Period() == 1 ) {
            if ( kansi_5m == true ) {   
               if ( Sen1_5m <= Sen2_5m )  buy = false;
            }
            if ( kansi_15m == true && buy == true ) {   
               if ( Sen1_15m <= Sen2_15m )  buy = false;
            }
            if ( kansi_30m == true && buy == true ) {   
               if ( Sen1_30m <= Sen2_30m )  buy = false;
            }
            if ( kansi_1H == true && buy == true ) {   
               if ( Sen1_1H <= Sen2_1H )  buy = false;
            }
            if ( kansi_4H == true && buy == true ) {   
               if ( Sen1_4H <= Sen2_4H )  buy = false;
            }
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D <= Sen2_1D )  buy = false;

            }
         }
         else if ( Period() == 5) {
            if ( kansi_15m == true && buy == true ) {   
               if ( Sen1_15m <= Sen2_15m )  buy = false;
            }
            if ( kansi_30m == true && buy == true ) {   
               if ( Sen1_30m <= Sen2_30m )  buy = false;
            }
            if ( kansi_1H == true && buy == true ) {   
               if ( Sen1_1H <= Sen2_1H )  buy = false;
            }
            if ( kansi_4H == true && buy == true ) {   
               if ( Sen1_4H <= Sen2_4H )  buy = false;
            }
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D <= Sen2_1D )  buy = false;

            }
         }
         else if ( Period() == 15) {
            if ( kansi_30m == true && buy == true ) {   
               if ( Sen1_30m <= Sen2_30m )  buy = false;
            }
            if ( kansi_1H == true && buy == true ) {   
               if ( Sen1_1H <= Sen2_1H )  buy = false;
            }
            if ( kansi_4H == true && buy == true ) {   
               if ( Sen1_4H <= Sen2_4H )  buy = false;
            }
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D <= Sen2_1D )  buy = false;

            }
         }
         
         else if ( Period() == 30) {
            if ( kansi_1H == true && buy == true ) {   
               if ( Sen1_1H <= Sen2_1H )  buy = false;
            }
            if ( kansi_4H == true && buy == true ) {   
               if ( Sen1_4H <= Sen2_4H )  buy = false;
            }
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D <= Sen2_1D )  buy = false;

            }
         }
         else if ( Period() == 60) {
            if ( kansi_4H == true && buy == true ) {   
               if ( Sen1_4H <= Sen2_4H )  buy = false;
            }
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D <= Sen2_1D )  buy = false;

            }
         }
         else if ( Period() == 240) {
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D <= Sen2_1D )  buy = false;

            }
         }
      }
      else if(Sen1_0 < Sen2_0 && Sen1_1 >= Sen2_1){
         sell = true;
         if ( Period() == 1 ) {
            if ( kansi_5m == true ) {   
               if ( Sen1_5m >= Sen2_5m )  sell = false;
            }
            if ( kansi_15m == true && buy == true ) {   
               if ( Sen1_15m >= Sen2_15m )  sell = false;
            }
            if ( kansi_30m == true && buy == true ) {   
               if ( Sen1_30m >= Sen2_30m )  sell = false;
            }
            if ( kansi_1H == true && buy == true ) {   
               if ( Sen1_1H >= Sen2_1H )  sell = false;
            }
            if ( kansi_4H == true && buy == true ) {   
               if ( Sen1_4H >= Sen2_4H )  sell = false;
            }
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D >= Sen2_1D )  sell = false;

            }
         }
         else if ( Period() == 5) {
            if ( kansi_15m == true && buy == true ) {   
               if ( Sen1_15m >= Sen2_15m )  sell = false;
            }
            if ( kansi_30m == true && buy == true ) {   
               if ( Sen1_30m >= Sen2_30m )  sell = false;
            }
            if ( kansi_1H == true && buy == true ) {   
               if ( Sen1_1H >= Sen2_1H )  sell = false;
            }
            if ( kansi_4H == true && buy == true ) {   
               if ( Sen1_4H >= Sen2_4H )  sell = false;
            }
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D >= Sen2_1D )  sell = false;

            }
         }
         else if ( Period() == 15) {
            if ( kansi_30m == true && buy == true ) {   
               if ( Sen1_30m >= Sen2_30m )  sell = false;
            }
            if ( kansi_1H == true && buy == true ) {   
               if ( Sen1_1H >= Sen2_1H )  sell = false;
            }
            if ( kansi_4H == true && buy == true ) {   
               if ( Sen1_4H >= Sen2_4H )  sell = false;
            }
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D >= Sen2_1D )  sell = false;

            }
         }
         else if ( Period() == 30) {
            if ( kansi_1H == true && buy == true ) {   
               if ( Sen1_1H >= Sen2_1H )  sell = false;
            }
            if ( kansi_4H == true && buy == true ) {   
               if ( Sen1_4H >= Sen2_4H )  sell = false;
            }
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D >= Sen2_1D )  sell = false;

            }
         }
         else if ( Period() == 60) {
            if ( kansi_4H == true && buy == true ) {   
               if ( Sen1_4H >= Sen2_4H )  sell = false;
            }
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D >= Sen2_1D )  sell = false;

            }
         }
         else if ( Period() == 240) {
            if ( kansi_1D == true && buy == true ) {   
               if ( Sen1_1D >= Sen2_1D )  sell = false;

            }
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
   }  
      if (Emailflag== true) {
         if ( buy == true ) {
               message= "Buy Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+Symbol()+","+Period()+"\r\n 現在値="+DoubleToStr(Close[0],4); 
         }
         if ( sell == true ) {
               message= "Sell Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+Symbol()+","+Period()+"\r\n 現在値="+DoubleToStr(Close[0],4); 
  
         }

      if ( buy == true || sell == true ) SendMail("Span model signal",message);


      buy = false;
      sell = false;
      Emailflag = false;      
   }
   return(0);
}

