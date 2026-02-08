#common workspace
workspace=~/workspace
navAppPath=$workspace/CAP/NavApp
shopAppPath=$workspace/CAP/ShopNServe
macysCliPath=/Users/ac-nalmeida/.nvm/versions/node/v8.12.0/lib/node_modules/@core/macys-cli
reappsjsPath=$workspace/CAP/reappsjs
alias reapps="code $reappsjsPath"

source $util_path/mcom_util.sh
source $util_path/bcom_util.sh

# Common / MCOM/BCOM
commit(){
  git commit -m "$1"
}

push_gerrit(){
  git push origin HEAD:refs/for/$1
}

killprocess(){
  ps -ax | grep $1 | awk '{print $1}' | xargs kill -9
}

freeport(){
  # sudo lsof -n -i4TCP:49152 | grep LISTEN
  lsof -i tcp:$1 | awk '{print $2}' | xargs kill -9
}

portuser(){
  lsof -i tcp:$1
}

sayit(){
  say -v Moira $1
}

whichprocess(){
  sudo lsof -n -i4TCP:$1 | grep LISTEN
}

# Write a function to repeat the karma:mcom/bcom failing test
# MacysUI
macysUI=$workspace/CAP/MacysUI
alias macysuidir="cd $macysUI"

precheck(){
    cd $macysUI/macysJS
    grunt jsbeautifier jshint codingStandards
    cd $macysUI/macysTemplates
    grunt jsbeautifier
    cd $macysUI
}

#find_string <extension> <term>
find_string(){
    grep -ri --include="*.$1" "$2" .
}

clean_macysui(){
  echo "Cleaning up target folders and node_modules on MacysUI"
  cd $macysUI
  rm -rf target/
  rm -rf macysJS/target
  rm -rf macysJS/node_modules
  rm -rf macysCSS/target
  rm -rf macysCSS/node_modules
  rm -rf macysTemplates/target
  rm -rf macysTemplates/node_modules
}

build_css(){
    # sayit "Building Macy's C.S.S."
    cd $macysUI/macysCSS
    grunt --altDest=../macysJS/styles
    # sayit "Macy's C.S.S. build complete. More info on the terminal."
}

build_templates(){
    cd $macysUI/macysTemplates
    grunt --altDest=../macysJS/templates
}

watch_js(){
    cd $macysUI/macysJS
    grunt watch
}

watch_templates(){
    cd $macysUI/macysTemplates
    # grunt
    grunt watch --altDest=../macysJS/templates
}

watch_css(){
    cd $macysUI/macysCSS
    # grunt
    grunt watch --altDest=../macysJS/styles
}

# Logs
nginx_log(){
    # tail -500f /usr/local/etc/nginx/log/access.log
    open /usr/local/etc/nginx/log/access.log
}

# Polaris MCOM & BCOM envs
export FOOTER_SERVICE_ENDPOINT=//172.21.7.79:8080
export FOOTER_XAPI_URI=/xapi/navigate/v1/footer
export HEADER_SERVICE_ENDPOINT=http://172.21.7.79:8080
export HEADER_XAPI_URI=/xapi/navigate/v1/header
export KILLSWITCH_XAPI_URI=/xapi/navigate/header-footer/v1/switches
export XAPI_BAG_SERVICE=http://172.21.11.9:8080/xapi/bag/v1
export PROXY_XAPI_BAG_SERVICE_HOST=https://www.bcom-075.tbe.zeus.fds.com
export WISHLIST_SERVICE_ENDPOINT=http://172.21.12.57:8080
export STORES_FCC_SERVICE=http://172.21.20.18:8080
export ASSET_HOST=http://localhost:8081
export BAG_ASSETS_HOST=http://localhost:8081
export PRODUCT_IMAGE_URL=https://images.bcom-075.tbe.zeus.fdsassets.com/is/image/BLM/products/
export TARGET_HOST=localhost
export NODE_ENV=development
# Lines above added after new BCOM project, started in 01.13.2020

# Run npm run build && npm run server when on a polaris project
run(){
  # npm run build && npm run server - OLD, node 4.x.x
  m server $brand
}

polaris_mcom(){
  # MCOM XAPI
  # export XAPI_DOMAIN=jcia3096:8080
  export BRAND=mcom
  export brand=mcom
  # export PROXY_ASSET_HOST=https://assets.qa12codemacys.fdsassets.com
  # export PROXY_SERVICE_HOST=https://www.qa12codemacys.fds.com
  # export ASSET_HOST=//assets.qa12codemacys.fdsassets.com

  echo "Your 'brand' environment variable is now set to:" $brand
}

polaris_bcom(){
  # BCOM XAPI
  # export XAPI_DOMAIN=origin-www.qa10codebloomingdales.fds.com
  export BRAND=bcom
  export brand=bcom
  # export PROXY_ASSET_HOST=https://assets.qa10codebloomingdales.fdsassets.com
  # export PROXY_SERVICE_HOST=https://www.qa10codebloomingdales.fds.com
  # export ASSET_HOST=//assets.qa10codebloomingdales.fdsassets.com

  echo "Your 'brand' environment variable is now set to:" $brand
}

# Function to help switching envs between brands
run_mcom(){
  polaris_mcom && run
}

run_bcom(){
  polaris_bcom && run
}

# Remove node_modules, install them again and build the project
# rebuild(){
#   nvm use default;
#   echo "Removing dist/ folder...";
#   rm -rf dist;
#   echo "Removing node_modules...";
#   rm -rf node_modules;
#   echo "installing npm packages (and slowing down the internet)...";
#   m setup;
#   # echo "Building the project...";
#   m build --verbose;
#   echo "Project rebuilt.";
# }

npmi(){
  mv ~/.npmrc ~/_npmrc
  npm i $1 $2
  mv ~/_npmrc ~/.npmrc
}

npmrcout(){
  mv ~/.npmrc ~/_npmrc
}

# set envs for bcom at startup
polaris_bcom
