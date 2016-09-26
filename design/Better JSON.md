## Views
We will have json view files in `views/<table_name>/<format>.json`.  These files will store hashes in the same format as the options hashes for as_json.

## Extension
as_json is extended on all models to either:

a) Load a view file if the :format option was provided at the aforementioned path.
b) Load the base view file if no :format, :only, :except, :include, or :methods options were provided.
c) Else calls super(options)

## Caching
Having the view templates compiled and cached would be best for performance.  See [rabl-rails#library.rb](https://github.com/ccocchi/rabl-rails/blob/master/lib/rabl-rails/library.rb).  A potential configuration option could allow the cache to be watched and templates recompiled if edited while the application is running.

## Controllers
We probably want to make a custom responder to call as_json with the proper format argument for the controller action like [rabl-rails#reponder.rb](https://github.com/ccocchi/rabl-rails/blob/master/lib/rabl-rails/responder.rb).

A possible extension is to have the controller action default to the base format if a view for the action isn't found, and/or to allow the user to override an action to use a specific template without calling render directly.

```ruby
# Better name pending
module BetterJson
  extend ActiveSupport::Concern
  
  # noinspection RubySuperCallWithoutSuperclassInspection
  def as_json(options={})
    if json_options_empty(options)
      super(load_json_template(options[:format] || :base)
    else
      super(options)
    end
  end
    
  def json_options_empty(options)
    keys = [:include, :only, :except, :methods]
    !(options.keys & keys).any?
  end
  
  # TODO: Template caching
  def load_json_template(format)
    file = File.read(json_template_path(format))
    JSON.parse(file)
  end
  
  def json_template_path(format)
    Rails.root.join('app', 'views', self.class.table_name, "#{format}.json")
  end
end
```
