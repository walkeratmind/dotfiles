local auto_session = require "auto-session"

auto_session.setup {
  enabled = true, -- Enables/disables auto creating, saving and restoring
  root_dir = vim.fn.stdpath "data" .. "/sessions/", -- Root dir where sessions will be stored
  auto_save = true, -- Enables/disables auto saving session on exit
  auto_restore = true, -- Enables/disables auto restoring session on start
  auto_create = true, -- Enables/disables auto creating new session files. Can take a function that should return true/false if a new session file should be created or not
  suppressed_dirs = nil, -- Suppress session restore/create in certain directories
  allowed_dirs = nil, -- Allow session restore/create in certain directories
  auto_restore_last_session = false, -- On startup, loads the last saved session if session for cwd does not exist
  use_git_branch = false, -- Include git branch name in session name
  lazy_support = true, -- Automatically detect if Lazy.nvim is being used and wait until Lazy is done to make sure session is restored correctly. Does nothing if Lazy isn't being used. Can be disabled if a problem is suspected or for debugging
  bypass_save_filetypes = nil, -- List of file types to bypass auto save when the only buffer open is one of the file types listed, useful to ignore dashboards
  close_unsupported_windows = true, -- Close windows that aren't backed by normal file before autosaving a session
  args_allow_single_directory = true, -- Follow normal sesion save/load logic if launched with a single directory as the only argument
  args_allow_files_auto_save = false, -- Allow saving a session even when launched with a file argument (or multiple files/dirs). It does not load any existing session first. While you can just set this to true, you probably want to set it to a function that decides when to save a session when launched with file args. See documentation for more detail
  continue_restore_on_error = true, -- Keep loading the session even if there's an error
  cwd_change_handling = false, -- Follow cwd changes, saving a session before change and restoring after
  log_level = "error", -- Sets the log level of the plugin (debug, info, warn, error).

  -- ⚠️ This will only work if Telescope.nvim is installed
  -- The following are already the default values, no need to provide them if these are already the settings you want.
  session_lens = {
    -- If load_on_setup is set to false, one needs to eventually call `require("auto-session").setup_session_lens()` if they want to use session-lens.
    buftypes_to_ignore = {}, -- list of buffer types what should not be deleted from current session
    load_on_setup = true,
    theme_conf = { border = true },
    previewer = false,
  },
}

local keymap = vim.keymap

keymap.set("n", "<leader>ssr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
keymap.set("n", "<leader>sss", "<cmd>SessionSave<CR>", { desc = "Save session for auto session" }) -- save workspace session for current working directory

keymap.set(
  "n",
  "<leader>ssp",
  "<cmd>SessionPurgeOrphaned<CR>",
  { desc = "Session purge orphaned, removes session with no working dir" }
)
keymap.set("n", "<leader>ssd", "<cmd>Autosession delete<CR>", { desc = "Session delete" })

-- Set mapping for searching a session.
-- ⚠️ This will only work if Telescope.nvim is installed
keymap.set(
  "n",
  "<leader>ssl",
  require("auto-session.session-lens").search_session,
  { desc = "Sessions List", noremap = true }
)
