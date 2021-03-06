//+------------------------------------------------------------------+
//|                                       Otyame  No.0124             |
//|                            Otyame017_MTF_Chiko_Span_Attaker_Bar.mq4 |
//|                                       2015.11.15                 |
//+------------------------------------------------------------------+

#property copyright   "2015,Otyame Trader"
#property description "Otyame017_MTF_Chiko_Span_Attaker_Bar"
#property indicator_minimum -0.5
#property indicator_maximum 3

#property indicator_buffers 5

#property indicator_separate_window


#property indicator_color1 Blue
#property indicator_color2 Aqua
#property indicator_color3 Red
#property indicator_color4 Violet
#property indicator_color5 Black

#property indicator_width1 0
#property indicator_width2 0
#property indicator_width3 0
#property indicator_width4 0
#property indicator_width4 0


#define NO 0
#define UP 1
#define DOWN 2


//---- buffers
double UpData_UP[];
double UpData_NO[];
double DownData_DOWN[];
double DownData_NO[];
double NoData_NO[];

double MA;
double Usigma_1;
double Lsigma_1;
double Usigma_2;
double Lsigma_2;
double Usigma_3;
double Lsigma_3;
double Chikou;

extern double Data_Pos = 0.0; // Gap between the lines of bars

extern int TimeFrame = 0;


extern string _Super_Bollin = "Super Bollinger Setting";
extern int MAPeriod = 21;            //中心期間
extern   string _MAMethod = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int MAMethod = 0;            //中心線用MA Method
extern int Chikou_Idou = 20;            //遅行スパン描画
extern string _OBJ = "Object Setting";
extern int O_UpData_UP = 110;
extern int O_UpData_NO = 108;
extern int O_DownData_DOWN = 110;
extern int O_DownData_NO = 108;
extern int O_NoData_NO = 108;

int cnt;
bool buy;
bool sell;
string TimeFrameStr;
string shortname;
int O_BandS;
int BandS;
int pos;
int init()
{

//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,O_UpData_UP);
   SetIndexBuffer(0,UpData_UP);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,O_UpData_NO);
   SetIndexBuffer(1,UpData_NO);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,O_DownData_DOWN);
   SetIndexBuffer(2,DownData_DOWN);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,O_DownData_NO);
   SetIndexBuffer(3,DownData_NO);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,O_NoData_NO);
   SetIndexBuffer(4,NoData_NO);
   SetIndexEmptyValue(4,EMPTY_VALUE);
 	IndicatorShortName("Otyame017_MTF_Chiko_Span_Attaker_Bar");
    switch(TimeFrame)
   {
      case 1 :  TimeFrameStr="_M1"; break;
      case 5 : TimeFrameStr="_M5"; break;
      case 15 : TimeFrameStr="_M15"; break;
      case 30 : TimeFrameStr="_M30"; break;
      case 60 : TimeFrameStr="_H1"; break;
      case 240 : TimeFrameStr="_H4"; break;
      case 1440 : TimeFrameStr="_D1"; break;
      case 10080 : TimeFrameStr="_W1"; break;
      case 43200 : TimeFrameStr="_MN1"; break;
      default : TimeFrameStr="_Current Timeframe";
   } 
   
  
   shortname = "Otyame017_MTF_Chiko_Span_Attaker_Bar("+TimeFrameStr+")";
   
   IndicatorShortName(shortname);
   return(0);
}
int deinit()
{
   return(0);
}



int start()
{
   int limit,i,y;
   datetime TimeArray[];
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;

   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 

   limit = Bars - counted_bars;
   if ( limit < 2 ) limit = 2;
   for(i= limit-1;i>=1;i--){
      y = iBarShift(NULL,TimeFrame,Time[i],true);
      if ( Time[i] > TimeArray[y]) {
         y++;
      }
      if ( y != pos ) {
         pos = y;
//      MA   = iMA(NULL,TimeFrame,MAPeriod,0,MAMethod,PRICE_CLOSE,y);
         if (Time[i]<TimeArray[y]) y++; 
         Lsigma_1   = iBands(NULL,TimeFrame,MAPeriod,1,0,PRICE_CLOSE,MODE_LOWER,y);
         Usigma_1   = iBands(NULL,TimeFrame,MAPeriod,1,0,PRICE_CLOSE,MODE_UPPER,y);
//      Lsigma_2   = iBands(NULL,TimeFrame,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,y);
//      Usigma_2   = iBands(NULL,TimeFrame,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,y);
//      Lsigma_3   = iBands(NULL,TimeFrame,MAPeriod,3,0,PRICE_CLOSE,MODE_LOWER,y);
//      Usigma_3   = iBands(NULL,TimeFrame,MAPeriod,3,0,PRICE_CLOSE,MODE_UPPER,y);
         Chikou = iClose(NULL,TimeFrame,y);
         buy = false;
         sell = false;
         if ( ( Chikou > iHigh(NULL,TimeFrame,y+Chikou_Idou) ) && (iClose(NULL,TimeFrame,y) >= Usigma_1)) {
            buy = true;
         }
         if (( Chikou < iLow(NULL,TimeFrame,y+Chikou_Idou) ) && (iClose(NULL,TimeFrame,y) <= Lsigma_1)) {
            sell = true;
         
         }
         if ( buy == true ) {
            BandS = UP;
         }
         else if ( sell == true ) {
            BandS = DOWN;
         }
         else {
            BandS = NO;
         }
         switch(O_BandS)   {
            case NO:
               switch(BandS) {
                  case NO:
                     NoData_NO[i] = Data_Pos;
                     O_BandS = NO;
                     break;
                  case UP:
                     UpData_UP[i] = Data_Pos;
                     O_BandS = UP;
                     break;
                  case DOWN:
                     DownData_DOWN[i] = Data_Pos;
                     O_BandS = DOWN;
                     break;
               }
               break;                    
            case UP:
               switch(BandS) {
                  case NO:
                     UpData_NO[i] = Data_Pos;
                     O_BandS = UP;
                     break;
                  case UP:
                     UpData_UP[i] = Data_Pos;
                     O_BandS = UP;
                     break;
                  case DOWN:
                     DownData_DOWN[i] = Data_Pos;
                     O_BandS = DOWN;
                     break;
               }
               break;                    
            case DOWN:
               switch(BandS) {
                  case NO:
                     DownData_NO[i] = Data_Pos;
                     O_BandS = DOWN;
                     break;
                  case UP:
                     UpData_UP[i] = Data_Pos;
                     O_BandS = UP;
                     break;
                  case DOWN:
                     DownData_DOWN[i] = Data_Pos;
                     O_BandS = DOWN;
                     break;
               }
               break;                    
         }
      }
      else {
         UpData_UP[i] = UpData_UP[i+1];
         UpData_NO[i]= UpData_NO[i+1];
         DownData_DOWN[i]= DownData_DOWN[i+1];
         DownData_NO[i] = DownData_NO[i+1];
         NoData_NO[i] = NoData_NO[i+1];
      }      
      
      
   }
   return(0);
}

         
         
              
            
            














   

