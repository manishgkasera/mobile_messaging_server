# mobile_messaging_server
### Requirements
  - ruby version 2.1.5
  - ruby gem bundler ```gem install bundler```
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
#### Enqueue messages
Example to enqueue messages from ruby irb
  - start the irb using ```bundle exec irb -r ./lib/niki/base.rb```
  
  ```ruby
  message = "hello client"
  client_id = Niki::ClientHandler.first.id
  Niki::ClientMessage.enqueue(client_id, message)
  ```
  - enqueue will automatically sends a event to all the servers and then the server connected to client will deliver the message

### Design overview
  - Main server starts two additional threads
    - 1. this listens to client commands like 'DISCONNECT' other commads can be added as required.
    - 2. this thread is an internal thread which gets invoked when a new message arrives and take the responsibility to deliver it to the client.
  - Main thread takes the responsibility to add new clients and on initial connect check and deliver pending messages (this happens in a seperate client specific thread)
  - when client send a command thread 1 will handle that
  - when new message arrives thread 2 will deliver it the client
 
### Future Improvements
  - once client is connected to server, server can lock (probaly db lock) the client so one client only connects to one server
  - currently enqueue message sends event to all the servers, this can be changed if server locks the client and send event only to that perticuler server


