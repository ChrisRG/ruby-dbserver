require 'socket'

server = TCPServer.new('localhost', 4000)
DATABASE = {}
ROUTES = ["get", "set"]

puts "Database server listening on port 4000..."

def parse_request(request)
  return parse_path(request.split[1])
end

def parse_path(path)
   route, query = path.split('?')
   route.delete!('/')

   return invalid_route unless ROUTES.include?(route)

   parsed = parse_query(query)

   msg = send(route, parsed)
   return response(200, "#{route.upcase} request at #{Time.now}.<br>#{msg}")
end

def parse_query(query)
  key, value = query.split('=')
end

def get(params)
  puts "Getting #{params}"
  data = DATABASE[params[1]]
  return "Retrieved #{params[1]}: #{data}"
end

def set(params)
  puts "Setting #{params}"
  DATABASE[params[0]] = params[1]
  p DATABASE
  return "Set #{params[0]} with value #{params[1]}"
end

def invalid_route
  return response(400, "Invalid route / request at #{Time.now}")
end

def response(code, body)
   return [
    "HTTP/1.1 #{code}",
    "Content-Type: text/html",
    "\r\n",
    "#{body}"
   ].join("\r\n")
end

while client = server.accept
  request = client.gets
  puts request
  response = parse_request(request)
  puts "Response: #{response}"
  client.print(response)

  client.close
end
