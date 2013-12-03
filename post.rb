require 'net/http'
require 'uri'
load '/boot/uboot/settings/config.rb'
uri=URI('http://172.20.0.2:4567')

File.open("/sys/class/gpio/export","w"){|f|
  f.print 60
}
File.open("/sys/class/gpio/gpio60/direction","w"){|f|
  f.print "out"
}

time = Time.now

Net::HTTP.start(uri.host,uri.port){|http|
  loop do
    data=-1
    File::open("/sys/devices/ocp.2/helper.14/AIN0","r"){|f|
      data= f.read.to_i
    }

    if Time.now>time then
      puts "send post req"
      body="client=#{$place}&data=#{data.to_s}&key=thermo"
      res = http.post('/service/write',body,{"user-agent"=>"RUBY"})
      puts res.body
      time = Time.now+5
    end
    
    puts "send get led req"
    res = http.get("/service/read/#{$place}/led01")
    puts res.body
    File.open("/sys/class/gpio/gpio60/value","w"){|f|
      f.print res.body
    }
    sleep 1
  end
}

