hancock
=======

It's like your [John Hancock][johnhancock] for all of your company's apps.  

A lot of this is extracted from our internal single sign on server at [Engine
Yard][ey].  We use a different [datamapper][datamapper] backend but it should
be a great start for most people.

Features
========
An [OpenID][openid] based [Single Sign On][sso] server that provides:

* a single authoritative source for user authentication
* a [whitelist][whitelist] for consumer applications
* integration with the big ruby frameworks via [rack][hancock_examples].
* configurable [sreg][sreg] parameters to consumers

How it Works
============
![SSO Handshake](http://img.skitch.com/20090305-be6wwmbc4gfsi9euy3w7np31mm.jpg)

This handshake seems kind of complex but it only happens when you need to
validate a user session on the consumer.

Your Rackup File
================
    #  thin start -p PORT -R config.ru
    require 'rubygems'
    gem 'sinatra', '~>0.9.1.1'
    require 'hancock'
    gem 'atmos-sinatra-ditties', '~>0.0.3'
    require 'sinatra/ditties'

    DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/development.db")

    Sinatra::Mailer.config = {
      :host   => 'smtp.example.com',
      :port   => '25',
      :user   => 'sso',
      :pass   => 'lolerskates',
      :auth   => :plain # :plain, :login, :cram_md5, the default is no auth
      :domain => "example.com" # the HELO domain provided by the client to the server
    }

    class Dragon < Hancock::App
      set :views,  'views'
      set :public, 'public'
      set :environment, :production

      set :provider_name, 'Example SSO Provider'
      set :do_not_reply,  'sso@atmos.org'

      get '/' do
        redirect '/sso/login' unless session[:hancock_server_user_id]
        erb "<h2>Hello <%= session[:first_name] %><!-- <%= session.inspect %>"
      end
    end
    run Dragon

Installation
============
    % gem sources
    *** CURRENT SOURCES ***

    http://gems.rubyforge.org/
    http://gems.engineyard.com
    http://gems.github.com

You need a few gems to function

    % sudo gem install dm-core do_sqlite3
    % sudo gem install sinatra ruby-openid 
    % sudo gem install atmos-sinatra-ditties

You need a few extra gems to run the specs
    % sudo gem install rspec webrat rack-test cucumber

Deployment Setup
================
You can deploy hancock on any rack compatible setup.  You need a database that
datamapper can connect to.  Generate an example rackup file for yourself based
on the example above.

    % irb
    >> require 'rubygems'
    => false
    >> require 'hancock'
    => true
    >> DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/development.db")
    => #<DataMapper::Adapters::Sqlite3Adapter:0x1ae639c ...>
    >> DataMapper.auto_migrate!
    => [Hancock::User, Hancock::Consumer]

Consult the datamapper documentation if you need to connect to something other
than sqlite.  This runs the initial user migration to bootstrap your db.

    >> Hancock::Consumer.create(:url => 'http://hr.example.com/sso/login', :label => 'Human Resources', :internal => true)
    => ...
    >> Hancock::Consumer.create(:url => 'http://localhost:3000/sso/login', :label => 'Local Rails Dev', :internal => false)
    => ...
    >> Hancock::Consumer.create(:url => 'http://localhost:4000/sso/login', :label => 'Local Merb Dev', :internal => false)
    => ...
    >> Hancock::Consumer.create(:url => 'http://localhost:4567/sso/login', :label => 'Local Sinatra Dev', :internal => false)

Here's how you setup most frameworks as consumers.  In a production environment you'd lock this down

Possibilities
=============
* single sign off
* some kinda awesome [oauth][oauth] hooks

Sponsored By
============
* [Engine Yard][ey]

[johnhancock]: http://www.urbandictionary.com/define.php?term=john+hancock
[ey]: http://www.engineyard.com/
[sr]: http://github.com/sr
[atmos]: http://github.com/atmos
[halorgium]: http://github.com/halorgium
[adelcambre]: http://github.com/adelcambre
[srfork]: http://github.com/sr/webrat/tree/sinatra
[webrat]: http://github.com/brynary/webrat
[hancock_examples]: http://github.com/atmos/hancock-client/tree/98aae96077a8fbfa0097f33ec3ecd628fc549c54/examples/dragon
[datamapper]: http://datamapper.org
[openid]: http://openid.net/
[sso]: http://en.wikipedia.org/wiki/Single_sign-on
[whitelist]: http://en.wikipedia.org/wiki/Whitelist
[oauth]: http://oauth.net/
[sreg]: http://openid.net/specs/openid-simple-registration-extension-1_0.html#response_format
[simpledb]: http://aws.amazon.com/simpledb/
