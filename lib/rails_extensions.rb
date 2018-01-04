# Inspired from: http://stackoverflow.com/a/677141

# TODO: Refactor this file in several files.

class Object
  # Returns the object itself if either is equal to the argument or (if the
  # argument is a collection) is contained in the argument. In all other cases
  # it returns nil. Note that therefore this method will always return nil when
  # called on nil itself (see NilClass#allow). If the argument is a collection,
  # it can be anything Enumerable, but usually a constant Set is the most
  # interesting for performance, e.g. ALLOWED_VIEWS = Set[:all, :admins].
  # Similar to Rails' #permit but for all objects.
  def allow(allowed_item_or_items)
    if allowed_item_or_items.is_a? Enumerable
      allowed_item_or_items.find { |item| item == self }
    elsif self == allowed_item_or_items
      self
    end
  end
end

class NilClass
  # Since the default Object#allow method does always return nil when called on
  # nil, we don't need to call it, and we can directly return nil.
  def allow(_)
    self
  end
end

# TODO: Consider relocating all the extensions in this file in proper places.
require_relative '../config/initializers/enum'

class Array

  class ClosestType < Enum
    enum :ABSOLUT
    enum :EQUAL_OR_GREATER
    enum :GREATER
    enum :EQUAL_OR_LESS
    enum :LESS
  end

  def find_closest_to(reference, closest_type: ClosestType::ABSOLUT)
    begin
      case closest_type
      when ClosestType::ABSOLUT
        min_by { |item| (item - reference).abs }
      when ClosestType::EQUAL_OR_GREATER
        sort.find { |item| item >= reference }
      when ClosestType::GREATER
        sort.find { |item| item > reference }
      when ClosestType::EQUAL_OR_LESS
        # NOTE: Seems like sort.reverse is the most efficient way to sort an
        #       array in descending order in Ruby.
        # SOURCE: http://stackoverflow.com/a/2651028
        sort.reverse.find { |item| item <= reference }
      when ClosestType::LESS
        sort.reverse.find { |item| item < reference }
      end
    rescue Exception => e
      raise "unable to find the #{closest_type} closest to #{reference.class}" +
            " '#{reference.inspect}' for an array of " +
            "#{map(&:class).uniq.join(' and ')} objects: #{e.class} '#{e}'" +
            " in #{e.backtrace.find {|s| s.match? __method__.to_s} }"
    end
  end

  def find_equal_or_greater_closest_to(reference)
    find_closest_to(reference, closest_type: ClosestType::EQUAL_OR_GREATER)
  end
end

class Hash

  # Returns the value given a path of keys, without failing.
  # NOTE: This method was initially written while on ruby v2.2, and the :dig
  #       method was introduced in v2.3. However, there is a subtle difference
  #       in the implementation: While :dig will safely return nil if any
  #       intermediate step is nil, it will fail if any intermediate step is an
  #       object other than a hash. The :get version will also safely return nil
  #       in this case. Therefore this implementation is not yet removed. See
  #       tests for comparison.
  # DOC: http://ruby-doc.org/core-2.4.3/Hash.html#method-i-dig
  # SOURCE: http://stackoverflow.com/a/10131410
  def get(*args)
    res = self
    args.each do |k|
      if res.is_a?(Hash) && res.include?(k)
        res = res[k]
      else
        return nil
      end
    end
    res
  end

  # Returns the value in the map for the given key and removes the key/values
  # pair from the original map in place. Like :pop for arrays.
  alias_method :pop, :delete
  # NOTE: I first implemented :pop because I ignored the existence and exact
  #       behavior of :delete. But I just learned that the default :delete does
  #       exactly what my :pop did. So, I'm aliasing directly the original one.

  def +(other_hash)
    other_hash ||= {}
    unless other_hash.is_a? Hash
      raise "cannot merge #{other_hash.inspect} (#{other_hash.class})" +
            " into #{self} (Hash)"
    end
    self.merge(other_hash || {})
  end

  # SOURCE: http://stackoverflow.com/a/5215838
  def update_vals(method = nil, &block)
    if block_given?
      update(self) { |k,v| block.call(v)}
    else
      update(self) { |k,v| v.send(method)}
    end
  end

  def merge_by(other_hash, method)
    merge(other_hash) { |k, v1, v2| v1.send(method, v2) }
  end

  def merge_by_add(other_hash)
    merge_by other_hash, :+
  end
end

module Enumerable
  def group_by_key(k, pop_key: false)
    if pop_key
      group_by { |i| i.pop(k) }
    else
      group_by { |i| i[k] }
    end
  end

  def reduce_by_add
    reduce { |acc, hash| acc.merge_by_add(hash) }
  end
end

module Classisize
  def to_class
    to_s.classify.constantize
  end
end

module NameUtils
  def ensure_suffix(str)
    to_s.chomp(str) + str
  end
end

class Symbol
  include Classisize
  include NameUtils
  def ensure_suffix(str_or_sym)
    super(str_or_sym.to_s).to_sym
  end
  def +(other_symbol)
    unless other_symbol.nil? || other_symbol.is_a?(Symbol)
      raise TypeError, "Cannot add #{other_symbol.class} to Symbol."
    end
    (to_s + other_symbol.to_s).to_sym
  end
end

module ToIntegerUtils
  def to_i_min(min)
    [min, to_i].max
  end
end

module NonBlankUtils
  def not_blank
    return self unless blank?
  end
end

class NilClass
  include ToIntegerUtils
  include NonBlankUtils
end

module NumericFormattingUtils

  include ActionView::Helpers::NumberHelper

  # Returns a string representing the BigDecimal but only with the significant
  # digits, i.e. without insignificant trailing zeros after 'decimals' digits
  # after the comma.
  def to_s_significant(decimals: 3)
    # NOTE: Similar to something like '"%g" % self' in pure ruby but arguably
    #       easier to understand. Moreover, it's not an overhead since we have
    #       Rails available anyway.
    # SOURCE: http://stackoverflow.com/a/18592312
    # DOC: http://api.rubyonrails.org/v5.1.4/classes/ActionView/Helpers/NumberHelper.html#method-i-number_with_precision
    number_with_precision(self,
                          precision: decimals,
                          significant: false,
                          strip_insignificant_zeros: true)
  end

  # Returns a string representing the BigDecimal as a currency value, using
  # Rails' :number_to_currency method.
  def to_s_currency(locale: I18n.locale, decimals: 2)
    # DOC: http://api.rubyonrails.org/v5.1.4/classes/ActionView/Helpers/NumberHelper.html#method-i-number_to_currency
    number_to_currency(self,
                       locale: locale,
                       precision: decimals)
  end
end

module NumericPredicateUtils
  def pos?
    self > 0
  end
  def neg?
    self < 0
  end
end

# NOTE: Numeric is a base class for other, more specific, types of number
#       objects, e.g. Fixnum, Float, Bignum, BigDecimal.
# DOC: http://ruby-doc.org/core-2.4.3/Numeric.html
# SOURCE: http://stackoverflow.com/questions/8514167/float-vs-decimal-in-activerecord
class Numeric
  include NumericFormattingUtils
  include NumericPredicateUtils
end

# SOURCE: http://stackoverflow.com/a/11482430
# NOTE: If more colorization features are needed, consider adding the gem
#       https://github.com/fazibear/colorize
module Colorize
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def white
    colorize(37)
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def magenta
    colorize(35)
  end

  def pink
    magenta
  end

  def cyan
    colorize(36)
  end

  def light_blue
    cyan
  end
end

class String
  include Colorize
  include ToIntegerUtils
  include NonBlankUtils
  include NameUtils
  include Classisize

  def number
    scan(/\d/).join
  end

  # Similar to :strip but removes *all* whitespace chars, i.e. also within the
  # string, not only at both ends.
  def remove_whitespace
    # NOTE: According to the docs, \s only matches [ \t\r\n\f], i.e. it does not
    #       match e.g. non-breaking space (&nbsp). The POSIX character class
    #       [[:space:]] does match non-breaking space. This is relevant because
    #       in Heroku, space in ENV variables might be translated as &nbsp.
    # DOC: http://ruby-doc.org/core-2.4.3/Regexp.html#class-Regexp-label-Character+Classes
    # SOURCE: http://stackoverflow.com/a/13288542
    gsub(/[[:space:]]/, '')
  end

  SWISS_PHONE_NUMBER_REGEXP = /^\+41\d{9}$/

  def match?(re_or_str)
    match(re_or_str).to_b
  end

  def not_match?(re_or_str)
    !match?(re_or_str)
  end

  # Returns the string stripping all the chars before the argument string.
  def strip_up_to(str)
    raise "Argument must be a string: #{str.inspect}" unless str.is_a? String
    sub(Regexp.new("^.*?#{str}"), str)
  end

  def swiss_phone_number?
    match? SWISS_PHONE_NUMBER_REGEXP
  end

  # Returns the first letter of a string.
  # NOTE: The meaning of the original method chr is not very clear.
  def initial
    chr
  end

  # DOC: http://www.regular-expressions.info/wordboundaries.html
  # DOC: http://www.regular-expressions.info/lookaround.html
  END_OF_WORD_REGEXP = /(?<=\w)\b/

  def truncate_naturally(at: 50)
    # DOC: http://api.rubyonrails.org/v5.1.4/classes/String.html#method-i-truncate
    self.truncate(at, separator: END_OF_WORD_REGEXP)
  end

  # DOC: http://www.rubydoc.info/stdlib/erb/ERB%2FUtil.url_encode
  include ERB::Util
  def url_encoded(only_spaces: false)
    if only_spaces
      gsub(" ", "%20")
    else
      url_encode(self)
    end
  end

  def replace_spaces_with(replacement)
    gsub(/\s+/, replacement)
  end

  # SOURCE: http://stackoverflow.com/a/5492450
  # SOURCE: http://www.monkeyandcrow.com/blog/reading_rails_how_does_message_encryptor_work/
  @@persistent_encryptor = ActiveSupport::MessageEncryptor
                          .new(Rails.application.secrets.secret_key_base)

  # NOTE: The volatile encryptor uses an on-run-time created key and
  # salt, so that it's not possible to retrieve them. However, on system
  # restart, the encryptor and so its key and salt will be regenerated.
  # Strings encrypted with an old @@volatile_encryptor will not be able
  # to be decrypted again.
  # NOTE: Key length on generated key must be 32 bytes.
  # SOURCE: https://github.com/rails/rails/issues/25185
  volatile_encryption_key = ActiveSupport::KeyGenerator
                              .new(SecureRandom.uuid + SecureRandom.uuid)
                              .generate_key(SecureRandom.urlsafe_base64, 32)
  @@volatile_encryptor = ActiveSupport::MessageEncryptor
                          .new(volatile_encryption_key)


  def encrypt
    @@persistent_encryptor.encrypt_and_sign(self)
  end

  def decrypt
    @@persistent_encryptor.decrypt_and_verify(self)
  end

  # See NOTE on @@volatile_encryptor
  def volatile_encrypt
    @@volatile_encryptor.encrypt_and_sign(self)
  end

  # See NOTE on @@volatile_encryptor
  def volatile_decrypt
    @@volatile_encryptor.decrypt_and_verify(self)
  end

  # Returns the hash digest of the given string.
  # SOURCE: https://www.railstutorial.org/book/_single-page#code-digest_method
  def digest
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(self, cost: cost)
  end

  # Returns true if the hash digest matches the given string.
  # SOURCE: https://www.railstutorial.org/book/_single-page#code-digest_method
  def is_digest_for?(string)
    return false unless BCrypt::Password.valid_hash? self
    BCrypt::Password.new(self).is_password?(string)
  end

  def secure_temp_digest
    digest.volatile_encrypt
  end

  def is_secure_temp_digest_for?(string)
    volatile_decrypt.is_digest_for? string
  end

  # DOC: http://stackoverflow.com/a/4471202
  # SOURCE: http://blog.bigbinary.com/2012/01/08/alias-vs-alias-method.html
  alias_method :original_percent_operator, :"%"

  # Allow an ActiveRecord as input for String#% formating to behave like a hash:
  #   "User %{id}: %{first_name} %{last_name} <%{email}>" % @user
  #   # => "User 1: John Example <john@example.org>"
  # Note that with this modification the behavior of
  #   "Hello %s" % @user
  # is not equivalent to
  #   "Hello #{@user.to_s}"
  # as it would normally, but to
  #   "Hello #{@user.attributes.symbolize_keys}"
  # leading to the whole attributes hash being printed in the '%s' placeholder.
  # To achieve the original behavior you must explicitly convert it to a String:
  #   "Hello %s" % @user.to_s
  # DOC: http://ruby-doc.org/core-2.4.3/String.html#method-i-25
  # DOC: http://ruby-doc.org/core-2.4.3/Kernel.html#method-i-sprintf
  def %(model)
    if model.is_a? ActiveRecord::Base
      original_percent_operator model.attributes.symbolize_keys
    else
      original_percent_operator model
    end
  end
end

class ActiveSupport::Duration

  # SOURCE: http://stackoverflow.com/a/28667334
  # DOC: http://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html
  include ActionView::Helpers::DateHelper

  def in_words
    distance_of_time_in_words(self, 0, include_seconds: true)
  end
end

class Integer
  def inc
    self + 1
  end
  def dec
    self - 1
  end
end

module DateHelpers

  # SOURCE: http://stackoverflow.com/a/28667334
  # DOC: http://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html
  include ActionView::Helpers::DateHelper

  def now?
    (Time.current - to_time).to_i == 0
  end

  def tomorrow?
    to_date == Date.tomorrow
  end

  def yesterday?
    to_date == Date.yesterday
  end

  def next_week?
    to_datetime.cweek % 52 == DateTime.current.cweek.inc % 52
  end

  def last_week?
    to_datetime.cweek.inc % 52 == DateTime.current.cweek % 52
  end

  def relative_in_words
    # Handle specific cases
    return I18n.t "time.now"        if now?
    return I18n.t "time.tomorrow"   if tomorrow?
    return I18n.t "time.yesterday"  if yesterday?
    return I18n.t "time.next_week"  if next_week?
    return I18n.t "time.last_week"  if last_week?

    # DOC: https://github.com/abhidsm/time_diff
    relevant_unit, count = Time.diff(Time.now, to_time).find { |u, c| c > 0 }
    I18n.t "time.about_x_#{relevant_unit}s.#{past? ? "ago" : "from_now"}",
           count: count
  end

  def to_localized_s(format = :long)
    I18n.l self, format: format
  end
end

class  ActiveSupport::TimeWithZone
  include DateHelpers
end

class  Date
  include DateHelpers
  def self.next_wday(wday)
    (current + 1.day).upto(current + 8.days).find { |d| d.wday == wday }
  end
end

class  DateTime
  include DateHelpers
end

class  Time
  include DateHelpers
end

# Allows to memoize methods and to create cached variables. If this module is
# included in an ActiveRecord model, both memoized methods and cached variables
# are properly and automatically invalidated on model reload. Note that in most
# cases, Rails and ActiveRecord will already cache a lot of things as expected,
# specially DB requests defined as scopes or relationships. Memoizing a method
# or caching a variable might be useful when doing a lot of work after Rails and
# ActiveRecord have handed out their results, like wrapping it in a custom
# object.
module Memoizable

  class CannotMemoizeException < Exception
  end

  # DOC: http://api.rubyonrails.org/v5.1.4/classes/ActiveSupport/Concern.html#method-i-append_features
  extend ActiveSupport::Concern

  included do
    # Memoize a method, i.e. the result for a given set of arguments will be
    # calculated the first time it is called. The next time the method is called
    # with the same arguments, the result will be retrieved from the cached
    # values. If this module is included in an ActiveRecord model, the memoized
    # results will be forgotten (i.e. cache will be invalidated) on model
    # reload. Otherwise you have to manually call the method :reload in order to
    # invalidate the cache.
    # Example:
    #     def order(date)
    #       Order.new self, date
    #     end
    #     memoize :order
    def self.memoize(method_name)
      unless instance_methods(false).include?(method_name)
        raise CannotMemoizeException,
              "unable to find method #{method_name.inspect} in class #{self}"
      end
      _non_memoized_method_name = "#{method_name}_non_memoized"
      alias_method _non_memoized_method_name, method_name
      define_method("#{method_name}") do |*args|
        cached_variable(method_name, {})[args] ||=
          send(_non_memoized_method_name, *args)
      end
    end
  end

  # Invalidates all cached valued of the self object and return the object. If
  # this module is included in an ActiveRecord model, the ActiveRecord's :reload
  # method will be also called.
  def reload
    invalidate_cached_variables
    # SOURCE: http://devblog.avdi.org/2010/09/24/checking-the-existence-of-a-super-method-in-ruby/
    defined?(super) ? super : self
  end

  # Created a cached variable managed by this module. Please note that
  # initial_value will always be evaluated before calling :cached_variable, so
  # that it's better used as a map, as in the example below. See also :memoize.
  # Example with a Hash:
  #     def order(date)
  #       cached_variable(:orders, {})[date] ||= Order.new(self, date)
  #     end
  def cached_variable(name, initial_value = nil)
    (@cached_variables ||= {})[name] ||= initial_value
  end

  private
    def invalidate_cached_variables
      return if @cached_variables.nil?
      logger.debug "invalidating cached_variables: #{@cached_variables.keys}"
      @cached_variables = nil
    end
end

class ActiveRecord::Base

  # SOURCE: http://stackoverflow.com/a/7830624
  # SOURCE: http://www.keenertech.com/articles/2011/06/26/recipe-detecting-required-fields-in-rails
  def required_attribute?(attribute)
    self.class.validators_on(attribute).map(&:class).include?(
      ActiveRecord::Validations::PresenceValidator)
  end

  # SOURCE: http://stackoverflow.com/a/9491479
  # DOC: http://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reorder
  def self.remove_order
    reorder('')
  end

  # E.g. in a model which belongs_to :user, add 'validate_id_for :user'.
  # NOTE: Direct validation using the :inclusion with a block (e.g.
  #       inclusion: { in: Subscription.pluck(:id) } ) does not work because
  #       validators are instantiated only once, i.e. the inclusion
  #       validator won't take into account ids of records created after
  #       application start.
  def self.validate_id_for(attribute, options = {})
    _class = (options.pop(:class_name) || attribute).to_class
    _scope = Cancelable.included_in?(_class) ? :not_canceled : :all
    _attribute_for_id = attribute.ensure_suffix "_id"
    validate options do
      _id = send(_attribute_for_id)
      unless _id.blank? || _class.send(_scope).find_by(id: _id)
        errors.add attribute, I18n.t("errors.messages.not_found.#{attribute}",
                                    id: _id)
      end
    end
  end

  # Returns a random record in a DB independent way. Note that prepended scopes
  # are also taken into account for the selection of the ID, e.g. if all
  # JobTypes were :canceled, requesting JobType.not_canceled.sample would give:
  # >> JobType.not_canceled.sample
  #   (0.4ms)  SELECT "job_types"."id" FROM "job_types"
  #              WHERE "job_types"."canceled_at" IS NULL
  #              ORDER BY "job_types"."title" ASC,
  #                       "job_types"."id" ASC
  #   JobType Load (0.3ms)  SELECT  "job_types".* FROM "job_types"
  #                           WHERE "job_types"."canceled_at" IS NULL
  #                             AND "job_types"."id" IS NULL
  #                           ORDER BY "job_types"."title" ASC,
  #                                    "job_types"."id" ASC LIMIT 1
  # => nil
  # Note that using :find instead of :where would make this case fail with:
  #    ActiveRecord::RecordNotFound: Couldn't find JobType without an ID
  def self.sample
    where(id: self.pluck(:id).sample).first
  end
end

class ActiveRecord::Relation

  # Returns a hash of the columns by which the relation is ordered mapped to the
  # direction of ordering and the level of the ordering. E.g.:
  # >> User.by_name.to_sql
  # => "SELECT \"users\".* FROM \"users\"  ORDER BY \"users\".\"last_name\" ASC,
  #    \"users\".\"id\" ASC"
  # >> User.by_name.ordering
  # => {:last_name=>[:asc, 0], :id=>[:asc, 1]}
  def ordering
    order_values.reduce({}) do | orders, ord |
      next orders if ord.blank? || orders[ord.expr.name].present?
      orders.merge ord.expr.name => [case ord
                                       when Arel::Nodes::Descending then :desc
                                       when Arel::Nodes::Ascending  then :asc
                                     end,
                                    orders.size]
    end
  end

  # If the relation is ordered by the attribute_name it returns an array with
  # the order direction and the order level. Returns nil otherwise. E.g.:
  # >> User.by_name.to_sql
  # => "SELECT \"users\".* FROM \"users\"  ORDER BY \"users\".\"last_name\" ASC,
  #    \"users\".\"id\" ASC"
  # >> User.by_name.ordered_by :last_name
  # => [:asc, 0]
  # >> User.by_name.ordered_by :id
  # => [:asc, 1]
  def ordered_by(attribute_name)
    ordering[attribute_name]
  end

  # Returns true if the relation is ordered by the attribute_name, and false
  # otherwise.
  def ordered_by?(attribute_name)
    ordered_by(attribute_name).to_b
  end

  # Returns :asc or :desc if the relation is first ordered by the
  # attribute_name, and nil otherwise. E.g.:
  # >> User.by_name.to_sql
  # => "SELECT \"users\".* FROM \"users\"  ORDER BY \"users\".\"last_name\" ASC,
  #    \"users\".\"id\" ASC"
  # >> User.by_name.first_ordered_by :last_name
  # => :asc
  # >> User.by_name.first_ordered_by :id
  # => nil
  def first_ordered_by(attribute_name)
    direction, level = ordering[attribute_name]
    return direction if level == 0
  end

  # Returns true if the relation is first ordered by the attribute_name, and
  # false otherwise.
  def first_ordered_by?(attribute_name)
    first_ordered_by(attribute_name).to_b
  end
end

class ActionDispatch::Request

  def remote_ip_and_address
    address = location.try(:address) || "address not found"
    "#{remote_ip} (approx #{address})"
  end
end

class ActionView::Helpers::FormBuilder

  # Full attribute type list.
  # SOURCE: http://stackoverflow.com/a/3260466
  # SOURCE: http://stackoverflow.com/a/15667038
  #
  # :binary
  # :boolean
  # :date
  # :datetime
  # :decimal
  # :float
  # :integer
  # :primary_key
  # :string
  # :text
  # :time
  # :timestamp

  INPUT_FIELD_TYPES = {
    string:   :text_field,
    text:     :text_area,
    boolean:  :check_box,
    password: :password_field,
    password_confirmation: :password_field,
    select:   :select
  }

  REQUIRED_ATTRIBUTE_MARK = '*'

  def input_tag_for(attribute)
    INPUT_FIELD_TYPES[attribute] ||
      INPUT_FIELD_TYPES[object.column_for_attribute(attribute).type] ||
      :text_field
  end

  # DOC: http://ruby-doc.org/core-2.4.3/String.html#method-i-5B-5D-3D
  SELECTED_OPTION_VALUE_REGEXP =
           /^<option[^>]*selected="selected"[^>]*>(?<selected>[^<]*)<\/option>$/

  # Returns HTML for a form field with labels and proper configuration
  # using Bootstrap classes.
  # Consider: https://github.com/bootstrap-ruby/rails-bootstrap-forms ;)
  def field_for(attribute, options = {})
    is_view_mode  = options.include?(:view_mode) ? options[:view_mode] :
                                              (self.options[:view_mode] == true)
    input_tag     = input_tag_for(options[:as_type] ||
                                  options[:real_attribute] ||
                                  attribute)
    is_checkbox   = input_tag == :check_box
    input_class   = ''
    input_class   << 'form-control' unless is_checkbox
    input_class   << ' view-mode'   if is_view_mode
    readonly      = options.include?(:readonly) ? options[:readonly] : false
    label_text    = options.include?(:label) ? options[:label] : nil
    include_blank = options.include?(:include_blank) ? options[:include_blank]
                                                     : false
    prompt        = options.include?(:prompt) ? options[:prompt] : false
    value         = options.include?(:value) ? options[:value]
                                             : object.try(attribute)
    hint_text     = options.get(:hint, :text) || options[:hint]
    hint_hidden   = options.get(:hint, :hidden).to_b

    if @object
      label_text  ||= @object.class.human_attribute_name(attribute)
      t_key_base_placeholder = "activerecord.placeholders.#{object.class.name.downcase}"
    else
      t_key_base  = "controllers.#{@template.controller_name}" +
                                       ".#{@template.action_name}"
      label_text  ||= I18n.t("#{t_key_base}.attributes.#{attribute}")
      t_key_base_placeholder = "#{t_key_base}.placeholders"
    end

    unless is_checkbox
      unless placeholder = options[:placeholder].not_blank
        t_key_placeholder = (options[:placeholder_t_key] || attribute)
        placeholder       = I18n.t("#{t_key_base_placeholder}" +
                                   ".#{t_key_placeholder}")
      end
    end


    if is_checkbox
      # NOTE: HTML structure of a checkbox in bootstrap:
      #       <div class="checkbox">
      #         <label>
      #           <input type="checkbox"> Check me out
      #         </label>
      #       </div>

      @template.content_tag :div, class: 'checkbox' do
        @template.concat( label(attribute, disabled: is_view_mode) do
          @template.concat check_box(attribute,
                                     class:    input_class,
                                     disabled: is_view_mode || readonly,
                                     checked:  value)
          @template.concat label_text
        end)
      end

    else
      # SOURCE: https://robots.thoughtbot.com/nesting-content-tag-in-rails-3
      @template.content_tag :div, class: 'form-group' do
        @template.concat( label(attribute, class: 'control-label') do
          @template.concat label_text
          if !is_view_mode && @object.try(:required_attribute?, attribute)
            @template.concat REQUIRED_ATTRIBUTE_MARK
          end
        end)
        if input_tag == :select
          if is_view_mode
            # NOTE: In a :select the value is a html string with the <option>
            #       tags. We have to extract the selected one with a regexp.
            # SOURCE: http://stackoverflow.com/a/519593
            # DOC: http://ruby-doc.org/core-2.4.3/String.html#method-i-5B-5D-3D
            selected_value = value[SELECTED_OPTION_VALUE_REGEXP, "selected"]
            @template.concat text_field(attribute,
                                        value:    selected_value,
                                        class:    input_class,
                                        readonly: readonly,
                                        disabled: true)
          else
            @template.concat select(attribute,
                                    value,
                                    class:          input_class,
                                    readonly:       readonly,
                                    include_blank:  include_blank,
                                    prompt:         prompt,
                                    autofocus:      options[:autofocus],
                                    disabled:       is_view_mode)
          end
        else
          @template.concat send(input_tag, attribute,
                                            class:       input_class,
                                            placeholder: placeholder,
                                            readonly:    readonly,
                                            value:       value,
                                            type:        options[:input_type],
                                            autofocus:   options[:autofocus],
                                            disabled:    is_view_mode)
        end
        unless hint_text.blank?
          classes = 'help-block'
          classes << ' hidden' if hint_hidden
          @template.concat(@template.content_tag(:span, class: classes,
            id: "hint-for-#{attribute.to_s}") do
            hint_text
          end)
        end
      end
    end
  end

  # Returns HTML for a cancel form button using Bootstrap classes.
  def cancel_button(destination_path)
    @template.link_to I18n.t('form.cancel'), destination_path,
                                             class: "btn btn-default"
  end

  # Returns HTML for a edit form button using Bootstrap classes.
  def edit_button(destination_path)
    # Consider using:
    # ActionDispatch::Routing::PolymorphicRoutes::edit_polymorphic_path(@object)
    @template.link_to I18n.t('form.edit'), destination_path,
                                             class: "btn btn-primary"
  end

  # Returns HTML for a submit form button using Bootstrap classes.
  def submit_button(button_text = nil, options = {})
    readonly = options.include?(:readonly) ? options[:readonly] : false
    confirm = options.include?(:confirm) ? options[:confirm] : nil
    submit button_text || I18n.t('form.submit'), class: "btn btn-primary",
                                                 readonly: readonly,
                                                 data: {
                                                  confirm: confirm
                                                 }
  end
end

# Modify 'byebug' breakpoint helper to prevent forgetting it in production and
# and to stop on breakpoints in tests.
# SOURCE: https://github.com/deivid-rodriguez/byebug/blob/3ac521e2/lib/byebug/attacher.rb#L28-L34
# DOC: http://ruby-doc.org/core-2.4.3/Binding.html#method-i-receiver
# DOC: http://ruby-doc.org/core-2.4.3/Kernel.html#method-i-caller
# TODO: Consider creating a PR to contribute this option to byebug.
module Kernel
  def byebug
    msg = "Debugger used in #{caller[0]} by #{binding.receiver}".red
    raise msg if Rails.env.test?
    logger.warn msg if defined? logger
    Byebug.attach if Rails.env.development?
  end

  alias debugger byebug

  # Returns the name of the method calling the current one.
  # NOTE: Cannot be inlined as string interpolation directly: i.e.
  #       'logger.debug "The calling method is #{caller_method}"' does not work.
  def caller_method(level = 1)
    caller[level][/.+`(?<method>\w+)'/, 'method']
  end
end

# Very lightweight TimelinessValidator inspired from gem 'validates_timeliness'.
# Usage: validates :valid_until, presence: false,  timeliness: { type: :date }
# Take into account that Rails will nil-lify date attributes whose
# value is not a valid date like Strings, but not Integers.
# SOURCE: http://stackoverflow.com/a/597776
# SOURCE: https://github.com/adzap/validates_timeliness
# DOC: http://api.rubyonrails.org/v5.1.4/classes/ActiveModel/Validator.html
# TODO: Find a better place fir this kind of class.
class TimelinessValidator < ActiveModel::EachValidator
  VALID_TYPES = [:date_time, :date, :time]
  def validate_each(record, attribute, value)
    type = @options[:type] || VALID_TYPES.first
    unless VALID_TYPES.include? type
      raise "Timeliness type: #{type.inspect} must be one of #{VALID_TYPES}"
    end
    return if value.blank? && !record.required_attribute?(attribute)
    unless value.is_a? type.to_class
      record.errors.add attribute, "must be a #{type.to_class}"
    end
  end
end
