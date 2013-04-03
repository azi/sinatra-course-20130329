# -*- encoding : utf-8 -*-

require 'sinatra'
require 'csv'

set :csvfile, 'fakedata.csv'

before do
  @contacts = []
  CSV.parse(File.read(settings.csvfile), headers: :first_row).each do |row|
    @contacts << row.to_hash
  end

end

helpers do

  def get_and_show_id(arr)
    id = arr.shift
    sprintf('<td><a href="/contacts/%d">%d</a></td>', id, id)
  end

  def save_csv(contacts)
    CSV.open(settings.csvfile ,'wb') do |csv|
      csv << contacts.first.keys
      contacts.each do |h|
        csv << h.values
      end
    end
  end

end

get '/' do
  redirect '/contacts'
end

get '/contacts' do
  @headers = @contacts.first.keys
  if params[:name_like]
    @contacts = @contacts.select{|contact| contact["name"].include?(params[:name_like])  }
  end
p @contacts
  erb :index
end

# 好拼湊的寫法啊。。。Orz..sintra 初體驗Orz...Orz...好糾結 
# hash要加值時，怎樣可以加在指定的位置，而不是每次都只能加在最後？
post '/contacts/new' do
	#_temp = {"id"=>@contacts.last['id'].to_i+1}
	#_temp.merge!(params[:contact])
  #@contacts << _temp
	
  _temp = {}
	_temp["id"]=@contacts.last['id'].to_i+1
	_temp["name"]=params[:contact]["name"]
	_temp["phone"]=params[:contact]["phone"]
	_temp["address"]=params[:contact]["address"]
	_temp["created_on"]=Time.new().strftime("%Y/%m/%d")
	_temp["note"]=params[:contact]["note"]  	

	@contacts << _temp
	save_csv(@contacts)
	redirect '/'
end


get '/contacts/new' do
	@action = "/contacts/new"
	@contact ||={}
	@contacts.first.keys.each {|key| @contact[key]="" }
	erb :form
end


before %r{\/contacts\/(\d+).*} do
  @contact = @contacts.select{|contact| contact["id"] == params[:captures].first}
	not_found if @contact.empty?
  @contact = @contact.first
end

put '/contacts/:id' do
	_temp = @contacts.select{|contact| contact["id"] == params[:id]}
	#@contacts[params[:id].to_i - 1].merge! params[:contact]
	_temp[0].merge! params[:contact]
	save_csv(@contacts)
  redirect '/contacts'
end

get '/contacts/:id/edit' do
  @action = "/contacts/#{@contact['id']}"
  @method = :put
  erb :form
end

get '/contacts/:id' do
  erb :show
end

get '/contacts/:id/delete' do
  @contact = @contacts.select{|contact| contact["id"] == params[:id]}
  @contacts.delete_if {|item| item["id"]== @contact[0]["id"]}
  #@contacts.delete_at(params[:id].to_i-1)
  save_csv(@contacts)
  redirect '/contacts'
end
