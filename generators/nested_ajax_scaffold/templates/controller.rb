# -*- coding: utf-8 -*-
class <%= controller_class_name %>Controller < ApplicationController
  include NestedAjax::RenderExt

  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  def index
    @<%= controller_plural_name %> = <%= class_name %>.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= controller_plural_name %> }
    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  def show
    @<%= controller_singular_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= controller_singular_name %> }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  def new
    @<%= controller_singular_name %> = <%= class_name %>.new(params[:<%= controller_singular_name %>])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= controller_singular_name %> }
    end
  end

  # GET /<%= table_name %>/1/edit
  def edit
    @<%= controller_singular_name %> = <%= class_name %>.find(params[:id])
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    @<%= controller_singular_name %> = <%= class_name %>.new(params[:<%= controller_singular_name %>])

    respond_to do |format|
      if @<%= controller_singular_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { render_if_xhr(:action => 'show') || redirect_to(:action => 'show', :id => @<%= controller_singular_name %>.id) }
        format.xml  { render :xml => @<%= controller_singular_name %>, :status => :created, :location => @<%= controller_singular_name %> }
      else
        format.html { render_if_xhr(:action => 'new') || render(:action => "new") }
        format.xml  { render :xml => @<%= controller_singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= controller_singular_name %> = <%= class_name %>.find(params[:id])
    
    respond_to do |format|
      if @<%= controller_singular_name %>.update_attributes(params[:<%= controller_singular_name %>])
        # belongs_to, has_one, has_many などの関連のキャッシュをクリアしておきます
        @<%= controller_singular_name %>.clear_association_cache
        # composed_of などの集約のキャッシュをクリアしておきます
        @<%= controller_singular_name %>.clear_aggregation_cache
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.html { render_if_xhr(:action => 'show') || redirect_to(:action => 'show', :id => @<%= controller_singular_name %>.id) }
        format.xml  { head :ok }
      else
        format.html { render_if_xhr(:action => 'edit') || render(:action => "edit") }
        format.xml  { render :xml => @<%= controller_singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    @<%= controller_singular_name %> = <%= class_name %>.find(params[:id])
    @<%= controller_singular_name %>.destroy
    flash[:notice] = '<%= class_name %> was successfully deleted.'
    respond_to do |format|
      # いきなりザクッと消したい場合はこんな感じで。ただし例外発生時に何も分からなくなるので、
      # 例外のメッセージをinlineでrenderする必要があるかもしれませんので、ご注意を。
      # format.html { render_if_xhr(:inline => '') || redirect_to(party_emails_url) }
      # エフェクトをかけたい場合はこんな感じ。
      format.html { render_if_xhr(:action => 'show') || redirect_to(:action => 'index') }
      format.xml  { head :ok }
    end
  end

  # GET /<%= table_name %>/name
  # GET /<%= table_name %>/names.xml
  # GET /<%= table_name %>/names.json
  def names
    <%= controller_plural_name %> = <%= class_name %>.find_with_name(params[:name])
    result = <%= controller_plural_name %>.map{|<%= controller_singular_name %>|
      [<%= controller_singular_name %>.name_for_nested_ajax, <%= controller_singular_name %>.id] }
    respond_to do |format|
      format.html { render :text => auto_complete_html(result)}
      format.json { render :text => result.map{|(name, id)| {:name => name, :id => id} }.to_json }
      format.xml  { render :xml => result.map{|(name, id)| {:name => name, :id => id} } }
    end
  end

end
