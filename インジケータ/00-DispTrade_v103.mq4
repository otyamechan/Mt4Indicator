//
// "00-DispTrade_v101.mq4" -- Macdtics
//
//    Ver. 1.00  2008/12/23(Tue)  initial version
//    Ver. 1.01  2009/01/13(Tue)  added displaying profit pips
//
//
// File Format:
//    Symbol, entry-date, entry-price, exit-date, exit-price
//
//    ex)
//    EURUSD, 2008/12/22 21:17,-1.39678, 2008/12/22 21:20,1.39697
//    EURUSD, 2008/12/22 21:38,-1.39818, 2008/12/22 21:41,1.39982
//
//
#property  copyright "00"
#property  link      "http://www.mql4.com/"

//---- indicator settings
#property  indicator_chart_window

#property  indicator_buffers  2

#property  indicator_color1  Aqua     // 0: profit
#property  indicator_color2  Magenta  // 1: loss

#property  indicator_width1  3
#property  indicator_width2  3

#property  indicator_style1  STYLE_SOLID
#property  indicator_style2  STYLE_SOLID

//---- defines

//---- indicator parameters
extern int       serverGMT       = 3;                    // server GMT offset hour
extern int       dataGMT         = 3;                    // data/file GMT offset hour
extern double    spread          = -1.0;                  // spread, 0: don't disp for spread, < 0: use MarketInfo(MODE_SPREAD)
extern bool      File_make       = false;                // ファイルを作成する
extern string    tradeFileName   = "trade.txt";          // file name of trade record
extern bool      bVertLine       = true;                 // vertical line on entry/exit time
extern bool      bDispProfit     = true;                 // profit and loss
extern bool      win_flag        = true;
extern bool      lose_flag       = true;
extern bool       winlose_flag   = true;
extern datetime  tStart          = 0;                    // display trades after this time
extern datetime  tEnd            = 0;                    // display trades before this time
extern int       wArrow          = 2;                    // width of entry/exit arrows
extern double    markOffset      = 5;                    // profit/loss mark offset in pips
extern double    profitOffset    = 5;                    // profit offset in pips
extern color     colLong         = DodgerBlue;           // color for long
extern color     colShort        = Crimson;              // color for short
extern color     colHolding      = Black;                // color for holding position
extern color     colProfitPlus   = Aqua;                 // color for profit
extern color     colProfitMinus  = Magenta;              // color for loss
extern int       profitFontSize  = 12;                   // profit font size
extern string    profitFontName  = "Arial";              // profit font name
extern int       nMaxTrade       = 1000;                  // maximum number of trades to display
//
extern datetime  tEntry0         = 0;                    // sample, entry time 0
extern double    pEntry0         = 0;                    // sample, entry price 0, '+' for long '-' for short
extern datetime  tExit0          = 0;                    // sample, exit time 0
extern double    pExit0          = 0;                    // sample, exit price 0, '+' for long '-' for short
//
extern datetime  tEntry1         = 0;                    // entry time 1
extern double    pEntry1         = 0;                    // entry price 1, '+' for long '-' for short
extern datetime  tExit1          = 0;                    // exit time 1
extern double    pExit1          = 0;                    // exit price 1, '+' for long '-' for short
//
extern datetime  tEntry2         = 0;                    // entry time 2
extern double    pEntry2         = 0;                    // entry price 2, '+' for long '-' for short
extern datetime  tExit2          = 0;                    // exit time 2
extern double    pExit2          = 0;                    // exit price 2, '+' for long '-' for short
//
extern datetime  tEntry3         = 0;                    // entry time 3
extern double    pEntry3         = 0;                    // entry price 3, '+' for long '-' for short
extern datetime  tExit3          = 0;                    // exit time 3
extern double    pExit3          = 0;                    // exit price 3, '+' for long '-' for short
//
extern datetime  tEntry4         = 0;                    // entry time 4
extern double    pEntry4         = 0;                    // entry price 4, '+' for long '-' for short
extern datetime  tExit4          = 0;                    // exit time 4
extern double    pExit4          = 0;                    // exit price 4, '+' for long '-' for short
//
extern datetime  tEntry5         = 0;                    // entry time 5
extern double    pEntry5         = 0;                    // entry price 5, '+' for long '-' for short
extern datetime  tExit5          = 0;                    // exit time 6
extern double    pExit5          = 0;                    // exit price 6, '+' for long '-' for short
//
extern datetime  tEntry6         = 0;                    // entry time 6
extern double    pEntry6         = 0;                    // entry price 6, '+' for long '-' for short
extern datetime  tExit6          = 0;                    // exit time 6
extern double    pExit6          = 0;                    // exit price 6, '+' for long '-' for short
//
extern datetime  tEntry7         = 0;                    // entry time 7
extern double    pEntry7         = 0;                    // entry price 7, '+' for long '-' for short
extern datetime  tExit7          = 0;                    // exit time 7
extern double    pExit7          = 0;                    // exit price 7, '+' for long '-' for short
//
extern datetime  tEntry8         = 0;                    // entry time 8
extern double    pEntry8         = 0;                    // entry price 8, '+' for long '-' for short
extern datetime  tExit8          = 0;                    // exit time 8
extern double    pExit8          = 0;                    // exit price 8, '+' for long '-' for short
//
extern datetime  tEntry9         = 0;                    // entry time 9
extern double    pEntry9         = 0;                    // entry price 9, '+' for long '-' for short
extern datetime  tExit9          = 0;                    // exit time 9
extern double    pExit9          = 0;                    // exit price 9, '+' for long '-' for short
//

//---- indicator buffers
double BufferProfit[];
double BufferLoss[];

//---- vars
string   sIndicatorName;
string   sPrefix;
string   sIndSelf = "00-DispTrade_v101";
int      arrowEntry  = 5;
int      arrowExit   = 6;
int      arrowProfit = 74;
int      arrowLoss   = 76;
int      nTrade;
datetime tEntryData[];
datetime tExitData[];
double   pEntryData[];
double   pExitData[];
bool     bLongData[];

//----------------------------------------------------------------------
string TimeFrameToStr(int timeFrame)
{
    switch (timeFrame) {
    case 1:     return("M1");
    case 5:     return("M5");
    case 15:    return("M15");
    case 30:    return("M30");
    case 60:    return("H1");
    case 240:   return("H4");
    case 1440:  return("D1");
    case 10080: return("W1");
    case 43200: return("MN");
    }
    
    return("??");
}

//----------------------------------------------------------------------
void addData(datetime tEntry, double pEntry, datetime tExit, double pExit)
{
    if (tEntry != 0) {
	Print("addData: ", nTrade, " entry= ", TimeToStr(tEntry), " ", pEntry, ", exit= ", TimeToStr(tExit), " ", pExit);
	int tOffset = (dataGMT - serverGMT) * 3600;
	tEntryData[nTrade] = tEntry - tOffset;
	pEntryData[nTrade] = MathAbs(pEntry);
	tExitData[nTrade]  = tExit - tOffset;
	pExitData[nTrade]  = MathAbs(pExit);
	if (pEntry > 0) {
	    bLongData[nTrade] = true;
	} else {
	    bLongData[nTrade] = false;
	}
	nTrade++;
    }
}

//----------------------------------------------------------------------
void init()
{  
   int id1=0,id2=0,id3=0;
   string id1_name = "Win";
   string id2_name = "Lose";
   string id3_name = "Win-Lose"; 

//   　objbtn(id1_name,1,1);
      objButton(id1_name,40,clrWhite,clrAqua);

//   　objButton(id2_name,clrBlack,clrBlue);
//   　objButton(id3_name,clrBlack,clrBlue);
   
    string tf = TimeFrameToStr(Period());
    sIndicatorName = sIndSelf + "(" + tf + ")";
    sPrefix = sIndicatorName;
    
    IndicatorShortName(sIndicatorName);
    
    SetIndexBuffer(0, BufferProfit);
    SetIndexBuffer(1, BufferLoss);
    
    SetIndexLabel(0, "profit");
    SetIndexLabel(1, "loss");
    
    SetIndexStyle(0, DRAW_ARROW);
    SetIndexStyle(1, DRAW_ARROW);
    
    SetIndexArrow(0, arrowProfit);
    SetIndexArrow(1, arrowLoss);
    
    // vars
    ArrayResize(tEntryData, nMaxTrade);
    ArrayResize(pEntryData, nMaxTrade);
    ArrayResize(tExitData,  nMaxTrade);
    ArrayResize(pExitData,  nMaxTrade);
    ArrayResize(bLongData,  nMaxTrade);
    
   


    if (spread < 0) {
	spread = MarketInfo(NULL, MODE_SPREAD);
    }
    
    nTrade = 0;
    // from parameters
    Print("addData from parameters");
    addData(tEntry0, pEntry0, tExit0, pExit0);
    addData(tEntry1, pEntry1, tExit1, pExit1);
    addData(tEntry2, pEntry2, tExit2, pExit2);
    addData(tEntry3, pEntry3, tExit3, pExit3);
    addData(tEntry4, pEntry4, tExit4, pExit4);
    addData(tEntry5, pEntry5, tExit5, pExit5);
    addData(tEntry6, pEntry6, tExit6, pExit6);
    addData(tEntry7, pEntry7, tExit7, pExit7);
    addData(tEntry8, pEntry8, tExit8, pExit8);
    addData(tEntry9, pEntry9, tExit9, pExit9);
    
    // from data file
    int handle = FileOpen(tradeFileName, FILE_CSV | FILE_READ, ",");
    if (handle >= 0) {
	Print("addData from file: ", tradeFileName);
	while (!FileIsEnding(handle) && nTrade < nMaxTrade) {
	    string sSym        = FileReadString(handle);
	    string sEntryDate  = FileReadString(handle);
	    string sEntryPrice = FileReadString(handle);
	    string sExitDate   = FileReadString(handle);
	    string sExitPrice  = FileReadString(handle);
	    if (sSym != Symbol()) {
		continue;
	    }
	    datetime tEntry = StrToTime(sEntryDate);
	    double   pEntry = StrToDouble(sEntryPrice);
	    datetime tExit  = StrToTime(sExitDate);
	    double   pExit  = StrToDouble(sExitPrice);
	    addData(tEntry, pEntry, tExit, pExit);
	}
	FileClose(handle);
    }
   

 
}

//----------------------------------------------------------------------
void deinit()
{
    int n = ObjectsTotal();
    for (int i = n - 1; i >= 0; i--) {
	string sName = ObjectName(i);
	if (StringFind(sName, sPrefix) == 0) {
	    ObjectDelete(sName);
	}
    }
}

//----------------------------------------------------------------------
void objButton(string sName,int ypos,int clrtext, int clrback)
{
      ObjectCreate(sName,OBJ_BUTTON,0,0,0,0);

      ObjectSet(sName,OBJPROP_COLOR,clrtext);    // 色設定
      ObjectSet(sName,OBJPROP_BACK,false);            // オブジェクトの背景表示設定
      ObjectSet(sName,OBJPROP_SELECTABLE,false);     // オブジェクトの選択可否設定
      ObjectSet(sName,OBJPROP_SELECTED,false);      // オブジェクトの選択状態
      ObjectSet(sName,OBJPROP_HIDDEN,true);         // オブジェクトリスト表示設定
      ObjectSet(sName,OBJPROP_ZORDER,0);            // オブジェクトのチャートクリックイベント優先順位


      ObjectSet(sName,OBJPROP_TEXT,sName);            // 表示するテキスト

      ObjectSet(sName,OBJPROP_FONTSIZE,12);                   // フォントサイズ
      ObjectSet(sName,OBJPROP_CORNER,CORNER_LEFT_UPPER);  // コーナーアンカー設定
      ObjectSet(sName,OBJPROP_XDISTANCE,10);                // X座標
      ObjectSet(sName,OBJPROP_YDISTANCE,ypos);                 // Y座標
      ObjectSet(sName,OBJPROP_XSIZE,50);                    // ボタンサイズ幅
      ObjectSet(sName,OBJPROP_YSIZE,15);                     // ボタンサイズ高さ
      ObjectSet(sName,OBJPROP_BGCOLOR,clrback);              // ボタン色
      ObjectSet(sName,OBJPROP_BORDER_COLOR,clrYellow);       // ボタン枠色
      ObjectSet(sName,OBJPROP_STATE,false);                  // ボタン押下状態
}
//----------------------------------------------------------------------
void objLine(string sName, int win, datetime ts, double ps, datetime te, double pe, color col,
	     int width = 1, int style = STYLE_SOLID, bool bBack = false, bool bRay = false)
{
    ObjectCreate(sName, OBJ_TREND, win, 0, 0);
    ObjectSet(sName, OBJPROP_TIME1,  ts);
    ObjectSet(sName, OBJPROP_PRICE1, ps);
    ObjectSet(sName, OBJPROP_TIME2,  te);
    ObjectSet(sName, OBJPROP_PRICE2, pe);
    ObjectSet(sName, OBJPROP_COLOR,  col);
    ObjectSet(sName, OBJPROP_WIDTH,  width);
    ObjectSet(sName, OBJPROP_STYLE,  style);
    ObjectSet(sName, OBJPROP_BACK,   bBack);
    ObjectSet(sName, OBJPROP_RAY,    bRay);
}	    

//----------------------------------------------------------------------
void objHLine(string sName, int win, double ps, color col,
	      int width = 1, int style = STYLE_SOLID, bool bBack = false, bool bRay = false)
{
    ObjectCreate(sName, OBJ_HLINE, win, 0, 0);
    ObjectSet(sName, OBJPROP_PRICE1, ps);
    ObjectSet(sName, OBJPROP_COLOR,  col);
    ObjectSet(sName, OBJPROP_WIDTH,  width);
    ObjectSet(sName, OBJPROP_STYLE,  style);
    ObjectSet(sName, OBJPROP_BACK,   bBack);
    ObjectSet(sName, OBJPROP_RAY,    bRay);
}	    

//----------------------------------------------------------------------
void objVLine(string sName, int win, datetime ts, color col,
	      int width = 1, int style = STYLE_SOLID, bool bBack = false, bool bRay = false)
{
    ObjectCreate(sName, OBJ_VLINE, win, 0, 0);
    ObjectSet(sName, OBJPROP_TIME1,  ts);
    ObjectSet(sName, OBJPROP_COLOR,  col);
    ObjectSet(sName, OBJPROP_WIDTH,  width);
    ObjectSet(sName, OBJPROP_STYLE,  style);
    ObjectSet(sName, OBJPROP_BACK,   bBack);
    ObjectSet(sName, OBJPROP_RAY,    bRay);
}	    

//----------------------------------------------------------------------
void objArrow(string sName, int win, datetime t, double p, int arrow, color col, int width = 1)
{
    ObjectCreate(sName, OBJ_ARROW, win, 0, 0);
    ObjectSet(sName, OBJPROP_TIME1,     t);
    ObjectSet(sName, OBJPROP_PRICE1,    p);
    ObjectSet(sName, OBJPROP_ARROWCODE, arrow);
    ObjectSet(sName, OBJPROP_COLOR,     col);
    ObjectSet(sName, OBJPROP_WIDTH,     width);
}

//----------------------------------------------------------------------
void objText(string sName, int win, datetime t, double p, string text, color col, int fontSize = 10, string fontName = "Arial")
{
    ObjectCreate(sName, OBJ_TEXT, win, 0, 0);
    ObjectSetText(sName, text, fontSize, fontName, col);
    ObjectSet(sName, OBJPROP_TIME1, t);
    ObjectSet(sName, OBJPROP_PRICE1, p);
}
//----------------------------------------------------------------------


//----------------------------------------------------------------------
void dispTrade(int i)
{
    int      win = 0;
    datetime tEntry     = tEntryData[i];
    double   pEntry     = pEntryData[i];
    datetime tExit      = tExitData[i];
    double   pExit      = pExitData[i];
    bool     bLongEntry = bLongData[i];
    double   profit;
    
    color colEntry, colExit;
    bool bShortExit;
    if (bLongEntry) {
	bShortExit = true;
	colEntry = colLong;
	colExit  = colShort;
	profit   = pExit - pEntry;
    } else {
	bShortExit = false;
	colEntry = colShort;
	colExit  = colLong;
	profit   = pEntry - pExit;
    }
    
    int shift = iBarShift(NULL, 0, tExit);
    double pMark = High[shift] + markOffset * Point;
    datetime tMark;
    if (shift - 2 >= 0) {
	tMark = Time[shift - 2];
    } else {
	tMark = Time[shift] + Period() * 2;
    }
    color colProfit;
    if (profit > 0) {
	BufferProfit[shift] = pMark;
	colProfit = colProfitPlus;
    } else {
	BufferLoss[shift] = pMark;
	colProfit = colProfitMinus;
    }
    string sPips = DoubleToStr(profit / Point, 0);
    if (profit > 0) {
	sPips = "+" + sPips;
    }
    if (bDispProfit) {
      if (win_flag == true ) {
	      if ( profit > 0 ) {
	         objText(sPrefix + tExit + pMark, win, tMark, pMark + profitOffset * Point, sPips, colProfit, profitFontSize, profitFontName);
         }
      }
      if (lose_flag == true ) {
	      if ( profit < 0 ) {
	         objText(sPrefix + tExit + pMark, win, tMark, pMark + profitOffset * Point, sPips, colProfit, profitFontSize, profitFontName);
         }
      }
      if (winlose_flag == true ) {
	      if ( profit == 0 ) {
	         objText(sPrefix + tExit + pMark, win, tMark, pMark + profitOffset * Point, sPips, colProfit, profitFontSize, profitFontName);
         }
      }
      
    }
   
    string sPrefixEntry = sPrefix + tEntry + pEntry + bLongEntry;
    string sPrefixExit  = sPrefix + tExit  + pExit  + bShortExit;
    
    if (( win_flag == true ) && ( profit > 0 )) {    
      objArrow(sPrefixEntry + "arrowEntry", win, tEntry, pEntry, arrowEntry, colEntry, wArrow);
      objArrow(sPrefixExit + "arrowExit",  win, tExit,  pExit,  arrowExit,  colExit,  wArrow);
    
      objLine(sPrefixEntry + "trade", win, tEntry, pEntry, tExit, pExit, colHolding);
    }     
      if (( lose_flag == true ) && ( profit < 0 )) {    
      objArrow(sPrefixEntry + "arrowEntry", win, tEntry, pEntry, arrowEntry, colEntry, wArrow);
      objArrow(sPrefixExit + "arrowExit",  win, tExit,  pExit,  arrowExit,  colExit,  wArrow);
    
      objLine(sPrefixEntry + "trade", win, tEntry, pEntry, tExit, pExit, colHolding);
    }     
      if (( winlose_flag == true ) && ( profit == 0 )) {    
      objArrow(sPrefixEntry + "arrowEntry", win, tEntry, pEntry, arrowEntry, colEntry, wArrow);
      objArrow(sPrefixExit + "arrowExit",  win, tExit,  pExit,  arrowExit,  colExit,  wArrow);
    
      objLine(sPrefixEntry + "trade", win, tEntry, pEntry, tExit, pExit, colHolding);
    }     
    if (spread > 0) {
	if (!bLongEntry) {
	    datetime t1 = Time[iBarShift(NULL, 0, tEntry) + 1];
	    double pBid = pEntry - spread * Point;
       if (( win_flag == true ) && ( profit > 0 )) {    
	      objLine(sPrefixEntry + "bidEntry0", win, tEntry, pEntry, tEntry, pBid, colEntry);
	      objLine(sPrefixEntry + "bidEntry1", win, tEntry, pBid, t1, pBid, colEntry);
      }
      if (( lose_flag == true ) && ( profit < 0 )) {    
	      objLine(sPrefixEntry + "bidEntry0", win, tEntry, pEntry, tEntry, pBid, colEntry);
	      objLine(sPrefixEntry + "bidEntry1", win, tEntry, pBid, t1, pBid, colEntry);
      }
      if (( winlose_flag == true ) && ( profit == 0 )) {    
	      objLine(sPrefixEntry + "bidEntry0", win, tEntry, pEntry, tEntry, pBid, colEntry);
	      objLine(sPrefixEntry + "bidEntry1", win, tEntry, pBid, t1, pBid, colEntry);
      }
	}
	if (bShortExit) {
	    t1 = Time[iBarShift(NULL, 0, tExit) - 1];
	    pBid = pExit - spread * Point;
       if (( win_flag == true ) && ( profit > 0 )) {    
	      objLine(sPrefixExit + "bidExit0", win, tExit, pExit, tExit, pBid, colExit);
	      objLine(sPrefixExit + "bidExit1", win, tExit, pBid, t1, pBid, colExit);
      }
      if (( lose_flag == true ) && ( profit < 0 )) {    
	      objLine(sPrefixExit + "bidExit0", win, tExit, pExit, tExit, pBid, colExit);
	      objLine(sPrefixExit + "bidExit1", win, tExit, pBid, t1, pBid, colExit);
      }
      if (( winlose_flag == true ) && ( profit == 0 )) {    
	      objLine(sPrefixExit + "bidExit0", win, tExit, pExit, tExit, pBid, colExit);
	      objLine(sPrefixExit + "bidExit1", win, tExit, pBid, t1, pBid, colExit);
      }
	}
    }
    
    if (bVertLine) {
      if (( win_flag == true ) && ( profit > 0 )) {    
	      objVLine(sPrefixEntry + "vlineEntry", win, tEntry, colEntry);
	      objVLine(sPrefixExit + "vlineExit", win, tExit, colExit);
      }
      if (( lose_flag == true ) && ( profit < 0 )) {    
	      objVLine(sPrefixEntry + "vlineEntry", win, tEntry, colEntry);
	      objVLine(sPrefixExit + "vlineExit", win, tExit, colExit);
      }
      if (( winlose_flag == true ) && ( profit == 0 )) {    
	      objVLine(sPrefixEntry + "vlineEntry", win, tEntry, colEntry);
	      objVLine(sPrefixExit + "vlineExit", win, tExit, colExit);
      }

    }
}

//----------------------------------------------------------------------
void start()
{
    int limit;
    int counted_bars = IndicatorCounted();
    
    if (counted_bars > 0) {
	counted_bars--;
    }
    
    limit = Bars - counted_bars;
    
    for (int i = limit - 1; i >= 0; i--) {
	BufferProfit[i] = EMPTY_VALUE;
	BufferLoss[i] = EMPTY_VALUE;
    }
    
    bool bContinuousUpdate = true;
    if (bContinuousUpdate) {
	for (i = 0; i < nTrade; i++) {
	    dispTrade(i);
	}
	WindowRedraw();
    }
}
