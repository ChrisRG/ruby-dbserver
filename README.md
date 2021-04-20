# ruby-dbserver
Basic HTTP/Database server only using the 'socket' gem for TCP connections.
# Server Setup
Clone this repo locally:
```
git clone https://github.com/ChrisRG/ruby-dbserver.git
``` 
To start the server, run in your terminal:
``` 
> ruby ruby-server.rb
```
# Routes
Access the server via your favorite web browser or ```curl``` in from the terminal. 
Currently there are only two routes available:
* ```/set?somekey=somevalue``` => stores the passed (case sensitive) key and value in memory
* ```/get?key=somekey``` => returns the value stored at somekey

# Example
* ```http://localhost:4000/set?chris=100``` => stores or updates the key 'chris' with the value '100'
* ```http://localhost:4000/get?key=chris``` => returns the key 'chris' with its value '100'

# To do
Implement file storage of some sort
