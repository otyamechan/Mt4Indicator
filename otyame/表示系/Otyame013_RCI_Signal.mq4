//+------------------------------------------------------------------+
//|                                       Otyame  No.002             |
//|                                       MACD_Rule 表示          　 |
//|                                       2014.05.20                 |
//+------------------------------------------------------------------+

#property copyright "Otyame"
#property link      ""

#property indicator_buffers 7

#property indicator_separate_window

#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_color4 Aqua
#property indicator_color5 Magenta
#property indicator_color6 Black
#property indicator_color7 Black

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1



//---- buffers
double Short_RCI[];
double Middle_RCI[];
double Long_RCI[];
double UpArrow[];
double DownArrow[];
double UpKessaiArrow[];
double DownKessaiArrow[];

datetime TimeOld= D'1970.01.01 00:00:00';
bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

string message;

extern bool AlertON=false;        //アラート表示　
extern bool EmailON=true;        //メール送信
extern bool Redraw = false;
extern   int Short_RCI_Period = 9;           //MACD期間
extern   int Middle_RCI_Period = 26;           //MACD期間
extern   int Long_RCI_Period = 52;           //MACD期間
extern   double Uper_Line = 0.7;           //MACD期間
extern   double Under_Line = -0.7;           //MACD期間

#define NO_SIGNAL  0
#define UP_SIGNAL  1 
#define UP_SIGNAL_END  2
#define DOWN_SIGNAL  3 
#define DOWN_SIGNAL_END  4

int BandS;
int O_BandS;
int Kind;
bool startflg = false;
int limit;


int init()
{

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Short_RCI);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Middle_RCI);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Long_RCI);
 
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,UpArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,234);
   SetIndexBuffer(4,DownArrow);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,234);
   SetIndexBuffer(5,UpKessaiArrow);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,233);
   SetIndexBuffer(6,DownKessaiArrow);
   SetIndexEmptyValue(6,EMPTY_VALUE);
   startflg = false;

   return(0);
}
int deinit()
{
   return(0);
}

int start()
{
   int i;
   if ((Time[0] != TimeOld) || (startflg  == false ))                      //時間が更新された場合
   {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
      if (counted_bars > 0) counted_bars--;
      if (startflg ==  true ) {
         limit = Bars - counted_bars;
      }
      else {
          limit = Bars;
          startflg  == true;
      }
      for( i = limit -1 ; i>= 0 ; i--) {
         UpArrow[i] = EMPTY_VALUE;
         DownArrow[i] = EMPTY_VALUE;
         UpKessaiArrow[i] = EMPTY_VALUE;
         DownKessaiArrow[i] = EMPTY_VALUE;
         Short_RCI[i] = iCustom(NULL,0,"RCI",Short_RCI_Period,0,52,0.8,0.7,true,0,i);
         Middle_RCI[i] = iCustom(NULL,0,"RCI",Middle_RCI_Period,0,52,0.8,0.7,true,0,i);
         Long_RCI[i] = iCustom(NULL,0,"RCI",Long_RCI_Period,0,52,0.8,0.7,true,0,i);
         switch(O_BandS) {
            case NO_SIGNAL:
               if (Short_RCI[i] >= Uper_Line && Middle_RCI[i] >= Uper_Line && Long_RCI[i] >= Uper_Line ) {
                  UpArrow[i] = Uper_Line - 0.1;
                  BandS = UP_SIGNAL;
                  Kind = UP_SIGNAL;
               }
               else if (Short_RCI[i] <= Under_Line && Middle_RCI[i] <= Under_Line && Long_RCI[i] <= Under_Line ) {
                  DownArrow[i] = Under_Line + 0.1;
                  BandS = DOWN_SIGNAL;
                  Kind = DOWN_SIGNAL;
               }
               


               else  {
                  BandS = NO_SIGNAL;
                  Kind = NO_SIGNAL;
            }        
            break;
            case UP_SIGNAL:
               if (Short_RCI[i] >= Uper_Line && Middle_RCI[i] >= Uper_Line && Long_RCI[i] >= Uper_Line ) {
                  BandS = UP_SIGNAL;
                  Kind = 0;
               }
               else {
                  UpKessaiArrow[i] = Uper_Line - 0.1;
                  BandS = NO_SIGNAL;
                  Kind = UP_SIGNAL_END;
               }
            break;
            case DOWN_SIGNAL:
               if (Short_RCI[i] <= Under_Line && Middle_RCI[i] <= Under_Line && Long_RCI[i] <= Under_Line ) {
                  BandS = DOWN_SIGNAL;
                  Kind = 0;
               }
               else {
                  DownKessaiArrow[i] = Under_Line + 0.1;
                  BandS = NO_SIGNAL;
                  Kind = DOWN_SIGNAL_END;
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
      if (Emailflag== true) {
         switch(Kind)   {
            case UP_SIGNAL:
               message= "三重天井発生"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
               message = message + "短期("+Short_RCI_Period+")="+Short_RCI[1];
               message = message + "中期("+Middle_RCI_Period+")="+Middle_RCI[1];
               message = message + "長期("+Long_RCI_Period+")="+Long_RCI[1];
               break;
            case UP_SIGNAL_END:
               message= "三重天井解除"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
               message = message + "短期("+Short_RCI_Period+")="+Short_RCI[1];
               message = message + "中期("+Middle_RCI_Period+")="+Middle_RCI[1];
               message = message + "長期("+Long_RCI_Period+")="+Long_RCI[1];
               break;
            case DOWN_SIGNAL:
               message= "三重底発生"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
               message = message + "短期("+Short_RCI_Period+")="+Short_RCI[1];
               message = message + "中期("+Middle_RCI_Period+")="+Middle_RCI[1];
               message = message + "長期("+Long_RCI_Period+")="+Long_RCI[1];
               break;
            case DOWN_SIGNAL_END:
               message= "三重底解除"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
               message = message + "短期("+Short_RCI_Period+")="+Short_RCI[1];
               message = message + "中期("+Middle_RCI_Period+")="+Middle_RCI[1];
               message = message + "長期("+Long_RCI_Period+")="+Long_RCI[1];
               break;
         }
         if ( Kind != 0 ) SendMail("Span model signal",message);
            Emailflag = false;      
      }
      if (Alertflag== true) {
         switch(Kind)   {
            case UP_SIGNAL:
               Alert("RCI UP Signal ",Symbol(),Period(),Open[0]);
               break;
            case UP_SIGNAL_END:
               Alert("RCI UP_END Signal ",Symbol(),Period(),Open[0]);
               break;
               break;
            case DOWN_SIGNAL:
               Alert("RCI DOWN Signal ",Symbol(),Period(),Open[0]);
               break;
            case DOWN_SIGNAL_END:
               Alert("RCI DOWN_END Signal ",Symbol(),Period(),Open[0]);
               break;
         }
         Alertflag = false;

      }

   }
   return(0);
}

