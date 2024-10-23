class TailwindFormBuilder < ActionView::Helpers::FormBuilder

  def text_field(method, options = {})
    default_style = "w-full px-2.5 h-9 border border-gray-300 rounded-md shadow-sm text-[15px] focus:outline-none focus:ring-sky-500 focus:border-sky-500"

    super(method, options.merge({class: default_style}))
  end

  def email_field(method, options = {})
    default_style = "w-full px-2.5 h-9 border border-gray-300 rounded-md shadow-sm text-[15px] focus:outline-none focus:ring-sky-500 focus:border-sky-500"

    super(method, options.merge({class: default_style}))
  end

  def password_field(method, options = {})
    default_style = "w-full px-2.5 h-9 border border-gray-300 rounded-md shadow-sm text-[15px] focus:outline-none focus:ring-sky-500 focus:border-sky-500"

    super(method, options.merge({class: default_style}))
  end

  def text_area(method, options = {})
    default_style = "w-full px-2.5 py-1.5 border border-gray-300 rounded-md shadow-sm text-[15px] focus:outline-none focus:ring-sky-500 focus:border-sky-500"

    super(method, options.merge({class: default_style}))
  end

  def label(method, text = nil, options = {})
    default_style = "text-gray-800 font-medium text-[15px]"

    super(method, text, options.merge({class: default_style}))
  end

  def submit(value, options = {})
    default_style = "self-start inline-flex items-center justify-center px-4 h-9 bg-sky-500 text-white text-[15px] font-medium rounded-full hover:bg-sky-600 cursor-pointer"

    super(value, options.merge({class: default_style}))
  end

end