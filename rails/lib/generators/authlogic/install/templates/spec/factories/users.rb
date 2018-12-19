FactoryBot.define do

  # normal user
  factory :user do
    password = Faker::Coffee.notes

    email 'g.p.burdell@example.com'
    first_name 'George'
    last_name 'Burdell'
    password password
    password_confirmation password

    # Administrator user
    factory :admin do
      roles { [:administrator] }
    end
  end

end
