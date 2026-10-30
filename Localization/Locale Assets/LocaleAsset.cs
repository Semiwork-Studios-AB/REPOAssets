using System;
using System.IO;
using Sirenix.OdinInspector;
using UnityEditor;
using UnityEngine;
using UnityEngine.Localization;
using UnityEngine.Localization.Settings;

[CreateAssetMenu(fileName = "LocaleAsset - [Unknown Locale Reference] (Disabled).asset", menuName = "Localization/Locale Asset")]
public class LocaleAsset : ScriptableObject{

    public string NativeName = "";
    public bool RightToLeft = false;
    public bool Enabled;
    public Locale LocaleReference;
    
#if UNITY_EDITOR
    private const string basePath = "Assets/Localization/Locale Assets/";
#endif    
    
#if UNITY_EDITOR
    public void OnValidate(){

        if(SemiFunc.OnValidateCheck()) return;
        ValidateTTSSupport();

        string _suffix = Enabled ? "(Enabled)" : "(Disabled)";
        string _localeName = LocaleReference ? LocaleReference.name : "[Unknown Locale Reference]";
        string _newName = $"LocaleAsset - {_localeName} {_suffix}";
        
        if(name == _newName) return;
        
        string _currentPath = AssetDatabase.GetAssetPath(this);
        
        EditorUtility.SetDirty(this);
        string _error = AssetDatabase.RenameAsset(_currentPath, _newName);
        if(_error != "") Debug.LogError($"Failed to rename asset: {_error}");
    }

    public void ValidateTTSSupport(){

        if(!Enabled || !LocaleReference) return;
        var _localeCode = LocaleReference.Identifier.Code;
        if(TTSPronunciation.LocaleSupported(_localeCode)) return;
        Debug.LogWarning("tts is not set up for " + _localeCode + "... add pronunciation and formatting support before enabling it for speech. tts will use english until then.", this);
    }

    [ButtonGroup]
    [Button("Auto Set Reference", ButtonSizes.Medium)]
    public void AutoSetReference(){
        
        foreach(var _locale in LocalizationSettings.AvailableLocales.Locales){
            
            string _path = $"{basePath}LocaleAsset - {_locale.name}";
            const string _extension = ".asset";
            
            if(File.Exists($"{_path} (Enabled){_extension}")) continue;
            if(File.Exists($"{_path} (Disabled){_extension}")) continue;
 
            string _suffix = Enabled ? "(Enabled)" : "(Disabled)";
            string _newName = $"LocaleAsset - {_locale.name} {_suffix}";
            string _currentPath = AssetDatabase.GetAssetPath(this);
            EditorUtility.SetDirty(this);
            LocaleReference = _locale;
            name = _locale.LocaleName;
            string _error = AssetDatabase.RenameAsset(_currentPath, _newName);
            if(_error != "") Debug.LogError($"Failed to rename asset: {_error}");
            return;
        }
        
        Debug.Log("All locales have a locale asset set. No changes made.", this);
    }
#endif
}