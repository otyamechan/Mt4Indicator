//+------------------------------------------------------------------+
//|                                       Otyame  No.003             |
//|                                       MACD_Rule のときのMA表示　 |
//|                                       2014.05.20                 |
//+------------------------------------------------------------------+
/*
  MACDルール表示(MA) 
 説明：チャートウインドウにMACDルールのMAを表示します
      表示時刻に関係なく表示します
　　　段数：
　　　１分⇒５分⇒１５分⇒１時間⇒４時間⇒日⇒週⇒月⇒日
      段数が０の場合は、カレント時刻とする
 
   パラメータ
      表示/非表示（０-６）
      段数（０－６）
      MA期間（０－６）
      MA演算種類（０－６）
      
      
      
   色
      MA(0-6)
*/

#property copyright "Otyame"
#property link      ""

#property indicator_buffers 8

#property indicator_chart_window

#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Aqua
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Red

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 2
#property indicator_width8 2



//---- buffers
double MA1[];
double MA2[];
double MA3[];
double MA4[];
double MA5[];
double MA6[];
double MA7[];
double MA8[];

extern   bool Disp1 = true;
extern   int Uper1 =   0;
extern   int MAPeriod1 =  8;
extern   int MAMethod1 =  0;
extern   bool Disp2 = true;
extern   int Uper2 =   0;
extern   int MAPeriod2 =  20;
extern   int MAMethod2 =  0;
extern   bool Disp3 = true;
extern   int Uper3 =   1;
extern   int MAPeriod3 =  20;
extern   int MAMethod3 =  0;
extern   bool Disp4 = true;
extern   int Uper4 =   2;
extern   int MAPeriod4 =  20;
extern   int MAMethod4 =  0;
extern   bool Disp5 = false;
extern   int Uper5 =   3;
extern   int MAPeriod5 =  20;
extern   int MAMethod5 =  0;
extern   bool Disp6 = false;
extern   int Uper6 =   4;
extern   int MAPeriod6 =  20;
extern   int MAMethod6 =  0;
extern   bool Disp7 = false;
extern   int Uper7 =   5;
extern   int MAPeriod7 =  20;
extern   int MAMethod7 =  0;
extern   bool Disp8 = false;
extern   int Uper8 =   6;
extern   int MAPeriod8 =  20;
extern   int MAMethod8 =  0;

bool Disp[8];
int Uper[8];
int MAPeriod[8];
int MAMethod[8];
int MAPerid_Time[8];
int init()
{

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA1);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MA2);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,MA3);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,MA4);
   SetIndexEmptyValue(3,EMPTY_VALUE);

   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,MA5);
   SetIndexEmptyValue(4,EMPTY_VALUE);

   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,MA6);
   SetIndexEmptyValue(5,EMPTY_VALUE);

   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,MA7);
   SetIndexEmptyValue(6,EMPTY_VALUE);

   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,MA8);
   SetIndexEmptyValue(7,EMPTY_VALUE);

   return(0);
}
int deinit()
{
   return(0);
}



int start()
{
   int i;

   Disp[0] = Disp1;
   Uper[0] = Uper1;
   MAPeriod[0] = MAPeriod1;
   MAMethod[0] = MAMethod1;
   
   Disp[1] = Disp2;
   Uper[1] = Uper2;
   MAPeriod[1] = MAPeriod2;
   MAMethod[1] = MAMethod2;
      
   Disp[2] = Disp3;
   Uper[2] = Uper3;
   MAPeriod[2] = MAPeriod3;
   MAMethod[2] = MAMethod3;
   
   Disp[3] = Disp4;
   Uper[3] = Uper4;
   MAPeriod[3] = MAPeriod4;
   MAMethod[3] = MAMethod4;
   
   Disp[4] = Disp5;
   Uper[4] = Uper5;
   MAPeriod[4] = MAPeriod5;
   MAMethod[4] = MAMethod5;

   Disp[5] = Disp6;
   Uper[5] = Uper6;
   MAPeriod[5] = MAPeriod6;
   MAMethod[5] = MAMethod6;

   Disp[6] = Disp7;
   Uper[6] = Uper7;
   MAPeriod[6] = MAPeriod7;
   MAMethod[6] = MAMethod7;

   Disp[7] = Disp8;
   Uper[7] = Uper8;
   MAPeriod[7] = MAPeriod8;
   MAMethod[7] = MAMethod8;
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
 
 
   switch(Period())  {
      case PERIOD_M1 :
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( Disp[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_M5 ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_M15 ;
                     break;
                  case 3:
                     MAPerid_Time[i]= MAPeriod[i] * PERIOD_H1 ;
                     break;
                  case 4:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H4 ;
                     break;
                  case 5:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 ;
                     break;
                  case 6:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 ;
                     break;
                  case 7:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4 ;
                     break;
                  case 8:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4 * 12 ;
                     break;
                  default:
                     Disp[i] = false;
                     break;
               }
            }
         }
 
         break;
      case PERIOD_M5:
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( Disp[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_M15 / Period() ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H1 / Period()  ;
                     break;
                  case 3:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H4 / Period()  ;
                     break;
                  case 4:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 / Period()  ;
                     break;
                  case 5:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 / Period()  ;
                     break;
                  case 6:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4/ Period()  ;
                     break;
                  case 7:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4 * 12/ Period() ;
                     break;
                  default:
                     Disp[i] = false;
                     break;
               }
            }
         }
         break;
      case PERIOD_M15:
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( Disp[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H1 / Period()  ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H4 / Period()  ;
                     break;
                  case 3:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 / Period()  ;
                     break;
                  case 4:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 / Period()  ;
                     break;
                  case 5:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4/ Period()  ;
                     break;
                  case 6:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4* 12/ Period() ;
                     break;
                  default:
                     Disp[i] = false;
                     break;
               }
            }
         }
         break;
      case PERIOD_H1:
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( Disp[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_H4 / Period()  ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 / Period()  ;
                     break;
                  case 3:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 / Period()  ;
                     break;
                  case 4:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4/ Period()  ;
                     break;
                  case 5:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4* 12/ Period() ;
                     break;
                  default:
                     Disp[i] = false;
                     break;
               }
            }
         }
         break;
      case PERIOD_H4:
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( Disp[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 / Period()  ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 / Period()  ;
                     break;
                  case 3:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4/ Period()  ;
                     break;
                  case 4:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4* 12/ Period() ;
                     break;
                  default:
                     Disp[i] = false;
                     break;
               }
            }
         }
         break;
        case PERIOD_D1:
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( Disp[i] == true ) {
               switch(Uper[i]) {
                  case 0:
                     MAPerid_Time[i] = MAPeriod[i];
                     break;
                  case 1:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 / Period()  ;
                     break;
                  case 2:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4/ Period()  ;
                     break;
                  case 3:
                     MAPerid_Time[i] = MAPeriod[i] * PERIOD_D1 * 5 * 4* 12/ Period() ;
                     break;
                  default:
                     Disp[i] = false;
                     break;
               }
            }
         }
         break;
      default:
         for ( i = 0 ; i < 8 ; i++ ) {
            if ( Disp[i] == true ) {
              Disp[i] = false;
            }
         }
         break;

 
   }                           
   for( i = limit -1 ; i >= 0 ; i--) {

      if ( Disp[0] == false ) {
            MA1[i] = EMPTY_VALUE;
      }
      else  {
            MA1[i] = iMA(NULL,0,MAPerid_Time[0],0,MAMethod[0],PRICE_CLOSE,i );
      }


      if ( Disp[1] == false ) {
            MA2[i] = EMPTY_VALUE;
      }
      else  {
         MA2[i] = iMA(NULL,0,MAPerid_Time[1],0,MAMethod[1],PRICE_CLOSE,i );
     }
     if ( Disp[2] == false ) {
            MA3[i] = EMPTY_VALUE;
         }
         else  {
            MA3[i] = iMA(NULL,0,MAPerid_Time[2],0,MAMethod[2],PRICE_CLOSE,i );
         }
      if ( Disp[3] == false ) {
            MA4[i] = EMPTY_VALUE;
         }
         else  {
            MA4[i] = iMA(NULL,0,MAPerid_Time[3],0,MAMethod[3],PRICE_CLOSE,i );
         }
      if ( Disp[4] == false ) {
            MA5[i] = EMPTY_VALUE;
         }
         else  {
            MA5[i] = iMA(NULL,0,MAPerid_Time[4],0,MAMethod[4],PRICE_CLOSE,i );
         }
      if ( Disp[5] == false ) {
            MA6[i] = EMPTY_VALUE;
         }
         else  {
            MA6[i] = iMA(NULL,0,MAPerid_Time[5],0,MAMethod[5],PRICE_CLOSE,i );
         }
      if ( Disp[6] == false ) {
            MA7[i] = EMPTY_VALUE;
         }
         else  {
            MA7[i] = iMA(NULL,0,MAPerid_Time[6],0,MAMethod[6],PRICE_CLOSE,i );
         }
      if ( Disp[7] == false ) {
            MA8[i] = EMPTY_VALUE;
         }
         else  {
            MA8[i] = iMA(NULL,0,MAPerid_Time[7],0,MAMethod[7],PRICE_CLOSE,i );
         }
   }
   return(0);
}

