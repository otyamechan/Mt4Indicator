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
 
extern int Band_Period3 = 20;
extern int Band_Deviation3 = 1;
extern int Band_Slide3 = 0;
extern int Band_Shift3 = 0;  
extern int Band_Period4 = 20;
extern int Band_Deviation4 = 1;
extern int Band_Slide4 = 0;
extern int Band_Shift4 = 0; 
 
extern int Average_Period2 = 10;
extern int Average_Shift2 = 1; 
int start(){
   int limit = Bars - IndicatorCounted();
   datetime TimeArray[];
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
   int i, y;
   for(i = 0, y = 0; i < Bars; i++){
      if(Time[i] < TimeArray[y]) y++;

      bool drawing1 = Drawing1(i);
      if(drawing1 == true){
         indicator1[i] = iBands(Symbol(), TimeFrame, Band_Period3, Band_Deviation3, Band_Slide3, PRICE_CLOSE, MODE_UPPER, y + Band_Shift3) - iBands(Symbol(), TimeFrame, Band_Period4, Band_Deviation4, Band_Slide4, PRICE_CLOSE, MODE_LOWER, y + Band_Shift4) ;
      }else{
         indicator1[i] = 0;
      }
   }
   datetime TimeArray2[];
   ArrayCopySeries(TimeArray2, MODE_TIME, Symbol(), TimeFrame);
   int i2, y2;
   for(i2 = 0, y2 = 0; i2 < Bars; i2++){
      if(Time[i2] < TimeArray2[y2]) y2++;

      bool drawing2 = Drawing2(i2);
      if(drawing2 == true){
         indicator2[i2] = iMAOnArray(indicator1, 0, Average_Period2, 0, MODE_SMA, y2 + Average_Shift2) ;
      }else{
         indicator2[i2] = 0;
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

