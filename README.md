# ruby-dbserver
Basic HTTP/Database server only using the 'socket' gem for TCP connections.
# Server Setup
Clone this repo locally:
```
https://github.com/ChrisRG/ruby-dbserver.git
``` 
To start the server, in your terminal run: 
``` 
> ruby ruby-server.rb
```
# Usage
Access via your favorite web browser or curl in from the terminal. 
Currently only two routes available:
```http://localhost:4000/set?somekey=somevalue``` => stores the passed key and value in memory.
```http://localhost:4000/get?key=somekey``` => returns the value stored at somekey
