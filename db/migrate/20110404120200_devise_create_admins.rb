class DeviseCreateAdmins < ActiveRecord::Migration
  def self.up
    create_table(:admins) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      t.string :user_name
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      t.timestamps
    end
      #~ admin = Admin.create!(:username=>"JesseMa",:email=>"jessema@gmail.com", :password=>"getmocha", :password_confirmation=> "getmocha")
    #~ admin.save!
    add_index (:admins, [:email,:reset_password_token])
    #~ add_index :admins, , :unique => true
    # add_index :admins, :confirmation_token,   :unique => true
    # add_index :admins, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :admins
  end
end
