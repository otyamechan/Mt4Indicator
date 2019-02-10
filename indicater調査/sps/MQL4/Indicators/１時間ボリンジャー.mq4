//�v���v���Z�b�T���߁i�v���O�����̐ݒ�j
#property  copyright "�Ƃ��"
#property link "tombofx.blog.fc2.com"

#property indicator_chart_window
#property  indicator_buffers 5
#property  indicator_color1 Red
#property  indicator_color2 Green
#property  indicator_color3 Green
#property  indicator_color4 Red
#property  indicator_color5 Red
#property  indicator_width1 2
#property  indicator_width2 1
#property  indicator_width3 1
#property  indicator_width4 2
#property  indicator_width5 2
#property  indicator_style1 0
#property  indicator_style2 0
#property  indicator_style3 0
#property  indicator_style4 0
#property  indicator_style5 0

//�`��p�z��̐錾
double indicator1[];
double indicator2[];
double indicator3[];
double indicator4[];
double indicator5[];

//�O���p�����[�^�̐錾
extern int TimeFrame = 60;
//�O���[�o���ϐ��̐錾
int Mult = 10;

//--------------------------------------------------------------------------------------------------------+
//����������                                                                                              |
//--------------------------------------------------------------------------------------------------------+
int init(){
   IndicatorBuffers(5);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(0, indicator1);
   SetIndexBuffer(1, indicator2);
   SetIndexBuffer(2, indicator3);
   SetIndexBuffer(3, indicator4);
   SetIndexBuffer(4, indicator5);
   SetIndexLabel(1, "�v�Z����:1");
   SetIndexLabel(2, "�v�Z����:2");
   SetIndexLabel(3, "�v�Z����:3");
   SetIndexLabel(4, "�v�Z����:4");
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
 
extern int Band_Period18 = 24;
extern int Band_Deviation18 = 1;
extern int Band_Slide18 = 0;
extern int Band_Shift18 = 0; 
 
extern int Band_Period17 = 24;
extern int Band_Deviation17 = 1;
extern int Band_Slide17 = 0;
extern int Band_Shift17 = 0; 
 
extern int Band_Period16 = 24;
extern int Band_Deviation16 = 1;
extern int Band_Slide16 = 0;
extern int Band_Shift16 = 0; 
 
extern int Band_Period15 = 24;
extern int Band_Deviation15 = 2;
extern int Band_Slide15 = 0;
extern int Band_Shift15 = 0; 
extern int Band_Period14 = 24;
extern int Band_Deviation14 = 2;
extern int Band_Slide14 = 0;
extern int Band_Shift14 = 0;
 
extern int Band_Period13 = 24;
extern int Band_Deviation13 = 2;
extern int Band_Slide13 = 0;
extern int Band_Shift13 = 0; 
int start(){
   int limit = Bars - IndicatorCounted();
   datetime TimeArray[];
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
   int i, y;
   for(i = 0, y = 0; i < Bars; i++){
      if(Time[i] < TimeArray[y]) y++;

      bool drawing1 = Drawing1(i);
      if(drawing1 == true){
         indicator1[i] = iBands(Symbol(), TimeFrame, Band_Period18, Band_Deviation18, Band_Slide18, PRICE_CLOSE, MODE_MAIN, y + Band_Shift18) ;
      }else{
         indicator1[i] = 0;
      }
      bool drawing2 = Drawing2(i);
      if(drawing2 == true){
         indicator2[i] = iBands(Symbol(), TimeFrame, Band_Period17, Band_Deviation17, Band_Slide17, PRICE_CLOSE, MODE_UPPER, y + Band_Shift17) ;
      }else{
         indicator2[i] = 0;
      }
      bool drawing3 = Drawing3(i);
      if(drawing3 == true){
         indicator3[i] = iBands(Symbol(), TimeFrame, Band_Period16, Band_Deviation16, Band_Slide16, PRICE_CLOSE, MODE_LOWER, y + Band_Shift16) ;
      }else{
         indicator3[i] = 0;
      }
      bool drawing4 = Drawing4(i);
      if(drawing4 == true){
         indicator4[i] = iBands(Symbol(), TimeFrame, Band_Period15, Band_Deviation15, Band_Slide15, PRICE_CLOSE, MODE_UPPER, y + Band_Shift15) ;
      }else{
         indicator4[i] = 0;
      }
      bool drawing5 = Drawing5(i);
      if(drawing5 == true){
         indicator5[i] = iBands(Symbol(), TimeFrame, Band_Period13, Band_Deviation13, Band_Slide13, PRICE_CLOSE, MODE_LOWER, y + Band_Shift13) ;
      }else{
         indicator5[i] = 0;
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
bool Drawing4(int i){
   bool draw = true;
   return(draw);
}
bool Drawing5(int i){
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

