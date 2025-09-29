-- la_peditor/locales/en.lua
-- theme="1950s-cartoon-noir"
-- English locale for la_peditor (Los Animales RP, 1950s cartoon-noir)
-- Keep keys compact; this covers strings used across client/server code.

local translations = {
    -- Generic UI
    ["open_menu"] = "Press ~INPUT_CONTEXT~ to open the Appearance Menu. (theme=\"1950s-cartoon-noir\")",
    ["open_clothingroom"] = "Press ~INPUT_CONTEXT~ to open the Clothing Room. (theme=\"1950s-cartoon-noir\")",
    ["open_player_outfit_room"] = "Press ~INPUT_CONTEXT~ to manage Player Outfits. (theme=\"1950s-cartoon-noir\")",
    ["cancelled.title"] = "Cancelled",
    ["cancelled.description"] = "You cancelled the operation.",

    -- Clothing / Outfits
    ["clothing.title"] = "Clothing Shop - $%s (theme=\"1950s-cartoon-noir\")",
    ["clothing.titleNoPrice"] = "Clothing - No Price (theme=\"1950s-cartoon-noir\")",
    ["clothing.options.title"] = "Los Animales Clothiers (theme=\"1950s-cartoon-noir\")",
    ["clothing.options.description"] = "Pick from suits, dresses and period accessories.",
    ["clothing.options.pDescription"] = "Manage your outfits and wardrobe.",
    ["clothing.outfits.title"] = "Saved Outfits",

    -- Outfits menu items
    ["outfits.change.title"] = "Change Outfit",
    ["outfits.change.pDescription"] = "Change between your saved outfits.",
    ["outfits.update.title"] = "Update Outfit",
    ["outfits.update.description"] = "Update an existing saved outfit with your current look.",
    ["outfits.save.menuTitle"] = "Save Outfit",
    ["outfits.save.menuDescription"] = "Save your current look as a new outfit.",
    ["outfits.save.title"] = "Save Outfit",
    ["outfits.save.name.label"] = "Outfit Name",
    ["outfits.save.name.placeholder"] = "e.g. \"Detective Suit\"",
    ["outfits.save.name.default"] = "My Outfit",
    ["outfits.save.failure.title"] = "Save Failed",
    ["outfits.save.failure.description"] = "An outfit with that name already exists.",
    ["outfits.save.managementTitle"] = "Save Management Outfit",

    ["outfits.save.gender.label"] = "Gender",
    ["outfits.save.gender.male"] = "Male",
    ["outfits.save.gender.female"] = "Female",
    ["outfits.save.rank.label"] = "Minimum Rank",

    ["outfits.import.title"] = "Import Outfit",
    ["outfits.import.name.label"] = "Name for Outfit",
    ["outfits.import.name.placeholder"] = "Give this outfit a name",
    ["outfits.import.name.default"] = "Imported Outfit",
    ["outfits.import.code.label"] = "Outfit Code",
    ["outfits.import.success.title"] = "Import Successful",
    ["outfits.import.success.description"] = "The outfit was imported and saved.",
    ["outfits.import.failure.title"] = "Import Failed",
    ["outfits.import.failure.description"] = "Invalid outfit code or import failed.",

    ["outfits.generate.title"] = "Generate Outfit Code",
    ["outfits.generate.success.title"] = "Code Generated",
    ["outfits.generate.success.description"] = "The outfit code has been copied to your clipboard.",
    ["outfits.generate.failure.title"] = "Generation Failed",
    ["outfits.generate.failure.description"] = "Could not generate a code for that outfit.",

    ["outfits.delete.title"] = "Delete Outfit",
    ["outfits.delete.mDescription"] = "Remove an outfit permanently.",
    ["outfits.delete.success.title"] = "Deleted",
    ["outfits.delete.success.description"] = "Outfit removed successfully.",
    ["outfits.delete.management.success.title"] = "Management Outfit Removed",
    ["outfits.delete.management.success.description"] = "Successfully deleted the management outfit.",

    ["outfits.import.menuTitle"] = "Import Outfit Code",
    ["outfits.import.description"] = "Paste an outfit code to import it.",

    -- Job / Management
    ["jobOutfits.title"] = "Work Outfits",
    ["jobOutfits.description"] = "Select a job uniform.",
    ["clothing.outfits.civilian.title"] = "Return to Civilian",
    ["clothing.outfits.civilian.description"] = "Switch your outfit back to civilian clothes.",

    -- Migrate
    ["migrate.success.title"] = "Migration Complete",
    ["migrate.success.description"] = "Successfully migrated %s skins.",
    ["migrate.success.descriptionSingle"] = "Skin migrated.",
    ["migrate.skip.title"] = "Migrate: Skipped",
    ["migrate.skip.description"] = "Skipping - not a compatible skin format.",
    ["migrate.typeError.title"] = "Unknown Migration",
    ["migrate.typeError.description"] = "Supported resources: fivem-appearance, qb-clothing.",

    -- Commands
    ["commands.reloadskin.failure.title"] = "Cannot Reload Skin",
    ["commands.reloadskin.failure.description"] = "You cannot reload your skin right now.",
    ["commands.clearstuckprops.failure.title"] = "Cannot Clear Props",
    ["commands.clearstuckprops.failure.description"] = "Unable to clear stuck props at this time.",

    -- Notifications
    ["notify.no_money.title"] = "Cannot Enter Shop",
    ["notify.no_money.description"] = "Not enough cash to access this shop.",

    -- Camera / Bostra (legacy naming kept for compatibility)
    ["bostra.camera"] = "Customization Camera (theme=\"1950s-cartoon-noir\")",

    -- Generic success/failure
    ["success.title"] = "Success",
    ["failure.title"] = "Failure",
    ["inform.title"] = "Note"
}

return translations
