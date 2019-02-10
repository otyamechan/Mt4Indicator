//+------------------------------------------------------------------+
//|                                               BreakOut-EAGLE.mq4 |
//|                                      Color Modified by ut2DaMax  |
//|                                                       2007.10.14 |
//|   ++ modified for those that use Black Backgrounds 4 Charts      |
//|   ++ and I think you will find these colors easier on the eyes   |
//|   ++ this indicator will help you indentify the breakouts        |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                               BreakOut-EAGLE.mq4 |
//|                                                        hapalkos  |
//|                                                       2007.02.11 |
//|   ++ modified so that rectangles do not overlay                  |
//|   ++ this makes color selection more versatile                   |
//|   ++ code consolidated                                           |
//+------------------------------------------------------------------+
#property copyright "hapalkos"
#property link      ""

#property indicator_chart_window
 
extern int    NumberOfDays = 6;        
extern string periodBegin    = "05:00"; 
extern string periodEnd      = "08:00";   
extern string LondonBegin    = "10:00"; 
extern string LondonEnd      = "16:00"; 
extern bool   LondonRealRange = false; 
extern string BoxEnd         = "23:00"; 
extern int    BoxBreakOut_Offset = 1; 
extern color  BoxHLColor       = C'44,50,48';
extern color  BoxBreakOutColor = C'97,82,43';
extern color  BoxLondonColor = Red;
extern color  BoxPeriodColor   = White;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  DeleteObjects();
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
   DeleteObjects();
   return;
}

//+------------------------------------------------------------------+
//| Remove all Rectangles                                            |
//+------------------------------------------------------------------+
void DeleteObjects() {
   ObjectsDeleteAll(0,OBJ_RECTANGLE);     
   return; 
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  datetime dtTradeDate=TimeCurrent();

  for (int i=0; i<NumberOfDays; i++) {
  
    DrawObjects(dtTradeDate, "BraekOutRange " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, periodBegin, BoxEnd, BoxHLColor, BoxBreakOut_Offset, 1);
    if (LondonRealRange){
      DrawObjects(dtTradeDate, "LondonRange " + TimeToStr(dtTradeDate,TIME_DATE), LondonBegin, LondonEnd, LondonBegin, LondonEnd, BoxLondonColor, BoxBreakOut_Offset, 4);
    }else{
      DrawObjects(dtTradeDate, "LondonRange " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, LondonBegin, LondonEnd, BoxLondonColor, BoxBreakOut_Offset, 4);
    }
    DrawObjects(dtTradeDate, "AsianRange " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, periodBegin, periodEnd, BoxPeriodColor, BoxBreakOut_Offset,4);

    dtTradeDate=decrementTradeDate(dtTradeDate);
    while (TimeDayOfWeek(dtTradeDate) > 5) dtTradeDate = decrementTradeDate(dtTradeDate);
  }
}

//+------------------------------------------------------------------+
//| Create Rectangles                                                |
//+------------------------------------------------------------------+

void DrawObjects(datetime dtTradeDate, string sObjName, string sTimeBegin, string sTimeEnd, string sTimeObjBegin, string sTimeObjEnd, color cObjColor, int iOffSet, int iForm) {
  datetime dtTimeBegin, dtTimeEnd,  dtTimeObjBegin, dtTimeObjEnd;
  double   dPriceHigh,  dPriceLow;
  int      iBarBegin,   iBarEnd;

  dtTimeBegin = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeBegin);
  dtTimeEnd = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeEnd);
  dtTimeObjBegin = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeObjBegin);
  dtTimeObjEnd = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeObjEnd);
      
  iBarBegin = iBarShift(NULL, 0, dtTimeBegin);
  iBarEnd = iBarShift(NULL, 0, dtTimeEnd);
  dPriceHigh = High[Highest(NULL, 0, MODE_HIGH, iBarBegin-iBarEnd, iBarEnd)];
  dPriceLow = Low [Lowest (NULL, 0, MODE_LOW , iBarBegin-iBarEnd, iBarEnd)];
 
  ObjectCreate(sObjName, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
  
  ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeObjBegin);
  ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
  
//---- High-Low Rectangle
   if(iForm==1){  
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh);  
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_BACK, True);
   }
   
//---- Upper Rectangle
  if(iForm==2){
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceHigh + iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_BACK, True);
   }
 
 //---- Lower Rectangle 
  if(iForm==3){
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceLow - iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_BACK, True);
   }

//---- Period Rectangle
  if(iForm==4){
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh + iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow - iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_WIDTH, 2);
      ObjectSet(sObjName, OBJPROP_BACK, False);
   }   
      string sObjDesc = StringConcatenate("High: ",dPriceHigh,"  Low: ", dPriceLow, " OffSet: ",iOffSet);  
      ObjectSetText(sObjName, sObjDesc,10,"Times New Roman",Black);
}

//+------------------------------------------------------------------+
//| Decrement Date to draw objects in the past                       |
//+------------------------------------------------------------------+

datetime decrementTradeDate (datetime dtTimeDate) {
   int iTimeYear=TimeYear(dtTimeDate);
   int iTimeMonth=TimeMonth(dtTimeDate);
   int iTimeDay=TimeDay(dtTimeDate);
   int iTimeHour=TimeHour(dtTimeDate);
   int iTimeMinute=TimeMinute(dtTimeDate);

   iTimeDay--;
   if (iTimeDay==0) {
     iTimeMonth--;
     if (iTimeMonth==0) {
       iTimeYear--;
       iTimeMonth=12;
     }
    
     // Thirty days hath September...  
     if (iTimeMonth==4 || iTimeMonth==6 || iTimeMonth==9 || iTimeMonth==11) iTimeDay=30;
     // ...all the rest have thirty-one...
     if (iTimeMonth==1 || iTimeMonth==3 || iTimeMonth==5 || iTimeMonth==7 || iTimeMonth==8 || iTimeMonth==10 || iTimeMonth==12) iTimeDay=31;
     // ...except...
     if (iTimeMonth==2) if (MathMod(iTimeYear, 4)==0) iTimeDay=29; else iTimeDay=28;
   }
  return(StrToTime(iTimeYear + "." + iTimeMonth + "." + iTimeDay + " " + iTimeHour + ":" + iTimeMinute));
}

//+------------------------------------------------------------------+

