/*
   Generated by EX4-TO-MQ4 decompiler V4.0.220.2c []
   Website: http://purebeam.biz
   E-mail : purebeam@gmail.com
*/

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 OrangeRed
#property indicator_color2 OrangeRed
#property indicator_color3 OrangeRed
#property indicator_color4 OrangeRed
#property indicator_color5 OrangeRed
#property indicator_color6 OrangeRed
#property indicator_color7 OrangeRed
#property indicator_color8 OrangeRed

extern int g_timeframe_76 = PERIOD_D1;
extern int g_period_80 = 252;
extern int LineStyle = 1;
extern int LineWidth = 0;
extern string _1 = "Band ";
extern string _2 = "1 - Upper";
extern string _3 = "2 - Lower";
extern int WhichBand = 2;
double g_ibuf_120[];
double g_ibuf_124[];
double gda_unused_128[];
double gda_unused_132[];
double g_ibuf_136[];
double g_ibuf_140[];
double g_ibuf_144[];
double g_ibuf_148[];
double g_ibuf_152[];
double g_ibuf_156[];
double gd_160;

int init() {
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, LineWidth + 2);
   SetIndexStyle(1, DRAW_LINE, LineStyle, LineWidth);
   SetIndexStyle(2, DRAW_LINE, LineStyle, LineWidth);
   SetIndexStyle(3, DRAW_LINE, LineStyle, LineWidth);
   SetIndexStyle(4, DRAW_LINE, LineStyle, LineWidth);
   SetIndexStyle(5, DRAW_LINE, LineStyle, LineWidth);
   SetIndexStyle(6, DRAW_LINE, LineStyle, LineWidth);
   SetIndexStyle(7, DRAW_LINE, LineStyle, LineWidth);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   SetIndexBuffer(0, g_ibuf_120);
   SetIndexBuffer(1, g_ibuf_124);
   SetIndexBuffer(2, g_ibuf_136);
   SetIndexBuffer(3, g_ibuf_140);
   SetIndexBuffer(4, g_ibuf_144);
   SetIndexBuffer(5, g_ibuf_148);
   SetIndexBuffer(6, g_ibuf_152);
   SetIndexBuffer(7, g_ibuf_156);
   SetIndexLabel(0, "Fibo 0.0 ");
   SetIndexLabel(1, "Fibo 1.00 ");
   SetIndexLabel(2, "Fibo 1.132 ");
   SetIndexLabel(3, "Fibo 1.272 ");
   SetIndexLabel(4, "Fibo 1.5 ");
   SetIndexLabel(5, "Fibo 2.0 ");
   SetIndexLabel(6, "Fibo 2.276 ");
   SetIndexLabel(7, "Fibo 2.618 ");
   if (WhichBand == MODE_UPPER) gd_160 = 1.0;
   else
      if (WhichBand == MODE_LOWER) gd_160 = -1.0;
   SetIndexDrawBegin(0, 0);
   SetIndexDrawBegin(1, 0);
   SetIndexDrawBegin(2, 0);
   SetIndexDrawBegin(3, 0);
   SetIndexDrawBegin(4, 0);
   SetIndexDrawBegin(5, 0);
   SetIndexDrawBegin(6, 0);
   SetIndexDrawBegin(7, 0);
   return (0);
}

int start() {
   int li_4 = IndicatorCounted();
   if (li_4 < 0) return (-1);
   if (li_4 > 0) li_4--;
   int li_0 = Bars - li_4;
   for (int li_8 = li_0; li_8 >= 0; li_8--) {
      g_ibuf_124[li_8] = iBands(NULL, g_timeframe_76, g_period_80, 2, 0, PRICE_CLOSE, WhichBand, GetShift(li_8, g_timeframe_76));
      g_ibuf_120[li_8] = iMA(NULL, g_timeframe_76, g_period_80, 0, MODE_SMA, PRICE_CLOSE, GetShift(li_8, g_timeframe_76));
      g_ibuf_136[li_8] = 1.132 * MathAbs(g_ibuf_124[li_8] - g_ibuf_120[li_8]) * gd_160 + g_ibuf_120[li_8];
      g_ibuf_140[li_8] = 1.272 * MathAbs(g_ibuf_124[li_8] - g_ibuf_120[li_8]) * gd_160 + g_ibuf_120[li_8];
      g_ibuf_144[li_8] = 1.5 * MathAbs(g_ibuf_124[li_8] - g_ibuf_120[li_8]) * gd_160 + g_ibuf_120[li_8];
      g_ibuf_148[li_8] = 2.0 * MathAbs(g_ibuf_124[li_8] - g_ibuf_120[li_8]) * gd_160 + g_ibuf_120[li_8];
      g_ibuf_152[li_8] = 2.276 * MathAbs(g_ibuf_124[li_8] - g_ibuf_120[li_8]) * gd_160 + g_ibuf_120[li_8];
      g_ibuf_156[li_8] = 2.618 * MathAbs(g_ibuf_124[li_8] - g_ibuf_120[li_8]) * gd_160 + g_ibuf_120[li_8];
   }
   return (0);
}

int GetShift(int ai_0, int a_timeframe_4) {
   return (iBarShift(NULL, a_timeframe_4, iTime(NULL, 0, ai_0), FALSE));
}