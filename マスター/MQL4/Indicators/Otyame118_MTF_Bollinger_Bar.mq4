//+------------------------------------------------------------------+
//|                                      Otyame123_MTF_Bollinger_Bar1.mq4 |
//+------------------------------------------------------------------+
#property copyright   "2015,Otyame Trader"
#property description "Otyame123_MTF_Bollinger_Bar1"

#property indicator_separate_window
#property indicator_minimum -0.5
#property indicator_maximum 3
#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Red

//---- buffers

double up3[];
double up2[];
double up1[];
double up0[];
double down0[];
double down1[];
double down2[];
double down3[];

extern double Data_Pos = 0.0; // Gap between the lines of bars

extern int TimeFrame = 0;

extern int MAPeriod=21;   // Tenkan-sen
extern int BandShift=0;   // Tenkan-sen
extern int BandPrice=PRICE_CLOSE;   // Tenkan-sen
extern int P3Sigma = 233;
extern int P2Sigma = 236;
extern int P1Sigma = 232;
extern int P0Sigma = 110;
extern int M0Sigma = 110;
extern int M1Sigma = 232;
extern int M2Sigma = 238;
extern int M3Sigma = 234;

string TimeFrameStr ="";


string shortname = "";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
  
    switch(TimeFrame)
   {
      case 1 : TimeFrameStr="_M1"; break;
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
   
  
   shortname = "Otyame123_MTF_Bollinger_Bar1("+TimeFrameStr+")";
   
   IndicatorShortName(shortname);
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,P3Sigma);
   SetIndexBuffer(0,up3);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,P2Sigma);
   SetIndexBuffer(1,up2);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,P1Sigma);
   SetIndexBuffer(2,up1);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,P0Sigma);
   SetIndexBuffer(3,up0);
   SetIndexEmptyValue(3,EMPTY_VALUE);

   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,M0Sigma);
   SetIndexBuffer(4,down0);
   SetIndexEmptyValue(4,EMPTY_VALUE);

   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,M1Sigma);
   SetIndexBuffer(5,down1);
   SetIndexEmptyValue(5,EMPTY_VALUE);

   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,M2Sigma);
   SetIndexBuffer(6,down2);
   SetIndexEmptyValue(6,EMPTY_VALUE);

   SetIndexStyle(7,DRAW_ARROW);
   SetIndexArrow(7,M3Sigma);
   SetIndexBuffer(7,down3);
   SetIndexEmptyValue(7,EMPTY_VALUE);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
   shortname = "Otyame123_MTF_Bollinger_Bar1("+TimeFrameStr+")";
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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

   for(i=0,y=0;i<limit;i++)
   {
      if (Time[i]<TimeArray[y]) y++; 
      double sigmaP1 = iBands(NULL, TimeFrame,MAPeriod,1,BandShift,BandPrice,MODE_UPPER,y);
      double sigmaM1 = iBands(NULL, TimeFrame,MAPeriod,1,BandShift,BandPrice,MODE_LOWER,y);
      double sigmaP2 = iBands(NULL, TimeFrame,MAPeriod,2,BandShift,BandPrice,MODE_UPPER,y);
      double sigmaM2 = iBands(NULL, TimeFrame,MAPeriod,2,BandShift,BandPrice,MODE_LOWER,y);
      double sigmaP3 = iBands(NULL, TimeFrame,MAPeriod,3,BandShift,BandPrice,MODE_UPPER,y);
      double sigmaM3 = iBands(NULL, TimeFrame,MAPeriod,3,BandShift,BandPrice,MODE_LOWER,y);
      double MAIN = iBands(NULL, TimeFrame,MAPeriod,1,BandShift,BandPrice,MODE_MAIN,y);
      up3[i] = EMPTY_VALUE;
      up2[i] = EMPTY_VALUE;
      up1[i] = EMPTY_VALUE;
      up0[i] = EMPTY_VALUE;
      down3[i] = EMPTY_VALUE;
      down2[i] = EMPTY_VALUE;
      down1[i] = EMPTY_VALUE;
      down0[i] = EMPTY_VALUE;
      if ( Close[i] >= sigmaP3 ) {
         up3[i] = Data_Pos;
      }
      else if (( Close[i] >= sigmaP2 ) && ( Close[i] < sigmaP3)) {
         up2[i] = Data_Pos;
      }
      else if (( Close[i] >= sigmaP1 ) && ( Close[i] < sigmaP2)) {
         up1[i] = Data_Pos;
      }
     else if (( Close[i] >= MAIN ) && ( Close[i] < sigmaP1)) {
          up0[i] = Data_Pos;
      }
     else if (( Close[i] >= sigmaM1 ) && ( Close[i] < MAIN)) {
          down0[i] = Data_Pos;
      }
     else if (( Close[i] >= sigmaM2 ) && ( Close[i] < sigmaM1)) {
         down1[i] = Data_Pos;
      }
     else if (( Close[i] >= sigmaM3 ) && ( Close[i] < sigmaM2)) {
         down2[i] = Data_Pos;
      }
      else {
         down3[i] = Data_Pos;
      }
   }         


   return(0);
  }
//+------------------------------------------------------------------+

