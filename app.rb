
require 'sinatra'
require 'sinatra/reloader'
require 'pg'

enable :sessions

client = PG::connect(
  dbname: 'task_insta'
)

def login_check()
  redirect '/login' if session[:user_id].nil?
end

get '/' do
  login_check()
  @res = client.exec('select * from posts')
  erb :top
end

get '/item/:item_id' do
  login_check()
  id = params[:item_id]
  @res = client.exec_params('select * from posts where id = $1', [id]).first

  @comments = client.exec_params('select * from comments where post_id = $1', [id])

  @tags = client.exec_params('select * from tags where post_id = $1', [id])

  erb :detail
end

get '/new' do
  login_check()
  erb :new
end

post '/new' do
  login_check()
  name = params[:name]
  title = params[:title]
  content = params[:content]
  client.exec_params('insert into posts(name, title, content) values($1, $2, $3)', [name, title, content])

  redirect '/'
end

get '/edit/:item_id' do
  login_check()
  id = params[:item_id]
  @res = client.exec_params('select * from posts where id = $1', [id]).first

  redirect '/' if @res.nil?

  erb :edit
end

post '/edit' do
  login_check()
  id = params[:id]
  name = params[:name]
  title = params[:title]
  content = params[:content]
  client.exec_params('update posts set name = $1, title = $2, content = $3 where id = $4', [name, title, content, id])

  redirect "/item/#{id}"
end

get '/delete/:item_id' do
  login_check()
  id = params[:item_id]
  @res = client.exec_params('select * from posts where id = $1', [id]).first

  redirect '/' if @res.nil?

  client.exec('delete from posts where id = $1;', [id])

  redirect '/'
end

post '/comment' do
  login_check()
  id = params[:id]
  name = params[:name]
  msg = params[:msg]

  client.exec_params('insert into comments(post_id, name, msg) values($1, $2, $3)', [id, name, msg])

  redirect "/item/#{id}"
end

post '/tag' do
  login_check()
  id = params[:id]
  name = params[:name]

  client.exec_params('insert into tags(post_id, name) values($1, $2)', [id, name])

  redirect "/item/#{id}"
end

get '/signup' do
  erb :signup
end

post '/signup' do
  name = params[:name]
  email = params[:email]
  pass = params[:pass]
  confirmation = params[:confirmation]

  redirect '/signup' if pass != confirmation

  client.exec_params('insert into users(name, email, password) values($1, $2, $3)', [name, email, pass])

  redirect '/'
end

get '/login' do
  erb :login
end

post '/login' do
  name = params[:name]
  email = params[:email]
  pass = params[:pass]

  @res = client.exec_params('select * from users where name = $1 and email = $2 and password = $3', [name, email, pass]).first

  redirect '/login' if @res.nil?

  session[:user_id] = @res['id'].to_i

  redirect '/'
end
