# NOTICE - THIS REPOSITORY HAS BEEN ARCHIVED AND DEPRECATED IN FAVOR OF STARSHIP
https://starship.rs


# Autodetect Behavior
This module automatically detects Windows Terminal and Visual Studio Code and performs the following customizations:

Windows Terminal - Enable partial emoji support, and detect Powerline/Nerd Fonts


# Settings
These settings can be set as environment variables PP_<variable>. This overrides any autodiscovery in place.
It's recommended these be set in your host-specific profile (`$profile.currentusercurrenthost`)
UseUnicode = true/false - Enables use of unicode characters (emojis)
