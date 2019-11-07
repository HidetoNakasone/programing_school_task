
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
