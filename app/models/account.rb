class Account < ApplicationRecord
    has_many :transactions

    validates :name, uniqueness: true
    validates :name, :account_type, presence: true
    
    def deposit(amount)
        if !amount.is_a?Numeric
            self.errors.add(:amount, 'Not a Number') 
            return
        end
        self.errors.add(:amount, 'Less than Zzero') if amount <= 0
        return if self.errors.any?
       
        ActiveRecord::Base.transaction do
            self.update!(balance: self.balance + amount)
        
            Transaction.create!(amount: amount, trx_type: 'Deposit', account_id: self.id)
        end
    end
end
