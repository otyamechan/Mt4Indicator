<chart>
id=130654214502880674
comment=■MagicalTouch(AlertMode=0) ライン情報■
symbol=USDJPY
period=60
leftpos=3416
digits=3
scale=8
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
window_left=208
window_top=208
window_right=1487
window_bottom=701
window_type=3
background_color=16777215
foreground_color=0
barup_color=0
bardown_color=0
bullcandle_color=16777215
bearcandle_color=0
chartline_color=0
volumes_color=32768
grid_color=12632256
askline_color=17919
stops_color=17919

<window>
height=100
fixed_height=0
<indicator>
name=main
<object>
type=1
object_name=MTSB1
period_flags=0
create_time=1420957955
color=255
style=0
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
value_0=116.512800
</object>
<object>
type=1
object_name=MTSB2
period_flags=0
create_time=1420957949
color=255
style=0
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
value_0=121.817200
</object>
<object>
type=2
object_name=MTSB3
period_flags=0
create_time=1420967159
color=255
style=0
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
time_0=1417809600
value_0=121.808933
time_1=1420488000
value_1=120.662547
ray=1
</object>
<object>
type=2
object_name=MTSB4
period_flags=0
create_time=1420967179
color=255
style=0
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
time_0=1417593600
value_0=119.385273
time_1=1420012800
value_1=118.238887
ray=1
</object>
<object>
type=1
object_name=MTSB5
period_flags=0
create_time=1420967203
color=32768
style=0
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
value_0=120.743787
</object>
<object>
type=1
object_name=MTSB6
period_flags=0
create_time=1420967221
color=32768
style=0
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
value_0=118.351720
</object>
<object>
type=1
object_name=MTSB7
period_flags=0
create_time=1420967261
color=36095
style=0
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
value_0=118.657800
</object>
<object>
type=1
object_name=MTSB8
period_flags=0
create_time=1420967318
color=16711680
style=0
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
value_0=119.824400
</object>
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=Otyame005_Super_Bollinger
flags=339
window_num=0
<inputs>
MAPeriod=21
_MAMethod=0:SMA 1:EMA 2:SMMA 3:LWMA
MAMethod=0
center_sen=true
sigma_1_sen=true
sigma_2_sen=true
sigma_3_sen=true
Chikou_sen=true
Chikou_Idou=-20
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=16711680
style_0=0
weight_0=2
shift_1=0
draw_1=0
color_1=32768
style_1=0
weight_1=2
shift_2=0
draw_2=0
color_2=32768
style_2=0
weight_2=2
shift_3=0
draw_3=0
color_3=255
style_3=0
weight_3=2
shift_4=0
draw_4=0
color_4=255
style_4=0
weight_4=2
shift_5=0
draw_5=0
color_5=16776960
style_5=0
weight_5=2
shift_6=0
draw_6=0
color_6=16776960
style_6=0
weight_6=2
shift_7=-20
draw_7=0
color_7=16711935
style_7=0
weight_7=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=MagicalTouch
flags=339
window_num=0
<inputs>
AlertMode=0
AlertKind=1
AlertRange=1
bDisplayInfo=1
bSendMail=1
ActiveMin=5
ActiveMax=1440
txSNS=【解説】
tx0= ※AlertMode アラートタイミング(0:少しでも出たら/1:現在の時間足の1つ前の足で判断)
tx1= ※AlertKind アラートモード(0:OFF/1:POPUP/2-9:音のみ)
tx1_2= ※AlertRange N個前の足以内でアラートしてたら出さない
tx2_1=　※bDisplayInfo ライン情報画面表示有無
tx2_2=　※bSendMail メール送信有無
tx3=ActiveMin ActiveMax の範囲（分）のチャートを表示中の場合だけアラートします
tx1000=※線の名前MT●●■■について
tx1001=●●エントリー方向(LB:LimitBuy/SB:StopBuy/LS:LimitSell/SS:StopSell)
tx1002=■■=1から50の番号(MT1とMTLS1のような同一番号はできません)
tx1011=例1）MT1 アラートのみ
tx1012=例2）MTLS1 LimitSellサイン
</inputs>
</expert>
shift_0=0
draw_0=3
color_0=14772545
style_0=0
weight_0=2
arrow_0=233
shift_1=0
draw_1=3
color_1=17919
style_1=0
weight_1=2
arrow_1=234
period_flags=0
show_data=1
</indicator>
</window>
</chart>

