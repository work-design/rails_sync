# RailsSync

This tools allow sync one way two tables one the moment, dont use BINLOG, compare
every row beetwen tables with MD5 algorithm to search changes, before create DML
sentences to equal same tables.

- Did not use BINLOG.
- Don't need SUPER PRIVILEGES.


## Usage


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails_sync'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install rails_sync
```

## Warning
* Source table and destined table must have same Primary Key value, `rails_sync` use primary key to as ID.


## Contributing
Bug report or pull request are welcome.

### Make a pull request
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
### Please write unit test with your code if necessary.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## reference
* [mysqlsync](https://github.com/swapbyt3s/mysqlsync), The tool brings me inspiration.
