<chart>
id=130575535127083489
comment=EA successfully activated. / EAの認証に成功しました。
symbol=EURUSD
period=5
leftpos=2109
digits=5
scale=16
graph=1
fore=0
grid=1
volume=0
scroll=1
shift=1
ohlc=1
one_click=0
askline=0
days=0
descriptions=0
shift_size=20
fixed_pos=0
window_left=182
window_top=182
window_right=1660
window_bottom=705
window_type=3
background_color=0
foreground_color=16777215
barup_color=65280
bardown_color=65280
bullcandle_color=0
bearcandle_color=16777215
chartline_color=65280
volumes_color=3329330
grid_color=10061943
askline_color=255
stops_color=255

<window>
height=142
<indicator>
name=main
<object>
type=23
object_name=IC_TrailingEA_0
period_flags=0
create_time=1413163185
description=[BreakEven] 有効: BreakEven=15; BreakEvenMargin=4
color=65280
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=30
</object>
<object>
type=23
object_name=IC_TrailingEA_1
period_flags=0
create_time=1413163185
description=[TrailingStop] 無効
color=255
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=44
</object>
<object>
type=23
object_name=IC_TrailingEA_2
period_flags=0
create_time=1413163185
description=[SwingBarTrailing] 有効
color=65280
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=58
</object>
<object>
type=23
object_name=IC_TrailingEA_3
period_flags=0
create_time=1413163185
description=SwingBarCount=3; SwingTimeframe=0
color=65280
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=72
</object>
<object>
type=23
object_name=IC_TrailingEA_4
period_flags=0
create_time=1413163185
description=SwingMargin=3; SwingTrailingStartsAt=10
color=65280
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=86
</object>
<object>
type=23
object_name=IC_TrailingEA_5
period_flags=0
create_time=1413163185
description=[AutoStopLoss] 有効: StopLoss=15
color=65280
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=100
</object>
<object>
type=23
object_name=IC_TrailingEA_6
period_flags=0
create_time=1413163185
description=[AutoTakeProfit] 無効
color=255
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=114
</object>
<object>
type=23
object_name=IC_TrailingEA_7
period_flags=0
create_time=1413163185
description=[EnableHLBandTrailing] 有効
color=65280
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=128
</object>
<object>
type=23
object_name=IC_TrailingEA_8
period_flags=0
create_time=1413163185
description=HLBandBarCount=5; HLBandTimeframe=0; HLBandSetCenter=false
color=65280
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=142
</object>
<object>
type=23
object_name=IC_TrailingEA_9
period_flags=0
create_time=1413163185
description=HLBandMargin=5; HLBandTrailingStartsAt=10
color=65280
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=156
</object>
<object>
type=23
object_name=IC_TrailingEA_10
period_flags=0
create_time=1413163185
description=[Email] 有効（日本語）
color=16777215
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=170
</object>
<object>
type=23
object_name=IC_TrailingEA_11
period_flags=0
create_time=1413163185
description=[Global] MinForcedStopLevel=5; ForcedStopLoss=50
color=16777215
font=Meiryo UI
fontsize=9
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=184
</object>
<object>
type=22
object_name=#33212352 sl modified 
period_flags=0
create_time=1413163876
color=65535
weight=1
background=0
symbol_code=4
anchor_pos=0
filling=0
selectable=1
hidden=0
zorder=0
time_0=1413174731
value_0=1.265630
</object>
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=IC_Trail_HLBands
flags=339
window_num=0
<inputs>
HLBarCount=5
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=16711680
style_0=0
weight_0=2
shift_1=0
draw_1=0
color_1=255
style_1=0
weight_1=2
shift_2=0
draw_2=0
color_2=16777215
style_2=0
weight_2=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=IC_Trail_SwingHL
flags=339
window_num=0
<inputs>
SwingBarCount=3
</inputs>
</expert>
shift_0=0
draw_0=3
color_0=16711680
style_0=0
weight_0=2
arrow_0=108
shift_1=0
draw_1=3
color_1=255
style_1=0
weight_1=2
arrow_1=108
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=8
<indicator>
name=Custom Indicator
<expert>
name=IC_OrderMail
flags=339
window_num=1
<inputs>
BETWEEN=15
MAIL_SUBJECT=MetaTrader4 Status
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

<expert>
name=IC_TrailingEA
flags=343
window_num=0
<inputs>
s1== SwingBarTrailingStop Settings =====
EnableSwingBarTrailing=true
SwingBarCount=3
SwingTimeframe=0
SwingMargin=3
SwingTrailingStartsAt=10
s2== HLBandTrailingStop Settings =====
EnableHLBandTrailing=true
HLBandBarCount=5
HLBandTimeframe=0
HLBandSetCenter=false
HLBandMargin=5
HLBandTrailingStartsAt=10
s3== TrailingStop Settings =====
EnableTrailingStop=false
TrailingStop=15.0
TrailingStep=3.0
TrailingStartsAt=15.0
s4== BreakEven Settings =====
EnableBreakEven=true
BreakEven=15.0
BreakEvenMargin=4.0
s5== AutoStopLoss Settings =====
EnableAutoStopLoss=true
StopLoss=15
s6== TakeProfit Settings =====
EnableAutoTakeProfit=false
TakeProfit=20
s7== Email Settings =====
EnableMail=true
SetMailEnglish=false
s8== Common Settings =====
MinForcedStopLevel=5
ForcedStopLoss=50
LabelCorner=0
</inputs>
</expert>
</chart>

