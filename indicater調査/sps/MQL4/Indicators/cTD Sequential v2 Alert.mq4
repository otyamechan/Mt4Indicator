//+------------------------------------------------------------------+
//|                                               cTD Sequential.mq4 |
//|                                         Copyright © 2006, ch33z3 |
//|                                   http://4xjournal.blogspot.com/ |
//|                    TD Sequential is a TradeMark of Thomas DeMark |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2006, ch33z3"
#property  link      "http://4xjournal.blogspot.com/"

//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

extern color BuySetup=Red;
extern color SellSetup=Green;
extern color Countdown=Orange;
extern bool  Alerts = True;

//---- indicator parameters

//---- indicator buffers
double R[];
double G[];

datetime last_alert = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  IndicatorBuffers(2);
  SetIndexStyle(0,DRAW_ARROW,0,1.5);
  SetIndexBuffer(0,R);
  SetIndexArrow(0,234);
  SetIndexStyle(1,DRAW_ARROW,0,1.5);
  SetIndexBuffer(1,G);
  SetIndexArrow(1,233);
  return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
int deinit() 
   {
   for(int i=0;i<Bars;i++) {
      ObjectDelete(""+i); 
      ObjectDelete("cd"+i); }	
   return(0);
   }
  
//+------------------------------------------------------------------+
//| TD Sequential                                                    |
//+------------------------------------------------------------------+
int start()
  {
   int bc=0;
   int sc=0;
   double tfm=Point*MathSqrt(Period())/1.05;
   double tfm2=Point*MathSqrt(Period());
   int x;
   int fbc=0;
   int fsc=0;
   double low;
   double high;
   int bcd=0;
   int scd=0;
   
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars+10;
   for(int i=limit; i>0; i--) {
   
      //+-- Buy Setup Start --|
      if(Close[i]<Close[i+4] && Close[i+1]>=Close[i+5] && bc==0) {
         bc=1;
         ObjectCreate(""+i,OBJ_TEXT,0,Time[i],High[i]+tfm);
         ObjectSetText(""+i,""+bc,8,"Arial",BuySetup);
         fbc=i; 
         scd=0;}
      if(Close[i]<Close[i+4] && bc!=0 && ObjectFind(""+i)==-1 && fbc!=i) {
         bc++;
         if(bc==9) {
            if(Low[i+2]>Low[i+3]) low=Low[i+3];
            else low=Low[i+2];
            if(Low[i]<low || Low[i+1]<low) {
               ObjectCreate(""+i,OBJ_TEXT,0,Time[i],High[i]+tfm);
               ObjectSetText(""+i,""+bc,10,"Arial Black",BuySetup); }
            else {
               ObjectCreate(""+i,OBJ_TEXT,0,Time[i],High[i]+tfm);
               ObjectSetText(""+i,""+bc,8,"Arial",BuySetup); }
            bc=0; 
            G[i]=Low[i]-tfm2; 
            
            if( Alerts == True && last_alert != Time[0] )
            {
               last_alert = Time[0];
               Alert("TD Sequential - ", Symbol(), " Buy Signal");
            }
            
            if(bcd==0) bcd=1; }
         else {
            ObjectCreate(""+i,OBJ_TEXT,0,Time[i],High[i]+tfm);
            ObjectSetText(""+i,""+bc,8,"Arial",BuySetup); } }
      else if(Close[i]>=Close[i+4]) {
         for(x=i+1; x<=i+bc; x++) ObjectDelete(""+x);
         bc=0; }
         
      if(bcd==1) bcd=-1*i;
      if(bcd==-1*(i+1)) bcd=1;
      if(bcd==13 && Close[i]<=Close[i+5]) {
         ObjectCreate("cd"+i,OBJ_TEXT,0,Time[i],High[i]+tfm*2.5);
         ObjectSetText("cd"+i,""+bcd,8,"Arial Black",Countdown); 
         bcd=0; }
      if(bcd==13 && Close[i]<=Close[i+2] && Close[i]>Close[i+5]) {
         ObjectCreate("cd"+i,OBJ_TEXT,0,Time[i],High[i]+tfm*2.5);
         ObjectSetText("cd"+i,""+bcd,8,"Arial",Countdown); 
         bcd=0; }
      if(bcd>=1 && Close[i]<=Close[i+2] && bcd<13) {
         ObjectCreate("cd"+i,OBJ_TEXT,0,Time[i],High[i]+tfm*2.5);
         ObjectSetText("cd"+i,""+bcd,8,"Arial",Countdown); 
         bcd++; }
         
      //+-- Sell Setup Start --|
      if(Close[i]>Close[i+4] && Close[i+1]<=Close[i+5] && sc==0) {
         sc=1;
         ObjectCreate(""+i,OBJ_TEXT,0,Time[i],Low[i]-tfm);
         ObjectSetText(""+i,""+sc,8,"Arial",SellSetup);
         fsc=i; 
         bcd=0;}
      if(Close[i]>Close[i+4] && sc!=0 && fsc!=i && ObjectFind(""+i)==-1) {
         sc++;
         if(sc==9) {
            if(High[i+2]>High[i+3]) high=High[i+2];
            else high=High[i+3];
            if(High[i]>high || High[i+1]>high) {
               ObjectCreate(""+i,OBJ_TEXT,0,Time[i],Low[i]-tfm);
               ObjectSetText(""+i,""+sc,10,"Arial Black",SellSetup); }
            else {
               ObjectCreate(""+i,OBJ_TEXT,0,Time[i],Low[i]-tfm);
               ObjectSetText(""+i,""+sc,8,"Arial",SellSetup); }
            sc=0; 
            R[i]=High[i]+tfm2; 
            
            if( Alerts == True && last_alert != Time[0] )
            {
               last_alert = Time[0];
               Alert("TD Sequential - ", Symbol(), " Buy Signal");
            }
                        
            if(scd==0) scd=1; }
         else {
            ObjectCreate(""+i,OBJ_TEXT,0,Time[i],Low[i]-tfm);
            ObjectSetText(""+i,""+sc,8,"Arial",SellSetup); } }
      else if(Close[i]<=Close[i+4]) {
         for(x=i+1; x<=i+sc; x++) ObjectDelete(""+x);
         sc=0; }
         
      if(scd==1) scd=-1*i;
      if(scd==-1*(i+1)) scd=1;
      if(scd==13) {
         if(Close[i]>=Close[i+5]) {
            ObjectCreate("cd"+i,OBJ_TEXT,0,Time[i],Low[i]-tfm*2.5);
            ObjectSetText("cd"+i,""+scd,8,"Arial Black",Countdown); 
            scd=0; }
         if(Close[i]>=Close[i+2] && Close[i]<Close[i+5]) {
            ObjectCreate("cd"+i,OBJ_TEXT,0,Time[i],Low[i]-tfm*2.5);
            ObjectSetText("cd"+i,""+scd,8,"Arial",Countdown); 
            scd=0; }}
      if(scd>=1 && Close[i]>=Close[i+2] && scd<13) {
         ObjectCreate("cd"+i,OBJ_TEXT,0,Time[i],Low[i]-tfm*2.5);
         ObjectSetText("cd"+i,""+scd,8,"Arial",Countdown); 
         scd++; }   
   }
   return(0);
  }
//+------------------------------------------------------------------+

