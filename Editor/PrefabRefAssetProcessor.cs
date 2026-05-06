using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class PrefabRefAssetProcessor : AssetModificationProcessor {
    static bool UpdateAssetValues(GameObject prefab, string newName, string newPath, SerializedObject serialized) {
        bool changed = false;
        var iterator = serialized.GetIterator();
        while(iterator.NextVisible(true)){
            if(iterator.propertyType != SerializedPropertyType.Generic || iterator.type != "PrefabRef") continue;
            var prefabProp = iterator.FindPropertyRelative("prefab");
            if(prefabProp == null || prefabProp.objectReferenceValue != prefab) continue;

            iterator.FindPropertyRelative("prefabName").stringValue = newName;

            var resourcePathProp = iterator.FindPropertyRelative("resourcePath");
            var cleanPath = newPath.Replace("//", "/");
            if(cleanPath.Contains("/Resources/")){
                int start = cleanPath.IndexOf("/Resources/", StringComparison.Ordinal) + 11;
                int end = cleanPath.LastIndexOf(".prefab", StringComparison.Ordinal);
                resourcePathProp.stringValue = cleanPath.Substring(start, end - start);
            }else{
                resourcePathProp.stringValue = newName;
            }
            changed = true;
        }
        return changed;
    }

    public static void ProcessPaths(string[] paths, GameObject prefab, string newName, string newPath, List<UnityEngine.Object> dirtyAssets, List<GameObject> dirtyPrefabs) {
        foreach(var path in paths){
            var so = AssetDatabase.LoadAssetAtPath<ScriptableObject>(path);
            if(so != null){
                var serialized = new SerializedObject(so);
                if(UpdateAssetValues(prefab, newName, newPath, serialized)){
                    serialized.ApplyModifiedProperties();
                    EditorUtility.SetDirty(so);
                    dirtyAssets.Add(so);
                }
                continue;
            }

            var go = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if(go != null){
                bool anyChanged = false;
                foreach(var comp in go.GetComponentsInChildren<MonoBehaviour>(true)){
                    if(comp == null) continue;
                    try{
                        var serialized = new SerializedObject(comp);
                        if(!UpdateAssetValues(prefab, newName, newPath, serialized)) continue;
                        serialized.ApplyModifiedProperties();
                        EditorUtility.SetDirty(comp);
                        anyChanged = true;
                    }catch(Exception ex){
                        Debug.LogError(ex);
                    }
                }

                if(!anyChanged) continue;
                EditorUtility.SetDirty(go);
                dirtyPrefabs.Add(go);
            }
        }
    }

    static AssetMoveResult OnWillMoveAsset(string oldPath, string newPath) {
        if(ParrelSync.ClonesManager.IsClone()) return AssetMoveResult.DidNotMove;
        if(!oldPath.EndsWith(".prefab")) return AssetMoveResult.DidNotMove;
        if(!oldPath.Contains("/Resources/") && !newPath.Contains("/Resources/")) return AssetMoveResult.DidNotMove;
        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(oldPath);
        if(prefab == null) return AssetMoveResult.DidNotMove;

        string newName = System.IO.Path.GetFileNameWithoutExtension(newPath);
        string prefabGuid = AssetDatabase.AssetPathToGUID(oldPath);

        var dependents = AssetDatabase.FindAssets("t:ScriptableObject")
            .Concat(AssetDatabase.FindAssets("t:Prefab"))
            .Distinct()
            .Select(AssetDatabase.GUIDToAssetPath)
            .Where(p => System.IO.File.Exists(p) && System.IO.File.ReadAllText(p).Contains(prefabGuid))
            .ToArray();

        List<UnityEngine.Object> dirtyAssets = new();
        List<GameObject> dirtyPrefabs = new();

        ProcessPaths(dependents, prefab, newName, newPath, dirtyAssets, dirtyPrefabs);

        if(dirtyAssets.Count > 0){
            AssetDatabase.StartAssetEditing();
            try{
                foreach(var obj in dirtyAssets){
                    AssetDatabase.SaveAssetIfDirty(obj);
                }
            }finally{
                AssetDatabase.StopAssetEditing();
            }
        }

        foreach(var go in dirtyPrefabs){
            PrefabUtility.SavePrefabAsset(go);
        }

        return AssetMoveResult.DidNotMove;
    }

    static AssetDeleteResult OnWillDeleteAsset(string newPath, RemoveAssetOptions options) {
        if(ParrelSync.ClonesManager.IsClone()) return AssetDeleteResult.DidNotDelete;
        if(!newPath.EndsWith(".prefab") || !newPath.Contains("/Resources/")) return AssetDeleteResult.DidNotDelete;
        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(newPath);
        if(prefab == null) return AssetDeleteResult.DidNotDelete;

        string newName = System.IO.Path.GetFileNameWithoutExtension(newPath);
        string prefabGuid = AssetDatabase.AssetPathToGUID(newPath);

        var dependents = AssetDatabase.FindAssets("t:ScriptableObject")
            .Concat(AssetDatabase.FindAssets("t:Prefab"))
            .Distinct()
            .Select(AssetDatabase.GUIDToAssetPath)
            .Where(p => System.IO.File.Exists(p) && System.IO.File.ReadAllText(p).Contains(prefabGuid))
            .ToArray();

        List<UnityEngine.Object> dirtyAssets = new();
        List<GameObject> dirtyPrefabs = new();

        ProcessPaths(dependents, prefab, newName, newPath, dirtyAssets, dirtyPrefabs);

        if(dirtyAssets.Count > 0){
            AssetDatabase.StartAssetEditing();
            try{
                foreach(var obj in dirtyAssets){
                    AssetDatabase.SaveAssetIfDirty(obj);
                }
            }finally{
                AssetDatabase.StopAssetEditing();
            }
        }

        foreach(var go in dirtyPrefabs){
            PrefabUtility.SavePrefabAsset(go);
        }

        return AssetDeleteResult.DidNotDelete;
    }
}

public class PrefabRefAssetPostprocessor : AssetPostprocessor {
    static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths) {
        if(!DebugDevEditor.updatePrefabRefsOnReimport || ParrelSync.ClonesManager.IsClone()) return;

        List<UnityEngine.Object> dirtyAssets = new();
        List<GameObject> dirtyPrefabs = new();

        Dictionary<string, string> allAssetContents = null;

        foreach(var newPath in importedAssets){
            if(!newPath.EndsWith(".prefab") || movedAssets.Contains(newPath) || !newPath.Contains("/Resources/")) continue;
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(newPath);
            if(prefab == null) continue;

            string newName = System.IO.Path.GetFileNameWithoutExtension(newPath);
            string prefabGuid = AssetDatabase.AssetPathToGUID(newPath);

            if(allAssetContents == null){
                allAssetContents = AssetDatabase.FindAssets("t:ScriptableObject").Concat(AssetDatabase.FindAssets("t:Prefab"))
                    .Distinct()
                    .Select(AssetDatabase.GUIDToAssetPath)
                    .ToDictionary(p => p, System.IO.File.ReadAllText);
            }
            var dependents = allAssetContents.Where(kvp => kvp.Value.Contains(prefabGuid)).Select(kvp => kvp.Key).ToArray();

            PrefabRefAssetProcessor.ProcessPaths(dependents, prefab, newName, newPath, dirtyAssets, dirtyPrefabs);
        }

        if(dirtyAssets.Count > 0){
            AssetDatabase.StartAssetEditing();
            try{
                foreach(var obj in dirtyAssets){
                    AssetDatabase.SaveAssetIfDirty(obj);
                }
            }finally{
                AssetDatabase.StopAssetEditing();
            }
        }

        foreach(var go in dirtyPrefabs){
            PrefabUtility.SavePrefabAsset(go);
        }
    }
}