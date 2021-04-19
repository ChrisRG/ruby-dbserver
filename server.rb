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

   send(route, parsed)
   return response(200, "#{route.upcase} request at #{Time.now}")
end

def parse_query(query)
  key, value = query.split('=')
end

def get(params)
  puts "Getting #{params}"
  puts DATABASE[params[1]]
end

def set(params)
  puts "Setting #{params}"
  DATABASE[params[0]] = params[1]
  p DATABASE
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
  response = parse_request(request)
  p response
  client.print(response)

  client.close
end

