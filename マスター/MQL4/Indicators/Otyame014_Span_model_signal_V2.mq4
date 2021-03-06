//+------------------------------------------------------------------+
//|                                       Otyame  No.001             |
//|                                       スパンモデル            　 |
//|                                       2014.05.20                 |
//+------------------------------------------------------------------+
/*
  スパンモデルシグナル配信版 
 説明：上位足のスパンモデルのシグナルと売買が一致した時にシグナルを発信する
 　　　時刻を変更しても、対応。下位足のシグナルについては無視する
 
   パラメータ
      Tenkan = 9;          //転換線
      Kijun = 26;          //基準線 
      Senkou = 52;         //先行スパン 
      kansi_5m = true;     //5分足考慮
      kansi_15m = true;    //15分足考慮
      kansi_30m = true;    //30分足考慮
      kansi_1H = true;     //1時間足考慮
      kansi_4H = true;     //4時間足考慮
      kansi_1D = true;     //日足考慮
      AlertON=true;        //アラート表示　
      EmailON=true;        //メール送信

   色
      買い矢印
      売り矢印
      決済矢印（未使用）


*/

#property copyright "Otyame"
#property link      ""

#property indicator_buffers 8

#property indicator_chart_window

#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Red

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 4
#property indicator_width6 4
#property indicator_width7 4
#property indicator_width8 4

#define NO_POSITION  0
#define BUY_POSITION  1 
#define SELL_POSITION  2
#define BUY_KESSAI  11
#define SELL_KESSAI 12


//---- buffers
double UpArrow[];
double DownArrow[];
double CheckPoint[];
double BollinPoint[];
double Sen1UpArrow[];
double Sen1DownArrow[];
double Sen2UpArrow[];
double Sen2DownArrow[];


string message;
extern bool AlertON=false;        //アラート表示　
extern bool EmailON=true;        //メール送信
extern  bool Redraw = false;    //5分足考慮
extern  int  Signal_Pos = 20;    //5分足考慮

extern bool bCrossArert = false;
extern bool bUseSpanAIn = false;
extern bool bUseSpanAOut = false;
extern bool bUseSpanBIn = false;
extern bool bUseSpanBOut = false;
extern bool bUseChikoCross = false;
extern bool bUseBandOut = true;
extern bool bSenSpanADirect = false;
extern bool bSenSpanBDirect = false;


extern int Tenkan = 9;           //転換線
extern int Kijun = 25;           //基準線 
extern int Senkou = 52;          //先行スパン 

extern  string _SuperBollin_Setting = "Super Bollinger Setting";
extern  bool kansi_5m = false;    //5分足考慮
extern  bool kansi_15m = false;   //15分足考慮
extern  bool kansi_30m = false;   //30分足考慮
extern  bool kansi_1H = true;    //1時間足考慮
extern  bool kansi_4H = false;    //4時間足考慮
extern  bool kansi_1D = false;    //日足考慮
extern  int  MAPeriod = 21;
extern  int  MAMethod = 0; 
bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ

double Bollin_P3sigma,Bollin_P2sigma,Bollin_P1sigma;
double Bollin_Center;
double Bollin_M3sigma,Bollin_M2sigma,Bollin_M1sigma;

double Before_Sen1,Before_Sen2;



datetime TimeOld= D'1970.01.01 00:00:00';
datetime k1mtime[];              //5分足格納用
datetime k5mtime[];              //5分足格納用
datetime k15mtime[];             //15分足格納用
datetime k30mtime[];             //30分足格納用
datetime k1Htime[];              //1時間足格納用
datetime k4Htime[];              //4時間足格納用
datetime k1Dtime[];              //日足格納用

int count_5m ;        //5分足時間格納
int count_15m ;     //15分足時間格納
int count_30m ;     //30分足時間格納
int count_1H ;       //1時間足時間格納
int count_4H ;      //4時間足時間格納
int count_1D ;     //日足時間格納

double Sen1_0,Sen1_1,Sen2_0,Sen2_1;          //クロスチェック用
double Sen1_5m,Sen2_5m,Sen1_15m,Sen2_15m;      //上位足確認用
double Sen1_30m,Sen2_30m,Sen1_1H,Sen2_1H;    
double Sen1_4H,Sen2_4H,Sen1_1D,Sen2_1D;    

bool SellCrossSignal,BuyCrossSignal,CrossSignal;
bool SellSignal,BuySignal;
bool SpanAInSignal,SpanAOutSignal;
bool SpanBInSignal,SpanBOutSignal;
bool BollinSignal;
bool Sen1DirectSignal,Sen2DirectSignal;
bool ChikoSignal;

int B_Bollin_Lank,Bollin_Lank;
double B_Bollin_Pos,Bollin_Pos;
bool B_Sen1_Direct,B_Sen2_Direct;
bool Sen1_Direct,Sen2_Direct;

bool Mail_Send_Flag;
int pos;
double pos_chk;

int c_1m,c_5m,c_15m,c_30m,c_1H,c_4H,c_1D;         //時間位置

string mes;

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
   SetIndexArrow(2,252);
   SetIndexBuffer(2,CheckPoint);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,117);
   SetIndexBuffer(3,BollinPoint);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,228);
   SetIndexBuffer(4,Sen1UpArrow);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,230);
   SetIndexBuffer(5,Sen1DownArrow);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,246);
   SetIndexBuffer(6,Sen2UpArrow);
   SetIndexEmptyValue(6,EMPTY_VALUE);
   SetIndexStyle(7,DRAW_ARROW);
   SetIndexArrow(7,248);
   SetIndexBuffer(7,Sen2DownArrow);
   SetIndexEmptyValue(7,EMPTY_VALUE);


    pos_chk = Point;
   pos = 0;
   int i;
    for ( i = 0 ; pos_chk < 1 ;i++) {
      pos++;
      pos_chk = pos_chk * 10;
   }      
   pos++;
 

   return(0);
}
int deinit()
{
   return(0);
}
int start()
{

   int i;
   if (Time[0] != TimeOld)                      //時間が更新された場合
   {
      count_5m = ArrayCopySeries(k1mtime,MODE_TIME,Symbol(),5);        //5分足時間格納
      count_5m = ArrayCopySeries(k5mtime,MODE_TIME,Symbol(),5);        //5分足時間格納
      count_15m = ArrayCopySeries(k15mtime,MODE_TIME,Symbol(),15);     //15分足時間格納
      count_30m = ArrayCopySeries(k30mtime,MODE_TIME,Symbol(),30);     //30分足時間格納
      count_1H = ArrayCopySeries(k1Htime,MODE_TIME,Symbol(),60);       //1時間足時間格納
      count_4H = ArrayCopySeries(k4Htime,MODE_TIME,Symbol(),240);      //4時間足時間格納
      count_1D = ArrayCopySeries(k1Dtime,MODE_TIME,Symbol(),1440);     //日足時間格納
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      if ( limit < 2 ) limit = 2;
      for(i= limit-1;i>=1;i--) {
         switch(Period())
         {
            case PERIOD_M1 : 
               c_1m = iBarShift(NULL,PERIOD_M1,Time[i],true);
               if ( k5mtime[c_1m] > Time[i] ) {
                  c_1m++;
               }            
            case PERIOD_M5 : 
               c_5m = iBarShift(NULL,PERIOD_M1,Time[i],true);
               if ( k5mtime[c_5m] > Time[i] ) {
                  c_5m++;
               }            
            case PERIOD_M15 :
               c_15m = iBarShift(NULL,PERIOD_M15,Time[i],true);
               if ( k15mtime[c_15m] > Time[i] ) {
                  c_15m++;
               }            
            case PERIOD_M30 :
             c_30m = iBarShift(NULL,PERIOD_M30,Time[i],true);
               if ( k30mtime[c_30m] > Time[i] ) {
                  c_30m++;
               }            
            case PERIOD_H1 :
               c_1H = iBarShift(NULL,PERIOD_H1,Time[i],true);
               if ( k1Htime[c_1H] > Time[i] ) {
                  c_1H++;
               }            
            case PERIOD_H4 :
               c_4H = iBarShift(NULL,PERIOD_H4,Time[i],true);
               if ( k4Htime[c_4H] > Time[i] ) {
                  c_4H++;
               }            
            case PERIOD_D1 :
               c_1D = iBarShift(NULL,PERIOD_D1,Time[i],true);
               if ( k1Dtime[c_1D] > Time[i] ) {
                  c_1D++;
               }            
         }
         if (c_1m == 0 ) c_1m++;
         if (c_5m == 0 ) c_5m++;
         if (c_15m == 0 ) c_15m++;
         if (c_30m == 0 ) c_30m++;
         if (c_1H == 0 ) c_1H++;
         if (c_4H == 0 ) c_4H++;
         if (c_1D == 0 ) c_1D++;
         if ( kansi_5m == true ) {
            Sen1_5m = iCustom(NULL,5,"span_model",Kijun,Tenkan,Senkou,5,c_5m);
            Sen2_5m = iCustom(NULL,5,"span_model",Kijun,Tenkan,Senkou,6,c_5m);
            Bollin_Pos = Bollin_Sigma_Chk(Time[i],Close[i],NULL,PERIOD_M5,MAPeriod,MAMethod,PRICE_CLOSE,c_5m);
         }
         else if ( kansi_15m == true ) {
           Sen1_15m = iCustom(NULL,15,"span_model",Kijun,Tenkan,Senkou,5,c_15m);
            Sen2_15m = iCustom(NULL,15,"span_model",Kijun,Tenkan,Senkou,6,c_15m);
            Bollin_Pos = Bollin_Sigma_Chk(Time[i],Close[i],NULL,PERIOD_M15,MAPeriod,MAMethod,PRICE_CLOSE,c_15m);
         }
         else  if ( kansi_30m == true ) {
            Sen1_30m = iCustom(NULL,30,"span_model",Kijun,Tenkan,Senkou,5,c_30m);
            Sen2_30m = iCustom(NULL,30,"span_model",Kijun,Tenkan,Senkou,6,c_30m);
            Bollin_Pos = Bollin_Sigma_Chk(Time[i],Close[i],NULL,PERIOD_M30,MAPeriod,MAMethod,PRICE_CLOSE,c_30m);
         }
         else if ( kansi_1H == true ) {
            Sen1_1H = iCustom(NULL,60,"span_model",Kijun,Tenkan,Senkou,5,c_1H);
            Sen2_1H = iCustom(NULL,60,"span_model",Kijun,Tenkan,Senkou,6,c_1H);
            Bollin_Pos = Bollin_Sigma_Chk(Time[i],Close[i],NULL,PERIOD_H1,MAPeriod,MAMethod,PRICE_CLOSE,c_1H);
         }
         else if ( kansi_4H == true ) {
            Sen1_4H = iCustom(NULL,240,"span_model",Kijun,Tenkan,Senkou,5,c_4H);
            Sen2_4H = iCustom(NULL,240,"span_model",Kijun,Tenkan,Senkou,6,c_4H);
            Bollin_Pos = Bollin_Sigma_Chk(Time[i],Close[i],NULL,PERIOD_H4,MAPeriod,MAMethod,PRICE_CLOSE,c_4H);
         }
         else if ( kansi_1D == true ) {
            Sen1_1D = iCustom(NULL,1440,"span_model",Kijun,Tenkan,Senkou,5,c_1D);
            Sen2_1D = iCustom(NULL,1440,"span_model",Kijun,Tenkan,Senkou,6,c_1D);
            Bollin_Pos = Bollin_Sigma_Chk(Time[i],Close[i],NULL,PERIOD_D1,MAPeriod,MAMethod,PRICE_CLOSE,c_1D);
         }
         Sen1_0 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i);
         Sen1_1 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i+1);
         Sen2_0 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i);
         Sen2_1 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i+1);
//先行スパン１、２のクロスチェック       
         if (( Sen1_1 >= Sen2_1 ) && ( Sen1_0 < Sen2_0 )) {
            SellCrossSignal = true;
            BuyCrossSignal = false;
            CrossSignal = true;
         }
         else if (( Sen1_1 <= Sen2_1 ) && ( Sen1_0 > Sen2_0 )) {
            SellCrossSignal = false;
            BuyCrossSignal = true;
            CrossSignal = true;
         }
         else {
            SellCrossSignal = true;
            BuyCrossSignal = false;
            CrossSignal = false;
         }
//売買シグナルチェック       
         if ( Sen1_0 < Sen2_0 ) {
            SellSignal = true;
            BuySignal = false;
         }
         else if ( Sen1_0 > Sen2_0 ) {
            SellSignal = false;
            BuySignal = true;
         }
         else {
            SellSignal = false;
            BuySignal = false;
         }
//SpanAを網の外からクロスした場合（bUseSpanAIn）
         SpanAInSignal = false;
         if ( BuySignal == true ) {
            if (( Close[i+1] > Sen1_1 ) && ( Close[i] <= Sen1_0 )) {
               SpanAInSignal = true;
            }
         }
         if ( SellSignal == true ) {
            if (( Close[i+1] < Sen1_1 ) && ( Close[i] >= Sen1_0 )) {
               SpanAInSignal = true;
            }
         }
//SpanAを網の内からクロスした場合（bUseSpanAOut）
         SpanAOutSignal = false;
         if ( BuySignal == true ) {
            if (( Close[i+1] < Sen1_1 ) && ( Close[i] >= Sen1_0 )) {
               SpanAOutSignal = true;
            }
         }
         if ( SellSignal == true ) {
            if (( Close[i+1] > Sen1_1 ) && ( Close[i] <= Sen1_0 )) {
               SpanAOutSignal = true;
            }
         }
//SpanBを網の外からクロスした場合（bUseSpanBIn)
         SpanBInSignal = false;
         if ( BuySignal == true ) {
            if (( Close[i+1] < Sen2_1 ) && ( Close[i] >= Sen2_0 )) {
               SpanBInSignal = true;
            }
         }
         if ( SellSignal == true ) {
            if (( Close[i+1] > Sen2_1 ) && ( Close[i] <= Sen2_0 )) {
               SpanBInSignal = true;
            }
         }
//SpanBを網の外からクロスした場合（bUseSpanBIn)
         SpanBOutSignal = false;
         if ( BuySignal == true ) {
            if( ( Close[i+1] > Sen2_1 ) && ( Close[i] <= Sen2_0 )) {
               SpanBOutSignal = true;
            }
         }
         if ( SellSignal == true ) {
            if (( Close[i+1] < Sen2_1 ) && ( Close[i] >= Sen2_0 )) {
               SpanBOutSignal = true;
            }
         }
 //ボリンジャーバンドの位置
         Bollin_Lank = Bollin_Lank_Chk(Bollin_Pos);
         if ( B_Bollin_Lank != Bollin_Lank ) {
            BollinSignal = true;
         }
         else {
            BollinSignal = false;
         }
         B_Bollin_Lank = Bollin_Lank;
         
         
//先行スパン１傾きチェック         
         Sen1DirectSignal = false;
         if ( Before_Sen1 != Sen1_0 ) {
            if ( Before_Sen1 > Sen1_0 ) {
               Sen1_Direct = false;
            }
            else if ( Before_Sen1 < Sen1_0 ) {
               Sen1_Direct = true;
            }
            Before_Sen1 = Sen1_0;
            if (( B_Sen1_Direct == true ) && ( Sen1_Direct == false )) {
               Sen1DirectSignal = true;
            }
            else if (( B_Sen1_Direct == false ) && ( Sen1_Direct == true )) {
               Sen1DirectSignal = true;
            }
            else {
               Sen1DirectSignal = false;
            }         
            B_Sen1_Direct = Sen1_Direct;
         }
//先行スパン2傾きチェック         
         Sen2DirectSignal = false;
         if ( Before_Sen2 != Sen2_0 ) {
            if ( Before_Sen2 > Sen2_0 ) {
               Sen2_Direct = false;
            }
            else if ( Before_Sen2 < Sen2_0 ) {
               Sen2_Direct = true;
            }
            Before_Sen2 = Sen2_0;
            if (( B_Sen2_Direct == true ) && ( Sen2_Direct == false )) {
               Sen2DirectSignal = true;
            }
            else if (( B_Sen2_Direct == false ) && ( Sen2_Direct == true )) {
               Sen2DirectSignal = true;
            }
            else {
               Sen2DirectSignal = false;
            }         
            B_Sen2_Direct = Sen2_Direct;
         }
//遅行スパンクロスチェック         
         ChikoSignal = false;
         if (( Close[i+1] > High[i+26] ) && (Close[i] <= High[i+25] )) {
            ChikoSignal = true;
         }
         else if (( Close[i+1] < Low[i+26] ) && (Close[i] >= Low[i+25] )) {
            ChikoSignal = true;
         }
         else if ((( Close[i+1] >= Low[i+26] ) && (Close[i+1] <= High[i+26] )) && (Close[i] > High[i+25])) {
           ChikoSignal = true;
         }
         else if ((( Close[i+1] >= Low[i+26] ) && (Close[i+1] <= High[i+26] )) && (Close[i] < Low[i+25])) {
            ChikoSignal = true;
         }
//シグナル         
         if (bCrossArert == true ) {
            if ( CrossSignal == true ) {
               if ( BuyCrossSignal == true ) {
                  UpArrow[i]=Low[i] - Point * Signal_Pos;
               }
               if ( SellCrossSignal == true ) {
                  DownArrow[i]=High[i] + Point * Signal_Pos;
               }
            }   
         }
          if (bUseSpanAIn == true ) {
            if ( SpanAInSignal == true ) {
               if ( BuySignal == true ) {
                  UpArrow[i]=Low[i] - Point * Signal_Pos;
               }
               if ( SellSignal == true ) {
                  DownArrow[i]=High[i] + Point * Signal_Pos;
               }
            }
         }   
         if (bUseSpanAOut == true ) {
            if ( SpanAOutSignal == true ) {
               if ( BuySignal == true)   {
                  UpArrow[i]=Low[i] - Point * Signal_Pos;
               }
               if ( SellSignal == true ) {
                  DownArrow[i]=High[i] + Point * Signal_Pos;
               }
            }
         }   
         if (bUseSpanBIn == true ) {
            if ( SpanBInSignal == true ) {
               if ( BuySignal == true ) {
                  UpArrow[i]=Low[i] - Point * Signal_Pos;
               }
               if ( SellSignal == true ) {
                  DownArrow[i]=High[i] + Point * Signal_Pos;
               }
            }
         }   
         if (bUseSpanBOut == true ) {
            if ( SpanBOutSignal == true ) {
               if ( BuySignal == true  ) {
                  DownArrow[i]=High[i] + Point * Signal_Pos;
               }
               if ( SellSignal == true ) {
                  UpArrow[i]=Low[i] - Point * Signal_Pos;
               }
            }
         }   
         if (bUseChikoCross == true ) {
            if ( ChikoSignal == true ) {
               if ( BuySignal == true  ) {
                  CheckPoint[i]=High[i] + Point * Signal_Pos;
               }
               if ( SellSignal == true ) {
                  CheckPoint[i]=Low[i] - Point * Signal_Pos;
               }
            }
         }   
         if (bUseBandOut == true ) {
            if ( BollinSignal == true ) {
               if ( BuySignal == true  ) {
                  BollinPoint[i]=High[i] + Point * Signal_Pos;
               }
               if ( SellSignal == true ) {
                  BollinPoint[i]=Low[i] - Point * Signal_Pos;
               }
            }
         }   
         if (bSenSpanADirect == true ) {
            if ( Sen1DirectSignal == true ) {
               if ( BuySignal == true  ) {
                  if ( Sen1_Direct == true ) {
                     Sen1UpArrow[i]=Sen1_0 + Point * Signal_Pos;
                  }
                  else {
                     Sen1DownArrow[i]=Sen1_0 + Point * Signal_Pos;
                  }
               }                  
               if ( SellSignal == true ) {
                  if ( Sen1_Direct == true ) {
                     Sen1UpArrow[i]=Sen1_0 - Point * Signal_Pos;
                  }
                  else {
                     Sen1DownArrow[i]=Sen1_0 - Point * Signal_Pos;
                  }
               }
            }
         }   
         if (bSenSpanBDirect == true ) {
            if ( Sen2DirectSignal == true ) {
               if ( BuySignal == true  ) {
                  if ( Sen2_Direct == true ) {
                     Sen2UpArrow[i]=Sen2_0 -Point * Signal_Pos;
                  }
                  else {
                     Sen2DownArrow[i]=Sen2_0 - Point * Signal_Pos;
                  }
              }                  
              if ( SellSignal == true ) {
                  if ( Sen2_Direct == true ) {
                     Sen2UpArrow[i] = Sen2_0 + Point * Signal_Pos;
                  }
                  else {
                     Sen2DownArrow[i]=Sen2_0 + Point * Signal_Pos;
                  }
               }
            }
         }   
 
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
         Mail_Send_Flag = false;
         message= "スパンモデル情報"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+DoubleToStr(Open[0],pos-1); 
         message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
         message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
         message = message + " \r\n 遅行スパン = "+chiko;
         message = message + " \r\n 26本前終値 = "+DoubleToStr(Close[25],pos-1);
         if ( kansi_5m == true ) {
            mes = "5分足";
         }
         else if ( kansi_15m == true ) {
            mes = "15分足";
         }
         else if ( kansi_30m == true ) {
            mes = "30分足";
         }
         else if ( kansi_1H == true ) {
            mes = "１時間足";
         }
         else if ( kansi_4H == true ) {
            mes = "４時間足";
         }
         else if ( kansi_1D == true ) {
            mes = "日足";
         }
         message = message + " \r\n ボリンジャーバンド "+ mes + " "+Bollin_Pos+"σ";
         if ( BuySignal == true ) {
            message = message + " \r\n 買いシグナル中";
         }
         else if ( SellSignal == true ) {
            message = message + " \r\n 売りシグナル中";
         }
         else if ( SellSignal == true ) {
             message = message + " \r\n 売買シグナル無";
         }
         if ( bCrossArert == true ) {
            Mail_Send_Flag = true;
            if ( CrossSignal == true ) {
               if ( BuyCrossSignal == true ) {
                  message = message + " \r\n 買いシグナル発生";
               }
               else if ( SellCrossSignal == true ) {
                  message = message + " \r\n 売りシグナル発生";
               }
            }
         }                          
         if (bUseSpanAIn == true ) {
            Mail_Send_Flag = true;
            if ( SpanAInSignal == true) {
               message = message +  " \r\n 先行スパン１インクロスアラート";        
            }
         }
         if (bUseSpanAOut == true ) {
            Mail_Send_Flag = true;
            if ( SpanAOutSignal == true) {
               message = message +  " \r\n 先行スパン１アウトクロスアラート";        
            }
         }
         if (bUseSpanBIn == true ) {
            Mail_Send_Flag = true;
            if ( SpanBInSignal == true) {
               message = message +  " \r\n 先行スパン２インクロスアラート";        
            }
         }
         if (bUseSpanBOut == true ) {
            Mail_Send_Flag = true;
            if ( SpanBOutSignal == true) {
               message = message +  " \r\n 先行スパン２アウトクロスアラート";        
            }
         }
         if (bUseChikoCross == true ) {
            Mail_Send_Flag = true;
            if ( ChikoSignal == true) {
               message = message +  " \r\n 遅行スパンクロスアラート";        
            }
         }
         if (bUseBandOut == true ) {            
            Mail_Send_Flag = true;
            if ( BollinSignal == true) {
               message = message +  " \r\n ボリンジャーバンドランク変更アラート";        
            }
         }
         if (bSenSpanADirect == true ) {
            Mail_Send_Flag = true;
            if ( Sen1DirectSignal == true) {
               if ( Sen1_Direct == true ) {
                  message = message +  " \r\n 先行スパン１上昇変化";        
               }
               else {
                  message = message +  " \r\n 先行スパン１下降変化";        
               
               }
            }
         }
         if (bSenSpanBDirect == true ) {
            Mail_Send_Flag = true;
            if ( Sen2DirectSignal == true) {
               if ( Sen2_Direct == true ) {
                  message = message +  " \r\n 先行スパン2上昇変化";        
               }
               else {
                  message = message +  " \r\n 先行スパン2下降変化";        
               
               }
            }
         }
         if ( Mail_Send_Flag ==  true ) {
            SendMail("スパンモデル " +"["+Symbol()+"]["+Period()+"]",message);
            Emailflag = false;      
         }
      }         
      if (Alertflag== true) {
         if ( bCrossArert == true ) {
            if ( CrossSignal == true ) {
               if ( BuyCrossSignal == true ) {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               }
               else if ( SellCrossSignal == true ) {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               }
            }
         }                          
         if (bUseSpanAIn == true ) {
            if ( SpanAInSignal == true) {
               Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
            }
         }
         if (bUseSpanAOut == true ) {
            if ( SpanAOutSignal == true) {
               Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
            }
         }
         if (bUseSpanBIn == true ) {
            if ( SpanBInSignal == true) {
               Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
            }
         }
         if (bUseSpanBOut == true ) {
            if ( SpanBOutSignal == true) {
               Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
            }
         }
         if (bUseChikoCross == true ) {
            if ( ChikoSignal == true) {
               Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
            }
         }
         if (bUseBandOut == true ) {            
            if ( BollinSignal == true) {
               Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
            }
         }
         if (bSenSpanADirect == true ) {
            if ( Sen1DirectSignal == true) {
               if ( Sen1_Direct == true ) {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               }
               else {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               }
            }
         }
         if (bSenSpanBDirect == true ) {
            if ( Sen2DirectSignal == true) {
               if ( Sen2_Direct == true ) {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               }
               else {
                  Alert("Spanmodel Infomation",Symbol(),Period(),DoubleToStr(Open[0],pos-1));
               }
            }
         }
         Alertflag = false;      
      } 
   }


   return(0);
}

double Bollin_Sigma_Chk(datetime date,double data,string Chk_symbol,int Chk_Period,int Chk_MAPeriod,int Chk_MAMethod,int Chk_Price,int position)
{
   int i;
   double Chk_data[2];
   double ret;
   Chk_data[0] = iMA(Chk_symbol,Chk_Period,Chk_MAPeriod,0,Chk_MAMethod,Chk_Price,position);
   
   if ( data > Chk_data[0] ) {
      i = 1;
      while(1) {
         Chk_data[1]   = iBands(Chk_symbol,Chk_Period,Chk_MAPeriod,i,0,Chk_Price,MODE_UPPER,position);
         if  ( data > Chk_data[1] ) {
            Chk_data[0] = Chk_data[1];
         }
         else {
            ret = (data- Chk_data[0])/(Chk_data[1] - Chk_data[0])+ i -1;
            break;
         }
         i++;
         if ( i > 4 ) break;
      }         
   }
   else if ( data < Chk_data[0] ) {
      i = 1;
      while(1) {
         Chk_data[1]   = iBands(Chk_symbol,Chk_Period,Chk_MAPeriod,i,0,Chk_Price,MODE_LOWER,position);
         if  ( data < Chk_data[1] ) {
            Chk_data[0] = Chk_data[1];
         }
         else {
            ret = (-1) * (data- Chk_data[0])/(Chk_data[1] - Chk_data[0])  - i +1;
            break;
         }
         i++;
         if ( i > 4 ) break;
      }         
   }
   else {
      ret = 0.00;
   }
   ret = NormalizeDouble(ret,2);

   return(ret);
}   
int  Bollin_Lank_Chk(double data)
{
   int ret;
   if ( data <= -3.0 ) {
      ret = -4;
   }
   else if (( data <= -2.0 ) && ( data > -3.0 )) {
      ret = -3;
   }         
   else if (( data <= -1.0 ) && ( data > -2.0 )) {
      ret = -2;
   }         
   else if (( data <= 0.0 ) && ( data > -1.0 )) {
      ret = -1;
   }         
   else if (( data <= 1.0 ) && ( data > 0.0 )) {
      ret = 1;
   }         
   else if (( data <= 2.0 ) && ( data > 1.0 )) {
      ret = 2;
   }         
   else if (( data <= 3.0 ) && ( data > 2.0 )) {
      ret = 3;
   }         
   else if ( data > 3.0 )  {
      ret = 4;
   }         
   return(ret);
}
