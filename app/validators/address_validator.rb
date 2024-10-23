class AddressValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless value && value =~ URI::MailTo::EMAIL_REGEXP
      record.errors.add(attribute, "'#{value}' is not a valid nela address")
    end
  end

end