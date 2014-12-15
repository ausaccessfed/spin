FactoryGirl.define do
  factory :aaf_attributes, class: 'Hash' do
    displayname { Faker::Name.name }
    mail { Faker::Internet.email(displayname) }
    auedupersonsharedtoken { SecureRandom.urlsafe_base64(16) }
    edupersontargetedid do
      "https://rapid.example.com!https://ide.example.com!#{SecureRandom.hex}"
    end

    initialize_with { attributes.dup }
    skip_create
  end

  factory :jwt, class: 'JSON::JWT' do
    iat { Time.now.to_i }
    nbf { 30.seconds.ago.to_i }
    exp { 30.seconds.from_now.to_i }
    typ 'authnresponse'
    jti { SecureRandom.hex }

    config = Rails.configuration.rapid_rack
    iss config.issuer
    aud config.audience
    transient do
      secret(config.secret)
      association :aaf_attributes
    end

    send('https://aaf.edu.au/attributes') { aaf_attributes }

    initialize_with { new(attributes).sign(secret).to_s }
    skip_create
  end
end
