//+---------------------------------------------------------------------------+
//|                                       Otyame  No.001                      |
//|                                       スパンモデル            　          |
//|                                       Otyame101_span_model_signal　　　　 |
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
#property indicator_color3 Black
#property indicator_color4 Black

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4

#define NO_SIGNAL  0
#define BUY_SIGNAL  1 
#define SELL_SIGNAL  2

#define NO  0
#define UP  1 
#define DOWN  2


//---- buffers
double UpArrow[];
double DownArrow[];
double UpKessaiArrow[];
double DownKessaiArrow[];

string message;
extern bool AlertON=false;					//アラート表示　
extern bool EmailON=true;       			//メール送信
extern  bool Redraw = false;    			//再描画
extern  int  Signal_Pos = 20;   			//シグナル位置

extern int Tenkan = 9;          			//転換線
extern int Kijun = 25;           		//基準線 
extern int Senkou = 52;          		//先行スパン
extern int MAPeriod = 21;
extern int MAMethod = 0; 

extern  bool Email_Bollin_15m = false;   		//15分足考慮
extern  bool Email_Bollin_30m = false;   		//15分足考慮
extern  bool Email_Bollin_1h = false;   		//15分足考慮
extern  bool Email_Bollin_4h = false;   		//15分足考慮
extern  bool Email_Bollin_1d = false;   		//15分足考慮
extern  bool kansi_Bollin_15m = false;   		//15分足考慮
extern  bool kansi_Bollin_30m = false;   		//30分足考慮
extern  bool kansi_Bollin_1H = true;    		//1時間足考慮
extern  bool kansi_Bollin_4H = false;    		//4時間足考慮
extern  bool kansi_Bollin_1D = false;    		//日足考慮

extern  bool Email_Span_15m = false;   		//15分足考慮
extern  bool Email_Span_30m = false;   		//15分足考慮
extern  bool Email_Span_1h = false;   		//15分足考慮
extern  bool Email_Span_4h = false;   		//15分足考慮
extern  bool Email_Span_1d = false;   		//15分足考慮
extern  bool kansi_Span_15m = false;   		//15分足考慮
extern  bool kansi_Span_30m = false;   		//30分足考慮
extern  bool kansi_Span_1H = true;    		//1時間足考慮
extern  bool kansi_Span_4H = false;    		//4時間足考慮
extern  bool kansi_Span_1D = false;    		//日足考慮
extern string _symbol_suu = "symbol_suu = (from 0 to 10)";
extern int symbol_suu = 10;
extern string symbol1 = "USDJPY";
extern string symbol2 = "EURJPY";
extern string symbol3 = "EURUSD";
extern string symbol4 = "GBPJPY";
extern string symbol5 = "AUDJPY";
extern string symbol6 = "AUDUSD";
extern string symbol7 = "GBPUSD";
extern string symbol8 = "CADJPY";
extern string symbol9 = "EURGBP";
extern string symbol10 = "NZDJPY";

bool Emailflag;                  		//メール送信判定フラグ            
bool Alertflag;                 		   //アラート表示判定フラグ

datetime TimeOld= D'1970.01.01 00:00:00';
datetime k5mtime[];                    //5分足格納用
datetime k15mtime[];                   //15分足格納用
datetime k30mtime[];                   //30分足格納用
datetime k1Htime[];                    //1時間足格納用
datetime k4Htime[];                    //4時間足格納用
datetime k1Dtime[];                    //日足格納用

int count_5m ;        	               //5分足時間格納
int count_15m ;     	                  //15分足時間格納
int count_30m ;                        //30分足時間格納
int count_1H ;                         //1時間足時間格納
int count_4H ;                         //4時間足時間格納
int count_1D ;                         //日足時間格納
int symbol_max;
int pos_chk;
string symbol_chk[10];
bool symbol_true[10];
int cnt;
int rtn;
bool buy[10];
bool sell[10];
bool S_buy[10];
bool S_sell[10];
bool Timeflg;

int c_5m,c_15m,c_30m,c_1H,c_4H,c_1D;   //時間位置
bool Bollin_15m_Flag[10],Bollin_30m_Flag[10],Bollin_1h_Flag[10],Bollin_4h_Flag[10],Bollin_1d_Flag[10];
bool Span_15m_Flag[10],Span_30m_Flag[10],Span_1h_Flag[10],Span_4h_Flag[10],Span_1d_Flag[10];

double Bollin_15m[10],Bollin_30m[10],Bollin_1h[10],Bollin_4h[10],Bollin_1d[10];
int Bollin_Lank_15m[10],Bollin_Lank_30m[10],Bollin_Lank_1h[10],Bollin_Lank_4h[10],Bollin_Lank_1d[10];
string mes_Bollin_15m[10],mes_Bollin_30m[10],mes_Bollin_1h[10],mes_Bollin_4h[10],mes_Bollin_1d[10];
double O_Bollin_15m[10],O_Bollin_30m[10],O_Bollin_1h[10],O_Bollin_4h[10],O_Bollin_1d[10];
int O_Bollin_Lank_15m[10],O_Bollin_Lank_30m[10],O_Bollin_Lank_1h[10],O_Bollin_Lank_4h[10],O_Bollin_Lank_1d[10];
double Sen1_0[10],Sen1_1[10],Sen2_0[10],Sen2_1[10];          //クロスチェック用
double Sen1_0_15m[10],Sen1_0_30m[10],Sen1_0_1h[10],Sen1_0_4h[10],Sen1_0_1d[10];
double Sen2_0_15m[10],Sen2_0_30m[10],Sen2_0_1h[10],Sen2_0_4h[10],Sen2_0_1d[10];
int Span_15m[10],Span_30m[10],Span_1h[10],Span_4h[10],Span_1d[10];
int O_Span_15m[10],O_Span_30m[10],O_Span_1h[10],O_Span_4h[10],O_Span_1d[10];
string mes_Span_15m[10],mes_Span_30m[10],mes_Span_1h[10],mes_Span_4h[10],mes_Span_1d[10];
string mes_period[10];
bool Send_Flag;


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
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,DownKessaiArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
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
	IndicatorShortName("Otyame119_span_model_signal");
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
      for (  cnt = 0 ; cnt < symbol_max ; cnt++) {  
         if ( symbol_true[cnt] == false ) {
            continue;
         }
         if ( limit < 2 ) limit = 2;
         for(i= limit-1;i>=1;i--){
            buy[cnt] = false;
            sell[cnt] = false;
            
            c_5m = iBarShift(NULL,PERIOD_M5,Time[i],true);
            if ( k5mtime[c_5m] > Time[i] ) {
               c_5m++;
            }            
            c_15m = iBarShift(NULL,PERIOD_M15,Time[i],true);
            if ( k15mtime[c_15m] > Time[i] ) {
               c_15m++;
            }            
            c_30m = iBarShift(NULL,PERIOD_M30,Time[i],true);
            if ( k30mtime[c_30m] > Time[i] ) {
               c_30m++;
            }            
            c_1H = iBarShift(NULL,PERIOD_H1,Time[i],true);
            if ( k1Htime[c_1H] > Time[i] ) {
               c_1H++;
            }            
            c_4H = iBarShift(NULL,PERIOD_H4,Time[i],true);
            if ( k4Htime[c_4H] > Time[i] ) {
               c_4H++;
            }            
            c_1D = iBarShift(NULL,PERIOD_D1,Time[i],true);
            if ( k1Dtime[c_1D] > Time[i] ) {
               c_1D++;
            }            
            if (c_1H == 0 ) c_1H++;
            if (c_15m == 0 ) c_15m++;
            if (c_30m == 0 ) c_30m++;
            if (c_1H == 0 ) c_1H++;
            if (c_4H == 0 ) c_4H++;
            if (c_1D == 0 ) c_1D++;
            Sen1_0[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,5,i);
            Sen1_1[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,5,i+1);
            Sen2_0[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,6,i);
            Sen2_1[cnt] = iCustom(symbol_chk[cnt],0,"span_model",Kijun,Tenkan,Senkou,6,i+1);
            switch(Period())  {
            case PERIOD_M5:
               mes_period[cnt] = "５分足";
               break;
            case PERIOD_M15:
               mes_period[cnt] = "１５分足";
               break;
            case PERIOD_M30:
               mes_period[cnt] = "３０分足";
               break;
            case PERIOD_H1:
               mes_period[cnt] = "時間足";
               break;
            case PERIOD_H4:
               mes_period[cnt] = "４時間足";
               break;
            case PERIOD_D1:
               mes_period[cnt] = "日足";
               break;
            }      
            buy[cnt] = false;
            sell[cnt] = false;
            S_buy[cnt] = false;
            S_sell[cnt] = false;
            if((Sen1_0[cnt] > Sen2_0[cnt]) && (Sen1_1[cnt] <= Sen2_1[cnt]) ) {
               S_buy[cnt] = true;
            }
            else if ((Sen1_0[cnt] < Sen2_0[cnt]) && (Sen1_1[cnt] >= Sen2_1[cnt]) ) {
               S_sell[cnt] = true;
            }
            if(Sen1_0[cnt] > Sen2_0[cnt]  ) {
               buy[cnt] = true;
               mes_period[cnt] = " \r\n"+mes_period[cnt] + ":買いシグナル"; 
            }
            else if (Sen1_0[cnt] < Sen2_0[cnt] ) {
               sell[cnt] = true;
               mes_period[cnt] = " \r\n"+mes_period[cnt] + ":売りシグナル"; 
            }
            else {
               mes_period[cnt] = " \r\n"+mes_period[cnt] + ":ＮＯシグナル"; 
            }            
            Bollin_15m_Flag[cnt] = false;
            Bollin_30m_Flag[cnt] = false;
            Bollin_1h_Flag[cnt] = false;
            Bollin_4h_Flag[cnt] = false;
            Bollin_1d_Flag[cnt] = false;
            Span_15m_Flag[cnt] = false;
            Span_30m_Flag[cnt] = false;
            Span_1h_Flag[cnt] = false;
            Span_4h_Flag[cnt] = false;
            Span_1d_Flag[cnt] = false;
            
            
            
            if (( kansi_Bollin_15m == true )&& (Period() < PERIOD_M15)) {
               Bollin_15m[cnt] = Bollin_Sigma_Chk(iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_M15,MAPeriod,MAMethod,PRICE_CLOSE,c_15m);
               Bollin_Lank_15m[cnt] = Bollin_Lank_Chk(Bollin_15m[cnt]);
               mes_Bollin_15m[cnt] = "\r\n 15分足："+DoubleToStr(O_Bollin_15m[cnt],2)+"σ →　"+DoubleToStr(Bollin_15m[cnt],2)+"σ";
               if ( Bollin_Lank_15m[cnt] != O_Bollin_Lank_15m[cnt] ) {
                  Bollin_15m_Flag[cnt] = true;
               }
               O_Bollin_Lank_15m[cnt] = Bollin_Lank_15m[cnt];
               O_Bollin_15m[cnt] = Bollin_15m[cnt];
            }  
            if (( kansi_Bollin_30m == true ) && (Period() < PERIOD_M30)){
               Bollin_30m[cnt] = Bollin_Sigma_Chk(iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_M30,MAPeriod,MAMethod,PRICE_CLOSE,c_30m);
               Bollin_Lank_30m[cnt] = Bollin_Lank_Chk(Bollin_30m[cnt]);
               mes_Bollin_30m[cnt] = "\r\n 30分足："+DoubleToStr(O_Bollin_30m[cnt],2)+"σ →　"+DoubleToStr(Bollin_30m[cnt],2)+"σ";
               if ( Bollin_Lank_30m[cnt] != O_Bollin_Lank_30m[cnt] ) {
                  Bollin_30m_Flag[cnt] = true;
               }
               O_Bollin_Lank_30m[cnt] = Bollin_Lank_30m[cnt];
               O_Bollin_30m[cnt] = Bollin_30m[cnt];
            }  
            if (( kansi_Bollin_1H == true ) && (Period() < PERIOD_H1)){
               Bollin_1h[cnt] = Bollin_Sigma_Chk(iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_H1,MAPeriod,MAMethod,PRICE_CLOSE,c_1H);
               Bollin_Lank_1h[cnt] = Bollin_Lank_Chk(Bollin_1h[cnt]);
               mes_Bollin_1h[cnt] = "\r\n 1時間足："+DoubleToStr(O_Bollin_1h[cnt],2)+"σ →　"+DoubleToStr(Bollin_1h[cnt],2)+"σ";
               if ( Bollin_Lank_1h[cnt] != O_Bollin_Lank_1h[cnt] ) {
                  Bollin_1h_Flag[cnt] = true;
               }
               O_Bollin_Lank_1h[cnt] = Bollin_Lank_1h[cnt];
               O_Bollin_1h[cnt] = Bollin_1h[cnt];
            }  
            if (( kansi_Bollin_4H == true ) && (Period() < PERIOD_H4)){
               Bollin_4h[cnt] = Bollin_Sigma_Chk(iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_H4,MAPeriod,MAMethod,PRICE_CLOSE,c_4H);
               Bollin_Lank_4h[cnt] = Bollin_Lank_Chk(Bollin_4h[cnt]);
               mes_Bollin_4h[cnt] = "\r\n 4時間足："+DoubleToStr(O_Bollin_4h[cnt],2)+"σ →　"+DoubleToStr(Bollin_4h[cnt],2)+"σ";
               if ( Bollin_Lank_4h[cnt] != O_Bollin_Lank_4h[cnt] ) {
                  Bollin_4h_Flag[cnt] = true;
               }
               O_Bollin_Lank_4h[cnt] = Bollin_Lank_4h[cnt];
               O_Bollin_4h[cnt] = Bollin_4h[cnt];
            }  
            if (( kansi_Bollin_1D == true ) && (Period() < PERIOD_D1)){
               Bollin_1d[cnt] = Bollin_Sigma_Chk(iClose(symbol_chk[cnt],0,i),symbol_chk[cnt],PERIOD_D1,MAPeriod,MAMethod,PRICE_CLOSE,c_1D);
               Bollin_Lank_1d[cnt] = Bollin_Lank_Chk(Bollin_1d[cnt]);
               mes_Bollin_1d[cnt] = "\r\n 日足："+DoubleToStr(O_Bollin_1d[cnt],2)+"σ →　"+DoubleToStr(Bollin_1d[cnt],2)+"σ";
               if ( Bollin_Lank_1d[cnt] != O_Bollin_Lank_1d[cnt] ) {
                  Bollin_1d_Flag[cnt] = true;
               }
               O_Bollin_Lank_1d[cnt] = Bollin_Lank_1d[cnt];
               O_Bollin_1d[cnt] = Bollin_1d[cnt];
            }  
            if (( kansi_Span_15m == true ) && (Period() < PERIOD_M15)){
               Sen1_0_15m[cnt] = iCustom(symbol_chk[cnt],PERIOD_M15,"span_model",Kijun,Tenkan,Senkou,5,c_15m);
               Sen2_0_15m[cnt] = iCustom(symbol_chk[cnt],PERIOD_M15,"span_model",Kijun,Tenkan,Senkou,6,c_15m);
               if ( Sen1_0_15m[cnt] > Sen2_0_15m[cnt] ) {
                  Span_15m[cnt] = BUY_SIGNAL;
                  mes_Span_15m[cnt] = "\r\n 15分足："+"買いシグナル";
               }
               else if ( Sen1_0_15m[cnt] < Sen2_0_15m[cnt] ) {
                  Span_15m[cnt] = SELL_SIGNAL;
                  mes_Span_15m[cnt] = "\r\n 15分足："+"売りシグナル";
               }
               else {
                  Span_15m[cnt] = NO_SIGNAL;
                  mes_Span_15m[cnt] = "\r\n 15分足："+"NOシグナル";
               }
               if ( Span_15m[cnt] != O_Span_15m[cnt] ) {
                  Span_15m_Flag[cnt] = true;
                  O_Span_15m[cnt] = Span_15m[cnt];
               }      
            }  
            if (( kansi_Span_30m == true ) && (Period() < PERIOD_M30)){
               Sen1_0_30m[cnt] = iCustom(symbol_chk[cnt],PERIOD_M30,"span_model",Kijun,Tenkan,Senkou,5,c_30m);
               Sen2_0_30m[cnt] = iCustom(symbol_chk[cnt],PERIOD_M30,"span_model",Kijun,Tenkan,Senkou,6,c_30m);
               if ( Sen1_0_30m[cnt] > Sen2_0_30m[cnt] ) {
                  Span_30m[cnt] = BUY_SIGNAL;
                  mes_Span_30m[cnt] = "\r\n 30分足："+"買いシグナル";
               }
               else if ( Sen1_0_30m[cnt] < Sen2_0_30m[cnt] ) {
                  Span_30m[cnt] = SELL_SIGNAL;
                  mes_Span_30m[cnt] = "\r\n 30分足："+"売りシグナル";
               }
               else {
                  Span_30m[cnt] = NO_SIGNAL;
                  mes_Span_30m[cnt] = "\r\n 30分足："+"NOシグナル";
               }
               if ( Span_30m[cnt] != O_Span_30m[cnt] ) {
                  Span_30m_Flag[cnt] = true;
                  O_Span_30m[cnt] = Span_30m[cnt];
               }      
            }  
            if( ( kansi_Span_1H == true ) && (Period() < PERIOD_H1)){
               Sen1_0_1h[cnt] = iCustom(symbol_chk[cnt],PERIOD_H1,"span_model",Kijun,Tenkan,Senkou,5,c_1H);
               Sen2_0_1h[cnt] = iCustom(symbol_chk[cnt],PERIOD_H1,"span_model",Kijun,Tenkan,Senkou,6,c_1H);
               if ( Sen1_0_1h[cnt] > Sen2_0_1h[cnt] ) {
                  Span_1h[cnt] = BUY_SIGNAL;
                  mes_Span_1h[cnt] = "\r\n 1時間足："+"買いシグナル";
               }
               else if ( Sen1_0_1h[cnt] < Sen2_0_1h[cnt] ) {
                  Span_1h[cnt] = SELL_SIGNAL;
                  mes_Span_1h[cnt] = "\r\n 1時間足："+"売りシグナル";
               }
               else {
                  Span_1h[cnt] = NO_SIGNAL;
                  mes_Span_1h[cnt] = "\r\n 1時間足："+"NOシグナル";
               }
               if ( Span_1h[cnt] != O_Span_1h[cnt] ) {
                  Span_1h_Flag[cnt] = true;
                  O_Span_1h[cnt] = Span_1h[cnt];
               }      
            }  
            if (( kansi_Span_4H == true )&& (Period() < PERIOD_H4)) {
               Sen1_0_4h[cnt] = iCustom(symbol_chk[cnt],PERIOD_H4,"span_model",Kijun,Tenkan,Senkou,5,c_4H);
               Sen2_0_4h[cnt] = iCustom(symbol_chk[cnt],PERIOD_H4,"span_model",Kijun,Tenkan,Senkou,6,c_4H);
               if ( Sen1_0_4h[cnt] > Sen2_0_4h[cnt] ) {
                  Span_4h[cnt] = BUY_SIGNAL;
                  mes_Span_4h[cnt] = "\r\n ４時間足："+"買いシグナル";
               }
               else if ( Sen1_0_4h[cnt] < Sen2_0_4h[cnt] ) {
                  Span_4h[cnt] = SELL_SIGNAL;
                  mes_Span_4h[cnt] = "\r\n ４時間足："+"売りシグナル";
               }
               else {
                  Span_4h[cnt] = NO_SIGNAL;
                  mes_Span_4h[cnt] = "\r\n ４時間足："+"NOシグナル";
               }
               if ( Span_4h[cnt] != O_Span_4h[cnt] ) {
                  Span_4h_Flag[cnt] = true;
                  O_Span_4h[cnt] = Span_4h[cnt];
               }      
            }  
            if (( kansi_Span_1D == true ) && (Period() < PERIOD_D1)){
               Sen1_0_1d[cnt] = iCustom(symbol_chk[cnt],PERIOD_D1,"span_model",Kijun,Tenkan,Senkou,5,c_1D);
               Sen2_0_1d[cnt] = iCustom(symbol_chk[cnt],PERIOD_D1,"span_model",Kijun,Tenkan,Senkou,6,c_1D);
               if ( Sen1_0_1d[cnt] > Sen2_0_1d[cnt] ) {
                  Span_1d[cnt] = BUY_SIGNAL;
                  mes_Span_1d[cnt] = "\r\n 日足："+"買いシグナル";
               }
               else if ( Sen1_0_1d[cnt] < Sen2_0_1d[cnt] ) {
                  Span_1d[cnt] = SELL_SIGNAL;
                  mes_Span_1d[cnt] = "\r\n 日足："+"売りシグナル";
               }
               else {
                  Span_1d[cnt] = NO_SIGNAL;
                  mes_Span_1d[cnt] = "\r\n 日足："+"NOシグナル";
               }
               if ( Span_1d[cnt] != O_Span_1d[cnt] ) {
                  Span_1d_Flag[cnt] = true;
                  O_Span_1d[cnt] = Span_1d[cnt];
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
      
      if (Emailflag== true) {
         for ( cnt = 0 ; cnt < symbol_max ; cnt++ ) {
            Send_Flag = false;
            if (symbol_true[cnt] == false ) {
               continue;
            }

            if ( S_buy[cnt] == true ) {
               Send_Flag = true;
               message= "買いシグナル発生"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
            }
            else if ( S_sell[cnt] == true ) {
               Send_Flag = true;
               message= "売りシグナル発生"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
            }
            else if (( Bollin_15m_Flag[cnt] == true ) && (Email_Bollin_15m == true)){
               Send_Flag = true;
               message= "15分足ランク変更"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
               message= message + mes_period[cnt];
            }
            else if (( Bollin_30m_Flag[cnt] == true ) && (Email_Bollin_30m== true)){
               Send_Flag = true;
               message= "30分足ランク変更"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
               message= message + mes_period[cnt];
            }
            else if (( Bollin_1h_Flag[cnt] == true ) && (Email_Bollin_1h== true)){
               Send_Flag = true;
               message= "１時間足ランク変更"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
               message= message + mes_period[cnt];
            }
            else if (( Bollin_4h_Flag[cnt] == true ) && (Email_Bollin_4h== true)){
               Send_Flag = true;
               message= "４時間足ランク変更"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
               message= message + mes_period[cnt];
            }
            else if (( Bollin_1d_Flag[cnt] == true ) && (Email_Bollin_1d== true)){
               Send_Flag = true;
               message= "日足ランク変更"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
               message= message + mes_period[cnt];
            }
            else if (( Span_15m_Flag[cnt] == true ) && (Email_Span_15m== true)){
               Send_Flag = true;
               message= "15分足売買シグナル変更"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
               message= message + mes_period[cnt];
            }
            else if (( Span_30m_Flag[cnt] == true )&& (Email_Span_30m== true)) {
               Send_Flag = true;
               message= "30分足売買シグナル変更"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
               message= message + mes_period[cnt];
            }
            else if (( Span_1h_Flag[cnt] == true )&& (Email_Span_1h== true)) {
               Send_Flag = true;
               message= "1時間足売買シグナル変更"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
               message= message + mes_period[cnt];
            }
            else if (( Span_4h_Flag[cnt] == true )&& (Email_Span_4h== true)) {
               Send_Flag = true;
               message= "4時間足売買シグナル変更"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
               message= message + mes_period[cnt];
            }
            else if (( Span_1d_Flag[cnt] == true )&& (Email_Span_1d== true)) {
               Send_Flag = true;
               message= "日足売買シグナル変更"+"\r\n"+"["+symbol_chk[cnt]+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+iOpen(symbol_chk[cnt],0,0); 
               message= message + mes_period[cnt];
            }
            if ( Send_Flag == true  ) {
               message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1[cnt]+","+Sen1_0[cnt];
               message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1[cnt]+","+Sen2_0[cnt];
               message = message + " \r\n 26本前高値 = "+iHigh(symbol_chk[cnt],0,25);
               message = message + " \r\n 26本前安値 = "+iLow(symbol_chk[cnt],0,25);
               if (( kansi_Bollin_15m == true ) && (Period() < PERIOD_M15)){
                  message = message + mes_Bollin_15m[cnt];
               }
               if (( kansi_Bollin_30m == true ) && (Period() < PERIOD_M30)){
                  message = message + mes_Bollin_30m[cnt];
               }
               if (( kansi_Bollin_1H == true )&& (Period() < PERIOD_H1)) {
                  message = message + mes_Bollin_1h[cnt];
               }
               if (( kansi_Bollin_4H == true ) && (Period() < PERIOD_H4)){
                  message = message + mes_Bollin_4h[cnt];
               }
               if (( kansi_Bollin_1D == true ) && (Period() < PERIOD_D1)){
                  message = message + mes_Bollin_1d[cnt];
               }
               if (( kansi_Span_15m == true ) && (Period() < PERIOD_M15)){
                  message = message + mes_Span_15m[cnt];
               }
               if (( kansi_Span_30m == true ) && (Period() < PERIOD_M30)){
                  message = message + mes_Span_30m[cnt];
               }
               if (( kansi_Span_1H == true ) && (Period() < PERIOD_H1)){
                  message = message + mes_Span_1h[cnt];
               }
               if (( kansi_Span_4H == true )&& (Period() < PERIOD_H4)){
                  message = message + mes_Span_4h[cnt];
               }
               if( ( kansi_Span_1D == true ) && (Period() < PERIOD_D1)){
                  message = message + mes_Span_1d[cnt];
               }
               SendMail("スパンモデル " +"["+symbol_chk[cnt]+"]["+Period()+"]",message);
            }
         }            
         if (Alertflag== true) {
            if ( S_buy[cnt] == true ) {
               Alert("Spanmodel BUY Signal ",symbol_chk[cnt],Period(),iOpen(symbol_chk[cnt],0.,0));
            }
            else if ( S_sell[cnt] == true ) {
               Alert("Spanmodel SELL Signal ",symbol_chk[cnt],Period(),iOpen(symbol_chk[cnt],0.,0));
            }
            Alertflag = false;
         }
      }
      Emailflag = false;                      //メール送信設定
      Alertflag = false;                      //アラート出力設定
   }   
   return(0);
}
double Bollin_Sigma_Chk(double data,string Chk_symbol,int Chk_Period,int Chk_MAPeriod,int Chk_MAMethod,int Chk_Price,int position)
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