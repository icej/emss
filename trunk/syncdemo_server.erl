-module(syncdemo_server).
-compile(export_all).

-define(TCP_OPTIONS,[list, {packet, 0}, {active, false}, {reuseaddr, true}]).

%% Listen on the given port, accept the first incoming connection and
%% launch the echo loop on it.

listen() ->
    {ok, LSocket} = gen_tcp:listen(7000, ?TCP_OPTIONS),
    do_accept(LSocket).

%% The accept gets its own function so we can loop easily.  Yay tail
%% recursion!

do_accept(LSocket) ->
    {ok, Socket} = gen_tcp:accept(LSocket),
    spawn(fun() -> do_echo(Socket) end),
    do_accept(LSocket).

%% Sit in a loop, echoing everything that comes in on the socket.
%% Exits cleanly on client disconnect.

do_echo(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
            S=Data,
	    io:format("client send: ~s\r\n",[S]),
            gen_tcp:send(Socket, Data),
           do_echo(Socket);
        {error, closed} ->
            ok
    end.
