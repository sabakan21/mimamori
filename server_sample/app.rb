# -*- coding: utf-8 -*-
#
# Sinatra がインストールされている必要があります
# 実行は「ruby app.rb」です
#

require 'sinatra'
require 'active_record'
require 'erb'


# ActiveRecord設定
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')
# AccessBoardの名称
class Client < ActiveRecord::Base
end
# AccessBoardのセンサ値
class Sensor < ActiveRecord::Base
end
# AccessBoardの制御用
class Control < ActiveRecord::Base
end


set :bind, '172.20.0.2'

post '/sensor/write' do
  #
  #  puts "client: #{params[:client]}"
  #  puts "data: #{params[:data]}"
  #  puts "key: #{params[:key]}"
  #  $stdout.flush
  #  "client: #{params[:client]} data: #{params[:data]} key: #{params[:key]}"
  #
  #client = params[:client]
  #key = params[:key]
  #data = params[:data]
  #if Client.find_by_client(client) then
  #  Sensor.create(:client => client, :key => key, :data => data, :date => Time.now)
    puts request.body.read
  #  'ok'
  #else
  #  'error'
  #end
end

get '/service/read/:client/:key' do
  #
  #  File.open("./#{params[:name]}","r"){|f| #nameと同じ名前のファイルに返す値が書いてあります
  #    "#{f.read}"
  #  }
  #
  ## 制御する対象は，クライアントごとに必要なので，clientもパラメータとします
  client = params[:client]
  key = params[:key]
  control = Control.where(client: client, key: key).first
  if control then
    control.data
  else
    'error'
  end
end

# client = "xxxxx id"
# data = [ {:sensor1 => 10}, {:sensor2 => 34}, {:sensorX => "ABCD"} ]
# key = "XXXXXX"
#
# 
# curl コマンドが使えるなら，以下でサーバのテストができます
# http://localhost:4567/ は適切に変えてください
# curl http://localhost:4567/service/read -X GET -d "client=c1" -d "data=sensor"# 


#
# Webでのアクセス用
#
# データベース
#
=begin
create table clients (
  client text,
  memo text,
  primary key (client)
);

create table sensors (
  id integer primary key autoincrement,
  client text,
  key text,
  data text,
  date datetime
);

create table controls (
  client text,
  data text,
  key text,
  primary key (client,data)
);
=end
#
# サンプルデータ
#
=begin
insert into clients (client,memo) values ("test01", "テスト01");
insert into clients (client,memo) values ("test02", "テスト02");

insert into controls (client,key,data) values ("test01","led01","0");
insert into controls (client,key,data) values ("test01","led02","1");

=end


get '/' do
  erb :index
end

get '/list' do
  @clients = Client.find(:all)
  erb :list
end

post '/client_add' do
  client = params[:client]
  memo = params[:memo]
  unless Client.find_by_client(client) then
    Client.create(:client => client, :memo => memo)
    redirect '/list'
  else
    'エラー： すでに登録されています'
  end
end

get '/detail' do
  client = params[:client]
  @client = Client.where(client: client).first
  @sensors = Sensor.where(client: client).order(date: :desc).take(50)
  @controls = Control.where(client: client).take(50)
  erb :detail
end

post '/control_update' do
  client = params[:client]
  "まだ作っていない"
  request.body # => client=test01&led01=0&led02=1
  #find method で書き換えたいレコードを取得
  #
  Control.find_all_by_client(params[:client])
  #update　メソッドで取得したレコードオブジェクトを書き換える
end

