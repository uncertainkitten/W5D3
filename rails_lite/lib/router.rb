require 'byebug'

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method.to_s
    @controller_class = controller_class
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    !!(@pattern =~ req.path) && @http_method == req.request_method.downcase
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    match_data = @pattern.match(req.path)
    params = {}
    match_data.names.each {|k| params[k] = match_data[k]}

    @controller_class.new(req, res, params).invoke_action(@action_name)


  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&prc)
    self.instance_eval(&prc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end


  # should return the route that matches this request
  def match(req)
    @routes.each {|route| return route if route.matches?(req)}
    nil
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    return self.match(req).run(req, res) unless self.match(req).nil?
    res.status = 404
  end
end
