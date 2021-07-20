A place for all one-off or general purpose scripts. This could include benchmarks or cleanup code.

`./script/migrate/` for data migration
`./script/cleanup/` for data cleanup
`./script/benchmark/` for benchmarking

Reference:
- https://guides.rubyonrails.org/command_line.html#rails-runner
- https://discuss.rubyonrails.org/t/is-there-any-official-way-to-organize-one-off-scripts/74186/11
- https://boringrails.com/articles/rails-database-migrations-strategy-how-to-manage-migrations-without-losing-your-mind/
- https://www.justinweiss.com/articles/writing-a-one-time-script-in-rails/

# Example

Create a script.

```ruby
# ./script/migrate/move_a_to_b_example.rb
require_relative "../../config/environment"
Rails.logger.info "Running #{__FILE__}"

impossible_users = User.inactive.where(updated_at: Date.tomorrow..)
impossible_users.update_all updated_at: Time.current

Rails.logger.info "❌💥 nothing was changed!"
Rails.logger.info "❓ what's the point?"
Rails.logger.info "✔️🚀✨ successful example!"
```

After testing in development, run it in production.

```bash
tail -f log/development.log
bundle exec rails runner -e development script/migrate/move_a_to_b_example.rb
```
