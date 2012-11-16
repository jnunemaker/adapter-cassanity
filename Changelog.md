# Changelog

## 0.2.0

* Added adapter options: :read, :write, :delete. These can be used to tune consistency and all other operation arguments.
* Added method options (ie: read('key', using: {consistency: :quorum})). Method operations override any similar adapter options.
