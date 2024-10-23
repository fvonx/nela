module ConversationsHelper

  def unread_indicator(conversation)
    unless conversation.up_to_date?
      tag.span class: "inline-block w-2 h-2 bg-sky-500 rounded-full"
    end
  end

  def tab_menu(params)
    link_css     = "inline-flex items-center justify-center px-4 py-1.5 font-medium rounded-full"
    active_css   = "#{link_css} bg-gray-800 text-white hover:bg-gray-950"
    inactive_css = "#{link_css} bg-gray-100 text-gray-800 hover:bg-gray-200"
  
    tag.div class: "inline-flex gap-x-1 self-start bg-gray-100 rounded-full p-1" do
      concat link_to("All Conversations", conversations_path, class: params[:filter].present? ? inactive_css : active_css)
      concat link_to("Unread Conversations", conversations_path(filter: :unseen), class: params[:filter].present? ? active_css : inactive_css)
    end
  end

  def new_conversation_button
    link_to new_conversation_path, class: "fixed bottom-5 right-5 inline-flex items-center justify-center h-12 w-12 bg-sky-500 text-white rounded-full hover:bg-sky-600" do
      heroicon_tag "plus", class: "w-[24px] h-[24px]"
    end
  end

  def back_to_conversations_button
    link_to conversations_path, class: "fixed bottom-5 left-5 inline-flex items-center justify-center h-12 w-12 bg-gray-800 text-white rounded-full hover:bg-gray-950" do
      heroicon_tag "arrow-left", class: "w-[24px] h-[24px]"
    end
  end

end
