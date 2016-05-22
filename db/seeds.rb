# Inspired from: https://www.railstutorial.org/book/_single-page#code-db_seed
# Apply with:
#   bundle exec rake db:reset => applies the db schema and runs this seeds script
#   bundle exec rake db:seed  => re-seeds the DB, i.e. add more items.

# SOURCE: http://stackoverflow.com/a/14450473
# SOURCE: http://cobwwweb.com/4-ways-to-pass-arguments-to-a-rake-task
STRESS_TEST = ENV['STRESS'].to_b

NUMBER_OF_USERS                  =  STRESS_TEST ? 2000    : 100
NUMBER_OF_SHARE_CERTS_PER_USER   =  STRESS_TEST ? (0..10) : (0..3)
NUMBER_OF_JOBS_TYPES             =  STRESS_TEST ? 50      : 4
NUMBER_OF_SUBSCRIPTIONS          =  (0.3 * NUMBER_OF_USERS).round(0)
NUMBER_OF_USERS_PER_SUBSCRIPTION =  STRESS_TEST ? (1..10) : (1..3)
NUMBER_OF_DEPOTS                 =  STRESS_TEST ? 50      : 8
NUMBER_OF_COORDINATORS_PER_DEPOT =  STRESS_TEST ? (2..5)  : (0..2)
NUMBER_OF_PRODUCT_OPTIONS        =  STRESS_TEST ? 20      : 5
CREATE_JOBS_SINCE                = (STRESS_TEST ? 5.years : 3.months).ago
CREATE_JOBS_UNTIL                = (STRESS_TEST ? 1.year  : 3.months).from_now
AVERAGE_NUMBER_OF_JOBS_PER_DAY   =  STRESS_TEST ? 3       : 0.5

SEPARATORS  = [".", "-", "_", ""]
LOCALES     = ['de-CH', 'fr-CH', 'it-CH']

def maybe(x = :bool)
  # Source: http://stackoverflow.com/a/8012789
  if x == :bool then [true, false].sample else maybe ? x : nil end
end

def log_record(record)
  new_logged_class = (@logged_class != record.class)
  if STRESS_TEST
    # SOURCE: http://stackoverflow.com/a/7366089
    # \r is "carriage return" to rewrite same line
    if new_logged_class then puts else print "\r" end
    print "Creating #{record.class} records... id #{record.id}"
  else
    puts "\n\n------ Creating #{record.class} records:\n" if new_logged_class
    puts record
  end
  @logged_class = record.class
end

def save!(record)
  unless record.valid?
    puts ">>>> INVALID RECORD #{record.inspect}"
    puts "     #{record.errors.messages}"
  end
  record.save!
  log_record record
end

puts
puts "******** Seeding Data Start ************"
puts
puts "NUMBER_OF_USERS:                  #{NUMBER_OF_USERS}"
puts "NUMBER_OF_SHARE_CERTS_PER_USER:   #{NUMBER_OF_SHARE_CERTS_PER_USER}"
puts "NUMBER_OF_JOBS_TYPES:             #{NUMBER_OF_JOBS_TYPES}"
puts "NUMBER_OF_SUBSCRIPTIONS:          #{NUMBER_OF_SUBSCRIPTIONS}"
puts "NUMBER_OF_USERS_PER_SUBSCRIPTION: #{NUMBER_OF_USERS_PER_SUBSCRIPTION}"
puts "NUMBER_OF_DEPOTS:                 #{NUMBER_OF_DEPOTS}"
puts "NUMBER_OF_PRODUCT_OPTIONS:        #{NUMBER_OF_PRODUCT_OPTIONS}"
puts "CREATE_JOBS_SINCE:                #{CREATE_JOBS_SINCE}"
puts "CREATE_JOBS_UNTIL:                #{CREATE_JOBS_UNTIL}"
puts "AVERAGE_NUMBER_OF_JOBS_PER_DAY:   #{AVERAGE_NUMBER_OF_JOBS_PER_DAY}"

unless User.first
  first_user = User.new(first_name:      "Admin",
                        last_name:       "Example",
                        admin:           true,
                        email:           "admin@example.org",
                        postal_address:  "Some Street 42",
                        postal_code:     "8953",
                        city:            "Dietikon",
                        # country:         "", # Use default
                        tel_mobile:      "012 345 67 89",
                        tel_home:        "098 765 43 21",
                        tel_office:      "+41 (0) 11 222 33 44",
                        # status:          "", # Use default
                        notes:           "The first user.",
                        activated: true,
                        activated_at: Time.current)
  first_user.save(validate: false)
  log_record first_user
end

# Using Faker to generate fake data. :)
# Source: https://github.com/stympy/faker

(NUMBER_OF_USERS - User.count).times do |n|
  Faker::Config.locale = LOCALES.sample

  first_name    = Faker::Name.first_name
  last_name     = Faker::Name.last_name
  username      = Faker::Internet.user_name("#{first_name} #{last_name}",
                                            SEPARATORS) +
                    maybe(SEPARATORS.sample + Faker::Number.number(2).to_s).to_s
  email         = Faker::Internet.email(username)
  activated     = maybe
  activated_at  = activated ? Faker::Time.between(CREATE_JOBS_SINCE,
                                                  Date.current,
                                                  :day) : nil

  user = User.new(first_name:     first_name,
                  last_name:      last_name,
                  email:          email,
                  postal_address: Faker::Address.street_address,
                  postal_code:    Faker::Number.number(4).to_s,
                  city:           Faker::Address.city,
                  # country:        "", # Use default
                  tel_mobile:     "+41 7" + Faker::Number.number(8).to_s,
                  tel_home:       maybe("+41 4" + Faker::Number.number(8).to_s),
                  tel_office:     maybe("+41 4" + Faker::Number.number(8).to_s),
                  # status:         "", # Use default
                  notes:          maybe(Faker::Lorem.sentence),
                  activated:      activated,
                  activated_at:   activated_at)
  user.save(validate: false)

  rand(NUMBER_OF_SHARE_CERTS_PER_USER).times do
    sent_at = activated_at ? activated_at.to_date - rand(2..30).days :
                             Faker::Date.backward(30)
    user.share_certificates.create!(
      sent_at:  sent_at,
      payed_at: maybe(sent_at + rand(2..30).days)
    )
  end

  log_record user
end
user_ids = User.pluck(:id)


(NUMBER_OF_JOBS_TYPES - JobType.count).times do |n|
  Faker::Config.locale = LOCALES.sample

  job_type = JobType.new(
    title:        Faker::Lorem.sentence(2, false, 2),     # t.string
    description:  Faker::Lorem.paragraph,                 # t.text
    place:        Faker::Commerce.department,             # t.string
    address:      "#{Faker::Address.street_address}," +   # t.string
                  " #{Faker::Number.number(4)} #{Faker::Address.city}",
    slots:        rand(2..10),                            # t.integer
    user_id:      user_ids.take(5).sample                 # t.integer
  )
  save! job_type
end
job_type_ids = JobType.pluck(:id)

years = (CREATE_JOBS_UNTIL - CREATE_JOBS_SINCE) / 1.year.in_milliseconds * 1000
number_of_jobs  = (365 * AVERAGE_NUMBER_OF_JOBS_PER_DAY * years).to_i

(number_of_jobs - Job.count).times do |n|
  Faker::Config.locale = LOCALES.sample

  start_date = Faker::Time.between(CREATE_JOBS_SINCE, CREATE_JOBS_UNTIL, :day)
  job = Job.new(
    title:        Faker::Lorem.sentence(2, false, 2),     # t.string
    description:  Faker::Lorem.paragraph,                 # t.text
    start_at:     start_date,                             # t.datetime
    end_at:       start_date + rand(1..4).hours,          # t.datetime
    place:        Faker::Commerce.department,             # t.string
    address:      "#{Faker::Address.street_address}," +   # t.string
                  " #{Faker::Number.number(4)} #{Faker::Address.city}",
    slots:        rand(2..10),                            # t.integer
    user_id:      user_ids.take(5).sample,                # t.integer
    job_type_id:  (job_type_ids + [nil]).sample
  )
  save! job
end
job_ids = Job.pluck(:id)


# Simulate that in average each user signs up the requested numbers of times
signups_trials = NUMBER_OF_USERS * JobSignup::MIN_NUMBER_PER_USER_PER_YEAR
# => "_trials" because some might not be possible if the jobs is full.

signups_trials.times do |n|
  job = Job.not_canceled.sample
  unless job.full?
    user_id = user_ids.sample
    job_signup = job.job_signups.build(
      user_id:    user_id,
      # User 1 is admin and thus allowed to sign up other users for past jobs.
      author_id:  job.past? ? 1 : [1, user_id].sample
    )
    save! job_signup
  end
end


(NUMBER_OF_DEPOTS - Depot.count).times do
  depot = Depot.new(
        name:                       Faker::Commerce.department,
        postal_address:             Faker::Address.street_address,
        # postal_address_supplement:  nil,
        postal_code:                Faker::Number.number(4),
        city:                       Faker::Address.city,
        # country:                    '', # Setup by default, cannot be changed
        # exact_map_coordinates:      '',
        # picture:                    '',
        directions:                 Faker::Lorem.paragraph,
        delivery_day:               rand(0..6),
        delivery_time:              rand(12..18),
        opening_hours:              Faker::Lorem.sentence(2, false, 2),
        notes:                      maybe(Faker::Lorem.sentence)
    )
    # Don't validate because the address won't be correct.
    depot.save(validate: false)
    log_record depot

    rand(NUMBER_OF_COORDINATORS_PER_DEPOT).times do
      coordinator = depot.coordinators.create!(user_id: user_ids.sample)
      puts "  - #{coordinator}" unless STRESS_TEST
    end
end
depot_ids = Depot.pluck(:id)

(NUMBER_OF_PRODUCT_OPTIONS - ProductOption.count).times do
  product_option = ProductOption.new(
        name:                       Faker::Beer.name,
        description:                Faker::Hipster.sentence,
        size:                       (0.5..500).step(0.5).to_a.sample.round(1),
        size_unit:                  %w(centiliter liter gram kilogram).sample,
        equivalent_in_milk_liters:  [0.5, 1.0, 2.0].sample,
        notes:                      maybe(Faker::Lorem.sentence)
      )
  save! product_option
end
product_option_ids = ProductOption.pluck(:id)


(NUMBER_OF_SUBSCRIPTIONS - Subscription.count).times do
  subscription = Subscription.new(
        name:             maybe(Faker::Hipster.words(2).join(' ').titleize),
        basic_units:      rand(1..2),
        supplement_units: rand(0..3),
        depot_id:         depot_ids.sample,
        notes:            maybe(Faker::Lorem.sentence)
      )
  save! subscription

  rand(NUMBER_OF_USERS_PER_SUBSCRIPTION).times do
    s = subscription.subscriberships.create!(user_id: user_ids.sample)
    puts " - #{s}" unless STRESS_TEST
  end
  target_size = subscription.flexible_milk_liters
  trial_count = items_size = 0
  max_trials  = 500
  items_trial = {}
  loop do
    items_trial = Hash[product_option_ids.map{ |p| [p, rand(0..4)]}]
    items_size = items_trial.reduce(0) do | acc, (id, quantity) |
      acc += ProductOption.find(id).equivalent_in_milk_liters * quantity
    end
    break if items_size == target_size || (trial_count += 1) > max_trials
  end
  if items_size == target_size
    unless STRESS_TEST
      puts " - Found combination #{items_trial} in #{trial_count} trials!"
    end
    valid_since = subscription.depot.delivery_days_of_current_year.first
    items_trial.each do | id, quantity |
      next if quantity.zero?
      subscription_item = subscription.subscription_items.create!(
          product_option_id:  id,
          quantity:           quantity,
          valid_since:        valid_since
        )
      puts "   - #{subscription_item}" unless STRESS_TEST
    end
  elsif !STRESS_TEST
    puts " - Not found a valid list of #{target_size} l (#{max_trials} trials)"
  end
end


puts
puts
puts "DB has now:"
puts "  #{User.count} users"
puts "  #{ShareCertificate.count} share_certificates"
puts "  #{Job.count} jobs"
puts "  #{JobType.count} job types"
puts "  #{JobSignup.count} job_signups"
puts "  #{Depot.count} depots"
puts "  #{ProductOption.count} product_options"
puts "  #{Subscription.count} subscriptions"
puts "  #{Subscribership.count} subscriberships"
puts "  #{SubscriptionItem.count} subscription items"
puts
puts "NB: Model validations were skipped for users and depots, since the adresses are" +
     " not valid, and for jobs, to allow past jobs to be added."
puts
puts "******** Seeding Data End ************"
puts
