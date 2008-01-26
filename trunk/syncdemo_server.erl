-module(syncdemo_server).
-compile(export_all).
-record(chat,{socket,accepter,clients}).
-record(client,{socket,name,pid}).

start()->
	{ok, Socket} = gen_tcp:listen(7000, [binary, {packet, 0},{active, false}]),
	 A = spawn_link(?MODULE, accepter, [Socket, self()]),%%为监听client加入起一个进程
	 loop(#chat{socket=Socket, accepter=A, clients=[]}).
loop(Chat=#chat{accepter=A,clients=Cs}) ->
    receive
        {'new client', Client} ->
	    io:format("new client ~w",[Client#client.pid]),
            erlang:monitor(process,Client#client.pid)
    end.
accepter(Socket, ServerPid)->
	{ok, Client} = gen_tcp:accept(Socket),
	spawn(?MODULE, client, [Client, ServerPid]),
	receive
		refresh -> ?MODULE:accepter(Socket, ServerPid)
	after 0 -> accepter(Socket, ServerPid)%%不断刷新检测新client加入
	end.


client(Sock, Server) ->
    gen_tcp:send(Sock, "Please respond with a sensible name.\r\n"),
    {ok,N} = gen_tcp:recv(Sock,0),
    M=binary_to_list(N),
    case string:tokens(M,"\n") of
        [Name] ->
	    Client = #client{socket=Sock, name=Name, pid=self()},
            io:format("client name ~w",[Name]),
            Server ! {'new client', Client};
            
        _ ->
            gen_tcp:send(Sock, "That wasn't sensible, sorry."),
            gen_tcp:close(Sock)
    end.

    
    
      