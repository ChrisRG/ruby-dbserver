# Basic database server for RC pairing interview!
# Before your interview, write a program that runs a server that is accessible on http://localhost:4000/. When your server receives a request on http://localhost:4000/set?somekey=somevalue it should store the passed key and value in memory. When it receives a request on http://localhost:4000/get?key=somekey it should return the value stored at somekey.

# During your interview, you will pair on saving the data to a file. You can start with simply appending each write to the file, and work on making it more efficient if you have time.

require 'socket'

server = TCPServer.new('localhost', 4000)
DATABASE = {}
puts "Database server listening on port 4000..."

# Parse the URI
def parse_request(request)
  puts "Parsing"
  # Parse the URL path
  path = parse_path(request.split[1])
end


# Check validity of path
# Two options: get and set
def parse_path(path)
   route, query = path.split('?')
   p route.delete('/')
   parse_query(query)
end

def parse_query(query)
  key, value = query.split('=')
  p key
  p value
end

while client = server.accept
  # client = server.accept
  # request = client.readpartial(2048)
  request = client.gets
  parse_request(request)

  client.print "HTTP/1.1 200\r\n" # 1
  client.print "Content-Type: text/html\r\n" # 2
  client.print "\r\n" # 3
  client.print "Hello world! The time is #{Time.now}" #4

  client.close
end

