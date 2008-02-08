-module(emssserver).
-export([init/0]).
-define(TCP_OPTIONS,[binary,{packet, 0}, {active, true}, {reuseaddr, true}]).
-define(PORT,7000).
-define(Debug,"YES").

-ifdef(Debug).
-define(DEBUG(Fmt, Args), io:format(Fmt, Args)).
-else.
-define(DEBUG(Fmt, Args), no_debug).
-endif.
-record(group,{name,gpid}).
-record(client, {name,pid,socket}).

init()->
	{ok, Listen} = gen_tcp:listen(?PORT, ?TCP_OPTIONS),
	register(accept_connection, spawn(fun() -> accept_connection(Listen) end)),
	register(group_manage, spawn(fun() -> group_manage([]) end)).

accept_connection(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    Pid = spawn(fun() -> client_recv(Socket,"","") end),
    gen_tcp:controlling_process(Socket,Pid),
    accept_connection(Listen).

client_recv(Socket,ClientName,GroupPid)->
	receive
		{tcp, Socket, Bin} ->
			?DEBUG("Server recv Data\r\n",""),
			case binary_to_term(Bin) of
				{join,JoinName,ClientNameTmp}->%%client join
					?DEBUG("client_recv Join:~s ~s\r\n",[JoinName,ClientNameTmp]),
					G=#group{name=JoinName},
					group_manage ! {join,G,self()},%%get group pid
						receive
							{grouppid,GPid}->%%recv group pid
								?DEBUG("Client_recv grouppid ~w ~s\r\n",[GPid,ClientNameTmp]),
								GPid!{join,Socket,ClientNameTmp,self()} %% send "join" msg to group
						end,
					client_recv(Socket,ClientNameTmp,GPid);
				{send,GroupName,Msg}->%%client send msg to group,but single group
					?DEBUG("client_recv Send:~s ~s\r\n",[GroupName,Msg]),
					GroupPid!{send,ClientName,Msg},
					client_recv(Socket,ClientName,GroupPid)
			end;
		{tcp_closed, Socket} ->
			?DEBUG("client_recv close\r\n",[])
	end.

group_manage(Group)->
	?DEBUG("group_manage start\r\n",[]),
	receive
		{join,JoinGroup,ClientPid}->
			?DEBUG("group_manage Join:~s\r\n",[JoinGroup#group.name]),
			case lists:keysearch(JoinGroup#group.name, #group.name, Group) of
				false ->
					Pid=spawn(fun() -> group([]) end),
					?DEBUG("group_manage group pid~w\r\n",[Pid]),
					ClientPid!{grouppid,Pid},%%return client_recv group pid
					JoinGroupp = #group{name=JoinGroup#group.name,gpid=Pid},
					Gs = [JoinGroupp|Group],
					?DEBUG("group_manage group:~w\r\n",[Gs]),
					group_manage(Gs);
				{value,SingleGroup} ->
					?DEBUG("group_manage group is set ~s\r\n",[SingleGroup#group.name]),
					ClientPid!{grouppid,SingleGroup#group.gpid},
					group_manage(Group)
			end

	end.

group(Client)->
	?DEBUG("group \r\n",[]),
	receive
		{join,Socket,ClientName,CPid} ->
			?DEBUG("group ClientName ~s\r\n",[ClientName]),
			?DEBUG("group Client set ~w\r\n",[Client]),
			case lists:keysearch(ClientName,#client.name,Client) of
				false->
					?DEBUG("group new client\r\n",[]),
					ClientNew = #client{name=ClientName,pid=CPid,socket=Socket},
					ClientTmp = [ClientNew|Client],
					group(ClientTmp);
				{value,SingleClient}->
					?DEBUG("group client is set ~s\r\n",[SingleClient#client.name]),
					group(Client)
			end;
		{send,ClientName,Msg}->
			?DEBUG("group recv client send ~s\r\n",[Msg]),
			lists:foreach(fun(T)->send(ClientName,T,Msg) end,Client),
			group(Client)
	end,
	ok.
	
send(FClientName,TClientName,Msg)->
	if
		FClientName /= TClientName#client.name ->
			?DEBUG("send f:~s t:~s ~s\r\n",[FClientName,TClientName#client.name,Msg]),
			M = {FClientName,Msg},
			gen_tcp:send(TClientName#client.socket,term_to_binary(M));
		true->
			?DEBUG("send from eq to\r\n",[])
	end.
	
