Definitions.

NamedParam = :[^%\s\n,\"':&;()|=+\-*/\\<>^\[\]]+
Fragment   = ([^?:'']+|::)+
String     = '([^\\'']|\\.)*'


Rules.

{NamedParam} : {token, {named_param, new_param(TokenChars)}}.
{String}     : {token, {fragment, new_fragment(TokenChars)}}.
{Fragment}   : {token, {fragment, new_fragment(TokenChars)}}.


Erlang code.

-export([tokenize/1]).

tokenize(Binary) ->
  List = binary_to_list(Binary),
  string(List).

new_param([$: | Name]) ->
  list_to_atom(Name).

new_fragment(Chars) ->
  list_to_binary(Chars).
