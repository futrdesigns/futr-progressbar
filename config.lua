Config = {}

Config.themes = {
    default = {
        bgColor = {45, 45, 45, 200},        -- Background color (RGBA)
        fillColor = {47, 128, 237, 255},    -- Progress fill color (RGBA)
        textColor = {255, 255, 255, 255},   -- Text color (RGBA)
        borderColor = {255, 255, 255, 50},  -- Border color (RGBA)
        borderRadius = 8.0,                 -- Border radius in pixels
        sound = "SELECT"                    -- Sound theme
    },
    success = {
        bgColor = {45, 45, 45, 200},
        fillColor = {46, 204, 113, 255},
        textColor = {255, 255, 255, 255},
        borderColor = {255, 255, 255, 50},
        borderRadius = 8.0,
        sound = "SELECT"
    },
    warning = {
        bgColor = {45, 45, 45, 200},
        fillColor = {241, 196, 15, 255},
        textColor = {255, 255, 255, 255},
        borderColor = {255, 255, 255, 50},
        borderRadius = 8.0,
        sound = "SELECT"
    },
    error = {
        bgColor = {45, 45, 45, 200},
        fillColor = {231, 76, 60, 255},
        textColor = {255, 255, 255, 255},
        borderColor = {255, 255, 255, 50},
        borderRadius = 8.0,
        sound = "SELECT"
    },
    purple = {
        bgColor = {45, 45, 45, 200},
        fillColor = {155, 89, 182, 255},
        textColor = {255, 255, 255, 255},
        borderColor = {255, 255, 255, 50},
        borderRadius = 8.0,
        sound = "SELECT"
    },
    dark = {
        bgColor = {30, 30, 30, 220},
        fillColor = {86, 101, 115, 255},
        textColor = {255, 255, 255, 255},
        borderColor = {100, 100, 100, 100},
        borderRadius = 4.0,
        sound = "SELECT"
    }
}

-- Progress bar position and size (relative to screen size)
Config.position = {x = 0.5, y = 0.88}           -- Center bottom
Config.size = {width = 0.25, height = 0.035}    -- Width and height

-- Animation settings
Config.animationSpeed = 1.0                    -- Animation speed multiplier

-- Display options
Config.showPercentage = true                   -- Show percentage text
Config.showCancelText = true                   -- Show "Press ESC to cancel" text
Config.enablePulseEffect = true                -- Enable pulsing animation on completion

-- Sound settings
Config.enableSounds = true                     -- Enable/disable sounds
Config.startSound = "SELECT"                   -- Sound when progress starts
Config.completeSound = "SELECT"                -- Sound when progress completes
Config.cancelSound = "BACK"                    -- Sound when progress cancelled

-- Key bindings
Config.cancelKeys = {200, 194}                -- ESC (200) and Backspace (194)

return Config