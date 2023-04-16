class Merchant < ApplicationRecord
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items

  def top_five_customers
    Customer.select('customers.*, COUNT(transactions.id) as transaction_count')
           .joins(invoices: [:transactions, :invoice_items => :item])
           .where("items.merchant_id = ? AND transactions.result = ?", self.id, 1)
           .group('customers.id')
           .order('transaction_count DESC')
           .limit(5)
  end

 def total_revenue
    invoices.joins(:transactions, :invoice_items)
            .where("transactions.result = 1")
            .group("invoices.id")
            .sum('invoice_items.unit_price * invoice_items.quantity')
            .values
            .sum
  end

  def self.top_five_merchants
          joins(invoices: [:transactions, :invoice_items])
          .where("transactions.result = 1")
          .group("merchants.id")
          .select('merchants.*, SUM(invoice_items.unit_price * invoice_items.quantity) as total_revenue')
          .order('total_revenue DESC')
          .limit(5)
          
  end

end