# Changelog

## 0.5.0

* Drop support for composite primary keys.
* Force supplying primary_key for adapter rather than reflecting from schema. Since cassanity has migrations, it is no longer needed to always supply schema. Easier to pass primary key and more performant than reflecting from the database like AR does.

## 0.3.0

* Updates for adapter 0.7.0.

## 0.2.0

* Added adapter options: :read, :write, :delete. These can be used to tune consistency and all other operation arguments.
* Added method options (ie: read('key', using: {consistency: :quorum})). Method operations override any similar adapter options.
