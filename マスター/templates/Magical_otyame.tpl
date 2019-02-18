<chart>
id=130678634827365426
comment=■MagicalTouch(AlertMode=0) ライン情報■
symbol=EURUSD
period=240
leftpos=7752
digits=5
scale=8
graph=1
fore=1
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
window_left=0
window_top=0
window_right=864
window_bottom=381
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

