
require 'sinatra'
require 'sinatra/reloader'
require 'pg'

client = PG::connect(
  dbname: 'task_insta'
)

get '/' do
  @res = client.exec('select * from posts')
  erb :top
end

get '/item/:item_id' do
  id = params[:item_id]
  @res = client.exec_params('select * from posts where id = $1', [id]).first
  erb :detail
end

get '/new' do
  erb :new
end

post '/new' do
  name = params[:name]
  title = params[:title]
  content = params[:content]
  client.exec_params('insert into posts(name, title, content) values($1, $2, $3)', [name, title, content])

  redirect '/'
end
