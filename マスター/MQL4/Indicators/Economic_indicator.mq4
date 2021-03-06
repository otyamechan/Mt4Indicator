//+------------------------------------------------------------------+
//|                                           Economic_indicator.mq4 |
//|                                                            Rondo |
//|                                  http://fx-dollaryen.seesaa.net/ |
//+------------------------------------------------------------------+

/**********************************************************/
/* 経済指標データ元 */ 
string urlTitle = "みんなのFX 【週間経済指標カレンダー】";
string url = "http://min-fx.jp/market/indicators/";
/**********************************************************/


#property copyright "Rondo"
#property link      "http://fx-dollaryen.seesaa.net/"
#property version "1.1"
#property description " "
#property description "[DLLの使用を許可する]にチェックを入れてください。"

#property indicator_chart_window
#property strict


#define INTERNET_FLAG_RELOAD            0x80000000
#define SW_SHOW 5

#import "wininet.dll"
   int InternetOpenW(string, int, string, string, int);
   int InternetOpenUrlW(int, string, string, int, int, int);
   int InternetReadFile(int hFile, uchar &sBuffer[], int lNumBytesToRead, int &lNumberOfBytesRead[]);   
   int InternetCloseHandle(int);

#import "kernel32.dll"
   void SleepEx(int dwMilliseconds, bool bAlertable);

#import "shell32.dll"
   int ShellExecuteW(int hWnd, string lpVerb, string lpFile, string lpParameters, string lpDirectory, int nCmdShow);
#import

#include <Arrays\ArrayChar.mqh>


input bool simple = true;  //重要度低、似た指標省略
input int FontSize = 10;  //フォントサイズ
input ENUM_BASE_CORNER Corner = CORNER_LEFT_UPPER;  //表示位置
input int Basic_X = 0; //横軸
input int Basic_Y = 0; //縦軸

input color comingColor = White; //これからの指標
input color importantColor = Gold; //重要度が高い指標
input color closeColor = Gray; //終わった指標

string sName = "EI";
string mainUrl = "http://min-fx.jp/if/market/indicators/if_indicators_w/";
string EI[][7];
string country[13] = {"USD", "EUR", "GBP", "JPY", "AUD", "CHF", "CAD", "NZD", "ZAR", "DEM", "HKD", "SGD", "FRF"};
string webContent = "";
bool updateCheck = true;
datetime updateCheckTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){

   if(IsDllsAllowed()==false){
      objCreateText(sName+"_error1", "[DLLの使用を許可する]にチェックを入れてください。", FontSize, Yellow, 10, Basic_Y+25);
      return(0);
   }
   
   ButtonCreate(0, "EcoIn_Button", 0, Basic_X+FontSize*2, Basic_Y+25, 50, 18, Corner, "更新", "MS Gothic");
   objCreateText("EcoIn_Label", urlTitle, FontSize-1, closeColor, Basic_X+FontSize*10, Basic_Y+25);
   
   objDele(sName);
   GrabWeb(mainUrl, webContent);
   show();
      
   EventSetTimer(1);
   
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){

   EventKillTimer();
   
   objDele(sName);
   ObjectDelete("EcoIn_Button");
   ObjectDelete("EcoIn_Label");
   
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){

   static bool checkDone;
   int min = TimeMinute(TimeCurrent());
   
   if(min == 5 || min == 35){
   
      if(!checkDone){
      
         objDele(sName);
         GrabWeb(mainUrl, webContent);
         show();
         checkDone = true;
      }
   }
   else checkDone = false;
   
   return(0);
}

void OnTimer(){

   if(updateCheckTime > TimeLocal()){
   
      ObjectSetString(0, "EcoIn_Button", OBJPROP_TEXT, 
                      IntegerToString(TimeSeconds(updateCheckTime-TimeLocal())));
   
   }
   else{
      ObjectSetInteger(0, "EcoIn_Button", OBJPROP_STATE, false);
      ObjectSetString(0, "EcoIn_Button", OBJPROP_TEXT, "更新");
      updateCheck = true;
   }
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam){
                  
   if(id == CHARTEVENT_OBJECT_CLICK){
         
      if(sparam == "EcoIn_Button"){

         if(updateCheck){

            ObjectSetInteger(0, "EcoIn_Button", OBJPROP_STATE, true);
            updateCheck = false;
            updateCheckTime = TimeLocal()+60;

            objDele(sName);
            GrabWeb(mainUrl, webContent);
            show();
         }
      }
      
      if(sparam == "EcoIn_Label") ShellExecuteW(0, "open", url, "", "", SW_SHOW);
   }
   
   if(id == CHARTEVENT_CLICK){
   
      if(!updateCheck) ObjectSetInteger(0, "EcoIn_Button", OBJPROP_STATE, true);
   
   }
}
 
//+------------------------------------------------------------------+
void show(){

   StringExtract4(webContent, 0, "tbody", webContent);

   int eCounts = StringFindCount3(webContent, "</tr>", 0);
   ArrayResize(EI, eCounts, eCounts);
   
   int nowPosion = 0;
   
   for(int i = 0; i<eCounts; i++){
   
      for(int k = 0; k<7; k++){

         string content = "";
         
         nowPosion = StringExtract4(webContent, nowPosion, "td", content);
         
         if(k == 1){
         
            for(int j = 0; j<13; j++){
               if(StringFind(content, country[j])>=0){
                  content = country[j];
                  break;
               }
            }
         }

         if(k == 2){
         
            if(StringFind(content, "高")>=0) content = "重要度高";
            else if(StringFind(content, "中")>=0) content = "重要度中";
            else content = "重要度低";
         }

         if(k == 3){
            //<span>対策
            if(StringFind(content, "span")>=0){
               string bufContent = "";
               StringExtract4(content, 0, "span", bufContent);
               content = bufContent;
            }
         }
         
         EI[i][k] = content;
      }
   }
   
   int EICounts = 0;
   
   for(int i = 0; i<eCounts; i++){
   
      if(StringFind(EI[i][0], IntegerToString(TimeDay(TimeLocal()))+"日") == 0){
         
         if(simple){
            if(i>0 &&
               StringFind(EI[i-1][3], StringSubstr(EI[i][3], 0, 3), 0) >= 0 &&
               EI[i-1][2] == EI[i][2]) continue; //似た指標
               
            if(EI[i][2] == "重要度低") continue; //重要度が低い
         }
         
         color objColor;
         if(EI[i][6] != "" || (i<eCounts-1 && EI[i+1][6] != "")) objColor = closeColor;
         else{
            if(EI[i][2] == "重要度高") objColor = importantColor;
            else objColor = comingColor;
         }
         
         if(EI[i][0] != "") objCreateText(sName+"["+IntegerToString(i)+"][0]", EI[i][0], FontSize, objColor, Basic_X+FontSize*2, Basic_Y+50+FontSize*2*EICounts);
         if(EI[i][1] != "") objCreateText(sName+"["+IntegerToString(i)+"][1]", EI[i][1], FontSize, objColor, Basic_X+FontSize*12, Basic_Y+50+FontSize*2*EICounts);
         if(EI[i][2] != "") objCreateText(sName+"["+IntegerToString(i)+"][2]", EI[i][2], FontSize, objColor, Basic_X+FontSize*17, Basic_Y+50+FontSize*2*EICounts);
         if(EI[i][3] != "") objCreateText(sName+"["+IntegerToString(i)+"][3]", EI[i][3], FontSize, objColor, Basic_X+FontSize*27, Basic_Y+50+FontSize*2*EICounts);
         if(EI[i][4] != ""){
            if(StringLen(EI[i][4]) > 7) EI[i][4] = StringSubstr(EI[i][4], 0, 7) + "…";
            objCreateText(sName+"["+IntegerToString(i)+"][4]", EI[i][4], FontSize-1, objColor, Basic_X+FontSize*77, Basic_Y+50+FontSize*2*EICounts);
         }
         if(EI[i][5] != ""){
            if(StringLen(EI[i][5]) > 7) EI[i][5] = StringSubstr(EI[i][5], 0, 7) + "…";
            objCreateText(sName+"["+IntegerToString(i)+"][5]", EI[i][5], FontSize-1, objColor, Basic_X+FontSize*87, Basic_Y+50+FontSize*2*EICounts);
         }
         if(EI[i][6] != ""){
            if(StringLen(EI[i][6]) > 7) EI[i][6] = StringSubstr(EI[i][6], 0, 7) + "…";
            objCreateText(sName+"["+IntegerToString(i)+"][6]", EI[i][6], FontSize-1, objColor, Basic_X+FontSize*97, Basic_Y+50+FontSize*2*EICounts);
         }
         
         EICounts++;
      }
   }
   
   if(EICounts == 0) objCreateText(sName+"0", IntegerToString(TimeDay(TimeLocal()))+"日は重要指標ありません", FontSize, closeColor, Basic_X+FontSize*2, Basic_Y+50+FontSize*2*EICounts);
}

//+------------------------------------------------------------------+
void GrabWeb(string strUrl, string& result){  

   int HttpOpen = InternetOpenW("", 0, "", "", 0);
   int HttpRequest = InternetOpenUrlW(HttpOpen, strUrl, NULL, 0, INTERNET_FLAG_RELOAD, 0);
        
   int read[1];
   
   CArrayChar *array = new CArrayChar;
   
   uchar buffer[1024];

   while(true) {
      InternetReadFile(HttpRequest, buffer, 1024, read);
      
      if(read[0]>0){
         array.AddArray(buffer);
         SleepEx(20, false);
      }
      else break;
   }
   
   int total = array.Total();
   
   ArrayResize(buffer, total);
   
   for(int i=0; i<total; i++) buffer[i] = array.At(i);

   result = CharArrayToString(buffer, 0, -1, CP_UTF8);
   
   delete array;

   InternetCloseHandle(HttpRequest);
   InternetCloseHandle(HttpOpen);

   return;

}

//+------------------------------------------------------------------+
int StringFindCount3(string str, string str2, int position){

   int counts = 0;
   
   while(true){
      
      int find = StringFind(str, str2, position);
      if(find != -1){
         counts++;
         position = find + StringLen(str2);
      }
      else break;
   }      
   return(counts);
}

//+------------------------------------------------------------------+
int StringExtract4(string str, int startPosition, string tag, string &content){
  
   int position1 = StringFind(str, ">", StringFind(str, "<"+tag, startPosition)+StringLen("<"+tag))+StringLen(">");
   int position2 = StringFind(str, "</"+tag, position1);

   if(position1 == position2) content = "";
   else content = StringSubstr(str, position1, position2-position1);
   
   int lastPosition = position2+StringLen("</"+tag+">");
   return(lastPosition);
}

//+------------------------------------------------------------------+
void objDele(string objDeleName){

   for(int i=ObjectsTotal(); i>=0; i--){
   
      string objName = ObjectName(i);
      if (StringFind(objName, objDeleName) >= 0) ObjectDelete(objName);
      
   }
}

//+------------------------------------------------------------------+
void objCreateText(string objName, string objContent, int objSize, color objFontColor, int XPosi, int YPosi){

   if(ObjectFind(0,objName) != 0){
      ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetText(objName, objContent, objSize, "MS UI Gothic", objFontColor);
      ObjectSet(objName, OBJPROP_CORNER, Corner);
      ObjectSet(objName, OBJPROP_XDISTANCE, XPosi);
      ObjectSet(objName, OBJPROP_YDISTANCE, YPosi);
   }
   else{
      ObjectSetText(objName, objContent, objSize, "MS UI Gothic", objFontColor);
      ObjectSet(objName, OBJPROP_CORNER, Corner);
      ObjectSet(objName, OBJPROP_XDISTANCE, XPosi);
      ObjectSet(objName, OBJPROP_YDISTANCE, YPosi);
   }
   
   WindowRedraw();
}


//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // 
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=9,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=false,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }

