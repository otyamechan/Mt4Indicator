//+------------------------------------------------------------------+
//|                                                 function.mq4     |
//|                        Copyright 2017, Otyame                    |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Otyame Trader"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---------------------------------------------------------------------
// 指定の時間足の過去直近のバー位置を返す関数
// Copyright by Otyame Trader
//    2017.04.09
//    IN:　時間軸　     int cPeriod 
//       　シンボル      string cSymbol
//       　検索時刻　　  datetime cTime
//    OUT:時間軸に対するバーの位置
//----------------------------------------------------------------------
int MTF_Bar_Position(int cPeriod,string cSymbol ,datetime cTime)
{
   datetime ktime[];                    //5分足格納用
   int count;
   int Pos;
   count = ArrayCopySeries(ktime,MODE_TIME,cSymbol,cPeriod);        //時間格納
   Pos = iBarShift(cSymbol,cPeriod,cTime,true);
   if ( ktime[Pos] > cTime ) {
      Pos++;
   }            
   if (Pos == 0 ) Pos++;
   return(Pos);
 }  
//---------------------------------------------------------------------
// パーフェクトオーダが成立している確認する
// Copyright by Otyame Trader
//    2017.04.09
//    IN:　チェックする時間軸　int cPeriod
//        シンボル　　　　　　　 string cSymbol
//        傾きチェックする際の前回時間　int Compare_Period
//        移動平均線の期間　     int MAPeriod[8] 
//       　検索時刻　　  datetime cTime
//        パーフェクトオーダーチェックするか　  bool PO_Check[8]
//        移動平均線平均時間　int MAPeriod[8]
//        移動平均計算方法　　 int MAMethod[8]
//        傾きチェックするか　　　　　bool Katamuki[8]
//
//
//    OUT:1  上昇パーフェクトオーダー成立
//        0  パーフェクトオーダー　不成立
//        -1 下降パーフェクトオーダー成立  
//----------------------------------------------------------------------
int MTF_Perfect_Order_Check(int cPeriod,string cSymbol,int Compare_Period,datetime cTime,bool& PO_Check[],int& MAPeriod[],int& MAMethod[],bool& Katamuki[])
{

   double MA_0[8];
   double MA_1[8];
   int count,cnt;
   int Chk_candle;
   bool UPcheck,DOWNcheck;
   double chkUPdata,chkDOWNdata;
   int ret;

	Chk_candle = Compare_Period / cPeriod ;
	count = MTF_Bar_Position(cPeriod,cSymbol,cTime);

// 上昇チェック
   UPcheck = true;
   chkUPdata = 0;
   for ( cnt = 0 ; cnt < 8 ; cnt++ ) {
      if ( PO_Check[cnt] == true ) {
         MA_0[cnt] = iMA(cSymbol,cPeriod,MAPeriod[cnt],0,MAMethod[cnt],PRICE_CLOSE,count);
         MA_1[cnt] = iMA(cSymbol,cPeriod,MAPeriod[cnt],0,MAMethod[cnt],PRICE_CLOSE,count+Chk_candle);
         if ( Katamuki[cnt] == true ) {
            if ( MA_1[cnt] > MA_0 [cnt] ) {
               UPcheck = false;
               break;
            }
         }
         if ( MA_0[cnt] >= chkUPdata ) {
              chkUPdata = MA_0[cnt];
         }
         else {
            UPcheck = false;
            break;
         }               
      }
   }       
// 下降チェック
   DOWNcheck = true;
   chkDOWNdata = 9999;
   for ( cnt = 0 ; cnt < 8 ; cnt++ ) {
      if ( PO_Check[cnt] == true ) {
         MA_0[cnt] = iMA(cSymbol,cPeriod,MAPeriod[cnt],0,MAMethod[cnt],PRICE_CLOSE,count);
         MA_1[cnt] = iMA(cSymbol,cPeriod,MAPeriod[cnt],0,MAMethod[cnt],PRICE_CLOSE,count+Chk_candle);
        if ( Katamuki[cnt] == true ) {
            if ( MA_1[cnt] < MA_0[cnt] ) {
               DOWNcheck = false;
               break;
            }
         }
         if ( MA_0[cnt] <= chkDOWNdata ) {
              chkDOWNdata = MA_0[cnt];
         }
         else {
            DOWNcheck = false;
            break;
         }               
      }
   }
   if ( UPcheck == true ) {
      ret = 1;
   }
   else if ( DOWNcheck == true ) {
      ret = -1;
   }
   else ret = 0;
   return(ret);             
}
//---------------------------------------------------------------------
// スパンモデルの売買シグナルを判定する
// Copyright by Otyame Trader
//    2017.04.09
//    IN:　チェックする時間軸　int cPeriod
//        シンボル　　　　　 string cSymbol
//       　検索時刻　　   datetime cTime
//        転換線　      int InpTenkan
//        基準線　      int InpKijun
//        先行　　       int InpSenkou
//        バーシフト　　　　　int Bar_Shift
//
//    OUT:1  買いシグナル
//        0  売買シグナルなし
//        -1 売りシグナル  
//----------------------------------------------------------------------
int MTF_Span_Model_Check(int cPeriod,string cSymbol,int Compare_Period,datetime cTime,int InpTenkan,int InpKijun,int InpSenkou,int Bar_Shift)
{
   int count;
   int ret;
   double SpanA,SpanB;
	count = MTF_Bar_Position(cPeriod,cSymbol,cTime);
   SpanA = iCustom(cSymbol, cPeriod,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou, Bar_Shift,5,count);
   SpanB = iCustom(cSymbol, cPeriod,"Otyame001_Ichimoku_Shift",InpTenkan,InpKijun,InpSenkou, Bar_Shift,6,count);
   if ( SpanA > SpanB ) {
      ret = 1;
   }
   else if ( SpanA < SpanB ) {
      ret = -1;
   }
   else ret = 0;
   return(ret);    
 }
//---------------------------------------------------------------------
// ボリンジャーバンドの偏差値を計算する
// Copyright by Otyame Trader
//    2017.04.09
//    IN:　チェックする時間軸　int cPeriod
//        シンボル　　　　　 string cSymbol
//       　検索時刻　　   datetime cTime
//        転換線　      int InpTenkan
//        基準線　      int InpKijun
//        先行　　       int InpSenkou
//        バーシフト　　　　　int Bar_Shift
//
//    OUT:1  買いシグナル
//        0  売買シグナルなし
//        -1 売りシグナル  
//----------------------------------------------------------------------
double MTF_Bollin_Sigma_Chk(int cPeriod,string cSymbol,datetime cTime,double cdata,int Chk_MAPeriod,int Chk_MAMethod,int Chk_Price,bool Close_flag = true)
{
   int i;
   double Chk_data[2];
   double ret;
   int count;
   double data;
	count = MTF_Bar_Position(cPeriod,cSymbol,cTime);
   Chk_data[0] = iMA(cSymbol,cPeriod,Chk_MAPeriod,0,Chk_MAMethod,Chk_Price,count);
   if (Close_flag == true) {
    data = iClose(cSymbol,cPeriod,count);
   }
   else {
      data = cdata;
   }  
   if ( data > Chk_data[0] ) {
      i = 1;
      while(1) {
         Chk_data[1]   = iBands(cSymbol,cPeriod,Chk_MAPeriod,i,0,Chk_Price,MODE_UPPER,count);
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
         Chk_data[1]   = iBands(cSymbol,cPeriod,Chk_MAPeriod,i,0,Chk_Price,MODE_LOWER,count);
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
//---------------------------------------------------------------------
// ボリンジャーバンドのランクを計算する
// Copyright by Otyame Trader
//    2017.04.09
//    IN:　チェックする時間軸　int cPeriod
//        シンボル　　　　　 string cSymbol
//       　検索時刻　　   datetime cTime
//        転換線　      int InpTenkan
//        基準線　      int InpKijun
//        先行　　       int InpSenkou
//        バーシフト　　　　　int Bar_Shift
//
//    OUT:1  買いシグナル
//        0  売買シグナルなし
//        -1 売りシグナル  
//----------------------------------------------------------------------
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
//---------------------------------------------------------------------
// 遅行スパンアタッカーの確認をする
// Copyright by Otyame Trader
//    2017.04.09
//    IN:　チェックする時間軸　int cPeriod
//        シンボル　　　　　 string cSymbol
//       　検索時刻　　   datetime cTime
//        転換線　      int InpTenkan
//        基準線　      int InpKijun
//        先行　　       int InpSenkou
//        バーシフト　　　　　int Bar_Shift
//
//    OUT:1  買いシグナル
//        0  売買シグナルなし
//        -1 売りシグナル  
//----------------------------------------------------------------------
int MTF_ChikoSpan_Atterker_Chk(int cPeriod,string cSymbol,datetime cTime,int Chk_MAPeriod,int Chikou_Idou)
{
   int count;
	int ret;
	count = MTF_Bar_Position(cPeriod,cSymbol,cTime);
   double Lsigma_1,Usigma_1;
   double Chikou;
   bool buy,sell;
   Lsigma_1   = iBands(cSymbol,cPeriod,Chk_MAPeriod,1,0,PRICE_CLOSE,MODE_LOWER,count);
   Usigma_1   = iBands(cSymbol,cPeriod,Chk_MAPeriod,1,0,PRICE_CLOSE,MODE_UPPER,count);
   Chikou = iClose(cSymbol,cPeriod,count);
   buy = false;
   sell = false;
   if ( ( Chikou > iHigh(cSymbol,cPeriod,count+Chikou_Idou) ) && (iClose(cSymbol,cPeriod,count) >= Usigma_1)) {
      buy = true;
   }
   if (( Chikou < iLow(cSymbol,cPeriod,count+Chikou_Idou) ) && (iClose(cSymbol,cPeriod,count) <= Lsigma_1)) {
      sell = true;
   }
   if ( buy == true ) {
      ret = 1;
   }
   else if ( sell == true ) {
      ret = -1;
   }
   else ret = 0;
   return(0);
}

