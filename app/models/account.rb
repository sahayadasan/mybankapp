class Account < ApplicationRecord
    has_many :transactions

    validates :name, uniqueness: true
    validates :name, :account_type, presence: true
    
    after_save :check_suspension
    
    def deposit(amount)
        return if amount_is_not_valid(amount)
        
        ActiveRecord::Base.transaction do
            self.update!(balance: self.balance + amount)
            Transaction.create!(amount: amount, trx_type: 'Deposit', account_id: self.id)
        end
    end
    
    def withdraw(amount)
        return if amount_is_not_valid(amount)
        
        return if is_account_suspended().any?
        
        
        if self.balance >= amount
            ActiveRecord::Base.transaction do
                self.update!(balance: self.balance - amount)
                Transaction.create!(amount: amount, trx_type: 'withdraw', account_id: self.id)
            end
        else
            ActiveRecord::Base.transaction do
                fee = 50
                self.update!(balance: self.balance - fee, flag: self.flag + 1)
                Transaction.create!(amount: fee, trx_type: 'Overdraft', account_id: self.id)
    
         end
        
        end
    end
    
    def deposits
        self.transaction.where(:trx_type, 'Deposit')
    end
    
    def withdraws
        self.transaction.where(:trx_type, 'Withdraw')
    end
    
    def overdrafts
        self.transaction.where(:trx_type, 'Overdraft')
    end
    
    def clear_suspension
        return if insufficient_fund
        ActiveRecord::Base.transaction do
            fee = 100
            self.update!(balance: self.balance - fee, is_suspended: false)
            Transaction.create!(amount: fee, trx_type: 'Unfreeze', account_id: self.id)
        end
    end
    
    
    private
    def amount_is_not_valid(amount)
        if !amount.is_a?Numeric
            self.errors.add(:amount, 'Not a Number') 
            return
        end
        self.errors.add(:amount, 'Less than Zero') if amount <= 0
        return self.errors.any?
    end
    def check_suspension
        if self.flag > 3
            self.update!(is_suspended: true, flag: 0)
        end
    end
    
    def is_account_suspended
        if self.is_suspended
            self.errors.add(:is_suspended, 'Account is Suspended')
        end
    end
    
    def insufficient_funds
        self.errors.add(:is_suspended, 'Does not have suffieient funds') if self.balance < 100
            
    end
end
