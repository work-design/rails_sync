# TheSync

This tools allow sync one way two tables one the moment, dont use BINLOG, compare
every row beetwen tables with MD5 algorithm to search changes, before create DML
sentences to equal same tables.

- Don't use BINLOG.
- Don't need SUPER PRIVILEGES.


## Usage


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'the_sync'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install the_sync
```

## Warning
* Source table and destined table must have same Primary Key value, `the_sync` use primary key to as ID.


## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## reference
* [mysqlsync](https://github.com/swapbyt3s/mysqlsync), The tool gives me inspiration, thanks!
