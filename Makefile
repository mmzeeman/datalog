PROJECT = datalog 
DIALYZER = dialyzer

ERL       ?= erl
REBAR3 := $(shell which rebar3 2>/dev/null || echo ./rebar3)
REBAR3_VERSION := 3.22.1
REBAR3_URL := https://github.com/erlang/rebar3/releases/download/$(REBAR3_VERSION)/rebar3

all: compile

$(REBAR3):
	$(ERL) -noshell -s inets -s ssl \
	 -eval '{ok, saved_to_file} = httpc:request(get, {"$(REBAR3_URL)", []}, [], [{stream, "./rebar3"}])' \
	 -s init stop
	chmod +x ./rebar3

compile: $(REBAR3)
	$(REBAR3) compile

test: compile
	$(REBAR3) eunit -v

clean: $(REBAR3)
	$(REBAR3) clean

distclean:
	rm $(REBAR3)

dialyzer: $(REBAR3)
	$(REBAR3) dialyzer

