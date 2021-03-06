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

bool Bollin_15m_Flag,Bollin_30m_Flag,Bollin_1h_Flag,Bollin_4h_Flag,Bollin_1d_Flag;
bool Span_15m_Flag,Span_30m_Flag,Span_1h_Flag,Span_4h_Flag,Span_1d_Flag;

double Bollin_15m,Bollin_30m,Bollin_1h,Bollin_4h,Bollin_1d;
int Bollin_Lank_15m,Bollin_Lank_30m,Bollin_Lank_1h,Bollin_Lank_4h,Bollin_Lank_1d;
string mes_Bollin_15m,mes_Bollin_30m,mes_Bollin_1h,mes_Bollin_4h,mes_Bollin_1d;
double O_Bollin_15m,O_Bollin_30m,O_Bollin_1h,O_Bollin_4h,O_Bollin_1d;
int O_Bollin_Lank_15m,O_Bollin_Lank_30m,O_Bollin_Lank_1h,O_Bollin_Lank_4h,O_Bollin_Lank_1d;
double Sen1_0,Sen1_1,Sen2_0,Sen2_1;          //クロスチェック用
double Sen1_0_15m,Sen1_0_30m,Sen1_0_1h,Sen1_0_4h,Sen1_0_1d;
double Sen2_0_15m,Sen2_0_30m,Sen2_0_1h,Sen2_0_4h,Sen2_0_1d;
int Span_15m,Span_30m,Span_1h,Span_4h,Span_1d;
int O_Span_15m,O_Span_30m,O_Span_1h,O_Span_4h,O_Span_1d;
string mes_Span_15m,mes_Span_30m,mes_Span_1h,mes_Span_4h,mes_Span_1d;
string mes_period;
bool Send_Flag;
bool buy = false;
bool sell = false;
bool S_buy = false;
bool S_sell = false;

int c_5m,c_15m,c_30m,c_1H,c_4H,c_1D;   //時間位置

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


 
	IndicatorShortName("Otyame019_span_model_signal");
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
      for(i= limit-1;i>=1;i--){
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
          
         
         
         
         Sen1_0 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i);
         Sen1_1 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,5,i+1);
         Sen2_0 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i);
         Sen2_1 = iCustom(NULL,0,"span_model",Kijun,Tenkan,Senkou,6,i+1);
         buy = false;
         sell = false;
         S_buy = false;
         S_sell = false;
         switch(Period())  {
         case PERIOD_M5:
            mes_period = "５分足";
            break;
         case PERIOD_M15:
            mes_period = "１５分足";
            break;
         case PERIOD_M30:
            mes_period = "３０分足";
            break;
         case PERIOD_H1:
            mes_period = "時間足";
            break;
         case PERIOD_H4:
            mes_period = "４時間足";
            break;
         case PERIOD_D1:
            mes_period = "日足";
            break;
         }      
         if((Sen1_0 > Sen2_0) && (Sen1_1 <= Sen2_1) ) {
            S_buy = true;
         }
         else if ((Sen1_0 < Sen2_0) && (Sen1_1 >= Sen2_1) ) {
            S_sell = true;
         }
         if((Sen1_0 > Sen2_0)  ) {
            buy = true;
            mes_period = " \r\n"+mes_period + ":買いシグナル"; 
        }
         else if ((Sen1_0 < Sen2_0)  ) {
            sell = true;
            mes_period = " \r\n"+mes_period + ":売りシグナル"; 
         }
         else {
            mes_period = " \r\n"+mes_period + ":ＮＯシグナル"; 
         }            
         Bollin_15m_Flag = false;
         Bollin_30m_Flag = false;
         Bollin_1h_Flag = false;
         Bollin_4h_Flag = false;
         Bollin_1d_Flag = false;
         Span_15m_Flag = false;
         Span_30m_Flag = false;
         Span_1h_Flag = false;
         Span_4h_Flag = false;
         Span_1d_Flag = false;
         if (( kansi_Bollin_15m == true ) && (Period() < PERIOD_M15)) {
            Bollin_15m = Bollin_Sigma_Chk(Close[i],NULL,PERIOD_M15,MAPeriod,MAMethod,PRICE_CLOSE,c_15m);
            Bollin_Lank_15m = Bollin_Lank_Chk(Bollin_15m);
            mes_Bollin_15m = "\r\n 15分足："+DoubleToStr(O_Bollin_15m,2)+"σ →　"+DoubleToStr(Bollin_15m,2)+"σ";
            if ( Bollin_Lank_15m != O_Bollin_Lank_15m ) {
               Bollin_15m_Flag = true;
            }
            O_Bollin_Lank_15m = Bollin_Lank_15m;
            O_Bollin_15m = Bollin_15m;
         }  
         if (( kansi_Bollin_30m == true )&& (Period() < PERIOD_M30)) {
            Bollin_30m = Bollin_Sigma_Chk(Close[i],NULL,PERIOD_M30,MAPeriod,MAMethod,PRICE_CLOSE,c_30m);
            Bollin_Lank_30m = Bollin_Lank_Chk(Bollin_30m);
            mes_Bollin_30m = "\r\n 15分足："+DoubleToStr(O_Bollin_15m,2)+"σ →　"+DoubleToStr(Bollin_15m,2)+"σ";
            if ( Bollin_Lank_30m != O_Bollin_Lank_30m ) {
               Bollin_30m_Flag = true;
            }
            O_Bollin_Lank_30m = Bollin_Lank_30m;
            O_Bollin_30m = Bollin_30m;
         }  
         if (( kansi_Bollin_1H == true ) && (Period() < PERIOD_H1)) {
            Bollin_1h = Bollin_Sigma_Chk(Close[i],NULL,PERIOD_H1,MAPeriod,MAMethod,PRICE_CLOSE,c_1H);
            Bollin_Lank_1h = Bollin_Lank_Chk(Bollin_1h);
            mes_Bollin_1h = "\r\n 1時間足："+DoubleToStr(O_Bollin_1h,2)+"σ →　"+DoubleToStr(Bollin_1h,2)+"σ";
            if ( Bollin_Lank_1h != O_Bollin_Lank_1h ) {
               Bollin_1h_Flag = true;
            }
            O_Bollin_Lank_1h = Bollin_Lank_1h;
            O_Bollin_1h = Bollin_1h;
            
         }  
         if (( kansi_Bollin_4H == true ) && (Period() < PERIOD_H4)){
            Bollin_4h = Bollin_Sigma_Chk(Close[i],NULL,PERIOD_H4,MAPeriod,MAMethod,PRICE_CLOSE,c_4H);
            Bollin_Lank_4h = Bollin_Lank_Chk(Bollin_4h);
            mes_Bollin_4h = "\r\n ４時間足："+DoubleToStr(O_Bollin_4h,2)+"σ →　"+DoubleToStr(Bollin_4h,2)+"σ";
            if ( Bollin_Lank_4h != O_Bollin_Lank_4h ) {
               Bollin_4h_Flag = true;
            }
            O_Bollin_Lank_4h = Bollin_Lank_4h;
            O_Bollin_4h = Bollin_4h;
         }  
         if (( kansi_Bollin_1D == true ) && (Period() < PERIOD_D1)) {
            Bollin_1d = Bollin_Sigma_Chk(Close[i],NULL,PERIOD_D1,MAPeriod,MAMethod,PRICE_CLOSE,c_1D);
            Bollin_Lank_1d = Bollin_Lank_Chk(Bollin_1d);
            mes_Bollin_1d = "\r\n 日足："+DoubleToStr(O_Bollin_1d,2)+"σ →　"+DoubleToStr(Bollin_1d,2)+"σ";
             if ( Bollin_Lank_1d != O_Bollin_Lank_1d ) {
               Bollin_1d_Flag = true;
            }
            O_Bollin_Lank_1d = Bollin_Lank_1d;
            O_Bollin_1d = Bollin_1d;
         }  
         if (( kansi_Span_15m == true )&& (Period() < PERIOD_M15)) {
            Sen1_0_15m = iCustom(NULL,PERIOD_M15,"span_model",Kijun,Tenkan,Senkou,5,c_15m);
            Sen2_0_15m = iCustom(NULL,PERIOD_M15,"span_model",Kijun,Tenkan,Senkou,6,c_15m);
            if ( Sen1_0_15m > Sen2_0_15m ) {
               Span_15m = BUY_SIGNAL;
               mes_Span_15m = "\r\n 15分足："+"買いシグナル";
            }
            else if ( Sen1_0_15m < Sen2_0_15m ) {
               Span_15m = SELL_SIGNAL;
               mes_Span_15m = "\r\n 15分足："+"売りシグナル";
            }
            else {
               Span_15m = NO_SIGNAL;
               mes_Span_15m = "\r\n 15分足："+"ＮＯシグナル";
            }
            if ( Span_15m != O_Span_15m ) {
               Span_15m_Flag = true;
               O_Span_15m = Span_15m;
            }      

         }  
         if (( kansi_Span_30m == true ) && (Period() < PERIOD_M30)){
            Sen1_0_30m = iCustom(NULL,PERIOD_M30,"span_model",Kijun,Tenkan,Senkou,5,c_30m);
            Sen2_0_30m = iCustom(NULL,PERIOD_M30,"span_model",Kijun,Tenkan,Senkou,6,c_30m);
            if ( Sen1_0_30m > Sen2_0_30m ) {
               Span_30m = BUY_SIGNAL;
               mes_Span_30m = "\r\n 30分足："+"買いシグナル";
            }
            else if ( Sen1_0_30m < Sen2_0_30m ) {
               Span_30m = SELL_SIGNAL;
               mes_Span_30m = "\r\n 30分足："+"売りシグナル";
            }
            else {
               Span_30m = NO_SIGNAL;
               mes_Span_30m = "\r\n 30分足："+"ＮＯシグナル";
            }
            if ( Span_30m != O_Span_30m ) {
               Span_30m_Flag = true;
               O_Span_30m = Span_30m;
            }      
         }  
         if (( kansi_Span_1H == true ) && (Period() < PERIOD_H1)){
            Sen1_0_1h = iCustom(NULL,PERIOD_H1,"span_model",Kijun,Tenkan,Senkou,5,c_1H);
            Sen2_0_1h = iCustom(NULL,PERIOD_H1,"span_model",Kijun,Tenkan,Senkou,6,c_1H);
            if ( Sen1_0_1h > Sen2_0_1h ) {
               Span_1h = BUY_SIGNAL;
               mes_Span_1h= "\r\n 1時間足："+"買いシグナル";
            }
            else if ( Sen1_0_1h < Sen2_0_1h ) {
               Span_1h = SELL_SIGNAL;
               mes_Span_1h = "\r\n 1時間足："+"売りシグナル";
            }
            else {
               Span_1h = NO_SIGNAL;
               mes_Span_1h = "\r\n 1時間足："+"ＮＯシグナル";
            }
            if ( Span_1h != O_Span_1h ) {
               Span_1h_Flag = true;
               O_Span_1h = Span_1h;
            }      
         }  
         if (( kansi_Span_4H == true ) && (Period() < PERIOD_H4)){
            Sen1_0_4h = iCustom(NULL,PERIOD_H4,"span_model",Kijun,Tenkan,Senkou,5,c_4H);
            Sen2_0_4h = iCustom(NULL,PERIOD_H4,"span_model",Kijun,Tenkan,Senkou,6,c_4H);
            if ( Sen1_0_4h > Sen2_0_4h ) {
               Span_4h = BUY_SIGNAL;
               mes_Span_4h = "\r\n ４時間足："+"買いシグナル";
            }
            else if ( Sen1_0_4h < Sen2_0_4h ) {
               Span_4h = SELL_SIGNAL;
               mes_Span_4h = "\r\n ４時間足："+"売りシグナル";
            }
            else {
               Span_4h = NO_SIGNAL;
               mes_Span_4h = "\r\n ４時間足："+"ＮＯシグナル";
            }
            if ( Span_4h != O_Span_4h ) {
               Span_4h_Flag = true;
               O_Span_4h = Span_4h;
            }      
         }  
         if (( kansi_Span_1D == true ) && (Period() < PERIOD_D1)){
            Sen1_0_1d = iCustom(NULL,PERIOD_D1,"span_model",Kijun,Tenkan,Senkou,5,c_1D);
            Sen2_0_1d = iCustom(NULL,PERIOD_D1,"span_model",Kijun,Tenkan,Senkou,6,c_1D);
            if ( Sen1_0_1d > Sen2_0_1d ) {
               Span_1d = BUY_SIGNAL;
               mes_Span_1d = "\r\n 日足："+"買いシグナル";
            }
            else if ( Sen1_0_1d < Sen2_0_1d ) {
               Span_1d = SELL_SIGNAL;
               mes_Span_1d = "\r\n 日足："+"売りシグナル";
            }
            else {
               Span_1d = NO_SIGNAL;
               mes_Span_1d = "\r\n 日足："+"ＮＯシグナル";
            }
            if ( Span_1d != O_Span_1d ) {
               Span_1d_Flag = true;
               O_Span_1d = Span_15m;
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
         Send_Flag = false;
         if ( S_buy == true ) {
            Send_Flag = true;
            message= "5分足買いシグナル発生"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
         }
         else if ( S_sell == true ) {
            Send_Flag = true;
            message= "5分足売りシグナル発生"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
         }
         else if (( Bollin_15m_Flag == true ) && (Email_Bollin_15m == true )) {
            Send_Flag = true;
            message= "15分足ランク変更"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
            message = message + mes_period;
         }
         else if (( Bollin_30m_Flag == true ) && (Email_Bollin_30m == true )){
            Send_Flag = true;
            message= "30分足ランク変更"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
            message = message + mes_period;
         }
         else if (( Bollin_1h_Flag == true )&& (Email_Bollin_1h == true )) {
            Send_Flag = true;
            message= "１時間足ランク変更"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
            message = message + mes_period;
         }
         else if (( Bollin_4h_Flag == true ) && (Email_Bollin_4h == true )){
            Send_Flag = true;
            message= "４時間足ランク変更"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
            message = message + mes_period;
         }
         else if (( Bollin_1d_Flag == true ) && (Email_Bollin_1d == true )){
            Send_Flag = true;
            message= "日足ランク変更"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
            message = message + mes_period;
         }
         else if (( Span_15m_Flag == true ) && (Email_Span_15m == true )){
            Send_Flag = true;
            message= "15分足売買シグナル変更"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
            message = message + mes_period;
         }
         else if (( Span_30m_Flag == true ) && (Email_Span_30m == true )){
            Send_Flag = true;
            message= "30分足売買シグナル変更"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
            message = message + mes_period;
         }
         else if (( Span_1h_Flag == true ) && (Email_Span_1h == true )){
            Send_Flag = true;
            message= "１時間足売買シグナル変更"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
            message = message + mes_period;
         }
         else if (( Span_4h_Flag == true ) && (Email_Span_4h == true )){
            Send_Flag = true;
            message= "４時間足売買シグナル変更"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
            message = message + mes_period;
         }
         else if (( Span_1d_Flag == true ) && (Email_Span_1d == true )){
            Send_Flag = true;
            message= "日足売買シグナル変更"+"\r\n"+"["+Symbol()+"]"+"["+Period()+"]"+"\r\n"+"LocalTime="+TimeToStr(TimeLocal(),TIME_DATE)+" "+TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+"\r\n "+"\r\n 現在値="+Open[0]; 
            message = message + mes_period;
         }
         if ( Send_Flag == true  ) {
            message = message + " \r\n 先行スパン１(1本前,0本前） = "+Sen1_1+","+Sen1_0;
            message = message + " \r\n 先行スパン２(1本前,0本前） = "+Sen2_1+","+Sen2_0;
            message = message + " \r\n 26本前高値 = "+High[25];
            message = message + " \r\n 26本前安値 = "+Low[25];
            if (( kansi_Bollin_15m == true ) && (Period() < PERIOD_M15)){
               message = message + mes_Bollin_15m;
            }
            if (( kansi_Bollin_30m == true ) && (Period() < PERIOD_M30)){
               message = message + mes_Bollin_30m;
            }
            if (( kansi_Bollin_1H == true )&& (Period() < PERIOD_H1)) {
               message = message + mes_Bollin_1h;
            }
            if (( kansi_Bollin_4H == true )&& (Period() < PERIOD_H4)) {
               message = message + mes_Bollin_4h;
            }
            if (( kansi_Bollin_1D == true )&& (Period() < PERIOD_D1)) {
               message = message + mes_Bollin_1d;
            }
            if (( kansi_Span_15m == true ) && (Period() < PERIOD_M15)){
               message = message + mes_Span_15m;
            }
            if (( kansi_Span_30m == true ) && (Period() < PERIOD_M30)){
               message = message + mes_Span_30m;
            }
            if (( kansi_Span_1H == true ) && (Period() < PERIOD_H1)){
               message = message + mes_Span_1h;
            }
            if (( kansi_Span_4H == true ) && (Period() < PERIOD_H4)){
               message = message + mes_Span_4h;
            }
            if (( kansi_Span_1D == true ) && (Period() < PERIOD_D1)){
               message = message + mes_Span_1d;
            }
            SendMail("スパンモデル " +"["+Symbol()+"]["+Period()+"]",message);
         }            
      }
      if (Alertflag== true) {
         if ( S_buy == true ) {
            Alert("Spanmodel BUY Signal ",Symbol(),Period(),Open[0]);
         }
         else if ( S_sell == true ) {
            Alert("Spanmodel SELL Signal ",Symbol(),Period(),Open[0]);
         }
         Alertflag = false;
      }
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