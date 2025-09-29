-- resources/la_peditor/game/constants.lua
-- theme="1950s-cartoon-noir"
-- Centralized constants used by client modules. Defensive and minimal.

local Constants = {}

-- Component / prop ids commonly used in MP freemode (trimmed to what editor needs)
Constants.PED_COMPONENTS_IDS = {
    0, -- face (or mask)
    1, -- hair
    2, -- torso
    3, -- legs
    4, -- bags/decals
    5, -- parachute / not used
    6, -- shoes
    7, -- accessories (e.g., scarf)
    8, -- undershirt
    9, -- body armor/vest
    10, -- decals / textures
    11 -- top
}

-- The props ids we care about
Constants.PED_PROPS_IDS = { 0, 1, 2, 6, 7 }

-- Face features names (index -> key). Keep short and map indices used in UI.
Constants.FACE_FEATURES = {
    "Nose_Width", "Nose_Peak_Hight", "Nose_Peak_Length", "Nose_Bone_High", "Nose_Bone_Width",
    "Nose_Bridge", "Nose_Tip_Length", "Nose_Tip_Width", "Cheeks_Bone_Height", "Cheeks_Bone_Width",
    "Cheeks_Width", "Eyes", "Lips", "Jaw_Width", "Jaw_High", "Chin_Length", "Chin_Position", "Neck_Width"
}

-- Head overlay names mapped to overlay index friendly names (few common ones)
Constants.HEAD_OVERLAYS = {
    "blemishes", "facial_hair", "eyebrows", "ageing", "makeup", "blush", "complexion", "sun_damage", "lipstick",
    "freckles", "chest_hair", "body_blemishes", "eyecolor" -- keep as reference, indices relative in code
}

-- hair decorations (for automatic "fade" effect) sample mapping by gender
Constants.HAIR_DECORATIONS = {
    male = {
        -- styleIndex = {collectionName, overlayName}
        [1] = {"mpbeach_overlays", "FM_Hair_Fuzz"},
        [5] = {"mphipster_overlays", "MP_Biker_Hair_001_M"}
    },
    female = {
        [1] = {"mpbeach_overlays", "FM_Hair_Fuzz"},
        [5] = {"mphipster_overlays", "MP_Biker_Hair_001_F"}
    }
}

-- Eye colors: keep a length that matches many native lists (0-15 safe)
Constants.EYE_COLORS = {
    "Black","Brown","Dark Brown","Hazel","Green","Blue","Gray","Amber","Gold","Hazel 2",
    "Blue Light","Blue Gray","Green Brown","Green 2","Gray 2","Ice"
}

-- Small helper to construct vec3 if needed
local function vec3(x,y,z) return { x = x, y = y, z = z } end
Constants.vec3 = vec3

return Constants
