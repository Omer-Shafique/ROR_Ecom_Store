class FlashMessageService
  def self.success!(flash, message)
    flash[:success] = message
  end

  def self.error!(flash, message)
    flash[:error] = message
  end
end
