# PoorManRedis

A test task key-value storage with websockets suppoirt implementation by Max Kuzmin


## Deployment

If you have Elixir installed, just run
```
mix deps.get
cd assets && npm install && cd ..

# to run tests
mix test

# to start app
mix phx.server

```

If you don't have Elixir on your machine, but have Docker and docker-compose on it, run:
```
# Will take some time to build
docker-compose build
# I know, it's a bit clunky, but I'm not a docker expert
docker-compose run app bash ../app/run_dockerized_app.sh  prepare

# tests if needed
docker-compose run app bash ../app/run_dockerized_app.sh  test

# run the app finally
docker-compose up
```


## After deployment
On your localhost:4000 you'll have an app with such endpoints:

* `PUT http://localhost:4000/storage/:key` - create/update record. Requires parameter "value" (supports strings, maps, lists, integers and floats) and has optional parameter "ttl", that accepts only positive integers.

* `DELETE http://localhost:4000/storage/:key` deletes record from storage

* `GET http://localhost:4000/storage/:key` replies with either null or json {value: value, expires_in: amount_in_seconds}


## How to connect to websocket:
With your websocket client establish connection with `localhost:4000//storage_socket/websocket`

To subscribe to update feed on specified key, send messaged with this params:
```
{
  "topic": "key:key_that_youre_interested_in", 
  "event": "phx_join", 
  "payload": null, 
  "ref": null
}
```

After subscription, you will start receiving messages of this format:

###### On put:
{"event":"Was updated","payload":{"expires_in":1,"value":1},"ref":null,"topic":"key:key_that_youre_interested_in"}

###### On delete:

{"event":"Was deleted","payload":{},"ref":null,"topic":"key:key_that_youre_interested_in"}

###### On expiration:
{"event":"was deleted after expiration","payload":{},"ref":null,"topic":"key:key_that_youre_interested_in"}
