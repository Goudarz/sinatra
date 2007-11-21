require File.dirname(__FILE__) + '/helper'

context "Dispatching" do
    
  include Sinatra::Test::Methods
    
  setup do
    Sinatra.routes.clear
    Sinatra.config.clear
  end
    
  specify "should return the correct block" do
    r = get '/' do
      'main'
    end
            
    result = Sinatra.determine_route(:get, '/')
    result.block.should.be r.block
  end
  
  specify "should return custom 404" do
    Sinatra.routes[404] = r = Proc.new { 'custom 404' }
        
    result = Sinatra.determine_route(:get, '/')
    result.should.be r
  end
  
  specify "should return standard 404" do
    get_it '/'
    body.should.equal '<h1>Not Found</h1>'
  end
  
  specify "should give custom 500 if error when called" do
    Sinatra.routes[500] = r = Proc.new { 'custom 500' }

    get '/' do
      raise 'asdf'
    end
    
    get_it '/'

    body.should.equal 'custom 500'
  end
  
  specify "should give standard 500 if error when called" do
    get '/' do
      raise 'asdf'
    end
    
    get_it '/'

    body.should.match /^asdf/
  end
  
  specify "should raise errors to top if requested" do
    Sinatra.config[:raise_errors] = true
    
    get '/' do
      raise 'asdf'
    end
    
    lambda { get_it '/' }.should.raise(RuntimeError)
  end

  specify "should run in a context" do
    Sinatra::EventContext.any_instance.expects(:foo).returns 'in foo'
    
    get '/' do
      foo
    end
    
    get_it '/'
    body.should.equal 'in foo'
  end
  
  specify "has access to the request" do
    
    get '/blake' do
      request.path_info
    end
    
    get_it '/blake'
    
    body.should.equal '/blake'
    
  end
      
end
