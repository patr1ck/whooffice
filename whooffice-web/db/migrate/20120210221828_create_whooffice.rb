class CreateWhooffice < ActiveRecord::Migration
  def self.up
    create_table Employee.table_name do |t|
      t.string :name
    end
      
    create_table Device.table_name do |t|
      t.string :name
      t.references :employee
    end 
      
    create_table DeviceInOffice.table_name do |t|
      t.references :device
      t.references :office_status
      t.timestamps
    end
      
    create_table OfficeStatus.table_name do |t|
      t.timestamps
    end     
  end

  def self.down
    drop_table Employee.table_name
    drop_table Device.table_name
    drop_table DeviceInOffice.table_name
    drop_table OfficeStatus.table_name
  end
end