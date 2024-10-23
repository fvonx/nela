class AddressArrayValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return unless value.is_a?(Array)

    value.each do |email|
      unless email =~ URI::MailTo::EMAIL_REGEXP
        record.errors.add(attribute, "'#{email}' is not a valid email address")
      end
    end
  end

end