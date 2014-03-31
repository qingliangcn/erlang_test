-module(mnesia_userdefined_transform).

-compile(export_all).

-record(test, {k, v}).

%% 测试数据条数
-define(TEST_DATA_NUM, 100 * 10000).


%% @doc 测试mnesia自带机制
test_mnesia_transform() ->
    reset(),
    mnesia_transform(),
    ok.

%% @doc 测试自定义方式
test_userdefined_transform() ->
    reset(),
    userdefined_transform(),
    ok.

%% @doc reset
reset() ->
    start(),
    delete_table(),
    init_db_table(),
    insert_datas(),
    mnesia:dump_log(),
    ok.


%% @doc 启动服务
start() ->
    mnesia:start(),
    mnesia:change_table_copy_type(schema, erlang:node(), disc_copies),
    mnesia:wait_for_tables(mnesia:system_info(local_tables), infinity),
    ok.

%% @doc 初始化数据库表
init_db_table() ->
    %% 注意:为了测试方便,这里的attribute直接使用 [k,v]
    mnesia:create_table(db_test_transform, [{disc_copies, [erlang:node()]}, {record_name, test}, {type, set}, {attributes, [k, v]}]).

%% @doc 删除表
delete_table() ->
    mnesia:delete_table(db_test_transform).

%% @doc 随机插入一些数据
insert_datas() ->
    [begin mnesia:dirty_write(db_test_transform, #test{k=K, v=K}) end || K <- lists:seq(1, ?TEST_DATA_NUM)]. 

%% @doc mnesia自带的transform
mnesia_transform() ->
    io:format("mnesia_transform begin time ~p~n", [erlang:localtime()]),
    {atomic, ok} = mnesia:transform_table(db_test_transform, fun(R) -> case R of {test, K, V} -> {test, K, V, 0}; _ -> R end end, [k, v, v2]), 
    io:format("mnesia_transform end time ~p~n", [erlang:localtime()]),
    ok.

%% @doc user-defined的transform
userdefined_transform() ->
    io:format("userdefined_transform begin time ~p~n", [erlang:localtime()]),
    {atomic, ok} = mnesia:transform_table(db_test_transform, ignore, [k, v, v2]),
    [begin
        case mnesia:dirty_read(db_test_transform, K) of
            {test, K, V} ->
                mnesia:dirty_write(db_test_transform, {test, K, V, 0});
            _ ->
                ok
        end
    end || K <- mnesia:dirty_all_keys(db_test_transform)],
    io:format("userdefined_transform end time ~p~n", [erlang:localtime()]),
    ok.
