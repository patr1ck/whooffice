require 'sinatra'
require 'sinatra/activerecord'

class Employee < ActiveRecord::Base
  has_many :devices
end
  
class Device < ActiveRecord::Base
  belongs_to :employee
end
  
class DeviceInOffice < ActiveRecord::Base
  belongs_to :device
  belongs_to :office_status
end
  
class OfficeStatus < ActiveRecord::Base
  has_many :device_in_offices
  has_many :devices, :through => :device_in_offices
end

get '/in_office.json' do
  os = OfficeStatus.find(:all, :order => "id desc", :limit => 1, :include => [:devices] )
  puts "os devices: " + os[0].devices.inspect
  
  os.to_json(:include => :devices)
end
    
post '/in_office.json' do
  request.body.rewind 
  devicesList = JSON.parse request.body.read
  
  # ewot
  devices_in_office = []
  status = OfficeStatus.new
  status.save
  devicesList["names"].each do |device_name|
    device = Device.find_or_create_by_name(device_name)
    device.save
    device_in_office = DeviceInOffice.new(:device => device, :office_status => status)
    device_in_office.save
    devices_in_office << device_in_office
  end
  status.device_in_offices = devices_in_office
  status.save
    
  "OK"
end
