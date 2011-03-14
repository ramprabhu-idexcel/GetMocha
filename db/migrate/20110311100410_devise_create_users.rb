class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.string :first_name
      t.string :last_name
      t.string :title
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      t.string :phone
      t.string :mobile
      t.string :time_zone
      t.string :color
      t.boolean :status,:default=>true
      t.boolean :is_guest,:default=>false
      t.datetime :joined_date
      t.recoverable
      t.rememberable
      #t.trackable
      t.confirmable
      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :users
  end
end
