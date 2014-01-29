require 'net/http'
require 'uri'
load '/boot/uboot/settings/config.rb'  #config�ɋL�q����Ă�����e��ǂݍ���($place��)
File.open("port","r"){|f|
  uri=URI("http://mimamori-sensor.care-link.net:#{f.read}")#���M��URI�̐ݒ�
}

=begin
�f�W�^�����o�͂ɂ���
�ȉ��̗����GPIO�s���𗘗p���܂��B
1.�s���𗘗p�ł���悤�ɂ���
/sys/class/gpio/��GPIO�Ɋւ���f�B���N�g���ł��B
/sys/class/gpio/export�ɗ��p����s���̔ԍ����������ނƁA���̃s���̃f�B���N�g�����o�����܂��B
�R�}���h���C���Ȃ��
$echo 60 > /sys/class/gpio/export
�Ƃ����gpio����gpio60�Ƃ����f�B���N�g��������܂��B

�s������͂Ɏg�����o�͂Ɏg������direction�ɏ������ނ��ƂŐݒ肵�܂��B
"out"���������߂Ώo�͂ɁA"in"���������߂Γ��̓��[�h�ɂȂ�܂��B

�s���̏�Ԃ�value�t�@�C���ł��B
�o�̓��[�h��0��1���������߂΁AHigh-Low��؂�ւ����܂����A
���̓��[�h�ł���΁A0��1�������Ă���܂��B


�A�i���O���͂ɂ���
�A�i���O���͂�/sys/devices/ocp.2/helper.14/�̃f�B���N�g�����ɂ���܂��B
�������A���̃f�B���N�g���̓R�}���h���C����
$echo cape-bone-iio > /sys/devices/bone_capemgr.9/slots
�����Ȃ���Α��݂��܂���B
�����/etc/rc.local�ɋL�q���Ă��܂��̂Ńv���O�����ł͎��s���Ă��܂���B

�A�i���O���͒l��/sys/devices/ocp.2/helper.14/AIN*�ɋL�q���Ă���܂�
���̒l�̒P�ʂ̓~���{���g�ł��B
�����̃A�i���O�l��ǂݎ��ɂ�A/D�ϊ��̓s���㏭���҂��Ă��玟�̃s����
=end


=begin
#�f�W�^���o�͂̐ݒ�
#60�Ԃ�GPIOpin�𗘗p�ł���悤�ɂ���
File.open("/sys/class/gpio/export","w"){|f|
  f.print 60
}

#60�Ԃ�GPIOpin���o�̓��[�h�ɐݒ�
File.open("/sys/class/gpio/gpio60/direction","w"){|f|
  f.print "out"
}
=end

=begin 
#�A�i���O���͂̐ݒ�Brc.local�ɋL�q���Ă���Εs�v�B
File.open("/sys/devices/bone_capemgr.9/slots","w"){|f|
  f.print "cape-bone-iio"
}
=end


time =Time.now #���b�f�[�^�𑗐M���Ȃ����߂̎��ԃ`�F�b�N�p�ϐ�

Net::HTTP.start(uri.host,uri.port){|http|  #http�ڑ��J�n
  loop do  #loop�J�n

=begin #�f�W�^���o��
    #60�Ԃ�GPIOpin�ŏo�͂���
        File.open("/sys/class/gpio/gpio60/value","w"){|f|
          f.print 1
        }
=end



    #�Z���T�f�[�^�p�̕ϐ��錾
    brightness = Numeric.new

    #�A�i���O�Z���T�̒l�ǂݎ��
    #BeagleboneBlack�ł̓A�i���O�l��1800mV�܂ł̃~���{���g���ǂݎ���
    File::open("/sys/devices/ocp.2/helper.14/AIN0","r"){|f|
      brightness = f.read.to_i
    }
    #�܂��A�ʂ̃s������̃A�i���O�l��ǂݎ��ɂ́A�����҂K�v������
    sleep 1
    File::open("/sys/devices/ocp.2/helper.14/AIN1","r"){|f|
      brightness = f.read.to_i
    }

      if Time.now>(time+10) then #�O��f�[�^�𑗐M���Ă���10�b�ȏ�o�߂��Ă���΁A���̃f�[�^�𑗐M
        puts "send post req"
        body="client=#{$place}&data[temperature]=#{brightness.to_s}"
        res = http.post('/sensor/write',body) #�f�[�^post
        puts body #���M�f�[�^�̕\��
        time = Time.now #���M�����̃A�b�v�f�[�g
      end
      
    sleep 1 #��b�҂�
  end  #loop�����܂�
}