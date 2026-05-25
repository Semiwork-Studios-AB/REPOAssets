# REPO ASSETS MIRROR

This repository is a public mirror for _some_ assets in the latest release build of R.E.P.O. and exists to help mod developers.

# Editor Scripts

The PrefabRef _editor_ scripts provided make it easier to work with the non-editor PrefabRef script (Assets/REPO/Game/Scripts/Assembly-CSharp/PrefabRef.cs) by automatically keeping the paths and references up to date.

For context, the non-editor PrefabRef script allows you to reference a prefab without loading it into memory until needed to help reduce ram usage.

# Shaders

The hurtable shaders are written using Ampify Shader Editor but can still be modified manually.

These shaders should be used when adding your own custom cosmetics and enemies to allow enemies and cosmetics to flash red and green when damaged and healed respectively.

# Localization

All the currently available localization-related assets have been mirrored here for convenience.

Please do note that localization is still a work in progress and issues may occur when adding your own localizations.

Fallback fonts have been added for most writing scripts, so it _should_ no longer be necessary to add your own fonts manually.

The base localization strings have been added as TSV (Tab-Separated Values) files to: `REPO/REPO_Data/StreamingAssets/Localization/Default/`.

Custom string overrides can now be made by copying these TSV files to the `StreamingAssets/Localization/` folder and editing them in a text editor.

For example, you can copy the HUD TSV file to `StreamingAssets/Localization/HUD.tsv` to load custom HUD-specific strings.