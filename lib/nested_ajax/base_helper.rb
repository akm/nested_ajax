# -*- coding: utf-8 -*-
require 'nested_ajax'

module NestedAjax
  module BaseHelper

    def nested_ajax_pane(object_or_object_name = nil, options = {}, &block)
      pane = eval("cascading_nested_ajax_pane ||= nil", Proc.new(&block).binding)
      # NestedAjax::Pane::AbstractPane.renderで描画されているブロック中ならば
      # ローカル変数 cascading_nested_ajax_pane にPaneが設定されているはずです。
      # もしそれがなかったらここで用意します。
      unless pane
        object, object_name = nil, nil
        if object_or_object_name.is_a?(String) || object_or_object_name.is_a?(Symbol)
          object_name = object_or_object_name
          object = self.instance_variable_get("@#{object_name}")
        else
          object = object_or_object_name
          object_name = object.class.name.underscore
        end
        options = {
          :form_name => params[:nested_ajax] ? params[:nested_ajax][:form_name] : nil,
          :object_name => object_name,
          # 現在実行中のコントローラ名をデフォルトで使用してるけど、
          :controller => self.controller_name 
          # :controller => object_name.to_s.singularize # の方がいいかな？うーん微妙
        }
        logger.debug("nested_ajax_pane options => #{options.inspect}")
        options.update(options || {})
        pane = Pane::SinglePane.new(self, object, options)
      end
      yield(pane) if block_given?
    end

    def nested_ajax_options
      @nested_ajax_options ||= params[:nested_ajax] || HashWithIndifferentAccess.new
    end
    

    
    FLASH_MESSAGE_COLORS = { 
      :notice => 'green',
      :warn => '#FF8C00',
      :error => 'red',
    }
    
    FLASH_MESSAGE_ID_PREFIX = "nested_ajax_flash_message"

    # flashのメッセージを表示するための領域を出力します。
    def flash_message_for(*args)
      options = args.extract_options!
      tag_name = options.delete(:tag_name) || 'p'
      tags = args.map do |key|
        options[:style] = "color: #{FLASH_MESSAGE_COLORS[key.to_sym]}" if options.empty?
        options.update(:id => "#{FLASH_MESSAGE_ID_PREFIX}_#{key.to_s}")
        content_tag(tag_name, flash[key] || ' ', options)
      end
      tags.join
    end

    def ajax_flash_message_for(*args)
      options = args.extract_options!
      effect = options[:effect]
      update_page_tag do |page|
        args.each do |key|
          page.replace_html("#{FLASH_MESSAGE_ID_PREFIX}_#{key.to_s}", flash[key])
        end
        if effect
          args.each do |key|
            page.visual_effect(effect, "#{FLASH_MESSAGE_ID_PREFIX}_#{key.to_s}")
          end
          if nested_ajax_options[:pane_id]
            page.visual_effect(effect, nested_ajax_options[:pane_id]) 
          end
        end
      end
    end

  end
end
