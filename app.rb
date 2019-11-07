
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

  @comments = client.exec_params('select * from comments where post_id = $1', [id])

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

get '/edit/:item_id' do
  id = params[:item_id]
  @res = client.exec_params('select * from posts where id = $1', [id]).first

  redirect '/' if @res.nil?

  erb :edit
end

post '/edit' do
  id = params[:id]
  name = params[:name]
  title = params[:title]
  content = params[:content]
  client.exec_params('update posts set name = $1, title = $2, content = $3 where id = $4', [name, title, content, id])

  redirect "/item/#{id}"
end

get '/delete/:item_id' do
  id = params[:item_id]
  @res = client.exec_params('select * from posts where id = $1', [id]).first

  redirect '/' if @res.nil?

  client.exec('delete from posts where id = $1;', [id])

  redirect '/'
end

post '/comment' do
  id = params[:id]
  name = params[:name]
  msg = params[:msg]

  client.exec_params('insert into comments(post_id, name, msg) values($1, $2, $3)', [id, name, msg])

  redirect "/item/#{id}"
end
