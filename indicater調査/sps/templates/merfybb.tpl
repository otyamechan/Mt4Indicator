<chart>
id=130505539251386391
symbol=EURZAR
period=1440
leftpos=30
digits=5
scale=8
graph=1
fore=0
grid=0
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
window_left=52
window_top=52
window_right=1054
window_bottom=376
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
height=100
<indicator>
name=main
<object>
type=2
object_name=MT45
period_flags=0
create_time=1406080469
description=Buy
color=11193702
style=0
weight=2
background=0
filling=0
selectable=1
hidden=0
zorder=0
time_0=0
value_0=13.995771
time_1=1406073600
value_1=14.331095
ray=1
</object>
<object>
type=2
object_name=MT46
period_flags=0
create_time=1406080469
description=Take
color=11193702
style=0
weight=2
background=0
filling=0
selectable=1
hidden=0
zorder=0
time_0=0
value_0=14.464943
time_1=1406073600
value_1=14.800267
ray=1
</object>
<object>
type=2
object_name=MT47
period_flags=0
create_time=1406080469
color=11193702
style=2
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
time_0=0
value_0=14.230357
time_1=1406073600
value_1=14.565681
ray=1
</object>
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=Bands
flags=339
window_num=0
<inputs>
InpBandsPeriod=20
InpBandsShift=0
InpBandsDeviations=1.0
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=11186720
style_0=0
weight_0=0
shift_1=0
draw_1=0
color_1=36095
style_1=0
weight_1=0
shift_2=0
draw_2=0
color_2=36095
style_2=0
weight_2=0
period_flags=0
show_data=1
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=Bands
flags=339
window_num=0
<inputs>
InpBandsPeriod=20
InpBandsShift=0
InpBandsDeviations=2.0
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=65535
style_0=0
weight_0=2
shift_1=0
draw_1=0
color_1=255
style_1=0
weight_1=2
shift_2=0
draw_2=0
color_2=255
style_2=0
weight_2=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=1
shift=-21
method=0
apply=0
color=16711935
style=0
weight=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=PuTrendLine_D1
flags=339
window_num=0
<inputs>
collor=11193702
LineName1=MT45
LineName2=MT46
LineName3=MT47
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=255
style_0=0
weight_0=0
period_flags=0
show_data=1
</indicator>
</window>
</chart>

