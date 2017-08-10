class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.decimal :amount, null: false
      t.string :trx_type, null: false
      t.belongs_to :account, index: true, null: false
      t.timestamps
    end
  end
end
