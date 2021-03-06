module Trackable
  extend ActiveSupport::Concern

  included do
    class_attribute :_subscriptions
    class_attribute :_tracked_attributes
    self._subscriptions = []
    self._tracked_attributes = []

    has_many :events, :as => 'content', :dependent => :destroy
  end

  def get_subscription_users(subscription)
    unless respond_to?(subscription[:users])
      raise "Subscription association for #{subscription[:users]} not found"
    end
    users = public_send(subscription[:users]) || []
    if users.respond_to?(:to_a)
      users
    else
      [users]
    end
  end

  def subscriber_ids_for(event)
    user_ids = []
    subscriptions.each do |subscription|
      next unless subscription[:actions].include?(event.event_type.to_sym)
      users = get_subscription_users(subscription)
      users.each do |user|
        if user.subscribed_to?(event) && Ability.new(user).can?(:read, self)
          user_ids.push(user.id)
        end
      end
    end

    user_ids.uniq - [event.user_id]
  end

  def notify_subscribers(event)
    notification_records = subscriber_ids_for(event).map do |user_id|
      { event_id: event.id, user_id: user_id }
    end
    Notification.create(notification_records) if notification_records.any?
  end

  def event_owner_attributes(event_type)
    config = Rails.application.config
    case event_type
      when :added
        return config.added_owner_attributes || [:added_by]
      when :removed
        return config.removed_owner_attributes || [:removed_by]
      else
        return config.updated_owner_attributes || [:updated_by]
    end
  end

  def get_owner_id(event_type)
    event_owner_attributes(event_type).each { |attr|
      return public_send(attr) if respond_to?(attr)
    }
    nil
  end

  def create_event(event_type)
    events.create(user_id: get_owner_id(event_type), event_type: event_type)
  end

  def track_attribute_change(event, column)
    return unless attribute_changed?(column)
    if self.class.columns_hash[column.to_s].type == :boolean
      create_event(self.public_send(column) ? event : :"un#{event}")
    else
      create_event(event)
    end
  end

  def get_milestone(milestones, value)
    for index in 0 .. milestones.size - 1
      return index if value < milestones[index]
    end
    milestones.size
  end

  def track_milestone_change(column, milestones)
    return unless attribute_changed?(column)
    old_milestone = get_milestone(milestones, attribute_was(column))
    new_milestone = get_milestone(milestones, public_send(column))
    return if old_milestone == new_milestone
    ((old_milestone + 1)..new_milestone).each { |n| create_event(:"milestone#{n}") }
  end

  def subscriptions
    @__subscriptions ||= self._subscriptions
  end

  def tracked_attributes
    @__tracked_attributes ||= self._tracked_attributes
  end

  module ClassMethods
    def subscribe(users, options={})
      self._subscriptions.push({users: users, actions: options[:to]})
    end

    def track_added(options={})
      class_eval do
        after_create :added_event
        def added_event
          create_event(:added)
        end
      end
    end

    def track_updated(options={})
      class_eval do
        after_update :updated_event
        def updated_event
          create_event(:updated)
        end
      end
    end

    def track_removed(options={})
      class_eval do
        after_destroy :removed_event
        def removed_event
          create_event(:removed)
        end
      end
    end

    def create_changed_callback_if_missing
      return if self.respond_to?(:changed_event)
      class_eval do
        after_update :changed_event
        def changed_event
          tracked_attributes.each do |tracking|
            if tracking.has_key?(:milestones)
              track_milestone_change(tracking[:column], tracking[:milestones])
            else
              track_attribute_change(tracking[:event], tracking[:column])
            end
          end
        end
      end
    end

    def track_change(event, options={})
      self._tracked_attributes.push({
          event: event,
          column: options.has_key?(:column) ? options[:column].to_sym : event
      })
      create_changed_callback_if_missing
    end

    def track_milestones(options={})
      self._tracked_attributes.push({
          column: options[:column].to_sym,
          milestones: options[:milestones]
      })
      create_changed_callback_if_missing
    end

    def track(*events, **options)
      events.each do |event|
        case event
          when :added
            track_added(options)
          when :updated
            track_updated(options)
          when :removed
            track_removed(options)
          else
            track_change(event, options)
        end
      end
    end
  end
end