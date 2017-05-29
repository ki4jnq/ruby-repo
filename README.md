# Ruby-Repo
### A lightweight Repository implementation based on the Sequel gem.

## Goals

Often Rails developers find themselves wishing they were working with objects
that were A) not as magical, B) lighterweight, or C) less monolithic than
ActiveRecord objects.

Many people reach for a pseudo-repository pattern solve there problems by
wrapping interaction ActiveRecord's query methods in small "repository"
objects. While this may lead it cleaner code, it still fails to address the
fact that ActiveRecord is heavy and the objects can still incur significant
overhead.

Ruby-Repo attempts to solve these by replacing ActiveRecord. It relies on the
excellent Sequel gem https://github.com/jeremyevans/sequel to manage building
SQL queries, and focuses on defining "Repository" objects.

## Structure

Ruby-Repo defines three levels to the "model" layer, which are from top to
bottom:

1. Entity models
2. Repositories
3. Physical models

### Entities

Entity objects are POROs. The example "user" and "post" entities utilize the
"Virtus" gem to make the definition of their attributes more declarative, but
it is not necessary. Entities can be very lightweight by design and can also
be treated as value objects, where as two entities with the same value may be
treated as equivalent. However, ruby-repo makes no decisions for you in this
regard.

Entities know nothing of the database from which they were loaded by design,
they are intended to purely model business objects. Entities are usually
loaded from the DB, but your app is free to create them anyay you want!

### Physical Models

Physical models model the data as it lives in the database. Currently, they
basically define your schema in a way that a Repository object can inspect.

### Repositories

Repositories form the glue between Entities and Physical models by inspecting
the Physical layer to understand how to build entitiy objects from the data.
Repositories do not try to hide you from the SQL, but instead encourage you to
write "nearly sql" in Ruby. Ideally, all of your query logic belongs to your
repositories.

Repositories do define bracket operations by default, but there is nothing to
stop you from defining your own. In this regard, ruby-repo's repositories
differ from the standard Repository pattern.
