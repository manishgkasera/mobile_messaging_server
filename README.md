# mobile_messaging_server
### Requirements
  - ruby version 2.1.5
  - ruby gem bundler
  - mysql

### Setup
Once all the requirements are met follow this steps
  - change the db configuration in ./lib/setup_db.rb
  - ``` bundle install ```
  - first run will setup the db(create schema) so no need to do that manually
  
### Running
#### Starting the server
  default port is 8000,
  change the port by giving  -p option,
  to know other options use -h
```
bundle exec ./lib/messaging_server.rb
```

Multiple servers can be run in parallel on the same or different boxes.


#### Connecting as client
Use telnet to connect, you have to use hostname as the first argument to telnet 'localhost' will not work
##### Initial Handshake
  - on connect server will ask for client_id by issueing GET_CLIENT_ID command, pass 'NONE' to get a new client id
  - once this is done sever will send the client_id back as 'SET_CLIENT_ID: 3000' client should store this and use for future connects

Once the initial handshake is complete, server will start sending messages as 'MESSAGE: hello'.

To disconnect give the command as 'DISCONNECT'



