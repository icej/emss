-module(syncdemo_client).
-compile(export_all).
client() ->
{ok, Sock} = gen_tcp:connect("127.0.0.1", 7000, [binary, {packet, 0}]),
    ok = gen_tcp:send(Sock, "abc\r\n"),
    A = spawn_link(?MODULE, loop, [Sock,self()]),
    receive
        {'new client', Spid} ->
	    io:format("new client ~w",[Spid]),
            erlang:monitor(process,Spid)
    end.

loop(Sock,SPid)->
    receive
	{tcp,Sock,Bin} ->
		io:format("Client received binary = ~p~n" ,[Bin]),
		Val = binary_to_list(Bin),
		io:format("Client result = ~p~n" ,[Val]),
		SPid ! {'new client', self()},
		ok = gen_tcp:send(Sock, "abc\r\n")
	after 0 -> loop(Sock,SPid)
    end.
    %%ok = gen_tcp:close(Sock).	