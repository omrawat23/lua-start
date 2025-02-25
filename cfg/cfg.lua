Config = {}

-- Framework Configuration
Config.framework = 'esx' -- Set this to 'qb' for QBCore or 'esx' for ESX

-- Core Settings
Config.Debug = false -- Enable debug mode for additional console output
Config.Target = 'ox_target'      -- 'qb-target' or 'ox_target'
Config.Inventory = 'ox' -- 'qb-inventory' or 'ox'
Config.Banking = 'ox'            -- 'qb' or 'ox'
Config.Notify = 'ox'            -- 'qb' or 'ox' or 'esx'

-- Target Interaction Distances
Config.TargetDistance = {
    ["rental:openMenu"] = 2.5,
    ["rental:returnVehicle"] = 2.5,
}

-- License Requirements
Config.DriverLicense = {
    ['car'] = 'driver',    -- Requires 'driver' license for cars
    ['boat'] = 'boat',     -- Requires 'boat' license for boats
    ['aircraft'] = 'pilot', -- Requires 'pilot' license for aircraft
}

-- Available Payment Methods
Config.PaymentMethods = {
    'cash',
    'bank'
}

-- Rental Documents
Config.Items = {
    rental_document = {
        name = "rental_document",
        label = "Vehicle Rental Agreement",
        weight = 0,
        type = "item",
        image = "rental_document.png",
        unique = true,
        useable = true,
        shouldClose = true,
        combinable = nil,
        description = "Official vehicle rental agreement document"
    }
}

-- Vehicle Return Settings
Config.ReturnSettings = {
    damageCharges = true,        -- Charge for vehicle damage
    fuelCharges = true,          -- Charge for missing fuel
    cleanlinessCheck = true,     -- Check vehicle cleanliness
    damageMultiplier = 1.5,      -- Multiplier for damage charges
    minimumFuelReturn = 0.3,     -- Minimum fuel level required (30%)
}

-- Available Vehicle Colors
Config.Colors = {
    { name = "Orange", value = "rgb(253, 126, 20)" },
    { name = "Red", value = "rgb(231, 76, 60)" },
    { name = "Purple", value = "rgb(142, 68, 173)" },
    { name = "Blue", value = "rgb(76, 110, 245)" },
    { name = "Teal", value = "rgb(22, 160, 133)" },
    { name = "Green", value = "rgb(39, 174, 96)" },
    { name = "Gray", value = "rgb(52, 73, 94)" },
    { name = "Black", value = "rgb(37, 38, 43)" },
    { name = "Pink", value = "rgb(230, 73, 128)" },
    { name = "Emerald", value = "rgb(18, 184, 134)" },
    { name = "Yellow", value = "rgb(250, 176, 5)" },
    { name = "Silver", value = "rgb(134, 142, 150)" },
}

-- Rental Locations
Config.Locations = {
    -- Downtown Location
    {
        name = "Downtown Rentals",
        ped = {
            hash = 'u_f_m_miranda_02',
            scenario = "WORLD_HUMAN_STAND_MOBILE"
        },
        coords = vector4(-324.28, -960.3, 30.08, 269.84),
        spawnpoint = vector4(-321.19, -959.94, 31.06, 161.47),
        returnPoint = vector4(-317.87, -963.77, 31.08, 161.47),
        type = 'vehicle',
        blip = {
            label = "Vehicle Rental",
            colour = 50,
            sprite = 56,
            scale = 0.8
        },
        categories = {
            {
                name = "Bicycles",
                vehicles = {
                    {
                        model = 'bmx',
                        money = 50,
                        img = 'nui://starting/build/assets/bmx.png',
                        seats = 1,
                        speed = "20 km/h",
                        efficiency = "90%",
                        colors = Config.Colors,
                    },
                    {
                        model = 'cruiser',
                        money = 50,
                        img = 'nui://starting/build/assets/cruiser.png',
                        colors = Config.Colors,
                    },
                    {
                        model = 'scorcher',
                        money = 75,
                        img = 'nui://starting/build/assets/scorcher.png',
                        colors = Config.Colors,
                    },
                }
            },
            {
                name = "Cars",
                licenseRequired = 'car',
                vehicles = {
                    {
                        model = 'panto',
                        money = 300,
                        type = 'car',
                        img = 'nui://starting/build/assets/panto.png',
                        colors = Config.Colors,
                        fuel = 'petrol',
                        fuelCapacity = 40,
                        deposit = 150,
                    },
                    {
                        model = 'asea',
                        money = 500,
                        type = 'car',
                        img = 'nui://starting/build/assets/asea.png',
                        colors = Config.Colors,
                        fuel = 'petrol',
                        fuelCapacity = 45,
                        deposit = 200,
                    }
                }
            }
        }
    },
    -- Beach Location
    {
        name = "Beach Rentals",
        ped = {
            hash = 'a_m_y_beach_01',
            scenario = "WORLD_HUMAN_STAND_IMPATIENT"
        },
        coords = vector4(-1637.95, -1166.37, 13.03, 127.32),
        spawnpoint = vector4(-1642.22, -1180.76, 0.32, 127.32),
        type = 'boat',
        blip = {
            label = "Boat Rental",
            colour = 3,
            sprite = 427,
            scale = 0.8
        },
        categories = {
            {
                name = "Water Sports",
                licenseRequired = 'boat',
                vehicles = {
                    {
                        model = 'seashark',
                        money = 500,
                        type = 'boat',
                        img = 'nui://starting/build/assets/seashark.png',
                        colors = Config.Colors,
                        deposit = 250,
                    },
                    {
                        model = 'jetmax',
                        money = 2000,
                        type = 'boat',
                        img = 'nui://starting/build/assets/jetmax.png',
                        colors = Config.Colors,
                        fuel = 'petrol',
                        fuelCapacity = 100,
                        deposit = 1000,
                    }
                }
            }
        }
    }
}