require 'sinatra'
require 'data_mapper'
set :bind, '0.0.0.0'
DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/project.db")
class User
	include DataMapper::Resource
	property :user_id, Serial
	property :email, String
	property :password, String
end
class Task
	include DataMapper::Resource
	property :id, Serial
	property :content, String
	property :done, Boolean
	property :detailsshown, Boolean
	property :details, String
	property :imp, Boolean
	property :urg, Boolean
	property :user_id, Integer
end

DataMapper.finalize
DataMapper.auto_upgrade!
set :sessions, true
get '/'  do
	if session[:user_id]
		user=User.get(session[:user_id])
		tasko=Task.all(:user_id=>user.user_id)

	erb :index, locals: {:yo=>user, :tasks=>tasko}
    else
    erb :login, locals: {t: 1}
    end

end
get '/login' do
	redirect '/'
end

post '/login' do
	emailid=params[:email]
	user=User.all(:email=>emailid).first
	if user
		if user.password==params[:password]
			session[:user_id]=user.user_id
			tasko=Task.all(:user_id=>user.user_id)
			erb :index, locals: {:yo=>user, :tasks=>tasko}
		else
			erb :login, locals: {t:0} 


        end
	else
		erb :login, locals: {t:0} 
    end
end 
get '/signup' do
	erb :signup, locals: {t:0 }
end
post '/register' do
	emailid=params[:email]
	user=User.all(:email=>emailid).first
	if user
		erb :signup, locals: {t:1}
	else
	user=User.new
	user.email=params[:email]
	user.password=params[:password]
	user.save
	erb :signup, locals: {t:2}

	
end


end

get '/logout' do
    session[:user_id] = nil
    redirect '/'
end

post '/addtask' do 
    task=Task.new
    task.content=params[:newtask]
    task.done=false
    task.details=nil
    task.detailsshown=false
    task.imp=true
    task.urg=true
    task.user_id=session[:user_id]
    task.save
redirect '/'
end
post '/removetask' do
	task_id=params[:removetask]
	tasko=Task.get(task_id)
	tasko.destroy
	redirect '/'
end
post '/completed' do
	task_id=params[:completed]
	tasko=Task.get(task_id)
	if tasko.done==true 
		tasko.done=false
	else 
		tasko.done=true
	end
	tasko.save
redirect '/'


end
post '/details' do
	task_id=params[:details]
	tasko=Task.get(task_id)
	if tasko.detailsshown==true
	tasko.details=params[:yo]
    end
	if tasko.detailsshown==true
		tasko.detailsshown=false
	else
		tasko.detailsshown=true

	end
	tasko.save
	redirect '/'

		
end
post '/important' do
	task_id=params[:important]
	tasko=Task.get(task_id)
	if tasko.imp==true
		tasko.imp=false
	else
		tasko.imp=true
	end
	tasko.save
redirect '/'
end
post '/urgent' do
	task_id=params[:urgent]
	tasko=Task.get(task_id)
	if tasko.urg==true
		tasko.urg=false
	else
		tasko.urg=true
	end
	tasko.save
		redirect '/'
end
get '/changepassword' do
	erb :changepassword, locals:{t:1}
end
post '/confirmpassword' do
	user=User.all(:user_id=>session[:user_id]).first
	if user.password==params[:password]
		erb :changepassword, locals:{t:2}
	else
		erb :changepassword,locals:{t:3}

	end 

end
post '/changepassword' do
	user=User.all(:user_id=>session[:user_id]).first
	user.password=params[:password]
	user.save
		erb :changepassword,locals:{t:4}
end
