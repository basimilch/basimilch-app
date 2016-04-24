# Follow the instructions in the README.md for using this task.

desc "This task is used to update on the challenge for letsencrypt certificate"

namespace :letsencrypt do

  CHALLENGE_PATH = File.join('.well-known', 'acme-challenge')
  CHALLENGE_FOLDER_PATH = File.join(Rails.root, 'public', CHALLENGE_PATH)

  # To be called from the command line with:
  #   $ rake letsencrypt:publish_challenge[filename,challenge]
  # E.g.:
  #   $ rake letsencrypt:publish_challenge[Hw5Bp26inPIn,Hw5Bp26inPIn8bqfsWVk7ec]
  # On Heroku:
  #   $ heroku run rake letsencrypt:publish_challenge[filename,challenge]
  # NOTE: When used on Heroku, the written files will be deleted when the dyno
  #       is restarted (e.g. on new pushed code or config change).
  task :publish_challenge, [:filename,:challenge] => :environment do |t, args|
    Dir.mkdir(CHALLENGE_FOLDER_PATH) unless File.exists?(CHALLENGE_FOLDER_PATH)
    file_path = File.join(CHALLENGE_FOLDER_PATH, args.filename)
    print "Writting challenge to #{file_path}"
    File.open(file_path, 'wb') { |f| f.write file args.challenge }
    puts ' => DONE'
    puts "The challenge is displayed at: /#{CHALLENGE_PATH}/#{args.filename}"
  end

  # To be called from the command line with:
  #   $ rake letsencrypt:cleanup_challenges
  # On Heroku:
  #   $ heroku run rake letsencrypt:cleanup_challenges
  task :cleanup_challenges => :environment do |t, args|
    if File.exists?(CHALLENGE_FOLDER_PATH)
      FileUtils.rm_rf Dir.glob("#{CHALLENGE_FOLDER_PATH}/*"), secure: true
    end
  end
end
