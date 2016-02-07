# DOC: http://stackoverflow.com/a/4410880
# DOC: http://stackoverflow.com/a/12461394
# DOC: http://stackoverflow.com/a/5393324
# DOC: http://stackoverflow.com/a/825832
# DOC: https://gist.github.com/arjunvenkat/1115bc41bf395a162084

require 'csv'

desc "This task is used to import a CSV file into the database"

def sanitize_string(s)
  if s
    return s.to_s.strip
  else
    return ""
  end
end

def email_missing(row)
  email = row['E-Mail']
  email.to_s.strip == "<no_email>" || email.blank?
end

def placeholder_email(row)
  "#{sanitize_string(row['Vorname']).parameterize}.#{sanitize_string(row['Name']).parameterize}@example.org"
end

def sanitized_email(row)
  if email_missing row
    return placeholder_email row
  else
    return row['E-Mail'].to_s.strip.downcase
  end
end

namespace :import_csv do
  # To be called from the command line with:
  # $ rake import_csv:users[/path/to/file.csv]
  task :users, [:file_path,:begin_from_id] => :environment do |t, args|
    unless File.exist? args.file_path
      raise "#{args.file_path} does not exist"
    end
    csv_text = File.read args.file_path
    csv = CSV.parse(csv_text, :headers => true)
    csv.each_with_index do |row, index|
      if args.begin_from_id
        next if row['Mitglieder-Nr.'].to_i < args.begin_from_id.to_i
      end
      user = User.new do |u|
        u.id              = row['Mitglieder-Nr.'].to_i
        u.first_name      = sanitize_string row['Vorname']
        u.last_name       = sanitize_string row['Name']
        u.admin           = false
        u.email           = sanitized_email row
        u.postal_address  = "#{sanitize_string row['Strasse']} #{sanitize_string row['Haus-Nr.']}"
        u.postal_address_supplement = sanitize_string row['Verein/Firma']
        u.postal_code     = sanitize_string row['PLZ']
        u.city            = sanitize_string row['Ort']
        u.tel_mobile      = sanitize_string row['Tel (Handy)']
        u.tel_home        = sanitize_string row['Tel (Haus)']
        u.tel_office      = sanitize_string row['Tel (Buero)']
        u.notes           = "#{ "ACHTUNG! EMAIL FEHLT! " if email_missing row}" +
                            "Abo #{row['Abo']}; " +
                            "Beteiligt sich am Abo von: #{row['Beteiligt sich am Abo von']};" +
                            "Teil das Abo mit: #{row['Teil das Abo mit']};" +
                            "Mitarbeit: #{row['Mitarbeit']}, #{row['Mitarbeit 2']}, #{row['Mitarbeit 3']};" +
                            "Erklärung Ort: #{row['Erklärung Ort']};" +
                            "Erklärung Datum: #{row['Erklärung Datum']};" +
                            "Wie hat sich die Person angemeldet?: #{row['Wie hat sich die Person angemeldet?'] || "Schriftlich mit unterschriebene Beitrittserklärung."};" +
                            "Anteilscheine: #{row['Anteilschein-Nr']} #{row['ASN2']} #{row['ASN3']} #{row['ASN4']} #{row['ASN5']};" +
                            "Notizen: #{row['Notizen']};"
        # u.activated       = nil
        # u.activated_at    = nil
      end
      puts "Importing: #{user}"
      user.save!
      puts "           User saved!"

      row['Anz. Anteilsch.'].to_i.times do |i|
        share_certificate = user.share_certificates.build do |sc|
          sc.id       = row[%w{Anteilschein-Nr  ASN2  ASN3  ASN4  ASN5}[i]].to_i
          sc.sent_at  = row['Wann?'] || Date.new(2015, 8, 14)
          sc.notes    = "Importiert aus GoogleDocs am #{Time.current.to_localized_s}"
        end
        puts "           Importing: share certificate:  #{share_certificate.inspect}"
        share_certificate.save!
        puts "                      Share certificate saved!"
      end
    end

    # Enable default admin
    admin = User.find_by(email: ENV['EMAIL_DEFAULT_ADMIN'])
    admin.update_attribute(:admin, true)
    admin.update_attribute(:activation_sent_at, Time.current)
  end
end
