all:
	@(rebar compile)

clean:
	@(rebar clean)

test:
	@(echo "测试自定义transform_table  => mnesia_userdefined_transform:test_userdefined_transform/0")
	@(erl -pa ebin -s mnesia_userdefined_transform test_userdefined_transform -noinput -mnesia dump_log_write_threshold 100000 -s erlang halt)
	@(echo "")
	@(echo "测试mnesia:transform_table => mnesia_userdefined_transform:test_mnesia_transform/0")
	@(erl -pa ebin -s mnesia_userdefined_transform test_mnesia_transform -noinput -mnesia dump_log_write_threshold 100000 -s erlang halt)
