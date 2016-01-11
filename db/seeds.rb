# Inspired from: https://www.railstutorial.org/book/_single-page#code-db_seed
# Apply with:
#   bundle exec rake db:migrate:reset
#   bundle exec rake db:seed

puts
puts "******** Seeding Data Start ************"
puts

unless User.first
  first_user = User.new(first_name:      "User",
                        last_name:       "Example",
                        admin:           true,
                        email:           "user@example.org",
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
  puts first_user.inspect
end

def maybe(str)
  # Source: http://stackoverflow.com/a/8012789
  [true, false].sample ? str : ""
end


# Using Faker to generate fake data. :)
# Source: https://github.com/stympy/faker

separators  = [".", "-", "_", ""]
locales     = ['de-CH', 'fr-CH', 'it-CH']

100.times do |n|
  Faker::Config.locale = locales.sample

  first_name  = Faker::Name.first_name
  last_name   = Faker::Name.last_name
  username    = Faker::Internet.user_name("#{first_name} #{last_name}",
                                          separators) +
                maybe(separators.sample + Faker::Number.number(2).to_s)
  email       = Faker::Internet.email(username)

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
                  activated:      false,
                  activated_at:   nil)
  user.save(validate: false)
  puts user.inspect
end

puts
puts "DB has now #{User.count} users."
puts
puts "NB: Model validations were skipped for seeding, since the adresses are" +
     " not valid."
puts
puts "******** Seeding Data End ************"
puts
