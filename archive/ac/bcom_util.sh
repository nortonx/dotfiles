# for BCOM

# BCOM/MCOM util
# export ZEUS_API_KEY="4ace887d0dbe0c51556170b68c42386a8c74d610"
# export GITLAB_API_TOKEN="ovDWmAf_sbGZKjiTPiN_"
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm (github, not homebrew)

# OrderMods/Returns Polaris settings
# export UPS_DROPOFF_URL="https://www.ups.com/dropoff"
# export CUSTOMER_SERVICE_HOST="//www.customerservice-bloomingdales.com"
# export STORE_LOCATIONS_URL="https://locations.bloomingdales.com/"

#navAppPath=$workspace/CAP/NavApp
alias bcom_navappdir="cd $navAppPath"

#shopAppPath=$bcom_workspace/CAP/ShopNServe/
alias bcom_shopappdir="cd $shopAppPath"

# BCOM config envs
alias bcom_config="mate $navAppPath/BloomiesNavApp/BloomiesNavAppWeb/src/main/webapp/WEB-INF/classes/configuration/navapp-config.properties $shopAppPath/BCOM/BloomiesShopNServe/src/main/resources/META-INF/properties/common/environment.properties /tmp"

# Edit ReappsJS
alias open_reappsjs="mate $workspace/CAP/ReappsJS"

bcom_navapp_log(){
    # tail -500f /tmp/Faceted-replica.log
    open /usr/local/etc/nginx/log/nginx.log
}

bcom_apache_log(){
    tail -500f /private/var/log/apache2/error_log
}

apache_config(){
    sudo mate /etc/apache2
}
