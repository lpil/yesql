# Yesql

Yesql is an Elixir library for _using_ SQL.

## Rationale

You're writing Elixir You need to write some SQL.

One option is to use [Ecto](https://github.com/elixir-ecto/ecto/),
which provides a sophisticated DSL for generating database queries at
runtime. This can be convenient for simple use, but its abstraction
only works with the simplest and common database features. Because of
this either the abstraction breaks down and we start passing raw strings
to `Repo.query` and `fragment`, or we will neglect these database
features altogether.

So what's the solution? Keep the SQL as SQL. Have one file with your
query:

``` sql
SELECT *
FROM users
WHERE country_code = :country_code
```

...and then read that file to turn it into a regular Elixir function at
compile time:

```elixir
defmodule Query do
  use Yesql, driver: Postgrex, conn: MyApp.ConnectionPool

  Yesql.defquery("some/where/select_users_by_country.sql")
end

# A function with the name `users_by_country/1` has been created.
# Let's use it:
iex> Query.users_by_country(country_code: "gbr")
{:ok, [%{name: "Louis", country_code: "gbr"}]}
```

By keeping the SQL and Elixir separate you get:

- No syntactic surprises. Your database doesn't stick to the SQL
  standard - none of them do - but Yesql doesn't care. You will
  never spend time hunting for "the equivalent Ecto syntax". You will
  never need to fall back to a `fragment("some('funky'::SYNTAX)")` function.
- Better editor support. Your editor probably already has great SQL
  support. By keeping the SQL as SQL, you get to use it.
- Team interoperability. DBAs and developers less familiar with Ecto can
  read and write the SQL you use in your Elixir project.
- Easier performance tuning. Need to `EXPLAIN` that query plan? It's
  much easier when your query is ordinary SQL.
- Query reuse. Drop the same SQL files into other projects, because
  they're just plain ol' SQL. Share them as a submodule.
- Simplicity. This is a very small library, it is easier to understand
  and review than Ecto and similar.


### When Should I Not Use Yesql?

When you need your SQL to work with many different kinds of
database at once. If you want one complex query to be transparently
translated into different dialects for MySQL, Oracle, Postgres etc.,
then you genuinely do need an abstraction layer on top of SQL.


## Alternatives

We've talked about Ecto, but how does Yesql compare to `$OTHER_LIBRARY`?

### [eql](https://github.com/artemeff/eql)

eql is an Erlang library with similar inspiration and goals.

- eql offers no solution for query execution, the library user has to
  implement this. Yesql offers a friendly API.
- Being an Erlang library eql has to compile the queries at runtime, Yesql
  does this at compile time so you don't need to write initialisation code and
  store your queries somewhere.
- eql requires the `neotoma` PEG compiler plugin, Yesql only uses the Elixir
  standard library.
- Yesql uses prepared statements so query parameters are sanitised and are
  only valid in positions that your database will accept parameters. eql
  functions more like a templating tool so parameters can be used in any
  position and sanitisation is left up to the user.
- A subjective point, but I believe the Yesql's implementation is simpler than
  eql's, while offering more features.


## Development & Testing

```sh
createdb yesql_test
mix deps.get
mix test
```


## Other Languages

Yesql ~~rips off~~ is inspired by [Kris Jenkins' Clojure Yesql](https://github.com/krisajenkins/yesql).
Similar libraries can be found for many languages:

| Language   | Project                                            |
| ---        | ---                                                |
| C#         | [JaSql](https://bitbucket.org/rick/jasql)          |
| Clojure    | [YeSPARQL](https://github.com/joelkuiper/yesparql) |
| Clojure    | [Yesql](https://github.com/krisajenkins/yesql)     |
| Erlang     | [eql](https://github.com/artemeff/eql)             |
| Go         | [DotSql](https://github.com/gchaincl/dotsql)       |
| Go         | [goyesql](https://github.com/nleof/goyesql)        |
| JavaScript | [Preql](https://github.com/NGPVAN/preql)           |
| JavaScript | [sqlt](https://github.com/eugeneware/sqlt)         |
| PHP        | [YepSQL](https://github.com/LionsHead/YepSQL)      |
| Python     | [Anosql](https://github.com/honza/anosql)          |
| Ruby       | [yayql](https://github.com/gnarmis/yayql)          |


## License

Copyright © 2018 Louis Pilfold. All Rights Reserved.
