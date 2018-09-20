require 'json'
require 'byebug'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)

    if req.cookies['_rails_lite_app']
      @rails_lite_app = JSON.parse(req.cookies['_rails_lite_app'])
    else

      @rails_lite_app = {}
    end
  end

  def [](key)
    @rails_lite_app[key]
  end

  def []=(key, val)
    @rails_lite_app[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie('_rails_lite_app', {path: '/', value: @rails_lite_app.to_json})
  end
end
