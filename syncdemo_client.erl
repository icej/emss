-module(syncdemo_client).
-compile(export_all).
client() ->
{ok, Sock} = gen_tcp:connect("127.0.0.1", 7000, [binary, {packet, 0}]),
    ok = gen_tcp:send(Sock, "abc\r\n").
    %%ok = gen_tcp:close(Sock).