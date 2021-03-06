//+------------------------------------------------------------------+
//|                                        Otyame115_Trix_V6.01.mq4  |
//+------------------------------------------------------------------+
#property copyright "basic version by Luis Damiani, all mods by Cobraforex, forbidden to distribute without permission of Cobraforex"
#property link      "www.cobraforex.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Crimson
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_color5 Lime
#property indicator_color6 Red

string gs_unused_76 = "Hey, if you see this message you used either a decompiler or got";
string gs_unused_84 = "this indi on another ilegal source, my decision is not to share the mq4";
string gs_unused_92 = "and you should respect that, I will get really pissed off if I see my";
string gs_unused_100 = "work copied somewhere else.";
string gs_unused_108 = "I can be your best friend but also you worst enemy, you choose.";
string gs_unused_116 = " - Cobra -";
int gi_124 = 20;
int gi_128 = 35;
string note1 = "===Trix level colors===";
color HighLine_Color = FireBrick;
color ZeroLine_Color = DimGray;
color LowLine_Color = DarkGreen;
int Line_Style = 2;
string note2 = "===Cobra Label colors===";
color text1Color = C'0x77,0x77,0x00';
color text2Color = C'0x77,0x77,0x00';
color text3Color = Green;
int Shift_UP_DN = 10;
int Shift_Left_Right = 50;
string note3 = "===== Alert Settings =====";
bool MsgAlerts = FALSE;
bool SoundAlerts = FALSE;
bool eMailAlerts = FALSE;
bool AlertOnTrixCross = FALSE;
bool AlertOnTrixSigCross = FALSE;
bool AlertOnSlopeChange = FALSE;
string note4 = "===Soundfiles user defined===";
string TrixSlopeSound = "analyze exit.wav";
string AnalyseBuySound = "analyze buy.wav";
string AnalyseSellSound = "analyze sell.wav";
string TrixCrossSound = "trixcross.wav";
string note5 = "=Where to place the alarm labels=";
int AnalyzeLabelWindow = 0;
int AnalyseLabelCorner = 1;
bool AnalyzeLabelonoff = FALSE;
string noteBox = "Box Parameters";
double gd_284 = 0.0;
string note5a = "=How many bars in history=";
extern int Trixnum_bars = 7500;
int gi_304 = 0;
int gi_308 = 0;
double gd_312 = 1.2;
double g_ibuf_320[];
double g_ibuf_324[];
double g_ibuf_328[];
double g_ibuf_332[];
double g_ibuf_336[];
double g_ibuf_340[];
double gd_344;
double gd_352;
int g_bars_360;
string gs_364;
string gs_372;
datetime g_time_380;
datetime g_time_384;
string note6 = "*** Divergence Settings ***";
extern int NumberOfDivergenceBars = 7500;
bool drawPriceTrendLines = FALSE;
bool drawIndicatorTrendLines = FALSE;
bool ShowIn1MChart = FALSE;
string note7 = "--- Divergence Alert Settings ---";
bool EnableAlerts = FALSE;
string _Info1 = "";
string _Info2 = "------------------------------------";
string _Info3 = "SoundAlertOnDivergence only works";
string _Info4 = "when EnableAlerts is true.";
string _Info5 = "";
string _Info6 = "If SoundAlertOnDivergence is true,";
string _Info7 = "then sound alert will be generated,";
string _Info8 = "otherwise a pop-up alert will be";
string _Info9 = "generated.";
string _Info10 = "------------------------------------";
string _Info11 = "";
bool SoundAlertOnDivergence = FALSE;
bool EmailDivergenceAlerts = FALSE;
string note8 = "--- Divergence Color Settings ---";
color BullishDivergenceColor = DodgerBlue;
color BearishDivergenceColor = FireBrick;
string note9 = "--- Divergence Sound Files ---";
string ClassicBullDivSound = "CBullishDiv.wav";
string ReverseBullDivSound = "RBullishDiv.wav";
string ClassicBearDivSound = "CBearishDiv.wav";
string ReverseBearDivSound = "RBearishDiv.wav";
double g_ibuf_576[];
double g_ibuf_580[];

int init() {
   IndicatorBuffers(8);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, g_ibuf_324);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, g_ibuf_328);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, g_ibuf_336);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, g_ibuf_340);
   SetIndexBuffer(4, g_ibuf_576);
   SetIndexBuffer(5, g_ibuf_580);
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(4, 233);
   SetIndexArrow(5, 234);
   SetIndexDrawBegin(5, 9);
   IndicatorDigits(Digits + 2);
   SetIndexBuffer(6, g_ibuf_332);
   SetIndexBuffer(7, g_ibuf_320);
   gs_364 = "Otyame115_Trix v" + "6" + "." + "01";
   gs_372 = gs_364;
   IndicatorShortName(gs_364);
   return (0);
}

int deinit() {
   DeleteObjects("Trix_");
   Comment("");
   return (0);
}

void drawLine(string a_name_0, double a_price_8, color a_color_16, int a_style_20) {
   if (WindowFind(gs_372) > -1) {
      ObjectDelete(a_name_0);
      ObjectCreate(a_name_0, OBJ_HLINE, WindowFind(gs_364), Time[0], a_price_8);
      ObjectSet(a_name_0, OBJPROP_STYLE, a_style_20);
      ObjectSet(a_name_0, OBJPROP_COLOR, a_color_16);
      ObjectSet(a_name_0, OBJPROP_WIDTH, 1);
   }
}

void DeleteObjects(string as_0) {
   string l_name_12;
   for (int li_8 = ObjectsTotal() - 1; li_8 >= 0; li_8--) {
      l_name_12 = ObjectName(li_8);
      if (StringFind(l_name_12, as_0) > -1) ObjectDelete(l_name_12);
   }
}

int start() {
   double ld_0;
   string ls_404;
   string ls_unused_428;
   if (WindowFind(gs_372) > -1) {
   }
   if (Period() == PERIOD_M1) ld_0 = 0.00018;
   if (Period() == PERIOD_M5) ld_0 = 0.00025;
   if (Period() == PERIOD_M15) ld_0 = 0.0005;
   if (Period() == PERIOD_M30) ld_0 = 0.008;
   if (Period() == PERIOD_H1) ld_0 = 0.0012;
   if (Period() == PERIOD_H4) ld_0 = 0.003;
   if (Period() == PERIOD_D1) ld_0 = 0.005;
   if (Period() == PERIOD_W1) ld_0 = 0.08;
   if (Period() == PERIOD_MN1) ld_0 = 0.015;
   if (gd_284 > 0.0) ld_0 = gd_284;
   double ld_8 = ld_0;
   double ld_16 = -1.0 * ld_0;
   if (WindowFind(gs_372) > -1) {
      drawLine("Trix_" + "line_HL", ld_8, HighLine_Color, Line_Style);
      drawLine("Trix_" + "line_ZL", 0, ZeroLine_Color, Line_Style);
      drawLine("Trix_" + "line_LL", ld_16, LowLine_Color, Line_Style);
   }
   int li_24 = 0;
   double ld_28 = 0;
   double ld_36 = 0;
   double ld_unused_44 = 0;
   double ld_52 = 0;
   double ld_60 = 0;
   double ld_68 = 0;
   double ld_76 = 0;
   double ld_84 = 0;
   double ld_92 = 0;
   double ld_100 = 0;
   double ld_108 = 0;
   double ld_116 = 0;
   double ld_124 = 0;
   double ld_132 = 0;
   double ld_140 = 0;
   double ld_148 = 0;
   double ld_156 = 0;
   double ld_164 = 0;
   double ld_172 = 0;
   double ld_180 = 0;
   double ld_188 = 0;
   double ld_196 = 0;
   double ld_204 = 0;
   double ld_212 = 0;
   double ld_220 = 0;
   double ld_228 = 0;
   double ld_236 = 0;
   double ld_244 = 0;
   double ld_252 = 0;
   double ld_260 = 0;
   double ld_268 = 0;
   double ld_276 = 0;
   double ld_284 = 0;
   double ld_292 = 0;
   double ld_300 = 0;
   double ld_308 = 0;
   double ld_316 = 0;
   double ld_324 = 0;
   double ld_332 = 0;
   double ld_340 = 0;
   double ld_348 = 1;
   double ld_356 = 0;
   double l_bars_364 = 0;
   double ld_372 = 0;
   double ld_380 = 0;
   double ld_388 = 0;
   double ld_396 = 0;
   string ls_412 = "nonono";
   int l_ind_counted_420 = IndicatorCounted();
   bool li_424 = TRUE;
   ld_380 = Trixnum_bars + gi_124 + gi_304 + gi_128 + gi_308 + gd_312;
   if (ld_380 == ld_388 && ls_412 == Symbol() && ld_396 == Time[4] - Time[5] && Bars - l_bars_364 < 2.0) ld_372 = Bars - l_bars_364;
   else ld_372 = -1;
   ls_412 = Symbol();
   ld_396 = Time[4] - Time[5];
   l_bars_364 = Bars;
   ld_388 = ld_380;
   if (ld_372 == 1.0 || ld_372 == 0.0) ld_356 = ld_372;
   else ld_348 = 1;
   if (!ShowIn1MChart && Period() == PERIOD_M1) li_424 = FALSE;
   if (ld_348 == 1.0) {
      ld_332 = gd_312 * gd_312;
      ld_340 = ld_332 * gd_312;
      ld_116 = -ld_340;
      ld_124 = 3.0 * (ld_332 + ld_340);
      ld_132 = -3.0 * (2.0 * ld_332 + gd_312 + ld_340);
      ld_140 = 3.0 * gd_312 + 1.0 + ld_340 + 3.0 * ld_332;
      ld_292 = gi_124;
      if (ld_292 < 1.0) ld_292 = 1;
      ld_292 = (ld_292 - 1.0) / 2.0 + 1.0;
      ld_300 = 2 / (ld_292 + 1.0);
      ld_308 = 1 - ld_300;
      ld_292 = gi_128;
      if (ld_292 < 1.0) ld_292 = 1;
      ld_292 = (ld_292 - 1.0) / 2.0 + 1.0;
      ld_316 = 2 / (ld_292 + 1.0);
      ld_324 = 1 - ld_316;
      g_ibuf_320[Trixnum_bars - 1] = 0;
      ld_244 = 0;
      ld_252 = 0;
      ld_260 = 0;
      ld_268 = 0;
      ld_276 = 0;
      ld_284 = 0;
      g_ibuf_332[Trixnum_bars - 1] = 0;
      ld_148 = 0;
      ld_156 = 0;
      ld_164 = 0;
      ld_172 = 0;
      ld_180 = 0;
      ld_188 = 0;
      ld_356 = Trixnum_bars - 2;
      ld_348 = 0;
   }
   for (li_24 = ld_356; li_24 >= 0; li_24--) {
      if (gi_304 == 1) ld_196 = ld_300 * Open[li_24] + ld_308 * ld_244;
      else ld_196 = ld_300 * Close[li_24] + ld_308 * ld_244;
      ld_204 = ld_300 * ld_196 + ld_308 * ld_252;
      ld_212 = ld_300 * ld_204 + ld_308 * ld_260;
      ld_220 = ld_300 * ld_212 + ld_308 * ld_268;
      ld_228 = ld_300 * ld_220 + ld_308 * ld_276;
      ld_236 = ld_300 * ld_228 + ld_308 * ld_284;
      ld_28 = ld_116 * ld_236 + ld_124 * ld_228 + ld_132 * ld_220 + ld_140 * ld_212;
      if ((ld_372 == 1.0 && li_24 == 1) || ld_372 == -1.0) {
         ld_244 = ld_196;
         ld_252 = ld_204;
         ld_260 = ld_212;
         ld_268 = ld_220;
         ld_276 = ld_228;
         ld_284 = ld_236;
      }
      ld_68 = ld_316 * Close[li_24] + ld_324 * ld_148;
      ld_76 = ld_316 * ld_68 + ld_324 * ld_156;
      ld_84 = ld_316 * ld_76 + ld_324 * ld_164;
      ld_92 = ld_316 * ld_84 + ld_324 * ld_172;
      ld_100 = ld_316 * ld_92 + ld_324 * ld_180;
      ld_108 = ld_316 * ld_100 + ld_324 * ld_188;
      ld_52 = ld_116 * ld_108 + ld_124 * ld_100 + ld_132 * ld_92 + ld_140 * ld_84;
      if (gi_308 == 1) {
         g_ibuf_320[li_24] = (ld_28 - ld_36) / ld_36 + (ld_52 - ld_60) / ld_60;
         g_ibuf_332[li_24] = (ld_28 - ld_36) / ld_36;
         gd_352 = g_ibuf_332[li_24];
      } else {
         if (ld_60 > 0.0 && ld_36 > 0.0) {
            g_ibuf_320[li_24] = (ld_52 - ld_60) / ld_60;
            g_ibuf_332[li_24] = (ld_28 - ld_36) / ld_36;
            gd_352 = g_ibuf_332[li_24];
         }
      }
      g_ibuf_324[li_24] = EMPTY_VALUE;
      g_ibuf_328[li_24] = EMPTY_VALUE;
//      if (g_ibuf_320[li_24 + 1] < g_ibuf_320[li_24]) {
//         if (g_ibuf_324[li_24 + 1] == EMPTY_VALUE) g_ibuf_324[li_24 + 1] = g_ibuf_320[li_24 + 1];
         g_ibuf_324[li_24] = g_ibuf_320[li_24];
//      } else {
//         if (g_ibuf_320[li_24 + 1] > g_ibuf_320[li_24]) {
//            if (g_ibuf_328[li_24 + 1] == EMPTY_VALUE) g_ibuf_328[li_24 + 1] = g_ibuf_320[li_24 + 1];
//            g_ibuf_328[li_24] = g_ibuf_320[li_24];
//         }
//      }
      g_ibuf_336[li_24] = EMPTY_VALUE;
      g_ibuf_340[li_24] = EMPTY_VALUE;
//      if (g_ibuf_332[li_24 + 1] < g_ibuf_332[li_24]) {
//         if (g_ibuf_336[li_24 + 1] == EMPTY_VALUE) g_ibuf_336[li_24 + 1] = g_ibuf_332[li_24 + 1];
         g_ibuf_336[li_24] = g_ibuf_332[li_24];
//      } else {
//         if (g_ibuf_332[li_24 + 1] > g_ibuf_332[li_24]) {
//            if (g_ibuf_340[li_24 + 1] == EMPTY_VALUE) g_ibuf_340[li_24 + 1] = g_ibuf_332[li_24 + 1];
//            g_ibuf_340[li_24] = g_ibuf_332[li_24];
//         }
//      }
      if ((ld_372 == 1.0 && li_24 == 1) || ld_372 == -1.0) {
         ld_36 = ld_28;
         ld_60 = ld_52;
         ld_148 = ld_68;
         ld_156 = ld_76;
         ld_164 = ld_84;
         ld_172 = ld_92;
         ld_180 = ld_100;
         ld_188 = ld_108;
      }
      if (li_24 <= NumberOfDivergenceBars && li_424) {
         CatchBullishDivergence(li_24 + 2);
         CatchBearishDivergence(li_24 + 2);
      }
   }
   if (gd_352 > 0.0) {
      if (WindowFind(gs_372) > -1) {
         if (gd_352 < 0.0) {
            if (WindowFind(gs_372) > -1) {
            }
         }
      }
   }
   if (gd_344 < 0.0 && gd_352 > 0.0) {
      if (AlertOnTrixCross)
         if (SoundAlerts) PlaySound(TrixCrossSound);
   }
   gd_344 = gd_352;
   if (AlertOnTrixSigCross) {
      if (g_ibuf_332[2] < g_ibuf_320[2] && g_ibuf_332[1] > g_ibuf_320[1] && g_bars_360 < Bars) {
         if (AnalyzeLabelonoff) ls_unused_428 = "Analyze Buy";
         if (WindowFind(gs_372) > -1) ls_404 = gs_364 + " " + Symbol() + " " + TF2Str(Period()) + " BUY ALARM @ " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES);
         DoAlerts(ls_404, ls_404);
         g_bars_360 = Bars;
         if (SoundAlerts) PlaySound(AnalyseBuySound);
      } else {
         if (g_ibuf_332[2] > g_ibuf_320[2] && g_ibuf_332[1] < g_ibuf_320[1] && g_bars_360 < Bars) {
            if (AnalyzeLabelonoff) ls_unused_428 = "Analyze Sell";
            if (WindowFind(gs_372) > -1) ls_404 = gs_364 + " " + Symbol() + " " + TF2Str(Period()) + " SELL ALARM @ " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES);
            DoAlerts(ls_404, ls_404);
            g_bars_360 = Bars;
            if (SoundAlerts) PlaySound(AnalyseSellSound);
         }
      }
   }
   if (AlertOnSlopeChange) {
      if (g_ibuf_332[1] > g_ibuf_320[1] && g_ibuf_336[2] != EMPTY_VALUE && g_ibuf_336[1] == EMPTY_VALUE && g_bars_360 < Bars) {
         if (AnalyzeLabelonoff) ls_unused_428 = "Analyze Exit";
         if (ObjectFind("Alarm_Crossing_Label" + Time[0]) == -1) {
         }
         ls_404 = gs_364 + " " + Symbol() + " " + TF2Str(Period()) + " TRIX EXIT ALARM @ " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES);
         DoAlerts(ls_404, ls_404);
         g_bars_360 = Bars;
         if (SoundAlerts) PlaySound(TrixSlopeSound);
      } else {
         if (g_ibuf_332[1] < g_ibuf_320[1] && g_ibuf_340[2] != EMPTY_VALUE && g_ibuf_340[1] == EMPTY_VALUE && g_bars_360 < Bars) {
            if (AnalyzeLabelonoff) ls_unused_428 = "Analyze Exit";
            if (ObjectFind("Alarm_Crossing_Label" + Time[0]) == -1) {
               if (AnalyzeLabelonoff) {
               }
            }
            ls_404 = gs_364 + " " + Symbol() + " " + TF2Str(Period()) + " TRIX EXIT ALARM @ " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES);
            DoAlerts(ls_404, ls_404);
            g_bars_360 = Bars;
            if (SoundAlerts) PlaySound(TrixSlopeSound);
         }
      }
      if (ObjectFind("Alarm_Crossing_Label" + Time[1]) != -1) ObjectDelete("Alarm_Crossing_Label" + Time[1]);
   }
   return (0);
}

void DoAlerts(string as_0, string as_8) {
   if (MsgAlerts) Alert(as_8);
   if (eMailAlerts) SendMail(as_0, as_8);
}

string TF2Str(int ai_0) {
   switch (ai_0) {
   case 1:
      return ("M1");
   case 5:
      return ("M5");
   case 15:
      return ("M15");
   case 30:
      return ("M30");
   case 60:
      return ("H1");
   case 240:
      return ("H4");
   case 1440:
      return ("D1");
   case 10080:
      return ("W1");
   case 43200:
      return ("MN");
   }
   return (Period());
}

void CatchBullishDivergence(int ai_0) {
   int li_4;
   int li_8;
   if (IsIndicatorTrough(ai_0) != 0) {
      li_4 = ai_0;
      li_8 = GetIndicatorLastTrough(ai_0);
      if (g_ibuf_332[li_4] > g_ibuf_332[li_8] && Low[li_4] < Low[li_8]) {
         g_ibuf_576[li_4] = g_ibuf_332[li_4] - 0.0001;
         if (drawPriceTrendLines == TRUE) DrawPriceTrendLine(Time[li_4], Time[li_8], Low[li_4], Low[li_8], BullishDivergenceColor, STYLE_SOLID);
         if (drawIndicatorTrendLines == TRUE) DrawIndicatorTrendLine(Time[li_4], Time[li_8], g_ibuf_332[li_4], g_ibuf_332[li_8], BullishDivergenceColor, STYLE_SOLID);
         if (EnableAlerts == TRUE) {
            if (SoundAlertOnDivergence == TRUE) SoundAlert(ClassicBullDivSound, li_4);
            else DisplayAlert("Classical bullish divergence on: ", li_4);
         }
      }
      if (g_ibuf_332[li_4] < g_ibuf_332[li_8] && Low[li_4] > Low[li_8]) {
         g_ibuf_576[li_4] = g_ibuf_332[li_4] - 0.0001;
         if (drawPriceTrendLines == TRUE) DrawPriceTrendLine(Time[li_4], Time[li_8], Low[li_4], Low[li_8], BullishDivergenceColor, STYLE_DOT);
         if (drawIndicatorTrendLines == TRUE) DrawIndicatorTrendLine(Time[li_4], Time[li_8], g_ibuf_332[li_4], g_ibuf_332[li_8], BullishDivergenceColor, STYLE_DOT);
         if (EnableAlerts == TRUE) {
            if (SoundAlertOnDivergence == TRUE) {
               SoundAlert(ReverseBullDivSound, li_4);
               return;
            }
            DisplayAlert("Reverse bullish divergence on: ", li_4);
         }
      }
   }
}

void CatchBearishDivergence(int ai_0) {
   int li_4;
   int li_8;
   if (IsIndicatorPeak(ai_0) != 0) {
      li_4 = ai_0;
      li_8 = GetIndicatorLastPeak(ai_0);
      if (g_ibuf_332[li_4] < g_ibuf_332[li_8] && High[li_4] > High[li_8]) {
         g_ibuf_580[li_4] = g_ibuf_332[li_4] + 0.0001;
         if (drawPriceTrendLines == TRUE) DrawPriceTrendLine(Time[li_4], Time[li_8], High[li_4], High[li_8], BearishDivergenceColor, STYLE_SOLID);
         if (drawIndicatorTrendLines == TRUE) DrawIndicatorTrendLine(Time[li_4], Time[li_8], g_ibuf_332[li_4], g_ibuf_332[li_8], BearishDivergenceColor, STYLE_SOLID);
         if (EnableAlerts == TRUE) {
            if (SoundAlertOnDivergence == TRUE) SoundAlert(ClassicBearDivSound, li_4);
            else DisplayAlert("Classical bearish divergence on: ", li_4);
         }
      }
      if (g_ibuf_332[li_4] > g_ibuf_332[li_8] && High[li_4] < High[li_8]) {
         g_ibuf_580[li_4] = g_ibuf_332[li_4] + 0.0001;
         if (drawPriceTrendLines == TRUE) DrawPriceTrendLine(Time[li_4], Time[li_8], High[li_4], High[li_8], BearishDivergenceColor, STYLE_DOT);
         if (drawIndicatorTrendLines == TRUE) DrawIndicatorTrendLine(Time[li_4], Time[li_8], g_ibuf_332[li_4], g_ibuf_332[li_8], BearishDivergenceColor, STYLE_DOT);
         if (EnableAlerts == TRUE) {
            if (SoundAlertOnDivergence == TRUE) {
               SoundAlert(ReverseBearDivSound, li_4);
               return;
            }
            DisplayAlert("Reverse bearish divergence on: ", li_4);
         }
      }
   }
}

int IsIndicatorTrough(int ai_0) {
   if (g_ibuf_332[ai_0] <= g_ibuf_332[ai_0 + 1] && g_ibuf_332[ai_0] < g_ibuf_332[ai_0 + 2] && g_ibuf_332[ai_0] < g_ibuf_332[ai_0 - 1]) return (1);
   return (0);
}

int GetIndicatorLastTrough(int ai_0) {
   for (int li_4 = ai_0 + 5; li_4 < Bars; li_4++) {
      if (g_ibuf_320[li_4] <= g_ibuf_320[li_4 + 1] && g_ibuf_320[li_4] <= g_ibuf_320[li_4 + 2] && g_ibuf_320[li_4] <= g_ibuf_320[li_4 - 1] && g_ibuf_320[li_4] <= g_ibuf_320[li_4 - 2]) {
         for (int li_ret_8 = li_4; li_ret_8 < Bars; li_ret_8++)
            if (g_ibuf_332[li_ret_8] <= g_ibuf_332[li_ret_8 + 1] && g_ibuf_332[li_ret_8] < g_ibuf_332[li_ret_8 + 2] && g_ibuf_332[li_ret_8] <= g_ibuf_332[li_ret_8 - 1] && g_ibuf_332[li_ret_8] < g_ibuf_332[li_ret_8 - 2]) return (li_ret_8);
      }
   }
   return (-1);
}

void DrawPriceTrendLine(int a_datetime_0, int a_datetime_4, double a_price_8, double a_price_16, color a_color_24, double a_style_28) {
   string l_name_36 = "THVTrix v" + "6" + "_Trix_DivergenceLine_# " + DoubleToStr(a_datetime_0, 0);
   ObjectDelete(l_name_36);
   ObjectCreate(l_name_36, OBJ_TREND, 0, a_datetime_0, a_price_8, a_datetime_4, a_price_16, 0, 0);
   ObjectSet(l_name_36, OBJPROP_RAY, FALSE);
   ObjectSet(l_name_36, OBJPROP_COLOR, a_color_24);
   ObjectSet(l_name_36, OBJPROP_STYLE, a_style_28);
}

void DrawIndicatorTrendLine(int a_datetime_0, int a_datetime_4, double a_price_8, double a_price_16, color a_color_24, double a_style_28) {
   string l_name_40;
   int l_window_36 = WindowFind(gs_372);
   if (l_window_36 >= 0) {
      l_name_40 = "THVTrix v" + "6" + "_Trix_DivergenceLine_$# " + DoubleToStr(a_datetime_0, 0);
      ObjectDelete(l_name_40);
      ObjectCreate(l_name_40, OBJ_TREND, l_window_36, a_datetime_0, a_price_8, a_datetime_4, a_price_16, 0, 0);
      ObjectSet(l_name_40, OBJPROP_RAY, FALSE);
      ObjectSet(l_name_40, OBJPROP_COLOR, a_color_24);
      ObjectSet(l_name_40, OBJPROP_STYLE, a_style_28);
   }
}

void DisplayAlert(string as_0, int ai_8) {
   string ls_unused_12;
   string ls_20;
   if (ai_8 <= 2 && Time[ai_8] != g_time_380) {
      g_time_380 = Time[ai_8];
      Alert(as_0, Symbol(), " , ", TF2Str(Period()), " minutes chart");
      ls_20 = "Divergence on " + TF2Str(Period());
      if (EmailDivergenceAlerts) SendMail(ls_20, as_0);
   }
}

void SoundAlert(string as_0, int ai_8) {
   if (ai_8 <= 2 && Time[ai_8] != g_time_384) {
      g_time_384 = Time[ai_8];
      PlaySound(as_0);
   }
}

int IsIndicatorPeak(int ai_0) {
   if (g_ibuf_332[ai_0] >= g_ibuf_332[ai_0 + 1] && g_ibuf_332[ai_0] > g_ibuf_332[ai_0 + 2] && g_ibuf_332[ai_0] > g_ibuf_332[ai_0 - 1]) return (1);
   return (0);
}

int GetIndicatorLastPeak(int ai_0) {
   for (int li_4 = ai_0 + 5; li_4 < Bars; li_4++) {
      if (g_ibuf_320[li_4] >= g_ibuf_320[li_4 + 1] && g_ibuf_320[li_4] >= g_ibuf_320[li_4 + 2] && g_ibuf_320[li_4] >= g_ibuf_320[li_4 - 1] && g_ibuf_320[li_4] >= g_ibuf_320[li_4 - 2]) {
         for (int li_ret_8 = li_4; li_ret_8 < Bars; li_ret_8++)
            if (g_ibuf_332[li_ret_8] >= g_ibuf_332[li_ret_8 + 1] && g_ibuf_332[li_ret_8] > g_ibuf_332[li_ret_8 + 2] && g_ibuf_332[li_ret_8] >= g_ibuf_332[li_ret_8 - 1] && g_ibuf_332[li_ret_8] > g_ibuf_332[li_ret_8 - 2]) return (li_ret_8);
      }
   }
   return (-1);
}