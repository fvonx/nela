module ApplicationHelper

  ActionView::Base.default_form_builder = TailwindFormBuilder

  def separator
    tag.hr class: "h-px bg-gray-200 border-0"
  end

  def link_button(name, type = "primary", path)
    link_to name, path, class: "inline-flex items-center justify-center px-4 py-1.5 bg-sky-500 text-white rounded-full hover:bg-sky-600"
  end

  def h1(text)
    tag.h1 text, class: "font-bold text-[40px] max-w-[580px] tracking-tight leading-tight" 
  end

  def h2(text)
    tag.h2 text, class: "font-semibold text-[26px] tracking-tight leading-tight" 
  end

  def h3(text)
    tag.h3 text, class: "font-semibold text-[18px] tracking-tight leading-tight" 
  end

  def h4(text)
    tag.h4 text, class: "font-semibold text-[16px] tracking-tight leading-tight" 
  end

  def paragraph(&block)
    tag.p(class: "text-gray-500 break-words", &block)
  end

  def section(&block)
    tag.section(class: "flex flex-col gap-y-4", &block)
  end

  def formatted_paragraph(text)
    simple_format(text, class: "text-gray-500 break-words")
  end

  def highlight(text, icon)
    tag.div(class: "w-full flex items-center gap-x-1 p-3 bg-orange-50 rounded-lg") do
      heroicon_tag(icon, class: "text-orange-500 w-[20px] h-[20px]") +
      tag.span(text)
    end
  end

  def handshake_icon(message)
    if message.handshaked?
      heroicon_tag "shield-check", class: "text-gray-800 w-[14px] h-[14px]"
    end
  end

  def back_to_button(path)
    link_to path, class: "fixed bottom-5 left-5 inline-flex items-center justify-center h-12 w-12 bg-gray-800 text-white rounded-full hover:bg-gray-950" do
      heroicon_tag "arrow-left", class: "w-[24px] h-[24px]"
    end
  end

  def form_group(direction = "column", &block)
    default_styles = "w-full flex"
    additional_styles = direction == "column" ? " flex-col gap-y-1" : " gap-x-2 items-center"
  
    tag.div(class: default_styles + additional_styles, &block)
  end

  def form_errors_for(resource)
    return unless resource.errors.any?

    content_tag :div, class: "flex flex-col gap-y-2 text-orange-500" do
      concat(content_tag(:h2, class: "flex items-center gap-x-1 gap-y-2 font-medium") do
        concat(heroicon_tag("face-frown", class: "text-orange-500 w-[20px] h-[20px]"))
        concat("Oops!")
      end)

      concat(content_tag(:ul) do
        resource.errors.full_messages.map do |message|
          concat(content_tag(:li, message))
        end.join.html_safe
      end)
    end
  end

end
