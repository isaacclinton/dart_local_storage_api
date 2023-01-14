import 'dart:async';

import 'package:hive/hive.dart';
import 'package:storage_api/storage_api.dart';

class LocalStorageApi extends StorageApi {
  LocalStorageApi({FutureOr<String?> path, String? name}) {
    _initializeFuture = Future(() async {
      Hive.init(await path);
      _box = await Hive.openBox(name ?? "main_box");
      await _box.compact();
    }).then((value) {
      _initializeFuture = null;
    });
  }

  late Box _box;
  Future? _initializeFuture;

  FutureOr<T> _act<T>(FutureOr<T> Function(Box box) action) async {
    await _waitInitialized();
    return await action(_box);
  }

  Future<void> _waitInitialized() async {
    if (_initializeFuture != null) {
      await _initializeFuture;
    }
  }

  @override
  Future<Iterable> getValues() async {
    return await _act((box) => box.values);
  }

  @override
  Future<void> delete(String key) async {
    return await _act((box) => box.delete(key));
  }

  @override
  Future<void> setAllValues(Map<String, dynamic> values) async {
    return await _act((box) => box.putAll(values));
  }

  @override
  Future<dynamic> getValue(String key) async {
    return await _act((box) => box.get(key));
  }

  @override
  Future<void> setValue(String key, value) async {
    return await _act((box) async {
      await box.delete(key);
      await box.put(key, value);
      await box.flush();
    });
  }

  @override
  Future<void> dispose() async {
    await _act((box) => box.close());
  }

  @override
  Future<Iterable<dynamic>> getKeys() async {
    return await _act((box) => box.keys);
  }
  
  @override
  FutureOr<void> deleteAll(Iterable<String> keys) async {
    return await _act((box) => box.deleteAll(keys));
  }
}
