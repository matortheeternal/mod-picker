## Views
We will have json view files in `views/<table_name>/<template>.json`.  These files will store hashes in the same format as the options hashes for as_json.

## JSON Extension
`as_json` is extended on all models to either:

1. Load a view file if the `:template` option was provided at the aforementioned path.
2. Load the base view file if no `:template`, `:only`, `:except`, `:include`, or `:methods` options were provided.
3. Else calls `super(options)`

## Caching
Having the view templates compiled and cached would be best for performance.  See [rabl-rails#library.rb](https://github.com/ccocchi/rabl-rails/blob/master/lib/rabl-rails/library.rb).  A potential configuration option could allow the cache to be watched and templates recompiled if edited while the application is running.

## Controllers
We probably want to make a custom responder to call as_json with the proper template argument for the controller action like [rabl-rails#responder.rb](https://github.com/ccocchi/rabl-rails/blob/master/lib/rabl-rails/responder.rb).

A possible extension is to have the controller action default to the base format if a view for the action isn't found, and/or to allow the user to override an action to use a specific template without calling render directly.

```ruby
# Better name pending
module BetterJson
  extend ActiveSupport::Concern
  
  included do
    class_attribute :_json_template_cache
    self._json_template_cache = {}
  end
  
  # noinspection RubySuperCallWithoutSuperclassInspection
  def as_json(options={})
    if json_options_empty(options)
      super(get_json_template(options[:template] || :base)
    else
      super(options)
    end
  end
    
  def json_options_empty(options)
    keys = [:include, :only, :except, :methods]
    !(options.keys & keys).any?
  end
  
  def get_json_template(template)
    self.class._json_template_cache[template] || load_json_template(template)
  end
  
  def load_json_template(template)
    file = File.read(json_template_path(template))
    self.class._json_template_cache[template] = JSON.parse(file)
  end
  
  def json_template_path(template)
    Rails.root.join('app', 'views', self.class.table_name, "#{template}.json")
  end
end
```
