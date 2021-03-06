//+---------------------------------------------------------------------------+
//|                                       Otyame  No.018                      |
//|                                       ピボットシグナル            　        　　  |
//|                                       Otyame018_Pivot_signal　　　　　　　　　　　 |
//|                                       2014.05.20                          |
//+---------------------------------------------------------------------------+
/*
  スパンモデルシグナル配信版 
 説明：上位足のスパンモデルのシグナルと売買が一致した時にシグナルを発信する
 　　　時刻を変更しても、対応。下位足のシグナルについては無視する
 
   パラメータ
		bool AlertON=false;					//アラート表示　
		bool EmailON=true;       			//メール送信
		bool Redraw = false;    			//再描画
		int  Signal_Pos = 20;   			//シグナル位置
		int Tenkan = 9;          			//転換線
		int Kijun = 25;           		//基準線 
		int Senkou = 52;          		//先行スパン 
		bool Span_chiko_Check = false;	//遅行スパン			
		bool kansi_5m = false;    		//5分足考慮
		bool kansi_15m = false;   		//15分足考慮
		bool kansi_30m = false;   		//30分足考慮
		bool kansi_1H = true;    		//1時間足考慮
		bool kansi_4H = false;    		//4時間足考慮
		bool kansi_1D = false;    		//日足考慮

   色
      買い矢印
      売り矢印
      決済矢印（買い決済）
      決済矢印（売り決済）


*/

#property copyright "Otyame"
#property link      ""

#property indicator_buffers 4

#property indicator_chart_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Red

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4



//---- buffers
double UpArrow[];
double DownArrow[];
double UpKessaiArrow[];

string message;
extern ServerTime = 7;
extern  bool Redraw = false;    			      //再描画
extern  int  Signal_Pos = 20;   			      //シグナル位置
extern string sWeekly = "Weekly Setting";
extern bool Weekly_EmailON=true;       			//メール送信
extern string sWeekday ="週(1:月,2:火,3:水,4:木,5:金) 
extern int Weekday =1; 
extern int Week_Hour = 9;
extern int Week_Minute = 10;

extern string sDaily = "Daily Setting";
extern bool Daily_EmailON=true;       			//メール送信
extern int TimeShift = 0;
extern int Day_Hour = 9;
extern int Day_Minute = 10;

bool Emailflag;                  		//メール送信判定フラグ            
bool Alertflag;                 		   //アラート表示判定フラグ

datetime TimeOld= D'1970.01.01 00:00:00';

double WeeklyPB;
double WeeklyS1;
double WeeklyR1;
double WeeklyS2;
double WeeklyR2;
double WeeklyS3;
double WeeklyR3;

double DailyR3;
double DailyR2;
double DailyR1);
double DailyPB;
double DailyS1);
double DailyS2);
double DailyS3);

datetime Send_Weekly_Time;
datetime Send_Daily_Time;


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
   SetIndexArrow(2,234);
   SetIndexBuffer(2,UpKessaiArrow);
   Weekly_Mail_Flag = false;
   Daily_Mail_Flag = false;
   Send_Weekly_Time = TimeCurrent()+ ServerTime * 3600;
   Send_Daily_Time = TimeCurrent()+ ServerTime * 3600;

   if ( Weekly_EmailON == true ) {
      if ( TimeDayOfWeek(Send_Weekly_Time) == Weekday ) {
         if (TimeHour(Send_Weekly_Time) == Week_Hour ) {
            if ( TimeMinute(Send_Weekly_Time) == Week_Minute) {
               Weekly_Mail_Flag = true;
               Send_Weekly_Time = Send_Weekly_Time + 604800;
               Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
            }
            else if ( TimeMinute(Send_Weekly_Time) > Week_Minute ) {
               Send_Weekly_Time = Send_Weekly_Time + 604800;
               Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
            }
         }
         else if( TimeHour(Send_Weekly_Time) > Week_Hour ) {
            Send_Weekly_Time = Send_Weekly_Time + 604800;
            Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
         }
         else {
            Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
         }
      }
      else if (  TimeDayOfWeek(Send_Weekly_Time) <  Weekday ) {
         Send_Weekly_Time = (Weekday - TimeDayOfWeek(Send_Weekly_Time)) * 3600;
         Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
      }
      else if ( TimeDayOfWeek(Send_Weekly_Time) >  Weekday ) {
         for ( i = 0;i < 6  ;i++) {
            Send_Weekly_Time = Send_Weekly_Time + 3600;
            if (  TimeDayOfWeek(Send_Weekly_Time) == Weekday ) {
               break;
            }
         }
         Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
      }
   }                            
   if ( Daily_EmailON == true ) {
      if (TimeHour(Send_Daily_Time) == Day_Hour ) {
         if ( TimeMinute(Send_Daily_Time) == Day_Minute) {
            Daily_Mail_Flag = true;
            Send_Daily_Time = Send_Daily_Time + 3600;
            Send_Daily_Time = StrToTime(TimeToStr(Send_Daily_Time,TIME_DATE))+" "+Day_Hour+":"+Day_Minute);
         }
         else if ( TimeMinute(Send_Daily_Time) > Day_Minute ) {
               Send_Daily_Time = Send_Daily_Time + 3600;
               Send_Daily_Time = StrToTime(TimeToStr(Send_Daily_Time,TIME_DATE))+" "+Day_Hour+":"+Day_Minute);
            }
         }
      }
      else if( TimeHour(Send_Daily_Time) > Day_Hour ) {
         Send_Daily_Time = Send_Daily_Time + 3600;
         Send_Daily_Time = StrToTime(TimeToStr(Send_Daily_Time,TIME_DATE))+" "+Day_Hour+":"+Day_Minute);
      }
      else {
         Send_Daily_Time = StrToTime(TimeToStr(Send_Daily_Time,TIME_DATE))+" "+Day_Hour+":"+Day_Minute);
      }
   }                            
	IndicatorShortName("Otyame018_Pivot_signal");
   return(0);
}
int deinit()
{
   return(0);
}
int start()
{
   int i;
   if ( Weekly_EmailON == true ) {
      if ( TimeDayOfWeek(Send_Weekly_Time) == Weekday ) {
         if (TimeHour(Send_Weekly_Time) == Week_Hour ) {
            if ( TimeMinute(Send_Weekly_Time) == Week_Minute) {
               Weekly_Mail_Flag = true;
               Send_Weekly_Time = Send_Weekly_Time + 604800;
               Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
            }
            else if ( TimeMinute(Send_Weekly_Time) > Week_Minute ) {
               Send_Weekly_Time = Send_Weekly_Time + 604800;
               Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
            }
         }
         else if( TimeHour(Send_Weekly_Time) > Week_Hour ) {
            Send_Weekly_Time = Send_Weekly_Time + 604800;
            Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
         }
         else {
            Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
         }
      }
      else if (  TimeDayOfWeek(Send_Weekly_Time) <  Weekday ) {
         Send_Weekly_Time = (Weekday - TimeDayOfWeek(Send_Weekly_Time)) * 3600;
         Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
      }
      else if ( TimeDayOfWeek(Send_Weekly_Time) >  Weekday ) {
         for ( i = 0;i < 6  ;i++) {
            Send_Weekly_Time = Send_Weekly_Time + 3600;
            if (  TimeDayOfWeek(Send_Weekly_Time) == Weekday ) {
               break;
            }
         }
         Send_Weekly_Time = StrToTime(TimeToStr(Send_Weekly_Time,TIME_DATE))+" "+Week_Hour+":"+Week_Minute);
      }
   }                            
   if ( Daily_EmailON == true ) {
      if (TimeHour(Send_Daily_Time) == Day_Hour ) {
         if ( TimeMinute(Send_Daily_Time) == Day_Minute) {
            Daily_Mail_Flag = true;
            Send_Daily_Time = Send_Daily_Time + 3600;
            Send_Daily_Time = StrToTime(TimeToStr(Send_Daily_Time,TIME_DATE))+" "+Day_Hour+":"+Day_Minute);
         }
         else if ( TimeMinute(Send_Daily_Time) > Day_Minute ) {
               Send_Daily_Time = Send_Daily_Time + 3600;
               Send_Daily_Time = StrToTime(TimeToStr(Send_Daily_Time,TIME_DATE))+" "+Day_Hour+":"+Day_Minute);
            }
         }
      }
      else if( TimeHour(Send_Daily_Time) > Day_Hour ) {
         Send_Daily_Time = Send_Daily_Time + 3600;
         Send_Daily_Time = StrToTime(TimeToStr(Send_Daily_Time,TIME_DATE))+" "+Day_Hour+":"+Day_Minute);
      }
      else {
         Send_Daily_Time = StrToTime(TimeToStr(Send_Daily_Time,TIME_DATE))+" "+Day_Hour+":"+Day_Minute);
      }
   }                            
   if ( Weekly_Mail_Flag == true ) {
      WeeklyPB = iCustom(NULL,0,"P-Weekly",0,i);
      WeeklyS1 = iCustom(NULL,0,"P-Weekly",1,i);
      WeeklyR1 = iCustom(NULL,0,"P-Weekly",2,i);
      WeeklyS2 = iCustom(NULL,0,"P-Weekly",3,i);
      WeeklyR2　= iCustom(NULL,0,"P-Weekly",4,i);
      WeeklyS3　= iCustom(NULL,0,"P-Weekly",5,i);
      WeeklyR3　= iCustom(NULL,0,"P-Weekly",6,i);
      message = "PB　="+WeeklyPB;
      message =  message + " \r\nWeekly R3 ="+WeeklyR3; 
      message =  message + " \r\nWeekly R2 ="+WeeklyR2; 
      message =  message + " \r\nWeekly R1 ="+WeeklyR1; 
      message =  message + " \r\nWeekly S1 ="+WeeklyS1; 
      message =  message + " \r\nWeekly S2 ="+WeeklyS2; 
      message =  message + " \r\nWeekly S3 ="+WeeklyS3;
      message = message + " \r\n現在値 = "+Open(0); 
      SendMail("週ピボット" +"["+Symbol()+"]["+Period()+"]",message);
      Weekly_Mail_Flag = false;
   }
   if ( Daily_Mail_Flag == true ) {
      DailyR3 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
      DailyR2 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
      DailyR1 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
      DailyPB = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
      DailyS1 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
      DailyS2 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
      DailyS3 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
      message = "PB　="+DailyPB;
      message =  message + " \r\nDaily R3 ="+DailyR3; 
      message =  message + " \r\nDaily R2 ="+DailyR2; 
      message =  message + " \r\nDaily R1 ="+DailyR1; 
      message =  message + " \r\nDaily S1 ="+DailyS1; 
      message =  message + " \r\nDaily S2 ="+DailyS2; 
      message =  message + " \r\nDaily S3 ="+DailyS3;
      Daily_Mail_Flag　= false; 
      message = message + " \r\n現在値 = "+Open(0); 
      SendMail("日ピボット" +"["+Symbol()+"]["+Period()+"]",message);
   }
   
   if (Time[0] != TimeOld)                      //時間が更新された場合
   {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      if ( limit < 2 ) limit = 2;
      for(i= limit-1;i>=1;i--){
         WeeklyPB = iCustom(NULL,0,"P-Weekly",0,i);
         WeeklyS1 = iCustom(NULL,0,"P-Weekly",1,i);
         WeeklyR1 = iCustom(NULL,0,"P-Weekly",2,i);
         WeeklyS2 = iCustom(NULL,0,"P-Weekly",3,i);
         WeeklyR2　= iCustom(NULL,0,"P-Weekly",4,i);
         WeeklyS3　= iCustom(NULL,0,"P-Weekly",5,i);
         WeeklyR3　= iCustom(NULL,0,"P-Weekly",6,i);

         DailyR3 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
         DailyR2 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
         DailyR1 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
         DailyPB = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
         DailyS1 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
         DailyS2 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
         DailyS3 = iCustom(NULL,0,"Pivots-timeshift",TimeShift,0,i);
         Close(i+1) 

         switch(Period())
         {
            case PERIOD_M1 : 
               c_5m = iBarShift(NULL,PERIOD_M5,Time[i],true);
               if ( k5mtime[c_5m] > Time[i] ) {
                  c_5m++;
               }            
            case PERIOD_M5 :
               c_15m = iBarShift(NULL,PERIOD_M15,Time[i],true);
               if ( k15mtime[c_15m] > Time[i] ) {
                  c_15m++;
               }            
            case PERIOD_M15 :
               c_30m = iBarShift(NULL,PERIOD_M30,Time[i],true);
               if ( k30mtime[c_30m] > Time[i] ) {
                  c_30m++;
               }            
            case PERIOD_M30 :
               c_1H = iBarShift(NULL,PERIOD_H1,Time[i],true);
               if ( k1Htime[c_1H] > Time[i] ) {
                  c_1H++;
               }            
            case PERIOD_H1 :
               c_4H = iBarShift(NULL,PERIOD_H4,Time[i],true);
               if ( k4Htime[c_4H] > Time[i] ) {
                  c_4H++;
               }            
            case PERIOD_H4 :
               c_1D = iBarShift(NULL,PERIOD_D1,Time[i],true);
               if ( k1Dtime[c_1D] > Time[i] ) {
                  c_1D++;
               }            
         }
         if (c_1H == 0 ) c_1H++;
         if (c_15m == 0 ) c_15m++;
         if (c_30m == 0 ) c_30m++;
         if (c_1H == 0 ) c_1H++;
         if (c_4H == 0 ) c_4H++;
         if (c_1D == 0 ) c_1D++;
          
         
         
         
         switch(Period())
         {
         case PERIOD_M1: 
            if ( kansi_5m == true ) {
               Sen1_5m = iCustom(NULL,5,"span_model",Kijun,Tenkan,Senkou,5,c_5m);
               Sen2_5m = iCustom(NULL,5,"span_model",Kijun,Tenkan,Senkou,6,c_5m);

            }
         case PERIOD_M5 :
               if ( kansi_15m == true ) {
                  Sen1_15m = iCustom(NULL,15,"span_model",Kijun,Tenkan,Senkou,5,c_15m);
                  Sen2_15m = iCustom(NULL,15,"span_model",Kijun,Tenkan,Senkou,6,c_15m);
               }
         case PERIOD_M15 :
               if ( kansi_30m == true ) {
                  Sen1_30m = iCustom(NULL,30,"span_model",Kijun,Tenkan,Senkou,5,c_30m);
                  Sen2_30m = iCustom(NULL,30,"span_model",Kijun,Tenkan,Senkou,6,c_30m);
               }
         case PERIOD_M30 :
               if ( kansi_1H == true ) {
                  Sen1_1H = iCustom(NULL,60,"span_model",Kijun,Tenkan,Senkou,5,c_1H);
                  Sen2_1H = iCustom(NULL,60,"span_model",Kijun,Tenkan,Senkou,6,c_1H);
            }
         case PERIOD_H1 :
               if ( kansi_4H == true ) {
                  Sen1_4H = iCustom(NULL,240,"span_model",Kijun,Tenkan,Senkou,5,c_4H);
                  Sen2_4H = iCustom(NULL,240,"span_model",Kijun,Tenkan,Senkou,6,c_4H);
               }

         case PERIOD_H4 :
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
         if(Sen1_0 > Sen2_0 ) {
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
               if ( Span_chiko_Check == true && buy == true) {
                  if ( Close[i] < Close[i+25] ) buy = false;
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
               if ( Span_chiko_Check == true && buy == true) {
                  if ( Close[i] < Close[i+25] ) buy = false;
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
               if ( Span_chiko_Check == true && buy == true) {
                  if ( Close[i] < Close[i+25] ) buy = false;
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
               if ( Span_chiko_Check == true && buy == true) {
                  if ( Close[i] < Close[i+25] ) buy = false;
               }
            }
            else if ( Period() == 60) {
               if ( kansi_4H == true && buy == true ) {   
                  if ( Sen1_4H <= Sen2_4H )  buy = false;
               }
               if ( kansi_1D == true && buy == true ) {   
                  if ( Sen1_1D <= Sen2_1D )  buy = false;

               }
               if ( Span_chiko_Check == true && buy == true) {
                  if ( Close[i] < Close[i+25] ) buy = false;
               }
            }
            else if ( Period() == 240) {
               if ( kansi_1D == true && buy == true ) {   
                  if ( Sen1_1D <= Sen2_1D )  buy = false;

               }
               if ( Span_chiko_Check == true && buy == true) {
                  if ( Close[i] < Close[i+25] ) buy = false;
               }
            }
         }
         else if(Sen1_0 < Sen2_0 ){
            sell = true;
               if ( Period() == 1 ) {
               if ( kansi_5m == true ) {   
                  if ( Sen1_5m >= Sen2_5m )  sell = false;
               }
               if ( kansi_15m == true && sell == true ) {   
                  if ( Sen1_15m >= Sen2_15m )  sell = false;
               }
               if ( kansi_30m == true && sell == true ) {   
                  if ( Sen1_30m >= Sen2_30m )  sell = false;
               }
               if ( kansi_1H == true && sell == true ) {   
                  if ( Sen1_1H >= Sen2_1H )  sell = false;
               }
               if ( kansi_4H == true && sell == true ) {   
                  if ( Sen1_4H >= Sen2_4H )  sell = false;
               }
               if ( kansi_1D == true && sell == true ) {   
                  if ( Sen1_1D >= Sen2_1D )  sell = false;

               }
               if ( Span_chiko_Check == true && sell == true) {
                  if ( Close[i] > Close[i+25] ) sell = false;
               }
            }
            else if ( Period() == 5) {
               if ( kansi_15m == true && sell == true ) {   
                  if ( Sen1_15m >= Sen2_15m )  sell = false;
               }
               if ( kansi_30m == true && sell == true ) {   
                  if ( Sen1_30m >= Sen2_30m )  sell = false;
               }
               if ( kansi_1H == true && sell == true ) {   
                  if ( Sen1_1H >= Sen2_1H )  sell = false;
               }
               if ( kansi_4H == true && sell == true ) {   
                  if ( Sen1_4H >= Sen2_4H )  sell = false;
               }
               if ( kansi_1D == true && sell == true ) {   
                  if ( Sen1_1D >= Sen2_1D )  sell = false;

               }
               if ( Span_chiko_Check == true && sell == true) {
                  if ( Close[i] > Close[i+25] ) sell = false;
               }
            }
            else if ( Period() == 15) {
               if ( kansi_30m == true && sell == true ) {   
                  if ( Sen1_30m >= Sen2_30m )  sell = false;
               }
               if ( kansi_1H == true && sell == true ) {   
                  if ( Sen1_1H >= Sen2_1H )  sell = false;
               }  
               if ( kansi_4H == true && sell == true ) {   
                  if ( Sen1_4H >= Sen2_4H )  sell = false;
               }
               if ( kansi_1D == true && sell == true ) {   
                  if ( Sen1_1D >= Sen2_1D )  sell = false;

               }
               if ( Span_chiko_Check == true && sell == true) {
                  if ( Close[i] > Close[i+25] ) sell = false;
               }
            }
            else if ( Period() == 30) {
               if ( kansi_1H == true && sell == true ) {   
                  if ( Sen1_1H >= Sen2_1H )  sell = false;
               }
               if ( kansi_4H == true && sell == true ) {   
                  if ( Sen1_4H >= Sen2_4H )  sell = false;
               }
               if ( kansi_1D == true && sell == true ) {   
                  if ( Sen1_1D >= Sen2_1D )  sell = false;

               }
               if ( Span_chiko_Check == true && sell == true) {
                  if ( Close[i] > Close[i+25] ) sell = false;
               }
            }
            else if ( Period() == 60) {
               if ( kansi_4H == true && sell == true ) {   
                  if ( Sen1_4H >= Sen2_4H )  sell = false;
               }
               if ( kansi_1D == true && sell == true ) {   
                  if ( Sen1_1D >= Sen2_1D )  sell = false;

               }
               if ( Span_chiko_Check == true && sell == true) {
                  if ( Close[i] > Close[i+25] ) sell = false;
               }
            }
            else if ( Period() == 240) {
               if ( kansi_1D == true && sell == true ) {   
                  if ( Sen1_1D >= Sen2_1D )  sell = false;

               }
               if ( Span_chiko_Check == true && sell == true) {
                  if ( Close[i] > Close[i+25] ) sell = false;
               }
            }        
        
         }
         switch( O_BandS ) {
            case NO_POSITION:
               if ( buy == true ) {
                  UpArrow[i]=Sen1_1 - Point * Signal_Pos;
                  BandS = BUY_POSITION;
                  Kind = BUY_POSITION;
               }
               else if ( sell == true ) {
                  DownArrow[i]=Sen1_1 + Point * Signal_Pos;
                  BandS = SELL_POSITION;
                  Kind = SELL_POSITION;
               }
               else {
                  BandS = NO_POSITION;
                  Kind = NO_POSITION;
               }
               break;         
            case BUY_POSITION:
               if ( buy == true ) {
                  BandS = BUY_POSITION;
                  Kind = 0;
               }
               else if ( sell == true ) {
                  DownArrow[i]=Sen1_1 + Point * Signal_Pos;
                  BandS = SELL_POSITION;
                  Kind = SELL_POSITION;
               }
               else {
                  UpKessaiArrow[i] = Sen1_1 + Point * Signal_Pos;
                  BandS = NO_POSITION;
                  Kind = BUY_KESSAI;
               }
               break;         
            case SELL_POSITION:
               if ( buy == true ) {
                  UpArrow[i]=Sen1_1 - Point * Signal_Pos;
                  BandS = BUY_POSITION;
                  Kind = BUY_POSITION;
               }
               else if ( sell == true ) {
                  BandS = SELL_POSITION;
                  Kind = 0;
               }
               else {
                  DownKessaiArrow[i] = Sen1_1 - Point * Signal_Pos;
                  BandS = NO_POSITION;
                  Kind = SELL_KESSAI;
               }
               break;         
         }
         O_BandS = BandS;
      }
      datetime a = D'1970.01.01 00:00:00'; 
      if ( TimeOld != a ) { 
         Emailflag = EmailON;                      //メール送信設定
         Alertflag = AlertON;                      //アラート出力設定
      }
      else
      {   
         Emailflag = false;                      //メール送信設定
         Alertflag = false;                      //アラート出力設定
      }         
      TimeOld = Time[0];                        //時間を更新
      double chiko;
      chiko =  iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,4,25);           
      if (Emailflag== true) {
         switch(Kind)   {
            case BUY_POSITION:
               message= "買い Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
            case SELL_POSITION:
               message= "売り Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
            case BUY_KESSAI:
               message= "買い決済 Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
            case SELL_KESSAI:
               message= "売り決済 Chance!!"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
               message = message + " \r\n 遅行スパン = "+chiko;
               message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
               break;
         }
         if ( Kind != 0 ) SendMail("スパンモデル " +"["+Symbol()+"]["+Period()+"]",message);
            Emailflag = false;      
      }
      if (Alertflag== true) {
         switch(Kind)   {
            case BUY_POSITION:
               Alert("Spanmodel BUY Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
            case SELL_POSITION:
               Alert("Spanmodel SELL Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
               break;
            case BUY_KESSAI:
               Alert("Spanmodel BUY Kessai Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
            case SELL_KESSAI:
               Alert("Spanmodel SELl Kessai Signal ",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               break;
         }
         Alertflag = false;

      }
   }
   return(0);
}

