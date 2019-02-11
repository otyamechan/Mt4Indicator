//�v���v���Z�b�T���߁i�v���O�����̐ݒ�j
#property  copyright "�Ƃ��"
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

//�`��p�z��̐錾
double indicator1[];
double indicator2[];
double indicator3[];

//�O���p�����[�^�̐錾
extern int TimeFrame = 60;
//�O���[�o���ϐ��̐錾
int Mult = 10;

//--------------------------------------------------------------------------------------------------------+
//����������                                                                                              |
//--------------------------------------------------------------------------------------------------------+
int init(){
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(0, indicator1);
   SetIndexBuffer(1, indicator2);
   SetIndexBuffer(2, indicator3);
   SetIndexLabel(1, "�v�Z����:1");
   SetIndexLabel(2, "�v�Z����:2");
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

//�`�攻��
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

