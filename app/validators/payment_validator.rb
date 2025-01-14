class PaymentValidator
  def self.successful?(charge)
    charge.status == 'succeeded'
  end
end
