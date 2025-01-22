module ApplicationHelper
  include RichTextHelper

  def flash_class(type)
    case type.to_sym
    when :notice
      "flash-notice"
    when :alert
      "flash-alert"
    when :info
      "flash-info"
    when :warning
      "flash-warning"
    else
      "flash-notice"
    end
  end
end
