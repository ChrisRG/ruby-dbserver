require 'socket'
require 'csv'

class Request     # Analyzes HTTP requests and prepares a response (status code + message)
  attr_reader :route, :query

  def initialize(request)
    puts "[#{Time.now}]\r\n#{request}" # Log to the server every time a request is initialized
    @route, @query = parse_path(request.split[1])   # Takes 1st element of request (URL path) to parse route and query
  end

  # For now assume a single ? in the URL, remove '/' since no index page
  def parse_path(path)
    route, query = path.split('?')
    return route if route == '/' 

    [route.delete('/'), query]
  end 

  # Single query separated into key/value pair to be passed to the routes
  def parse_query
    return nil if @query.nil?

    key, value = @query.split('=')
    return { key: key, value: value }
  end

  def respond(result, status_code, msg)
    { status: status_code, body: "[#{Time.now}] #{result} => #{msg}" }
  end

  # To prepare the response message, invoke (via meta-programming!) the proper method with route name
  def prepare_response
    self.send(route, parse_query)
  end

  # If an invalid method (i.e. route) is called, return a 404 error
  def method_missing(m, *args, &block)
    respond('Error', 404, 'page not found')
  end

  # Routes
  def /(params)
    respond('Success', 200, 'this is the homepage')
  end

  def get(params)
    return respond('Error', 404, "poorly formatted GET request") if params.nil? || params[:key] != 'key' || params[:value].nil?
    
    key = params[:value].to_sym
    data = DB.find(key)
    if data
      respond('Success', 200, "retrieved #{key}: #{data}")
    else
      respond('Error', 404, "#{key} not found")
    end
  end

  def set(params)
    return respond('Error', 404, "poorly formatted SET request") if params.nil? || params[:value].nil?

    key = params[:key].to_sym
    value = params[:value]

    verb = DB.find(key) ? 'updated' : 'created'
    DB.write(key: key, value: value)
    respond('Success', 200, "#{verb} #{key}: #{value}")
  end

  def all(params)
    if DB.empty?
      msg = "database empty"
    else
      msg = DB.all
        .map { |pair| pair.join " : " }
        .join("\r\n")
    end
    respond('Success', 200, "\r\n" + msg)  
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

    @data[params[:key]] = params[:value]
    save_csv
  end

  def all
    @data.to_a
  end

  def empty?
    @data.empty?
  end

  private

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
  request = Request.new(client.readpartial(1024))
  response = Response.new(request.prepare_response)
  response.send(client)

  client.close
end
