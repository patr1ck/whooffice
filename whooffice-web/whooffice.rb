require 'sinatra'
require 'sinatra/activerecord'

class Employee < ActiveRecord::Base
  has_many :devices
end
  
class Device < ActiveRecord::Base
  belongs_to :employee
  has_many :device_in_offices
end
  
class DeviceInOffice < ActiveRecord::Base
  belongs_to :device
  belongs_to :office_status
end
  
class OfficeStatus < ActiveRecord::Base
  has_many :device_in_offices
  has_many :devices, :through => :device_in_offices
end

#
# GET /last_seen/:employee_name.json
# Returns the last datetime where the employee_name was in the office
# 

get '/last_seen/:employee_name.json' do
  employee = Employee.find_by_name(params[:employee_name])
  unless employee then return 404 end
  
  # We have all the devices here, so we need to search through the DeviceInOffice list to 
  devices_in_offices = []
  employee.devices.each do |device|
    devices_in_offices << DeviceInOffice.find_by_device_id(device.id, :order => "id desc", :limit => 1)
  end
  
  unless devices_in_offices.size > 0 then return 404 end
  
  sorted_devices = devices_in_offices.sort_by &:created_at
  return {"last_seen" => sorted_devices[0].created_at}.to_json
end


#
# GET /in_office.json
# Returns the names of employees currently in the office
# 

get '/in_office.json' do
  os = OfficeStatus.find(:all, :order => "id desc", :limit => 1, :include => [:devices])
  unless os then return 404 end
  
  employee_names = []
  os.first.devices.each do |device|
    employee_names << device.employee.name if device.employee
  end
  {"in_office" => employee_names.uniq, "time" => os.first.created_at}.to_json
end

#
# POST /in_office.json
# Takes a json dictionary with a "names" key, which has an array of device names, and stores them.
# 
    
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

#
# POST /set_device_owner/:device/:employee_name.json
# Sets :employee_name as the owner of :device. Creates any records that don't already exist.
# 
    
post '/set_device_owner/:device_name/:employee_name.json' do
  device = Device.find_or_create_by_name(params[:device_name])
  employee = Employee.find_or_create_by_name(params[:employee_name])
  
  device.employee = employee
  employee.save
  device.save

  "OK"
end

