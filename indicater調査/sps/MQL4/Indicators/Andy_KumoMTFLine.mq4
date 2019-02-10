//+------------------------------------------------------------------+
//|                                                 Andy_KumoMTF.mq4 |
//|             http://ichimoku119.blog15.fc2.com/blog-entry-88.html |
//|                           Copyright (c) 2009, Fai Software Corp. |
//|                                    http://d.hatena.ne.jp/fai_fx/ |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2009, Fai Software Corp."
#property link      "http://d.hatena.ne.jp/fai_fx/"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Lime
#property indicator_color2 MediumVioletRed
#property indicator_color3 SandyBrown
#property indicator_color4 Thistle
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT

#property indicator_color5 White
#property indicator_color6 SandyBrown
#property indicator_color7 Thistle
#property indicator_color8 DeepPink
//---- input parameters

extern int TimeFrame =  0;//MTF

extern int Tenkan=9;
extern int Kijun=26;
extern int Senkou=52;
extern int Senko_Shift = 1;

extern bool Interpolate = true;
//---- buffers
double Tenkan_Buffer[];
double Kijun_Buffer[];
double SpanA_Buffer[];
double SpanB_Buffer[];
double Chinkou_Buffer[];
double SpanA2_Buffer[];
double SpanB2_Buffer[];

string ObjPrefix = "Andy-Obj-";

//----
int a_begin;
string IndicatorFileName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if(TimeFrame==0) TimeFrame = Period();
   switch(TimeFrame)
   {
      case 1 : string TimeFrameStr="_M1"; break;
      case 5 : TimeFrameStr="_M5"; break;
      case 15 : TimeFrameStr="_M15"; break;
      case 30 : TimeFrameStr="_M30"; break;
      case 60 : TimeFrameStr="_H1"; break;
      case 240 : TimeFrameStr="_H4"; break;
      case 1440 : TimeFrameStr="_D1"; break;
      case 10080 : TimeFrameStr="_W1"; break;
      case 43200 : TimeFrameStr="_MN1"; break;
      default : TimeFrameStr="";
   }
//----
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,Tenkan_Buffer);
   SetIndexDrawBegin(0,Tenkan-1);
   SetIndexLabel(0,"Tenkan Sen");
//----
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,Kijun_Buffer);
   SetIndexDrawBegin(1,Kijun-1);
   SetIndexLabel(1,"Kijun Sen");
//----
   a_begin=Kijun; if(a_begin<Tenkan) a_begin=Tenkan;
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_DOT);
   SetIndexBuffer(2,SpanA_Buffer);
   SetIndexDrawBegin(2,Kijun+a_begin-1);
   SetIndexShift(2,Senko_Shift*TimeFrame/Period());
   SetIndexLabel(2,NULL);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,SpanA2_Buffer);
   SetIndexDrawBegin(5,Kijun+a_begin-1);
   SetIndexShift(5,Senko_Shift*TimeFrame/Period());
   SetIndexLabel(5,"Senkou Span A");
//----
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_DOT);
   SetIndexBuffer(3,SpanB_Buffer);
   SetIndexDrawBegin(3,Kijun+Senkou-1);
   SetIndexShift(3,Senko_Shift*TimeFrame/Period());
   SetIndexLabel(3,NULL);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,SpanB2_Buffer);
   SetIndexDrawBegin(6,Kijun+Senkou-1);
   SetIndexShift(6,Senko_Shift*TimeFrame/Period());
   SetIndexLabel(6,"Senkou Span B");
//----
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Chinkou_Buffer);
   SetIndexShift(4,(-Kijun+1)*TimeFrame/Period());
   SetIndexLabel(4,"Chikou Span");
//----
   IndicatorShortName("AndyKumo"+TimeFrameStr+"("+Senko_Shift+")");
   IndicatorFileName = WindowExpertName();
   ObjPrefix = ObjPrefix + Tenkan+Kijun+Senkou+Senko_Shift+"-";
   return(0);
  }
  
int deinit() {
   for(int i= Bars -2;i>=0;i--)
      ObjectDelete(ObjPrefix+TimeToStr(Time[i]));
}
//+------------------------------------------------------------------+
//| Ichimoku Kinko Hyo                                               |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double high,low,price;
   
   if(TimeFrame == Period()){
//----
   if(Bars<=Tenkan || Bars<=Kijun || Bars<=Senkou) return(0);
//---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=Tenkan;i++)    Tenkan_Buffer[Bars-i]=0;
      for(i=1;i<=Kijun;i++)     Kijun_Buffer[Bars-i]=0;
      for(i=1;i<=a_begin;i++) { SpanA_Buffer[Bars-i]=0; SpanA2_Buffer[Bars-i]=0; }
      for(i=1;i<=Senkou;i++)  { SpanB_Buffer[Bars-i]=0; SpanB2_Buffer[Bars-i]=0; }
     }
//---- Tenkan Sen
   i=Bars-Tenkan;
   if(counted_bars>Tenkan) i=Bars-counted_bars-1;
   while(i>=0)
     {
      high=High[i]; low=Low[i]; k=i-1+Tenkan;
      while(k>=i)
        {
         price=High[k];
         if(high<price) high=price;
         price=Low[k];
         if(low>price)  low=price;
         k--;
        }
      Tenkan_Buffer[i]=(high+low)/2;
      i--;
     }
//---- Kijun Sen
   i=Bars-Kijun;
   if(counted_bars>Kijun) i=Bars-counted_bars-1;
   while(i>=0)
     {
      high=High[i]; low=Low[i]; k=i-1+Kijun;
      while(k>=i)
        {
         price=High[k];
         if(high<price) high=price;
         price=Low[k];
         if(low>price)  low=price;
         k--;
        }
      Kijun_Buffer[i]=(high+low)/2;
      i--;
     }
//---- Senkou Span A
   i=Bars-a_begin+1;
   if(counted_bars>a_begin-1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      price=(Kijun_Buffer[i]+Tenkan_Buffer[i])/2;
      SpanA_Buffer[i]=price;
      SpanA2_Buffer[i]=price;
      i--;
     }
//---- Senkou Span B
   i=Bars-Senkou;
   if(counted_bars>Senkou) i=Bars-counted_bars-1;
   while(i>=0)
     {
      high=High[i]; low=Low[i]; k=i-1+Senkou;
      while(k>=i)
        {
         price=High[k];
         if(high<price) high=price;
         price=Low[k];
         if(low>price)  low=price;
         k--;
        }
      price=(high+low)/2;
      SpanB_Buffer[i]=price;
      SpanB2_Buffer[i]=price;
      i--;
     }
//---- Chinkou Span
   i=Bars-1;
   if(counted_bars>1) i=Bars-counted_bars-1;
   while(i>=0) { Chinkou_Buffer[i]=Close[i]; i--; }
//----

   }else{
   // MTF MODE
      datetime TimeArray[];
      int    shift,y=0;
    
   // Plot defined timeframe on to current timeframe   
      ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
      int limit=Bars-counted_bars+TimeFrame/Period();

 	for(i = limit; i >= 0; i--)
   {
      int      shift1 = iBarShift(NULL,TimeFrame,Time[i]);
      datetime time1  = iTime    (NULL,TimeFrame,shift1);
      
      Tenkan_Buffer[i] = iCustom(NULL,TimeFrame,IndicatorFileName,0,Tenkan,Kijun,Senkou,Senko_Shift,0,shift1);
      Kijun_Buffer[i]  = iCustom(NULL,TimeFrame,IndicatorFileName,0,Tenkan,Kijun,Senkou,Senko_Shift,1,shift1);
      SpanA_Buffer[i]  = iCustom(NULL,TimeFrame,IndicatorFileName,0,Tenkan,Kijun,Senkou,Senko_Shift,2,shift1-Senko_Shift);
      SpanB_Buffer[i]  = iCustom(NULL,TimeFrame,IndicatorFileName,0,Tenkan,Kijun,Senkou,Senko_Shift,3,shift1-Senko_Shift);
      Chinkou_Buffer[i]= iCustom(NULL,TimeFrame,IndicatorFileName,0,Tenkan,Kijun,Senkou,Senko_Shift,4,shift1-(-Kijun+1));
      SpanA2_Buffer[i] = iCustom(NULL,TimeFrame,IndicatorFileName,0,Tenkan,Kijun,Senkou,Senko_Shift,5,shift1-Senko_Shift);
      SpanB2_Buffer[i] = iCustom(NULL,TimeFrame,IndicatorFileName,0,Tenkan,Kijun,Senkou,Senko_Shift,6,shift1-Senko_Shift);
         if (TimeFrame <= Period() || shift1==iBarShift(NULL,TimeFrame,Time[i-1])) continue;
         if (!Interpolate) continue;

      //
      //
      //
      //
      //

         for(int n = 1; i+n < Bars && Time[i+n] >= time1; n++) continue;
         double factor = 1.0 / n;
         for(k = 1; k < n; k++)
            {
               Tenkan_Buffer[i+k] = k*factor*Tenkan_Buffer[i+n] + (1.0-k*factor)*Tenkan_Buffer[i];
               Kijun_Buffer[i+k] = k*factor*Kijun_Buffer[i+n] + (1.0-k*factor)*Kijun_Buffer[i];
               Chinkou_Buffer[i+k] = k*factor*Chinkou_Buffer[i+n] + (1.0-k*factor)*Chinkou_Buffer[i];
               SpanA_Buffer[i+k] = k*factor*SpanA_Buffer[i+n] + (1.0-k*factor)*SpanA_Buffer[i];
               SpanB_Buffer[i+k] = k*factor*SpanB_Buffer[i+n] + (1.0-k*factor)*SpanB_Buffer[i];
               SpanA2_Buffer[i+k] = k*factor*SpanA_Buffer[i+n] + (1.0-k*factor)*SpanA2_Buffer[i];
               SpanB2_Buffer[i+k] = k*factor*SpanB_Buffer[i+n] + (1.0-k*factor)*SpanB2_Buffer[i];
            }  
      }//for   
   
   
   }//MTF
   
   //Draw Vertical Line;
   i=MathMin(Bars-Senkou,Bars-a_begin+1)-1;
   if(counted_bars>1) i=Bars-counted_bars-1;
   while(i>=0) {
   if(SpanA_Buffer[i+1]>=SpanB_Buffer[i+1] && SpanA_Buffer[i]<SpanB_Buffer[i] ){
      DrawVerticalLine(i-Senko_Shift*TimeFrame/Period(),true);
   }else if(SpanA_Buffer[i+1]<=SpanB_Buffer[i+1] && SpanA_Buffer[i]>SpanB_Buffer[i]){
      DrawVerticalLine(i-Senko_Shift*TimeFrame/Period(),false);
   }else{
      delObj(i-Senko_Shift*TimeFrame/Period());
   }
   
   i--;
   }
   return(0);
  }
//+------------------------------------------------------------------+
//////////////////////////////////////////////////////////////////////////////////
void DrawVerticalLine(int i ,bool isUp){
   string objname = ObjPrefix+TimeToStr(Time[i]);
   if(ObjectFind(objname) !=0){
      ObjectCreate(objname,OBJ_VLINE,0,Time[i],0);
   }else{
      ObjectSet(objname,OBJPROP_TIME1,Time[i]);
   }
   ObjectSet(objname,OBJPROP_BACK,true);
   if(isUp){
      ObjectSet(objname,OBJPROP_COLOR,DeepSkyBlue);
   }else{
      ObjectSet(objname,OBJPROP_COLOR,HotPink);
   }
}
//////////////////////////////////////////////////////////////////////////////////
void delObj(int i){
   ObjectDelete(ObjPrefix+TimeToStr(Time[i]));
}
//////////////////////////////////////////////////////////////////////////////////