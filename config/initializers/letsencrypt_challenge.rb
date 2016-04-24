module LetsencryptChallenge

  CHALLENGE = ENV['LETSENCRYPT_CHALLENGE']

  CHALLENGE_PATH = File.join('.well-known', 'acme-challenge')
  CHALLENGE_FOLDER_PATH = File.join(Rails.root, 'public', CHALLENGE_PATH)

  # NOTE: When used on Heroku, the written files will be deleted when the dyno
  #       is restarted (e.g. on new pushed code or config change).
  if CHALLENGE.present?
    filename, challenge = CHALLENGE.split(',')
    Dir.mkdir(CHALLENGE_FOLDER_PATH) unless File.exists?(CHALLENGE_FOLDER_PATH)
    file_path = File.join(CHALLENGE_FOLDER_PATH, filename)
    # NOTE: logger is not yet initialized when this file is executed.
    print "Writting challenge to #{file_path}"
    File.open(file_path, 'wb') { |f| f.write challenge }
    puts ' => DONE'
    puts "The challenge is displayed at: /#{CHALLENGE_PATH}/#{filename}"
  end
end
