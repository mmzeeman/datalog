%%
%%   Copyright 2016 Dmitry Kolesnikov, All Rights Reserved
%%
%%   Licensed under the Apache License, Version 2.0 (the "License");
%%   you may not use this file except in compliance with the License.
%%   You may obtain a copy of the License at
%%
%%       http://www.apache.org/licenses/LICENSE-2.0
%%
%%   Unless required by applicable law or agreed to in writing, software
%%   distributed under the License is distributed on an "AS IS" BASIS,
%%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%   See the License for the specific language governing permissions and
%%   limitations under the License.
%%
%% @doc
%%   build-in datalog primitives
-module(datalog_lang).

-export([
   unique/1,
   eq/1, ne/1, lt/1, gt/1, le/1, ge/1
]).

%%
%% scalable bloom filter definition
-define(SBF, sbf:new(128, 0.0001)).


%%
%% a predicate ensures unique terms within the stream
-spec unique(datalog:predicate()) -> _.

unique(#{'_' := Head}) ->   
   fun(_) ->
      fun(Stream) ->
         [pipe|stream:unfold(fun uniq/1, {?SBF, Head, Stream})]
      end
   end.

uniq({_, _, {}}) ->
   stream:new();  

uniq({Sbf0, Head, Stream}) ->
   Item = maps:with(Head, stream:head(Stream)),
   Sbf1 = sbf:add(Item, Sbf0),
   Tail = stream:dropwhile(fun(X) -> sbf:has(maps:with(Head, X), Sbf1) end, Stream),
   {stream:head(Stream), {Sbf1, Head, Tail}}.


%%
%% comparison predicates
%% ```
%% h(x,z) :- a(x,y), b(y,z), :eq(x,z). 
%% ``` 
-spec eq(datalog:predicate()) -> _.

eq(#{'_' := [A, B]}) ->
   fun(_) ->
      fun(Stream) ->
         [pipe|stream:filter(fun(#{A := Ax, B := Bx}) -> Ax =:= Bx end, Stream)]
      end
   end.

-spec ne(datalog:predicate()) -> _.

ne(#{'_' := [A, B]}) ->
   fun(_) ->
      fun(Stream) ->
         [pipe|stream:filter(fun(#{A := Ax, B := Bx}) -> Ax =/= Bx end, Stream)]
      end
   end.

-spec lt(datalog:predicate()) -> _.

lt(#{'_' := [A, B]}) ->
   fun(_) ->
      fun(Stream) ->
         [pipe|stream:filter(fun(#{A := Ax, B := Bx}) -> Ax < Bx end, Stream)]
      end
   end.

-spec gt(datalog:predicate()) -> _.

gt(#{'_' := [A, B]}) ->
   fun(_) ->
      fun(Stream) ->
         [pipe|stream:filter(fun(#{A := Ax, B := Bx}) -> Ax > Bx end, Stream)]
      end
   end.

-spec le(datalog:predicate()) -> _.

le(#{'_' := [A, B]}) ->
   fun(_) ->
      fun(Stream) ->
         [pipe|stream:filter(fun(#{A := Ax, B := Bx}) -> Ax =< Bx end, Stream)]
      end
   end.

-spec ge(datalog:predicate()) -> _.

ge(#{'_' := [A, B]}) ->
   fun(_) ->
      fun(Stream) ->
         [pipe|stream:filter(fun(#{A := Ax, B := Bx}) -> Ax >= Bx end, Stream)]
      end
   end.



