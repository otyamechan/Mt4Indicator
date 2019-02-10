<chart>
symbol=GBPJPY
period=5
leftpos=2357
digits=3
scale=8
graph=1
fore=0
grid=0
volume=0
scroll=1
shift=0
ohlc=0
one_click=0
askline=1
days=0
descriptions=0
shift_size=20
fixed_pos=0
window_left=0
window_top=0
window_right=1133
window_bottom=745
window_type=1
background_color=0
foreground_color=16777215
barup_color=16748574
bardown_color=15631086
bullcandle_color=0
bearcandle_color=0
chartline_color=65535
volumes_color=3329330
grid_color=255
askline_color=255
stops_color=16711935

<window>
height=200
<indicator>
name=main
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=turbo-fx_v1.1
flags=339
window_num=0
<inputs>
Mail_M1=0
Mail_M5=0
Doten=1
HMA1_Period=12
HMA1_Method=3
HMA1_Price=0
HMA1_FilterNumber=1.70000000
HMA2_Period=240
HMA2_Method=2
HMA2_Price=0
HMA2_FilterNumber=2.00000000
QQE_SF=8
QQE_RSI_Period=8
QQE_DARFACTOR=3.60000000
QQE_BorderBuyUp=75
QQE_BorderBuyDn=50
QQE_BorderSellUp=50
QQE_BorderSellDn=25
QQE_BuyExit=80
QQE_SellExit=20
T3CCI_CCI_Period=14
T3CCI_T3_Period=2
T3CCI_b=0.61800000
T3CCI_BuyExit=100
T3CCI_SellExit=-100
ZIGZAG_ExtDepth=5
ZIGZAG_ExtDeviation=1
ZIGZAG_ExtBackstep=2
Filter_LastHighLow=0
MinProfitPips=10.00000000
MaxProfitPips=30.00000000
MaxLossPips=27.00000000
StopPips=2.00000000
ForceExitMinute=120
ForceExitProfitMin=14.00000000
ForceExitProfitMax=30.00000000
EnableSound=1
EnableAlert=1
SoundFileEntry=alert.wav
SoundFileExit=alert2.wav
SoundFileStop=stops.wav
ShowSignal=1
ShowStopLine=1
SignalColorBuy=65280
SignalColorSell=255
SignalColorBuyExit=65535
SignalColorSellExit=65535
SignalColorBuyStop=16711935
SignalColorSellStop=16711935
ArrowMargin=0.50000000
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=0
style_0=0
weight_0=0
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=58
<indicator>
name=Custom Indicator
<expert>
name=PST_QQE_v02
flags=339
window_num=1
<inputs>
SF=8
RSI_Period=8
DARFACTOR=3.60000000
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=16748574
style_0=0
weight_0=2
shift_1=0
draw_1=0
color_1=255
style_1=0
weight_1=0
levels_color=16777215
levels_style=2
levels_weight=1
level_0=20.0000
level_1=25.0000
level_2=50.0000
level_3=75.0000
level_4=80.0000
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=49
<indicator>
name=Custom Indicator
<expert>
name=T3_CCI_MOD
flags=339
window_num=2
<inputs>
CCI_Period=14
T3_Period=2
b=0.61800000
</inputs>
</expert>
shift_0=0
draw_0=12
color_0=16711680
style_0=0
weight_0=2
shift_1=0
draw_1=2
color_1=16748574
style_1=0
weight_1=3
shift_2=0
draw_2=2
color_2=255
style_2=0
weight_2=3
levels_color=16777215
levels_style=2
levels_weight=1
level_0=100.0000
level_1=200.0000
level_2=-100.0000
level_3=-200.0000
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=15
<indicator>
name=Custom Indicator
<expert>
name=HMA_BAR
flags=339
window_num=3
<inputs>
HMA1_Period=12
HMA1_Method=3
HMA1_Price=0
HMA1_FilterNumber=1.70000000
HMA2_Period=240
HMA2_Method=2
HMA2_Price=0
HMA2_FilterNumber=2.00000000
</inputs>
</expert>
shift_0=0
draw_0=3
color_0=16748574
style_0=0
weight_0=0
arrow_0=110
shift_1=0
draw_1=3
color_1=255
style_1=0
weight_1=0
arrow_1=110
shift_2=0
draw_2=3
color_2=16748574
style_2=0
weight_2=0
arrow_2=110
shift_3=0
draw_3=3
color_3=255
style_3=0
weight_3=0
arrow_3=110
min=0.000000
max=4.000000
period_flags=0
show_data=1
</indicator>
</window>
</chart>

