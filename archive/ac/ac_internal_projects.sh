# AC Internal Projects

# backend path
ac_interviews_backend_path=$HOME/workspace/AC/ac-interviews-api

# frontend path
ac_interviews_frontend_path=$HOME/workspace/AC/ac-interviews-ui

interviews_backend() {
    #params up
    docker-compose -f docker-compose-stage.yml $1 --build
}

interviews_frontend() {
    echo "Building frontend..."
    docker build . -t interviews-ui
    echo "Run dist locally on docker..."
    docker run --env-file ./.env -d -p 3000:3000 interviews-ui
}

