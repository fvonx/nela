module MessagesHelper

  def avatar(address)
    css = "inline-flex items-center shrink-0 justify-center w-10 h-10 bg-gray-100 text-gray-950 font-medium rounded-full"
    css += " ring-offset-2 ring-1 ring-gray-800" if current_user.address == address

    tag.span address[0].upcase, class: css
  end

  def addresses_group(addresses)
    displayed_addresses = addresses.take(3)
    remaining_count     = addresses.size - displayed_addresses.size
    address_string      = displayed_addresses.join(', ')

    if remaining_count > 0
      address_string += ", +#{remaining_count}"
    end

    address_string
  end

end
