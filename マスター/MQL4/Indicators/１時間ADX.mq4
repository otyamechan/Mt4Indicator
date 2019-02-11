//プリプロセッサ命令（プログラムの設定）
#property  copyright "とんぼ"
#property link "tombofx.blog.fc2.com"

#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1 Orange
#property  indicator_color2 Red
#property  indicator_color3 Blue
#property  indicator_width1 1
#property  indicator_width2 1
#property  indicator_width3 1
#property  indicator_style1 0
#property  indicator_style2 0
#property  indicator_style3 0
#property indicator_level1 25
#property indicator_levelcolor White
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_SOLID

//描画用配列の宣言
double indicator1[];
double indicator2[];
double indicator3[];

//外部パラメータの宣言
extern int TimeFrame = 60;
//グローバル変数の宣言
int Mult = 10;

//--------------------------------------------------------------------------------------------------------+
//初期化処理                                                                                              |
//--------------------------------------------------------------------------------------------------------+
int init(){
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(0, indicator1);
   SetIndexBuffer(1, indicator2);
   SetIndexBuffer(2, indicator3);
   SetIndexLabel(1, "計算項目:1");
   SetIndexLabel(2, "計算項目:2");
   IndicatorDigits(Digits);

   MultCal();

   return(0);
}
//--------------------------------------------------------------------------------------------------------+
//終了処理                                                                                                |
//--------------------------------------------------------------------------------------------------------+
int deinit(){
   return(0);
}

//--------------------------------------------------------------------------------------------------------+
//メイン処理                                                                                              |
//--------------------------------------------------------------------------------------------------------+
 
extern int ADX_Period10 = 14;
extern int ADX_Shift10 = 0; 
 
extern int ADX_Period11 = 14;
extern int ADX_Shift11 = 0; 
 
extern int ADX_Period12 = 14;
extern int ADX_Shift12 = 0; 
int start(){
   int limit = Bars - IndicatorCounted();
   datetime TimeArray[];
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
   int i, y;
   for(i = 0, y = 0; i < Bars; i++){
      if(Time[i] < TimeArray[y]) y++;

      bool drawing1 = Drawing1(i);
      if(drawing1 == true){
         indicator1[i] = iADX(Symbol(), TimeFrame, ADX_Period10, PRICE_CLOSE, MODE_MAIN, y + ADX_Shift10) ;
      }else{
         indicator1[i] = 0;
      }
      bool drawing2 = Drawing2(i);
      if(drawing2 == true){
         indicator2[i] = iADX(Symbol(), TimeFrame, ADX_Period11, PRICE_CLOSE, MODE_PLUSDI, y + ADX_Shift11) ;
      }else{
         indicator2[i] = 0;
      }
      bool drawing3 = Drawing3(i);
      if(drawing3 == true){
         indicator3[i] = iADX(Symbol(), TimeFrame, ADX_Period12, PRICE_CLOSE, MODE_MINUSDI, y + ADX_Shift12) ;
      }else{
         indicator3[i] = 0;
      }
   }

   return(0);
}

//描画判定
bool Drawing1(int i){
   bool draw = true;
   return(draw);
}
bool Drawing2(int i){
   bool draw = true;
   return(draw);
}
bool Drawing3(int i){
   bool draw = true;
   return(draw);
}

//--------------------------------------------------------------------------------------------------------+
//レートの桁数対応関数                                                                                    |
//   処理:ブローカーが配信するレートの小数点以下の桁数を確認し、                                          |
//        グローバル変数 Mult の値を適正値に設定する。                                                    |
//   引数:無し                                                                                            |
//   戻り値:無し                                                                                          |
//--------------------------------------------------------------------------------------------------------+
void MultCal(){
   if(Digits == 4 || Digits == 2) Mult = 1;
   if(Digits == 5 || Digits == 3) Mult = 10;
}

