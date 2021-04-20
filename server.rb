# Basic HTTP/Database server only using the 'socket' gem for TCP connections.
# To start the server: > ruby ruby-server.rb
# Access via your favorite web browser or curl in from the terminal. 
# Currently only two routes available:
# http://localhost:4000/set?somekey=somevalue => stores the passed key and value in memory.
# http://localhost:4000/get?key=somekey => returns the value stored at somekey

require 'socket'

DATABASE = {}     # TODO: save the database to a file!

class Request     # Analyzes HTTP requests and prepares a response (status code + message)
  attr_reader :route, :query

  def initialize(request)
    puts "[#{Time.now}]\r\n#{request}"
    @route, @query = parse_path(request.split[1])   # Takes 1st element of request (URL path) to parse route and query
    @routes = ['get', 'set']
  end

  # For now assume a single ? in the URL, remove '/' since no index page
  def parse_path(path)
   route, query = path.split('?')
   [route.delete('/'), query]
  end 

  # Queries separated into key/value pairs to be passed to the routes
  def parse_query
    key, value = @query.split('=')
  end

  # Rudimentary route checking: is it in the list?
  def valid_route?(route)
    @routes.include?(route)
  end

  def error(status, msg)
    { status: status, body: "[#{Time.now}] Error => #{msg}" }
  end

  def success(msg)
    { status: 200, body: "[#{Time.now}] Success => #{msg}" }
  end

  # To prepare the response message, invoke (via meta-programming!) the proper method with route name, if valid 
  # Responses here consist of a status code and a simple message
  def prepare_response
    unless valid_route?(@route)
      error(404, 'route not found.')
    else
      self.send(route, parse_query)
    end
  end

## Routing functions -- could probably use a separate class!
  # Params consist of query key/value pair as an array, e.g. ['key', some_key]
  def get(params)
    return error(404, "poorly formatted GET request") unless params[0] == 'key'

    key = params[1]
    data = DATABASE[key]
    if data
      success("retrieved #{key}: #{data}")
    else
      error(404, "key not found")
    end
  end

  # Params like above: key/value pair, e.g. [some_key, some_value]
  def set(params)
    key = params[0]
    value = params[1]
    verb = DATABASE[key] ? 'updated' : 'created'
    DATABASE[params[0]] = params[1]
    success("#{verb} #{key}: #{value}")
  end
end

class Response
  def initialize(message)
     @response =
       [
        "HTTP/1.1 #{message[:status]}",
        "Content-Type: text/html",
        "\r\n",
        "#{message[:body]}"
       ].join("\r\n")
  end

  def send(client)
    client.write(@response)
  end
end

# To start the server: use socket to create a new local instance of a TCP server on port 4000
server = TCPServer.new('localhost', 4000)

puts "Database server listening on port 4000..."

while client = server.accept
  # Upon connection: create a request, passing in 1024 bytes from the client
  request = Request.new(client.readpartial(1024))
  # The request object will prepare a message and pass it into a response
  response = Response.new(request.prepare_response)
  # The response object will write back to the client
  response.send(client)

  client.close
end
