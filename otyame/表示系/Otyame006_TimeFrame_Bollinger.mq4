//+------------------------------------------------------------------+
//|                                 Otyame006_TimeFrame_Bollinger.mq4|
//|                                    2014.05.20                    |
//+------------------------------------------------------------------+


#property copyright   "2015,Otyame Trader"
#property description "Otyame006_TimeFrame_Bollinger"
#property strict

#property indicator_buffers 7

#property indicator_chart_window

#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red

#property indicator_width1 2
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1



//---- buffers
double MA[];
double Usigma_1[];
double Lsigma_1[];
double Usigma_2[];
double Lsigma_2[];
double Usigma_3[];
double Lsigma_3[];

extern int Uper   = 1;
extern int MAPeriod =  20;
extern   string _MAMethod = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int MAMethod = 0;            //中心線用MA Method
extern bool center_sen = true;         //1σ描画
extern bool sigma_1 = true;         //1σ描画
extern bool sigma_2 = true;         //2σ描画
extern bool sigma_3 = true;         //3σ描画


int init()
{

//---- indicators
   IndicatorDigits(Digits+1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexLabel(1,"MA");


   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Lsigma_1);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexLabel(1,"-1σ");


   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Usigma_1);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexLabel(2,"+1σ");

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Lsigma_2);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexLabel(2,"-2σ");

   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Usigma_2);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexLabel(3,"+2σ");

   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Lsigma_3);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexLabel(5,"-3σ");

   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,Usigma_3);
   SetIndexEmptyValue(6,EMPTY_VALUE);
   SetIndexLabel(7,"+3σ");
	IndicatorShortName("Otyame006_TimeFrame_Bollinger");

   return(0);
}
int deinit()
{
   return(0);
}

int start()
{
   int i;
   int MAPerid_Time = 0;
   bool Disp = true;

   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
 
 
   switch(Period())  {
      case PERIOD_M1 :
         switch(Uper) {
            case 0:
               MAPerid_Time = MAPeriod;
               break;
            case 1:
               MAPerid_Time = MAPeriod * PERIOD_M5 ;
               break;
            case 2:
               MAPerid_Time = MAPeriod * PERIOD_M15 ;
               break;
            case 3:
               MAPerid_Time= MAPeriod * PERIOD_H1 ;
               break;
            case 4:
               MAPerid_Time = MAPeriod * PERIOD_H4 ;
               break;
            case 5:
               MAPerid_Time = MAPeriod * PERIOD_D1 ;
               break;
            case 6:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 ;
               break;
            case 7:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4 ;
               break;
            case 8:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4 * 12 ;
               break;
            default:
               Disp = false;
               break;
         }
 
         break;
      case PERIOD_M5:
         switch(Uper) {
            case 0:
               MAPerid_Time = MAPeriod;
               break;
            case 1:
               MAPerid_Time = MAPeriod * PERIOD_M15 / Period() ;
               break;
            case 2:
               MAPerid_Time = MAPeriod * PERIOD_H1 / Period()  ;
               break;
            case 3:
               MAPerid_Time = MAPeriod * PERIOD_H4 / Period()  ;
               break;
            case 4:
               MAPerid_Time = MAPeriod * PERIOD_D1 / Period()  ;
               break;
            case 5:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 / Period()  ;
               break;
            case 6:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4/ Period()  ;
               break;
            case 7:
                MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4 * 12/ Period() ;
                break;
             default:
                Disp = false;
                break;
         }
         break;
      case PERIOD_M15:
         switch(Uper) {
            case 0:
               MAPerid_Time = MAPeriod;
               break;
            case 1:
               MAPerid_Time = MAPeriod * PERIOD_H1 / Period()  ;
               break;
             case 2:
               MAPerid_Time = MAPeriod * PERIOD_H4 / Period()  ;
               break;
             case 3:
               MAPerid_Time = MAPeriod * PERIOD_D1 / Period()  ;
               break;
             case 4:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 / Period()  ;
               break;
             case 5:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4/ Period()  ;
               break;
             case 6:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4* 12/ Period() ;
               break;
             default:
                Disp = false;
                break;
         }
         break;
      case PERIOD_H1:
         switch(Uper) {
            case 0:
               MAPerid_Time = MAPeriod;
               break;
             case 1:
                MAPerid_Time = MAPeriod * PERIOD_H4 / Period()  ;
                 break;
             case 2:
                 MAPerid_Time = MAPeriod * PERIOD_D1 / Period()  ;
                  break;
              case 3:
                 MAPerid_Time = MAPeriod * PERIOD_D1 * 5 / Period()  ;
                 break;
              case 4:
                 MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4/ Period()  ;
                 break;
              case 5:
                 MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4* 12/ Period() ;
                 break;
              default:
                 Disp = false;
                 break;
         }
         break;
      case PERIOD_H4:
         switch(Uper) {
            case 0:
               MAPerid_Time = MAPeriod;
               break;
            case 1:
               MAPerid_Time = MAPeriod * PERIOD_D1 / Period()  ;
               break;
            case 2:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 / Period()  ;
               break;
            case 3:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4/ Period()  ;
               break;
            case 4:
               MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4* 12/ Period() ;
               break;
             default:
                Disp = false;
                break;
         }
         break;
        case PERIOD_D1:
            switch(Uper) {
               case 0:
                  MAPerid_Time = MAPeriod;
                  break;
               case 1:
                  MAPerid_Time = MAPeriod * PERIOD_D1 * 5 / Period()  ;
                  break;
                case 2:
                  MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4/ Period()  ;
                  break;
               case 3:
                  MAPerid_Time = MAPeriod * PERIOD_D1 * 5 * 4* 12/ Period() ;
                  break;
               default:
                  Disp = false;
                  break;
         }
         break;
      default:
          Disp = false;
         break;

 
   }                           
   for( i = limit -1 ; i >= 0 ; i--) {

      if ( Disp == false ) {
         MA[i] = EMPTY_VALUE;
         Usigma_1[i] =  EMPTY_VALUE;
         Lsigma_1[i] = EMPTY_VALUE;
         Usigma_2[i] = EMPTY_VALUE;
         Lsigma_2[i] = EMPTY_VALUE;
         Usigma_3[i] = EMPTY_VALUE;
         Lsigma_3[i] = EMPTY_VALUE;
      }
      else  {
            if  ( center_sen == true ) {
               MA[i] = iMA(NULL,0,MAPerid_Time,0,MAMethod,PRICE_CLOSE,i );
            }
            else  {
               MA[i] = EMPTY_VALUE;
            }
              
            if  ( sigma_1 == true ) {
               Lsigma_1[i]   = iBands(NULL,0,MAPerid_Time,1,0,PRICE_CLOSE,MODE_LOWER,i);
               Usigma_1[i]   = iBands(NULL,0,MAPerid_Time,1,0,PRICE_CLOSE,MODE_UPPER,i);
            }
            else {
               Lsigma_1[i]   = EMPTY_VALUE;
               Usigma_1[i]   = EMPTY_VALUE;
            }         
            if  ( sigma_2 == true ) {
               Lsigma_2[i]   = iBands(NULL,0,MAPerid_Time,2,0,PRICE_CLOSE,MODE_LOWER,i);
               Usigma_2[i]   = iBands(NULL,0,MAPerid_Time,2,0,PRICE_CLOSE,MODE_UPPER,i);
            }
            else {
               Lsigma_2[i]   = EMPTY_VALUE;
               Usigma_2[i]   = EMPTY_VALUE;
            }         
            if  ( sigma_3 == true ) {
               Lsigma_3[i]   = iBands(NULL,0,MAPerid_Time,3,0,PRICE_CLOSE,MODE_LOWER,i);
               Usigma_3[i]   = iBands(NULL,0,MAPerid_Time,3,0,PRICE_CLOSE,MODE_UPPER,i);
            }
            else {
               Lsigma_3[i]   = EMPTY_VALUE;
               Usigma_3[i]   = EMPTY_VALUE;
            }         
      }
   }
   return(0);
}

