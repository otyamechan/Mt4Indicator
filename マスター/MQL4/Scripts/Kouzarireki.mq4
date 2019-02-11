
//+------------------------------------------------------------------+
//|                                               StatementToCSV.mq4 |
//|                                     Copyright 2014, Life with FX |
//|                                             http://lifewithfx.jp |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Life with FX"
#property link      "http://lifewithfx.jp"
#property version   "1.30"
#property strict
#property show_inputs

extern string CSVOutputFolder = "-- MT4 MQL4/Files folder --";
extern bool OutputRecordDescendingOrder = false;
//extern bool OutputHeaderRecord = ;
extern string ReportPeriod = "-- PeriodFilter: Order close time base --";
extern bool UsePeriodFilter = false;
extern int  ReportFromDate = 20140331;
extern int  ReportToDate   = 20150830;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int OnStart()
{

  bool OutputHeaderRecord = false;
  int hFile = -1;
  int historyTotal = OrdersHistoryTotal();
  bool BUY = false;
  bool SELL = false;

  if(historyTotal <= 0)
    {
      Print("No History Data. Skip process...");
      return(0);
    }

  int ticket[];

  ArrayResize(ticket, historyTotal);
  ArrayInitialize(ticket, -1);

  for(int i=0; i<historyTotal; i++)
    {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
          switch(OrderType())
            {
            case OP_BUY:
            case OP_SELL:
              ticket[i] = OrderTicket();
              break;
            default:
              ticket[i] = -1;
            }
        }
    }

  // output filename  StatementCSV_YYYYMMDD_HHMM.csv
  string fileName = "trade.txt";
  //string fileName = "StatementCSV_" + Year();
  //if(Month() < 10)  { fileName = fileName + "0" + Month(); }
  //else              { fileName = fileName + Month(); }
  //if(Day() < 10)    { fileName = fileName + "0" + Day() + "_"; }
  //else              { fileName = fileName + Day() + "_"; }
  //if(Hour() < 10)   { fileName = fileName + "0" + Hour(); }
  //else              { fileName = fileName + Hour(); }
  //if(Minute() < 10) { fileName = fileName + "0" + Minute(); }
  //else              { fileName = fileName + Minute(); }
  //fileName = fileName + ".csv";
  Print("output filename: " + fileName);

  //get handle
  hFile = FileOpen(fileName, FILE_BIN|FILE_WRITE, ",");
  if(hFile < 0) {
    Print("error abort: output file creation error!!");
    return(-1);
  }

  // CSV Record Header
  string header = "Ticket,OrderType,OrderSymbol,OrderLots,OrderOpenTime,OrderOpenPrice,OrderCloseTime,OrderClosePrice,OrderProfitInPips,OrderCommission,OrderSwap,OrderProfit,TradeProfit,OrderMagicNumber,OrderComment,OrderCommentShort" + "\n";
  if (OutputHeaderRecord) {
    FileWriteString(hFile, header, StringLen(header));
  }

  const string ITEM_SEPARATOR = ",";
  int startIdx;  
  int idxStep;
  int ordersLastIdx = historyTotal - 1;
//  double takeprice;
// double takepips;  
   
  if (!OutputRecordDescendingOrder) {
    startIdx = 0;
    idxStep = 1;
  } else {
    startIdx = ordersLastIdx;
    idxStep = -1;
  }

  for (int i = startIdx; !(i < 0 || ordersLastIdx < i) ; i += idxStep) {

    if(ticket[i] != -1) {
      if(OrderSelect(ticket[i], SELECT_BY_TICKET, MODE_HISTORY)) {

        // PeriodRangeFilter
        string closeDateStr = TimeToStr(OrderCloseTime(), TIME_DATE);
        int closeDateInt = StrToInteger(StringSubstr(closeDateStr, 0, 4) + StringSubstr(closeDateStr, 5, 2) + StringSubstr(closeDateStr, 8, 2));

        if (!UsePeriodFilter) {
	  // OK
        } else if (ReportFromDate <= closeDateInt &&
                   closeDateInt   <= ReportToDate) {
	  // OK
        } else {
          continue;
        }
            
        string output;
 //       output = ticket[i]+ ITEM_SEPARATOR;
        switch(OrderType()) {
        case OP_BUY:
          BUY  = true;
          SELL = false;
          break;
        case OP_SELL:
          BUY  = false;
          SELL = true;
          break;
        default:
          BUY  = false;
          SELL = false;
        }
            
        output = OrderSymbol()                                                              + ITEM_SEPARATOR;
        output = output + TimeToStr(OrderOpenTime(),TIME_DATE | TIME_MINUTES)                       + ITEM_SEPARATOR;
         if ( BUY == true ) {
            output = output + DoubleToStr(OrderOpenPrice())+ ITEM_SEPARATOR;         
         }
         else if ( SELL == true ) {
            output = output + DoubleToStr((-1) * OrderOpenPrice())+ ITEM_SEPARATOR;         
         }           
         else {
            output = output + DoubleToStr(OrderOpenPrice())+ ITEM_SEPARATOR;         
         }
        output = output + TimeToStr(OrderCloseTime(),TIME_DATE | TIME_MINUTES )                     + ITEM_SEPARATOR;
        output = output + DoubleToStr(OrderClosePrice());         

        output = output + "\n";

        FileSeek(hFile, 0, SEEK_END);
        FileWriteString(hFile, output, StringLen(output));
      }
    }
  }

  if(0 < hFile) {
    FileClose(hFile);
  }

  Print ("works fine: finished!!");
  return(0);
}


