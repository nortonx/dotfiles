# former Dale
update_project() {
  git fetch --all --prune
  git pull --rebase
  git submodule update
  bundle install
  SITE=dcv bundle exec rake db:migrate --trace
  SITE=dcv bundle exec rake data:migrate --trace
  # SITE=dcv bundle exec rake parallel:migrate
  SITE=dcv bundle exec rake db:test:prepare --trace
  SITE=dcv RAILS_ENV=test bundle exec rake db:migrate --trace
  git restore db/data_schema.rb db/structure.sql
}

# former DaleDale
update_projects() {
  (cd ~/Decisiv/pricing && update_project)
  (cd ~/Decisiv/portal && update_project)
  (cd -) # go back to previous directory
}

run_pricing() {
  bundle exec rails s -p 3001
}

run_portal() {
  bundle exec rails s -p 3000
}

aws_login() {
  # param $1 = qa/staging
  echo "Connecting to $1 profile..."
  aws sso login --profile $1
}

aws_describe_instances() {
  # $1 qa/staging/prod
  aws ec2 describe-instances --filters "Name=tag:Name,Values=case*" --profile=$1 --query 'Reservations[*].Instances[*].{Instance:InstanceId,Name:Tags[?Key==`Name`]|[0].Value}' --output table
}

aws_start_session() {
  # params
  # $1 profile (qa/staging)
  # $2 instance-id, listed on aws_describe_instances()
  AWS_PROFILE=$1 aws ssm start-session --target $2
}

aws_connect() {
  PROFILE=$(grep '\[.*\]' ~/.aws/config | fzf)
  # format profile
  PROFILE=$(echo $PROFILE | sed -e 's/\[profile //g' | tr -d ])
  INSTANCEID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=case-pricing*" --profile=$PROFILE --query 'Reservations[*].Instances[*].{Instance:InstanceId,Name:Tags[?Key==`Name`]|[0].Value}' --output table | fzf)
  # format instanceid
  INSTANCEID=$(echo $INSTANCEID | tr -d '|' | awk '{ print $1 }')
  AWS_PROFILE=$PROFILE aws ssm start-session --target $INSTANCEID
}