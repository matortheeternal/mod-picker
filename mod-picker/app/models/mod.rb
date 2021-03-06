class Mod < ActiveRecord::Base
  include Filterable, Sortable, Reportable, Imageable, RecordEnhancements, CounterCache, SourceHelpers, ScopeHelpers, Searchable, Trackable, BetterJson, Dateable, Approveable

  # ATTRIBUTES
  enum status: [ :good, :outdated, :unstable ]
  enum notice_type: [ :success, :warning, :error ]
  attr_accessor :updated_by, :mark_updated
  self.per_page = 60
  self.approval_method = :has_mod_auto_approval?

  # DATE COLUMNS
  date_column :submitted

  # EVENT TRACKING
  track :added, :hidden, :updated
  #track_change :analysis_updated, :column => 'updated'
  track_milestones :column => 'stars_count', :milestones => [10, 50, 100, 500, 1000, 5000, 10000, 50000, 100000, 500000]

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :author_users, to: [:updated, :hidden, :unhidden, *Event.milestones]
  # TODO: Fix this.
  # subscribe :contribution_authors, to: [:analysis_updated]
  # subscribe :user_stars, to: [:analysis_updated]

  # SCOPES
  hash_scope :approved, alias: 'approved'
  hash_scope :hidden, alias: 'hidden'
  hash_scope :adult, alias: 'adult', column: 'has_adult_content'
  include_scope :is_official, :alias => 'include_official'
  include_scope :is_utility, :alias => 'include_utilities'
  value_scope :is_utility
  game_scope :parent => true
  enum_scope :status
  date_scope :released, :updated, :submitted
  range_scope :reputation, :tags_count
  range_scope :average_rating, :alias => 'rating'
  counter_scope :mod_options_count, :plugins_count, :asset_files_count, :required_mods_count, :required_by_count, :stars_count, :mod_lists_count, :reviews_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count, :related_mod_notes_count, :corrections_count
  source_search_scope :mod_name, :sites => [:nexus, :lab, :workshop]
  source_scope :views, :sites =>  [:nexus, :lab, :workshop]
  source_scope :downloads, :sites => [:nexus, :lab]
  source_scope :file_size, :sites => [:nexus, :lab]
  source_scope :posts, :sites => [:nexus, :workshop], :alias => [:posts_count, :comments_count]
  source_scope :videos, :sites => [:nexus, :workshop], :alias => [:videos_count, :videos_count]
  source_scope :images, :sites => [:nexus, :workshop], :alias => [:images_count, :images_count]
  source_scope :favorites, :sites => [:lab, :workshop], :alias => [:followers_count, :favorites]
  source_scope :discussions, :sites => [:nexus, :workshop]
  source_scope :endorsements, :sites => [:nexus]
  source_scope :unique_downloads, :sites => [:nexus]
  source_scope :files, :sites => [:nexus], :alias => [:files_count]
  source_scope :bugs, :sites => [:nexus], :alias => [:bugs_count]
  source_scope :articles, :sites => [:nexus], :alias => [:articles_count]
  source_scope :subscribers, :sites => [:workshop]
  relational_division_scope :tags, :text, [
      { class_name: 'ModTag', join_on: :mod_id, joinable_on: :tag_id },
      { class_name: 'Tag', join_on: :id }
  ]

  # UNIQUE SCOPES
  scope :visible, -> { where(hidden: false, approved: true) }
  scope :include_games, -> (bool) { where.not(primary_category_id: nil) if !bool }
  scope :compatibility, -> (mod_list_id) {
    mod_list = ModList.find(mod_list_id)
    where.not(id: mod_list.incompatible_mod_ids)
  }
  scope :excluded_tags, -> (tags) {
    tags_condition = ModTag.arel_table.project(Arel.sql('*')).where(Mod.arel_table[:id].eq(ModTag.arel_table[:mod_id])).join(Tag.arel_table, Arel::Nodes::OuterJoin).on(ModTag.arel_table[:tag_id].eq(Tag.arel_table[:id])).where(Tag.arel_table[:text].in(tags)).exists.not
    where(tags_condition)
  }
  scope :tag_groups, -> (tag_groups) {
    conditions = tag_groups.map do |tag_group|
      if tag_group.has_key?(:include)
        tags_condition.where(Tag.arel_table[:text].in(tag_group[:include])).exists
      elsif tag_group.has_key?(:exclude)
        tags_condition.where(Tag.arel_table[:text].in(tag_group[:exclude])).exists.not
      end
    end
    where(conditions.inject(:and))
  }
  scope :terms, -> (terms) {
    eager_load(:mod_licenses).where(terms.map {|key,value| ModLicense.arel_table[key].eq(value)}.inject(:and))
  }
  scope :sources, -> (sources) {
    eager_load(sources.map {|key, value| get_source_class(key).table_name if value}.compact).
        where(sources.map {|key, value|
          get_source_class(key).arel_table[get_source_primary_key_column(key)].not_eq(nil) if value}.compact.inject(:or))
  }
  scope :source_mod_name, -> (mod_name, source_class) {
    eager_load(source_class.table_name).where(source_class.arel_table[:mod_name].eq(mod_name))
  }
  scope :categories, -> (ids) { where("primary_category_id in (:ids) OR secondary_category_id in (:ids)", ids: ids) }
  scope :nexus_id, -> (id) {
    eager_load(:nexus_infos).where(nexus_infos: { nexus_id: id })
  }

  belongs_to :game, :inverse_of => 'mods'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'submitted_mods'

  # categories the mod belongs to
  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'primary_category_id', :inverse_of => 'primary_mods'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'secondary_category_id', :inverse_of => 'secondary_mods'

  # site statistics associated with the mod
  has_one :nexus_infos, :class_name => 'NexusInfo', :dependent => :nullify
  has_one :lover_infos, :class_name => 'LoverInfo', :dependent => :nullify
  has_one :workshop_infos, :class_name => 'WorkshopInfo', :dependent => :nullify

  # custom sources
  has_many :custom_sources, :inverse_of => 'mod', :dependent => :destroy

  # mod options
  has_many :mod_options, :inverse_of => 'mod', :dependent => :destroy
  # plugins associated with the mod
  has_many :plugins, :inverse_of => 'mod', :through => 'mod_options'
  # assets associated with the mod
  has_many :mod_asset_files, :inverse_of => 'mod', :through => 'mod_options'
  has_many :asset_files, :through => :mod_asset_files, :inverse_of => 'mods'

  # requirements associated with the mod
  has_many :required_mods, -> { order(:required_id) }, :class_name => 'ModRequirement', :inverse_of => 'mod', :dependent => :destroy
  has_many :required_by, -> { order(:mod_id) }, :class_name => 'ModRequirement', :inverse_of => 'required_mod', :foreign_key => 'required_id', :dependent => :destroy

  # config files associated with the mod
  has_many :config_files, :inverse_of => 'mod', :dependent => :destroy

  # license
  has_many :mod_licenses

  # users who can edit the mod
  has_many :mod_authors, :inverse_of => 'mod', :dependent => :destroy
  has_many :author_users, :class_name => 'User', :through => 'mod_authors', :source => 'user', :inverse_of => 'mods'

  # curator requests on the mod
  has_many :curator_requests, :inverse_of => 'mod', :dependent => :destroy

  # community feedback on the mod
  has_many :corrections, :as => 'correctable', :dependent => :destroy
  has_many :reviews, :inverse_of => 'mod', :dependent => :destroy
  has_many :mod_stars, :inverse_of => 'mod', :dependent => :destroy
  has_many :user_stars, :class_name => 'User', :through => 'mod_stars', :source => 'user', :inverse_of => 'starred_mods'

  # tags
  has_many :mod_tags, :inverse_of => 'mod', :dependent => :destroy
  has_many :tags, :through => 'mod_tags', :inverse_of => 'mods'

  # mod list usage
  has_many :mod_list_mods, :inverse_of => 'mod', :dependent => :destroy
  has_many :mod_lists, :through => 'mod_list_mods', :inverse_of => 'mods'

  accepts_nested_attributes_for :mod_options, allow_destroy: true
  accepts_nested_attributes_for :custom_sources, allow_destroy: true
  accepts_nested_attributes_for :config_files, allow_destroy: true
  accepts_nested_attributes_for :mod_licenses, allow_destroy: true
  # cannot update required mods
  accepts_nested_attributes_for :required_mods, reject_if: proc {
      |attributes| attributes[:id] && !attributes[:_destroy]
  }, allow_destroy: true
  # can only update author role for an existing mod_author record
  accepts_nested_attributes_for :mod_authors, reject_if: proc {
      |attributes| attributes[:id] && attributes[:user_id] && !attributes[:_destroy]
  }, allow_destroy: true

  # COUNTER CACHE
  counter_cache :required_mods, :required_by
  counter_cache :mod_stars, column: 'stars_count'
  counter_cache :reviews, conditional: { hidden: false, approved: true }
  counter_cache :compatibility_notes, conditional: { hidden: false, approved: true },
      custom_reflection: { klass: CompatibilityNote, query_method: 'mod_count_subquery' }
  counter_cache :related_mod_notes, conditional: { hidden: false, approved: true },
      custom_reflection: { klass: RelatedModNote, query_method: 'mod_count_subquery' }
  counter_cache :install_order_notes, conditional: { hidden: false, approved: true },
      custom_reflection: { klass: InstallOrderNote, query_method: 'mod_count_subquery' }
  counter_cache :load_order_notes, conditional: { hidden: false, approved: true },
      custom_reflection: { klass: LoadOrderNote, query_method: 'mod_count_subquery' }
  counter_cache :corrections, conditional: { hidden: false, correctable_type: 'Mod' }
  counter_cache :mod_tags, column: 'tags_count'
  counter_cache :mod_list_mods, column: 'mod_lists_count'
  counter_cache_on :submitter, column: 'submitted_mods_count', conditional: { hidden: false, approved: true }

  # VALIDATIONS
  validates :game_id, :submitted_by, :name, :authors, :released, presence: true
  validates :name, :aliases, length: {maximum: 128}

  # CALLBACKS
  before_create :set_id
  before_save :touch_updated

  def self.find_by_mod_name(mod_name, game)
    base_query = Mod.visible.game(game)
    base_query.search(mod_name).first ||
        base_query.source_mod_name(mod_name, NexusInfo).first ||
        base_query.source_mod_name(mod_name, LoverInfo).first ||
        base_query.source_mod_name(mod_name, WorkshopInfo).first
  end

  def self.find_batch(batch, game)
    batch.collect do |item|
      if item.has_key?(:nexus_info_id)
        Mod.visible.game(game).nexus_id(item[:nexus_info_id]).first
      else
        Mod.find_by_mod_name(item[:mod_name], game)
      end
    end
  end

  def self.submission_history(time_zone)
    pluck(:submitted).group_by { |d|
      d.in_time_zone(time_zone).to_date.to_s(:db)
    }.map { |k,v| [k, v.length] }.sort
  end

  def self.tags_condition
    ModTag.arel_table.project(Arel.sql('*')).where(Mod.arel_table[:id].eq(ModTag.arel_table[:mod_id])).join(Tag.arel_table, Arel::Nodes::OuterJoin).on(ModTag.arel_table[:tag_id].eq(Tag.arel_table[:id])).where(ModTag.arel_table[:mod_id].eq(Mod.arel_table[:id]))
  end

  def visible
    approved && !hidden
  end

  def was_visible
    return false if new_record?
    attribute_was(:approved) && !attribute_was(:hidden)
  end

  def url
    sources_array.first.url
  end

  def sources_array
    [nexus_infos, workshop_infos, lover_infos, custom_sources].flatten.compact
  end

  def source_links
    sources_array.map {|source| source.url}
  end

  def quality_options
    opts = {}
    opts[:lq] = 1 if tags.any?{|tag| tag.text == "Low Quality Option"}
    opts[:hq] = 1 if tags.any?{|tag| tag.text == "High Quality Option"}
    opts
  end

  def dlc_requirements
    req_mods = association(:required_mods).loaded? ? required_mods : []
    req_mods.each_with_object(Hash.new(0)) do |req, reqs|
      reqs[req.required_mod.name] = 1 if req.required_mod.is_official
    end
  end

  def correction_passed(correction)
    update_columns(status: Mod.statuses[correction.mod_status])
  end

  def asset_file_paths
    mod_asset_files.eager_load(:asset_file).pluck(:subpath, :path).map { |item| item.join('') }
  end

  def update_lazy_counters
    mod_option_ids = mod_options.ids
    self.mod_options_count = mod_options.count
    self.asset_files_count = ModAssetFile.mod_options(mod_option_ids).count
    self.plugins_count = Plugin.mod_options(mod_option_ids).count
  end

  def compute_average_rating
    total = reviews.visible.reduce(0) { |total, r| total += r.overall_rating }
    self.average_rating = total / (reviews.length.nonzero? || 1)
  end

  def review_reputation
    (average_rating / 100)**3 * (510.0 / (1 + Math::exp(-0.2 * (reviews_count - 10))) - 60)
  end

  def use_nexus_reputation
    reviews_count < 5 && NexusInfo.can_scrape_statistics? && nexus_infos.present?
  end

  def compute_reputation
    self.reputation = use_nexus_reputation ? nexus_infos.endorsement_reputation : review_reputation
    self.reputation = reputation / 4 if status == :unstable
    self.reputation = reputation / 2 if status == :outdated
  end

  def update_metrics
    nexus_infos.compute_extra_metrics if nexus_infos.present?
    compute_average_rating
    compute_reputation
    update_lazy_counters
    save!
  end

  def update_review_metrics
    compute_average_rating
    compute_reputation
    update_columns({
        :reputation => reputation,
        :average_rating => average_rating
    })
  end

  # note associations
  def compatibility_notes
    CompatibilityNote.mod(id)
  end

  def install_order_notes
    InstallOrderNote.mod(id)
  end

  def load_order_notes
    LoadOrderNote.plugin(plugins.pluck(:filename).uniq)
  end

  def related_mod_notes
    RelatedModNote.mod(id)
  end

  def contribution_authors
    User.contributors(self)
  end

  def links_text
    a = ["    - #{name}:"]
    space = " " * 8
    a.push("#{space}Nexus Mods: #{nexus_infos.url}") if nexus_infos
    a.push("#{space}Lover's Lab: #{lover_infos.url}") if lover_infos
    a.push("#{space}Steam Workshop: #{workshop_infos.url}") if workshop_infos
    custom_sources.each { |source| a.push("#{space}#{source.label}: #{source.url}") }
    a.join("\r\n") + "\r\n"
  end

  private
    def touch_updated
      if mark_updated
        self.updated ||= DateTime.now
        self.updated += 1.second
      end
    end

    def set_id
      self.id = next_id
    end
end
