# Colima + Supabase Fix Integration for ac_utils
# Add this to your ~/.zshrc or ~/.bashrc alongside other ac_utils

# Colima + Supabase Functions
source ~/ac_utils/colima-supabase-fix/colima-supabase-shell-functions.sh

# Convenience Aliases
alias supabase-fix='~/ac_utils/colima-supabase-fix/fix-colima-supabase.sh'
alias supabase-test='~/ac_utils/colima-supabase-fix/test-colima-setup.sh'
alias supabase-global-install='~/ac_utils/colima-supabase-fix/install-global-colima-fix.sh'

# Auto-fix on shell start (optional - uncomment if needed)
# if command -v colima > /dev/null && command -v supabase > /dev/null; then
#   export DOCKER_HOST="unix:///var/run/docker.sock"
#   export DOCKER_CONTEXT="colima"
# fi

echo '🔧 Colima + Supabase utilities loaded from ac_utils'
