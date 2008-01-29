-module(syncdemo_server).
-compile(export_all).

-define(TCP_OPTIONS,[list, {packet, 0}, {active, true}, {reuseaddr, true}]).

%% Listen on the given port, accept the first incoming connection and
%% launch the echo loop on it.

listen() ->
    {ok, LSocket} = gen_tcp:listen(7000, ?TCP_OPTIONS),
    register(start,self()),
    %%register(server,spawn(fun() -> show() end)),
    register(accept, spawn(fun() -> do_accept(LSocket) end)).

%% The accept gets its own function so we can loop easily.  Yay tail
%% recursion!
show()->
	receive
		{recvmsg, Data} ->
			io:format("client send: ~s\r\n",[Data])
	after 0->show()
	end.
	

do_accept(LSocket) ->
    {ok, Socket} = gen_tcp:accept(LSocket),
    Pid = spawn(fun() -> do_echo(Socket) end),
    gen_tcp:controlling_process(Socket,Pid),
   
    do_accept(LSocket).

%% Sit in a loop, echoing everything that comes in on the socket.
%% Exits cleanly on client disconnect.

do_echo(Socket) ->
    receive
        {tcp, Socket, Bin} ->
	   %% server!{recvmsg,Bin},
	    io:format("do_echo: ~s\r\n",[Bin]),
            gen_tcp:send(Socket, Bin),
           do_echo(Socket);
        {tcp_closed, Socket} ->
            ok
    end.
