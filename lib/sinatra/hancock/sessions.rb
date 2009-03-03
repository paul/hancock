module Sinatra
  module Hancock
    module Sessions
      module Helpers
        def session_user
          session[:user_id].nil? ? nil : ::Hancock::User.get(session[:user_id])
        end

        def ensure_authenticated
          login_view = <<-HTML
%form{:action => '/sso/login', :method => 'POST'}
  %label{:for => 'email'} 
    Email:
    %input{:type => 'text', :name => 'email'}
    %br
  %label{:for => 'password'} 
    Password:
    %input{:type => 'password', :name => 'password'}
    %br
  %input{:type => 'submit', :value => 'Login'}
HTML
          throw(:halt, [401, haml(login_view)]) unless session_user
        end
      end

      def self.registered(app)
        app.send(:include, Sinatra::Hancock::Sessions::Helpers)
        app.post '/sso/login' do
          @user = ::Hancock::User.authenticate(params['email'], params['password'])
          if @user
            session[:user_id] = @user.id
          end
          ensure_authenticated
          redirect '/'
        end

        app.get '/sso/logout' do
          session.clear
          redirect '/'
        end
      end
    end
  end
  register Hancock::Sessions
end
