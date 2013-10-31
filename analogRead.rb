require 'net/http'
require 'uri'
load '/boot/uboot/settings/config.rb'
uri=URI('http://172.20.100.1:4567')

Net::HTTP.start(uri.host,uri.port){|http|
  loop do 
    data=[]
    File::open("/sys/devices/ocp.2/helper.14/AIN0","r"){|f|
      data << {:sensor1 =>f.read}
    } 
    puts "send post req"
    body="client=\"#{$place}\sid\"&data=#{data.to_s}&key=\"PassPhrase\""
    res = http.post('/service/write',body,{"user-agent"=>"RUBY"})
    puts res.body
    sleep 5
  end
}
