use '~/.cache/starship/init.nu'

# atuin
source ~/.local/share/atuin/init.nu


# Hooks
# Load zellij tab hook
source ~/.config/nushell/hooks/zellij-tab.nu


# Load zellij helper functions
source ~/.config/nushell/hooks/zellij-helpers.nu

# load fzf useful aliases
# use modules/integrations/fzf.nu [zf, "zf files", "zf git"]
# In config.nu - load everything
# use modules/integrations/fzf.nu *
use modules/integrations/zf-menu.nu *

# Import both modules (adjust paths as needed)
use modules/integrations/zellij-session.nu *
# use fzf.nu *
use modules/integrations/fzf-utils.nu *


