# In config/initializers/rack-attack.rb
class Rack::Attack
  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  throttle('sign_in/ip', :limit => 5, :period => 10.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end

  # Throttle POST requests to /login by email param
  throttle("sign_in/account", :limit => 5, :period => 10.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      # return the email if present, nil otherwise
      req.params['login'].presence
    end
  end


  ### Mitigate Contributions System Abuse ###
  #
  # Users could submit a bunch of false/incorrect/malicious data, potentially
  # creating a lot of work for admins to clean up.  We should throttle the
  # amount of submissions users can make.

  # Throttle POST requests to new content by IP
  throttle("new_content", :limit => 60, :period => 60.minutes) do |req|
    if req.post? &&
       (req.path == '/compatibility_notes' ||
        req.path == '/install_order_notes' ||
        req.path == '/load_order_notes' ||
        req.path == '/reviews' ||
        req.path == '/comments' ||
        req.path == '/mod_lists' ||
        req.path == '/mods')
      req.ip
    end
  end

  # Throttle POST requests to new mod or mod list tags by IP
  throttle("tag_associations", :limit => 80, :period => 40.minutes) do |req|
    if req.post? && /\/(mods|mod_lists)\/([0-9]+)\/tag/.match(req.path)
      req.ip
    end
  end

  # Throttle POST requests to make new tags by IP
  throttle("new_tags", :limit => 20, :period => 60.minutes) do |req|
    if req.post? && req.path == '/tags'
      req.ip
    end
  end

  # Throttle POST requests to make new corrections by IP
  throttle("new_tags", :limit => 12, :period => 60.minutes) do |req|
    if req.post? && req.path == '/corrections'
      req.ip
    end
  end


  ### Prevent Request Flooding ###
  #
  # We should limit scraping strongly to prevent users from querying other
  # site’s servers too much.  We should limit requests overall to mitigate
  # DDOS attacks.

  # Throttle scraping by IP
  throttle("scraping", :limit => 20, :period => 40.minutes) do |req|
    if req.get? && req.path == '/nexus_infos'
      req.ip
    end
  end

  # Throttle tags index by IP
  # throttle("tags_index", :limit => 1, :period => 4.minutes) do |req|
  #   if req.get? && req.path == '/tags'
  #     req.ip
  #   end
  # end

  # Throttle all requests by IP (180rpm) excluding assets
  throttle('req/ip', :limit => 900, :period => 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  # Whitelist POST requests from admin users
  # whitelist('allow from admins') do |req|
  #   if req.post?
  #     user_id = req.env['rack.session']["warden.user.user.key"][0][0]
  #     current_user = User.find(user_id)
  #     current_user.present? && current_user.admin?
  #   end
  # end


  ### Custom Throttle Response ###
  self.throttled_response = lambda do |env|
    # respond 304 not modified for throttles where we want to force caching
    # if env['rack.attack.matched'] == 'tags_index'
    #   status = 304
    # respond 503 service unavailable if it looks like a DDOS attack
    if env['rack.attack.matched'] == 'req/ip'
      status = 503
    else
      status = 429
    end

    # response
    [ status,  # status
      {},   # headers
      ['']] # body
  end
end