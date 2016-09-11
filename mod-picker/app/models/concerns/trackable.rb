module Trackable
  extend ActiveSupport::Concern

  included do
    class_attribute :_subscriptions
    class_attribute :_tracked_columns
    self._subscriptions = []
    self._tracked_columns = []

    has_many :events, :as => 'content', :dependent => :nullify
  end

  def subscriber_ids_for(event)
    user_ids = []
    subscriptions.each do |subscription|
      next unless subscription[:actions].include?(event.event_type.to_sym)
      users = public_send(subscription[:users]) || []
      users = [users] if !users.respond_to?(:to_a)
      users.each do |user|
        if user.subscribed_to?(event) && Ability.new(user).can?(:read, self)
          user_ids.push(user.id)
        end
      end
    end

    user_ids.uniq
  end

  def notify_subscribers(event)
    notification_records = subscriber_ids_for(event).map do |user_id|
      { event_id: event.id, user_id: user_id }
    end
    Notification.create(notification_records)
  end

  def event_owner_attributes(event_type)
    case event_type
      when "added"
        return config.added_owner_attributes || [:added_by]
      when "removed"
        return config.removed_owner_attributes || [:removed_by]
      else
        return config.updated_owner_attributes || [:updated_by]
    end
  end

  def get_owner_id(event_type)
    attributes = event_owner_attributes(event_type)
    if attributes.present?
      attributes.each do |attr|
        return public_send(attr) if respond_to?(attr)
      end
    end

    nil
  end

  def create_event(event_type)
    events.create(user_id: get_owner_id(event_type), event_type: event_type)
  end

  def track_column_change(event, column)
    return unless attribute_changed?(column)
    if self.class.columns_hash[column].type == :boolean
      create_event(self.public_send(column) ? event : :"un#{event}")
    else
      create_event(event)
    end
  end

  def track_milestone_change(column, milestones)
    return unless attribute_changed?(column)
    def get_milestone(value)
      milestones.each_with_index do |milestone, index|
        return index - 1 if value < milestone
      end
    end

    old_milestone = get_milestone(attribute_was(column))
    new_milestone = get_milestone(public_send(column))
    create_event(:"milestone#{new_milestone}") if old_milestone < new_milestone
  end

  def subscriptions
    @__subscriptions ||= self._subscriptions
  end

  def tracked_columns
    @__tracked_columns ||= self._tracked_columns
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
          tracked_columns.each do |tracked|
            if tracked.has_key?(:milestones)
              track_milestone_change(tracked[:column], tracked[:milestones])
            else
              track_column_change(tracked[:event], tracked[:column])
            end
          end
        end
      end
    end

    def track_change(event, options={})
      self._tracked_columns.push({
          event: event,
          column: options.has_key?(:column) ? options[:column].to_sym : event
      })
      create_changed_callback_if_missing
    end

    def track_milestones(options={})
      self._tracked_columns.push({
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