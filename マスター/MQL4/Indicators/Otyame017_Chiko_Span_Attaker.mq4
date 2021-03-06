//+------------------------------------------------------------------+
//|                                       Otyame  No.017             |
//|                                    Otyame017_Chiko_Span_Attaker.mq4 |
//|                                       2014.05.22                 |
//+------------------------------------------------------------------+

#property copyright   "2015,Otyame Trader"
#property description "Otyame017_Chiko_Span_Attaker"


#property indicator_buffers 2

#property indicator_chart_window


#property indicator_color1 Aqua
#property indicator_color2 Magenta

#property indicator_width1 4
#property indicator_width2 4


#define NO 0
#define UP 1
#define DOWN 2



//---- buffers
double UpArrow[];
double DownArrow[];

double MA[10];
double Usigma_1[10];
double Lsigma_1[10];
double Usigma_2[10];
double Lsigma_2[10];
double Usigma_3[10];
double Lsigma_3[10];
double Chikou[10];
double Sigma_data[10];

string message;
extern bool AlertON=false;					//アラート表示　
extern bool EmailON=true;       			//メール送信
extern  bool Redraw = false;    			//再描画
extern  int  Signal_Pos = 20;   			//シグナル位置

extern bool Keizoku_hantei = true;
extern string _Super_Bollin = "Super Bollinger Setting";
extern int MAPeriod = 21;            //中心期間
extern   string _MAMethod = "0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int MAMethod = 0;            //中心線用MA Method
extern int Chikou_Idou = 20;            //遅行スパン描画


extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 7;
extern string symbol1 = "USDJPY";
extern string symbol2 = "EURJPY";
extern string symbol3 = "EURUSD";
extern string symbol4 = "GBPJPY";
extern string symbol5 = "EURGBP";
extern string symbol6 = "AUDUSD";
extern string symbol7 = "GBPUSD";
extern string symbol8 = "CADJPY";
extern string symbol9 = "EURGBP";
extern string symbol10 = "NZDJPY";

int cnt;
int symbol_max;
double pos_chk;
string symbol_chk[10];
string mes;
bool symbol_true[10];
bool Emailflag;                  //メール送信判定フラグ            
bool Alertflag;                 //アラート表示判定フラグ
int rtn;
int pos[10];
bool Timeflg = false;
bool buy[10];
bool sell[10];
int BandS[10];
int O_BandS[10];
int kind[10];

datetime TimeOld= D'1970.01.01 00:00:00';
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
 	IndicatorShortName("Otyame017_Chiko_Span_Attaker");
  if ( symbol_suu >= 10 ) {
      symbol_max = 10;
   }
   else    symbol_max = symbol_suu;
   symbol_chk[0] = symbol1;
   symbol_chk[1] = symbol2;
   symbol_chk[2] = symbol3;
   symbol_chk[3] = symbol4;
   symbol_chk[4] = symbol5;
   symbol_chk[5] = symbol6;
   symbol_chk[6] = symbol7;
   symbol_chk[7] = symbol8;
   symbol_chk[8] = symbol9;
   symbol_chk[9] = symbol10;
   if (symbol_max == 0 ) {
      symbol_max = 1;
      symbol_true[0] = true;
      symbol_chk[0] = Symbol();
    }
    else      {
      for ( cnt = 0 ; cnt < symbol_max ; cnt++) {
         symbol_true[cnt] = true;
         pos_chk = MarketInfo(symbol_chk[cnt],MODE_POINT);
         rtn = GetLastError();         
         if ( rtn == ERR_UNKNOWN_SYMBOL ) {
            Print(symbol_chk[cnt]+"は存在しません。 ERR NO = ",rtn);
            symbol_true[cnt] = false;
         }
      } 
           
   }   
   return(0);
}
int deinit()
{
   return(0);
}



int start()
{
   int i;
   if (Time[0] != TimeOld)    {                     //時間が更新された場合
      Timeflg = true;
      for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
         if ( symbol_true[cnt] == true ) {
            if (iTime(symbol_chk[cnt],Period(),0) != Time[0])  {
               Timeflg = false;
               break;
            }
         }
      }                      
   }
   else {
      Timeflg = false;
   }
   if ( Timeflg == true ) {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return (-1);
//      if (counted_bars > 0) counted_bars;
      int limit = Bars - counted_bars;
      if ( Redraw == true ) {
         limit = Bars ;
      } 
      for (  cnt = 0 ; cnt < symbol_max ; cnt++) {  
         if ( symbol_true[cnt] == false ) {
            continue;
         }
         if ( limit < 2 ) limit = 2;
         for(i= limit-1;i>=1;i--){
            MA[cnt]   = iMA(NULL,0,MAPeriod,0,MAMethod,PRICE_CLOSE,i);
            Lsigma_1[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,1,0,PRICE_CLOSE,MODE_LOWER,i);
            Usigma_1[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,1,0,PRICE_CLOSE,MODE_UPPER,i);
            Lsigma_2[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,2,0,PRICE_CLOSE,MODE_LOWER,i);
            Usigma_2[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,2,0,PRICE_CLOSE,MODE_UPPER,i);
            Lsigma_3[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,3,0,PRICE_CLOSE,MODE_LOWER,i);
            Usigma_3[cnt]   = iBands(symbol_chk[cnt],0,MAPeriod,3,0,PRICE_CLOSE,MODE_UPPER,i);
            Sigma_data[cnt] = Bollin_Sigma_Chk(iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],0,MAPeriod,MAMethod,PRICE_CLOSE,i);
            Chikou[cnt] = iClose(symbol_chk[cnt],0,i);
            buy[cnt] = false;
            sell[cnt] = false;
//            if ( O_BandS[cnt] != UP ) {
               if ( ( Chikou[cnt] > iHigh(symbol_chk[cnt],0,i+Chikou_Idou) ) && (iClose(symbol_chk[cnt],0,i) >= Usigma_1[cnt])) {
                  buy[cnt] = true;
               }
//            }
//            if ( O_BandS[cnt] != DOWN ) {
               if (( Chikou[cnt] < iLow(symbol_chk[cnt],0,i+Chikou_Idou) ) && (iClose(symbol_chk[cnt],0,i) <= Lsigma_1[cnt])) {
                  sell[cnt] = true;
               }
//            }
            switch(O_BandS[cnt]) {
               case NO:
                  if ( buy[cnt] == true ) {
                     BandS[cnt] = UP;
                     kind[cnt] = UP;
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpArrow[i]=Low[i]  - Point * Signal_Pos;
                     }  
                  }
                  else if ( sell[cnt] == true ) {
                     BandS[cnt] = DOWN;
                     kind[cnt] = DOWN;
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownArrow[i]=High[i]  + Point * Signal_Pos;
                     }
                  }
                  else {
                     BandS[cnt] = NO;
                     kind[cnt] = 0;
                  }              
                  break;  
               case UP:
                  if ( buy[cnt] == true ) {
                     BandS[cnt] = UP;
                     kind[cnt] = 0;
                  }
                  else if ( sell[cnt] == true ) {
                     BandS[cnt] = DOWN;
                     kind[cnt] = DOWN;
                     if ( symbol_chk[cnt] == Symbol()) {
                        DownArrow[i]=High[i]  + Point * Signal_Pos;
                     }
                  }
                  else {
                     if ( Keizoku_hantei == true ) {
                        BandS[cnt] = UP;
                     }
                     else {
                        BandS[cnt] = NO;
                     }                         
                     kind[cnt] = 0;
                  }              
                  break;  
               case DOWN:
                  if ( buy[cnt] == true ) {
                     BandS[cnt] = UP;
                     kind[cnt] = UP;
                     if ( symbol_chk[cnt] == Symbol()) {
                        UpArrow[i]=Low[i]  - Point * Signal_Pos;
                     }
                  }
                  else if ( sell[cnt] == true ) {
                     BandS[cnt] = DOWN;
                     kind[cnt] = 0;
                  }
                  else {
                     if ( Keizoku_hantei == true ) {
                        BandS[cnt] = DOWN;
                     }
                     else {
                        BandS[cnt] = NO;
                     }                         
                     kind[cnt] = 0;
                  }              
                  break;
            }  
            O_BandS[cnt] = BandS[cnt];
            
            
            
            
            
            
            
            
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
      if (Emailflag== true) {
          for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
            if (symbol_true[cnt] == false ) {
               continue;
            }
            switch(kind[cnt])   {
            case UP:
               message= "遅行スパンアタック買いシグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n 現在値="+DoubleToString(iOpen(symbol_chk[cnt],Period(),0));
               message = message + "\r\n"+"現在値　"+DoubleToStr(Sigma_data[cnt],2)+"σ ";
               break;
            case DOWN:
               message= "遅行スパンアタック売りシグナル"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+IntegerToString(Period())+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE | TIME_MINUTES)+"\r\n 現在値="+DoubleToString(iOpen(symbol_chk[cnt],Period(),0));
               message = message + "\r\n"+"現在値　"+DoubleToStr(Sigma_data[cnt],2)+"σ ";
               break;
            }

            message = message + "\r\n"+"＋１σ= "+DoubleToString(Usigma_1[cnt]);
            message = message + "\r\n"+"＋２σ= "+DoubleToString(Usigma_2[cnt]);
            message = message + "\r\n"+"＋３σ= "+DoubleToString(Usigma_3[cnt]);
            message = message + "\r\n"+"ＭＡ= "+DoubleToString(MA[cnt]);
            message = message + "\r\n"+"－１σ= "+DoubleToString(Lsigma_1[cnt]);
            message = message + "\r\n"+"－２σ= "+DoubleToString(Lsigma_2[cnt]);
            message = message + "\r\n"+"－３σ= "+DoubleToString(Lsigma_3[cnt]);
            message = message + " \r\n "+IntegerToString(Chikou_Idou)+"本前高値 = "+DoubleToString(iHigh(symbol_chk[cnt],0,Chikou_Idou));
            message = message + " \r\n "+IntegerToString(Chikou_Idou)+"本前安値 = "+DoubleToString(iLow(symbol_chk[cnt],0,Chikou_Idou));
            message = message + " \r\n "+IntegerToString(Chikou_Idou)+"本前終値 = "+DoubleToString(iClose(symbol_chk[cnt],0,Chikou_Idou));
            message = message + " \r\n "+IntegerToString(Chikou_Idou)+"本前始値 = "+DoubleToString(iOpen(symbol_chk[cnt],0,Chikou_Idou));

            if ( kind[cnt] != 0 ) SendMail("遅行スパンアタックシグナル " +"["+symbol_chk[cnt]+"]["+IntegerToString(Period())+"]",message);
         }      
      }
      Emailflag = false;      
      if (Alertflag== true) {
         for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
 
            if (symbol_true[cnt] == false ) {
               continue;
            }

      
            if (Alertflag== true) {
               switch(kind[cnt])   {
               case UP:
                  Alert("Chiko Span Attacker BUY Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               case DOWN:
                  Alert("Chiko Span Attacker SELL Signal ",symbol_chk[cnt],Period(),DoubleToStr(iOpen(symbol_chk[cnt],Period(),0),pos[cnt]-1));
                  break;
               }
            }
         }
      }
      Alertflag = false;
   }
   return(0);
}
double Bollin_Sigma_Chk(double data,string Chk_symbol,int Chk_Period,int Chk_MAPeriod,int Chk_MAMethod,int Chk_Price,int position)
{
   int i_chk;
   double Chk_data[2];
   double ret;
   Chk_data[0] = iMA(Chk_symbol,Chk_Period,Chk_MAPeriod,0,Chk_MAMethod,Chk_Price,position);
   
   if ( data > Chk_data[0] ) {
      i_chk = 1;
      while(1) {
         Chk_data[1]   = iBands(Chk_symbol,Chk_Period,Chk_MAPeriod,i_chk,0,Chk_Price,MODE_UPPER,position);
         if  ( data > Chk_data[1] ) {
            Chk_data[0] = Chk_data[1];
         }
         else {
            ret = (data- Chk_data[0])/(Chk_data[1] - Chk_data[0])+ i_chk -1;
            break;
         }
         i_chk++;
         if ( i_chk > 4 ) break;
      }         
   }
   else if ( data < Chk_data[0] ) {
     i_chk = 1;
      while(1) {
         Chk_data[1]   = iBands(Chk_symbol,Chk_Period,Chk_MAPeriod,i_chk,0,Chk_Price,MODE_LOWER,position);
         if  ( data < Chk_data[1] ) {
            Chk_data[0] = Chk_data[1];
         }
         else {
            ret = (-1) * (data- Chk_data[0])/(Chk_data[1] - Chk_data[0])  - i_chk +1;
            break;
         }
         i_chk++;
         if ( i_chk > 4 ) break;
      }         
   }
   else {
      ret = 0.00;
   }
   ret = NormalizeDouble(ret,2);

   return(ret);
}   
         
         
              
            
            














   

