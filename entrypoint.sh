set -e
bundle exec rake db:migrate
bundle exec ruby main.rb