class ErrorHandlerService
  def self.handle_error(flash, error)
    flash[:error] = error.message
  end
end
