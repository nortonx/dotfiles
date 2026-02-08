# FCA Utils

# aem
# parameters: up / down
# start AEM docker container
aem(){
  # replaced docker-compose with `nerdctl compose`
  COMPOSE_HTTP_TIMEOUT=200 docker-compose -f ~/workspace/fca/com.fcagroup.wisdom.tools/docker/docker-compose-65.yml $1
}

aem_update(){
  # replaced docker with nerdctl
  aws ecr get-login-password | docker login --username AWS --password-stdin 949385213276.dkr.ecr.us-east-1.amazonaws.com/aem-author:6.5.12
  echo "Run 'aem up' to update images"
  # docker pull 949385213276.dkr.ecr.us-east-1.amazonaws.com/aem-author:6.5
  # docker pull 949385213276.dkr.ecr.us-east-1.amazonaws.com/aem-publish:6.5
}

full_base_rebuild(){
  mvn clean install -DskipTests
  mvn clean install -DskipTests -PautoInstallPackage -Daem.port=4502 -Daem.protocol=http
  mvn clean install -DskipTests -PautoInstallPackagePublish -Daem.port=4503 -Daem.protocol=http
}

full_sg_rebuild(){
  mvn clean install -DskipTests -PautoInstallPackage --projects=app,bundle -Daem.port=4502 -Daem.protocol=http
  mvn clean install -DskipTests -PautoInstallPackagePublish --projects=app,bundle -Daem.port=4503 -Daem.protocol=http
}

publish_rebuild(){
  mvn clean install -DskipTests -PautoInstallPackage
  mvn clean install -DskipTests -PautoInstallPackagePublish
  aemsync -t http://admin:admin@localhost:4502 -t http://admin:admin@localhost:4503
}

rebuild(){
  mvn clean install -DskipTests -PautoInstallPackage -Daem.port=4502 -Daem.protocol=http && aemsync
}

