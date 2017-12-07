require "sparql/client"
require 'open-uri'
require 'anemone'
require 'nokogiri'
require 'net/http'
require 'json'
require 'uri'

class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.all
    @input = Category.new
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @categories = Category.all
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    @keyword = dbpedia_crawl

    render 'index'
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      begin
          @category = Category.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
          @category = nil
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name)
    end

    def dbpedia_crawl
      word = params[:category][:keyword]
      url = 'http://ja.dbpedia.org/resource/' + word
      client = SPARQL::Client.new("http://ja.dbpedia.org/sparql")
    
      redirect = client.query("
      SELECT *
      WHERE {
        <" + url + "> dbpedia-owl:wikiPageRedirects ?thing1 .
        ?thing1 rdfs:label ?thing2 .
      }
      ")
      if redirect.size == 0 then
        results = client.query("
        SELECT *
        WHERE {
          <" + url + "> dbpedia-owl:wikiPageWikiLink ?thing1 .
          ?thing1 rdfs:label ?thing2 .
        }
        ") 
      else
          results = client.query("
          SELECT *
          WHERE {
            <" + "#{redirect[0][:thing1]}" + "> dbpedia-owl:wikiPageWikiLink ?thing1 .
            ?thing1 rdfs:label ?thing2 .
          }
          ") 
      end
    
      d = {}
      # p "{"
      results.each do |solution|
          request_url = URI.escape("https://api.apitore.com/api/8/word2vec-neologd-jawiki/similarity?access_token=4af25e9f-e0ac-46e8-b6da-f89590b8af29&word1=" + word + "&word2=" + solution[:thing2].to_s)
          charset = nil
          html = open(request_url, :redirect => false) do |f|
            charset = f.charset #文字種別を取得します。
            f.read #htmlを読み込み変数htmlに渡します。
          end
          doc = Nokogiri::HTML.parse(html, nil, charset)
          jtod = JSON.parse(doc)
          d[URI.unescape(jtod['word2'].to_s)] = URI.unescape(jtod['similarity'].to_s)
      end
      json_str = JSON.pretty_generate(Hash[d.sort_by{|_,v|-v}])
    end
    
end
