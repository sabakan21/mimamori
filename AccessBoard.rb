require 'net/http'
require 'uri'
load '/boot/uboot/settings/config.rb'  #configに記述されている内容を読み込む($place等)
File.open("port","r"){|f|
  uri=URI("http://mimamori-sensor.care-link.net:#{f.read}")#送信先URIの設定
}

=begin
デジタル入出力について
以下の流れでGPIOピンを利用します。
1.ピンを利用できるようにする
/sys/class/gpio/がGPIOに関するディレクトリです。
/sys/class/gpio/exportに利用するピンの番号を書き込むと、そのピンのディレクトリが出現します。
コマンドラインならば
$echo 60 > /sys/class/gpio/export
とするとgpio内にgpio60というディレクトリが現れます。

ピンを入力に使うか出力に使うかはdirectionに書き込むことで設定します。
"out"を書き込めば出力に、"in"を書き込めば入力モードになります。

ピンの状態はvalueファイルです。
出力モードで0か1を書き込めば、High-Lowを切り替えられますし、
入力モードであれば、0か1が書いてあります。


アナログ入力について
アナログ入力は/sys/devices/ocp.2/helper.14/のディレクトリ内にあります。
ただし、このディレクトリはコマンドラインで
$echo cape-bone-iio > /sys/devices/bone_capemgr.9/slots
をしなければ存在しません。
今回は/etc/rc.localに記述していますのでプログラムでは実行していません。

アナログ入力値は/sys/devices/ocp.2/helper.14/AIN*に記述してあります
この値の単位はミリボルトです。
複数のアナログ値を読み取るにはA/D変換の都合上少し待ってから次のピンを
=end


=begin
#デジタル出力の設定
#60番のGPIOpinを利用できるようにする
File.open("/sys/class/gpio/export","w"){|f|
  f.print 60
}

#60番のGPIOpinを出力モードに設定
File.open("/sys/class/gpio/gpio60/direction","w"){|f|
  f.print "out"
}
=end

=begin 
#アナログ入力の設定。rc.localに記述してあれば不要。
File.open("/sys/devices/bone_capemgr.9/slots","w"){|f|
  f.print "cape-bone-iio"
}
=end


time =Time.now #毎秒データを送信しないための時間チェック用変数

Net::HTTP.start(uri.host,uri.port){|http|  #http接続開始
  loop do  #loop開始

=begin #デジタル出力
    #60番のGPIOpinで出力する
        File.open("/sys/class/gpio/gpio60/value","w"){|f|
          f.print 1
        }
=end



    #センサデータ用の変数宣言
    brightness = Numeric.new

    #アナログセンサの値読み取り
    #BeagleboneBlackではアナログ値は1800mVまでのミリボルトが読み取れる
    File::open("/sys/devices/ocp.2/helper.14/AIN0","r"){|f|
      brightness = f.read.to_i
    }
    #また、別のピンからのアナログ値を読み取るには、少し待つ必要がある
    sleep 1
    File::open("/sys/devices/ocp.2/helper.14/AIN1","r"){|f|
      brightness = f.read.to_i
    }

      if Time.now>(time+10) then #前回データを送信してから10秒以上経過していれば、次のデータを送信
        puts "send post req"
        body="client=#{$place}&data[temperature]=#{brightness.to_s}"
        res = http.post('/sensor/write',body) #データpost
        puts body #送信データの表示
        time = Time.now #送信時刻のアップデート
      end
      
    sleep 1 #一秒待つ
  end  #loopここまで
}