class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :account_type, null: false
      t.decimal :balance, default: 0, null: false
      t.integer :flag, default: 0, null: false
      t.boolean :is_suspended, default: false, null: false
      
      t.timestamps
    end
    
    add_index :accounts, [:name], unique: true
   
  end
end
