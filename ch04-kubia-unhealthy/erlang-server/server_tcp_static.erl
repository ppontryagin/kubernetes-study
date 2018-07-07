-module(server_tcp_static).
-export([start/0]).

start() ->
    io:format("SERVER Trying to bind to port 2345~n"),
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    io:format("SERVER Listening on port 2345~n"),
    accept(Listen, 0).

accept(Listen, N) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    if
        N == 4 ->
            respond(Socket, bad_text_response()),
            accept(Listen, 0);
        true ->       
            respond(Socket, good_text_response()),
            accept(Listen, N+1)
    end.

respond(Socket, Response) ->
    receive
        {tcp, Socket, _Bin} ->
            gen_tcp:send(Socket, Response);
        {tcp_closed, Socket} ->
            io:format("SERVER: The client closed the connection~n")
    end.

good_text_response() ->
    {ok, Host} = inet:gethostname(),
    Msg = "You've hit " ++ Host ++ "\n",
    Length = integer_to_list(string:len(Msg)),
    "HTTP/1.1 200 OK\r\nContent-Length: " ++ Length ++ "\r\nContent-Type: text/plain\r\n\r\n" ++ Msg.

bad_text_response() ->
    Msg = "I'm not well. Please restart me!\n",
    Length = integer_to_list(string:len(Msg)),
    "HTTP/1.1 500 Internal Error\r\nContent-Length: " ++ Length ++ "\r\nContent-Type: text/plain\r\n\r\n" ++ Msg.