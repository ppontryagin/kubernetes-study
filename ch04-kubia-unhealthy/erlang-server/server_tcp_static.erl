-module(server_tcp_static).
-export([start/0]).

start() ->
    io:format("SERVER Trying to bind to port 2345~n"),
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    io:format("SERVER Listening on port 2345~n"),
    accept(Listen).

accept(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    respond(Socket),
    accept(Listen).

respond(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            Response = plain_text_response(),
            gen_tcp:send(Socket, Response),
            respond(Socket);
        {tcp_closed, Socket} ->
            io:format("SERVER: The client closed the connection~n")
    end.

plain_text_response() ->
    {ok, Host} = inet:gethostname(),
    Msg = "You've hit " ++ Host ++ "\n",
    Length = integer_to_list(string:len(Msg)),
    "HTTP/1.1 200 OK\r\nContent-Length: " ++ Length ++ "\r\nContent-Type: text/plain\r\n\r\n" ++ Msg.