require 'socket'
require 'csv'

class Request     # Analyzes HTTP requests and prepares a response (status code + message)
  attr_reader :route, :query

  def initialize(request)
    puts "[#{Time.now}]\r\n#{request}"
    @route, @query = parse_path(request.split[1])   # Takes 1st element of request (URL path) to parse route and query
    @routes = ['get', 'set', 'all']
  end

  # For now assume a single ? in the URL, remove '/' since no index page
  def parse_path(path)
    route, query = path.split('?')
    [route.delete('/'), query]
  end 

  # Queries separated into key/value pairs to be passed to the routes
  def parse_query
    return nil if @query.nil?

    key, value = @query.split('=')
    return { key: key, value: value }
  end

  # Rudimentary route checking: is it in the list?
  def valid_route?(route)
    @routes.include?(route)
  end

  def error(status, msg)
    { status: status, body: "[#{Time.now}] Error => #{msg}" }
  end

  def success(status, msg)
    { status: status, body: "[#{Time.now}] Success => #{msg}" }
  end

  # To prepare the response message, invoke (via meta-programming!) the proper method with route name, if valid 
  # Responses here consist of a status code and a simple message
  def prepare_response
    unless valid_route?(@route)  # Error if route invalid or query is nil
      error(404, 'route not found.')
    else
      self.send(route, parse_query)
    end
  end

## Routing functions -- could probably use a separate class!
  # Params consist of query key/value pair as an array, e.g. ['key', some_key]
  def get(params)
    return error(404, "poorly formatted GET request") if params.nil? || params[:key] != 'key'
    
    key = params[:value].to_sym
    data = DB.find(key)
    if data
      success(200, "retrieved #{key}: #{data}")
    else
      error(404, "#{key} not found")
    end
  end

  # Params like above: key/value pair, e.g. [some_key, some_value]
  def set(params)
    return error(404, "poorly formatted SET request") if params.nil? || params[:value].nil?

    key = params[:key].to_sym
    value = params[:value]

    verb = DB.find(key) ? 'updated' : 'created'
    DB.write(key: key, value: value)
    success(200, "#{verb} #{key}: #{value}")
  end

  def all(params)
    if DB.empty?
      msg = "database empty"
    else
      msg = DB.all
        .map { |pair| pair.join " : " }
        .join("\r\n")
    end
    success(200, "\r\n" + msg)  
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

class DatabaseHandler
  # Load with server from CSV
  #
  def initialize(csv_file)
    @csv = csv_file
    @data = {}
    load_csv  
  end
  
  def find(key)
    @data[key] 
  end

  def write(params = {})
    return "error" if params.empty?
    p @data
    @data[params[:key]] = params[:value]
    p @data
    save_csv
  end

  def all
    @data.to_a
  end

  def empty?
    @data.empty?
  end

  def load_csv
    CSV.foreach(@csv) do |row|
      @data[row[0].to_sym] = row[1]
    end
  end

  def save_csv
    CSV.open('data.csv', 'wb') do |csv|
      @data.each_pair do |key, value|
        csv << [key, value]
      end
    end
  end
end

# To start the server: use socket to create a new local instance of a TCP server on port 4000
server = TCPServer.new('localhost', 4000)
puts "Database server listening on port 4000..."

puts "Initializing DB server..."
DB = DatabaseHandler.new('data.csv')
puts "DB server loaded."

while client = server.accept
  # Upon connection: create a request, passing in 1024 bytes from the client
  request = Request.new(client.readpartial(1024))
  # The request object will prepare a message and pass it into a response
  response = Response.new(request.prepare_response)
  # The response object will write back to the client
  response.send(client)

  client.close
end
