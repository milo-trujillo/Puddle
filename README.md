# Puddle

Puddle is a distributed and anonymous data store. You can send out a request for information, and nodes in the network with relevant files will send them back to you.

**This project should be considered a toy, and does not provide adequate anonymity or encryption.**

## Design

Puddle is broken into a client and server. The server must run constantly to integrate with the network and process requests from the client.

The server is broken into three segments:

* Request processing - Receives requests from client or other relays, decides how to handle them

* File processing - Determines whether relevant files are in our own data store, forwards them to signalling

* Signalling - sends requests to other relays, including queries from the user or relays, responses with available data, or pairing requests / responses to link with other peers

### Request Processing

We send and receive all requests over HTTP for ease of use. For request processing we use Sinatra to become an HTTP server and register handlers for each type of request. These handlers then pass off work to the file or signalling modules as needed.

### File Processing

The file processing module reads the files in a datastore folder and determines what topics they are related to. When the module receives a request it checks whether there is relevant data, and if there is sends those files to the Signalling module.

### Signalling

This module sends HTTP requests to other relays. It acts as a threadpool so that requests can pile up and be sent incrementally. Otherwise this module is mostly a wrapper around different HTTP requests.

### Client

The client simply sends requests to localhost, and provides a friendlier interface to the Puddle API. The server will only accept client connections from localhost, thus providing a modicum of authentication.

## Dependencies

[Sinatra](http://www.sinatrarb.com/), for receiving http requests

[Patron](https://github.com/toland/patron), for sending http requests to other neighbors

All other dependencies should be in the Ruby core libraries.
