//�v���v���Z�b�T���߁i�v���O�����̐ݒ�j
#property  copyright "�Ƃ��"
#property link "tombofx.blog.fc2.com"

#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1 Red
#property  indicator_color2 Blue
#property  indicator_width1 1
#property  indicator_width2 1
#property  indicator_style1 0
#property  indicator_style2 0
#property indicator_level1 0
#property indicator_levelcolor White
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

//�`��p�z��̐錾
double indicator1[];
double indicator2[];

//�O���p�����[�^�̐錾
extern int TimeFrame = 60;
//�O���[�o���ϐ��̐錾
int Mult = 10;

//--------------------------------------------------------------------------------------------------------+
//����������                                                                                              |
//--------------------------------------------------------------------------------------------------------+
int init(){
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(0, indicator1);
   SetIndexBuffer(1, indicator2);
   SetIndexLabel(1, "�v�Z����:1");
   IndicatorDigits(Digits);

   MultCal();

   return(0);
}
//--------------------------------------------------------------------------------------------------------+
//�I������                                                                                                |
//--------------------------------------------------------------------------------------------------------+
int deinit(){
   return(0);
}

//--------------------------------------------------------------------------------------------------------+
//���C������                                                                                              |
//--------------------------------------------------------------------------------------------------------+
 
extern int MACD_Fast_EMA_Period11 = 12;
extern int MACD_Slow_EMA_Period11 = 26;
extern int MACD_Signal_Period11 = 9;
extern int MACD_Shift11 = 0; 
 
extern int MACD_Fast_EMA_Period12 = 12;
extern int MACD_Slow_EMA_Period12 = 26;
extern int MACD_Signal_Period12 = 9;
extern int MACD_Shift12 = 0; 
int start(){
   int limit = Bars - IndicatorCounted();
   datetime TimeArray[];
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
   int i, y;
   for(i = 0, y = 0; i < Bars; i++){
      if(Time[i] < TimeArray[y]) y++;

      bool drawing1 = Drawing1(i);
      if(drawing1 == true){
         indicator1[i] = iMACD(Symbol(), TimeFrame, MACD_Fast_EMA_Period11, MACD_Slow_EMA_Period11, MACD_Signal_Period11, PRICE_CLOSE, MODE_MAIN, y + MACD_Shift11) ;
      }else{
         indicator1[i] = 0;
      }
      bool drawing2 = Drawing2(i);
      if(drawing2 == true){
         indicator2[i] = iMACD(Symbol(), TimeFrame, MACD_Fast_EMA_Period12, MACD_Slow_EMA_Period12, MACD_Signal_Period12, PRICE_CLOSE, MODE_SIGNAL, y + MACD_Shift12) ;
      }else{
         indicator2[i] = 0;
      }
   }

   return(0);
}

//�`�攻��
bool Drawing1(int i){
   bool draw = true;
   return(draw);
}
bool Drawing2(int i){
   bool draw = true;
   return(draw);
}

//--------------------------------------------------------------------------------------------------------+
//���[�g�̌����Ή��֐�                                                                                    |
//   ����:�u���[�J�[���z�M���郌�[�g�̏����_�ȉ��̌������m�F���A                                          |
//        �O���[�o���ϐ� Mult �̒l��K���l�ɐݒ肷��B                                                    |
//   ����:����                                                                                            |
//   �߂�l:����                                                                                          |
//--------------------------------------------------------------------------------------------------------+
void MultCal(){
   if(Digits == 4 || Digits == 2) Mult = 1;
   if(Digits == 5 || Digits == 3) Mult = 10;
}

