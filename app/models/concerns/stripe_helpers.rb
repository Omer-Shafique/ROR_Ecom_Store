module StripeHelpers
  def self.construct_metadata(user_name, user_email, image_url)
    {
      "Name" => user_name,
      "Email" => user_email,
      "Product Image" => image_url
    }
  end
end
