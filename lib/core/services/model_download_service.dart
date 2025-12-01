import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// 模型下载状态
enum DownloadStatus {
  idle,
  downloading,
  completed,
  failed,
}

/// 模型下载进度
class DownloadProgress {
  final DownloadStatus status;
  final double progress; // 0.0 - 1.0
  final String? currentFile;
  final String? error;
  final int downloadedBytes;
  final int totalBytes;

  const DownloadProgress({
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.currentFile,
    this.error,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
  });

  DownloadProgress copyWith({
    DownloadStatus? status,
    double? progress,
    String? currentFile,
    String? error,
    int? downloadedBytes,
    int? totalBytes,
  }) {
    return DownloadProgress(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentFile: currentFile ?? this.currentFile,
      error: error,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }

  String get progressText {
    if (totalBytes > 0) {
      final downloadedMB = (downloadedBytes / 1024 / 1024).toStringAsFixed(1);
      final totalMB = (totalBytes / 1024 / 1024).toStringAsFixed(1);
      return '$downloadedMB MB / $totalMB MB';
    }
    return '${(progress * 100).toStringAsFixed(0)}%';
  }
}

/// 模型下载服务
class ModelDownloadService {
  static final ModelDownloadService instance = ModelDownloadService._init();
  ModelDownloadService._init();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 30),
  ));

  /// Kokoro 模型下载地址
  /// 优先使用中国镜像，备用原始地址

  /// 中国镜像 (hf-mirror.com)
  static const String _modelUrlChina =
      'https://hf-mirror.com/hexgrad/Kokoro-82M/resolve/main/kokoro-v1.0.onnx';
  static const String _voicesUrlChina =
      'https://hf-mirror.com/hexgrad/Kokoro-82M/resolve/main/voices.json';

  /// HuggingFace 原始地址
  static const String _modelUrl =
      'https://huggingface.co/hexgrad/Kokoro-82M/resolve/main/kokoro-v1.0.onnx';
  static const String _voicesUrl =
      'https://huggingface.co/hexgrad/Kokoro-82M/resolve/main/voices.json';

  /// 备用下载地址 (GitHub Release)
  static const String _modelUrlBackup =
      'https://github.com/hexgrad/kokoro-onnx/releases/download/v1.0/kokoro-v1.0.onnx';
  static const String _voicesUrlBackup =
      'https://github.com/hexgrad/kokoro-onnx/releases/download/v1.0/voices.json';

  CancelToken? _cancelToken;
  bool _isCancelled = false;

  /// 下载模型文件
  Future<void> downloadModels({
    required Function(DownloadProgress) onProgress,
  }) async {
    _isCancelled = false;
    _cancelToken = CancelToken();

    try {
      // 获取模型目录
      final appDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${appDir.path}/kokoro_models');

      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      final modelFile = File('${modelDir.path}/kokoro-v1.0.onnx');
      final voicesFile = File('${modelDir.path}/voices.json');

      // 下载 voices.json (小文件先下载)
      onProgress(const DownloadProgress(
        status: DownloadStatus.downloading,
        progress: 0.0,
        currentFile: 'voices.json',
      ));

      await _downloadFile(
        urls: [_voicesUrlChina, _voicesUrl, _voicesUrlBackup],
        savePath: voicesFile.path,
        onProgress: (received, total) {
          // voices.json 很小，算作 1% 的进度
          onProgress(DownloadProgress(
            status: DownloadStatus.downloading,
            progress: 0.01 * (received / total),
            currentFile: 'voices.json',
            downloadedBytes: received,
            totalBytes: total,
          ));
        },
      );

      if (_isCancelled) return;

      // 下载主模型文件
      onProgress(const DownloadProgress(
        status: DownloadStatus.downloading,
        progress: 0.01,
        currentFile: 'kokoro-v1.0.onnx',
      ));

      await _downloadFile(
        urls: [_modelUrlChina, _modelUrl, _modelUrlBackup],
        savePath: modelFile.path,
        onProgress: (received, total) {
          // 主模型占 99% 的进度
          final modelProgress = total > 0 ? received / total : 0.0;
          onProgress(DownloadProgress(
            status: DownloadStatus.downloading,
            progress: 0.01 + 0.99 * modelProgress,
            currentFile: 'kokoro-v1.0.onnx',
            downloadedBytes: received,
            totalBytes: total,
          ));
        },
      );

      if (_isCancelled) return;

      // 下载完成
      onProgress(const DownloadProgress(
        status: DownloadStatus.completed,
        progress: 1.0,
      ));

    } catch (e) {
      if (_isCancelled) {
        onProgress(const DownloadProgress(
          status: DownloadStatus.idle,
          progress: 0.0,
        ));
      } else {
        onProgress(DownloadProgress(
          status: DownloadStatus.failed,
          progress: 0.0,
          error: _getErrorMessage(e),
        ));
      }
    }
  }

  /// 下载单个文件，支持多个备用地址
  Future<void> _downloadFile({
    required List<String> urls,
    required String savePath,
    required Function(int received, int total) onProgress,
  }) async {
    Exception? lastError;

    for (int i = 0; i < urls.length; i++) {
      final url = urls[i];
      try {
        print('尝试下载: $url');
        await _tryDownload(url, savePath, onProgress);
        print('下载成功: $url');
        return; // 成功则返回
      } catch (e) {
        print('下载失败 (${i + 1}/${urls.length}): $e');
        lastError = e is Exception ? e : Exception(e.toString());
        // 继续尝试下一个地址
      }
    }

    // 所有地址都失败
    throw lastError ?? Exception('所有下载地址都失败');
  }

  Future<void> _tryDownload(
    String url,
    String savePath,
    Function(int received, int total) onProgress,
  ) async {
    await _dio.download(
      url,
      savePath,
      cancelToken: _cancelToken,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          onProgress(received, total);
        }
      },
    );
  }

  /// 取消下载
  void cancelDownload() {
    _isCancelled = true;
    _cancelToken?.cancel('用户取消下载');
  }

  /// 删除已下载的模型
  Future<void> deleteModels() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${appDir.path}/kokoro_models');
    if (await modelDir.exists()) {
      await modelDir.delete(recursive: true);
    }
  }

  /// 获取模型文件大小（用于显示）
  static String get modelSizeText => '约 330 MB';

  /// 获取错误信息
  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时，请检查网络';
        case DioExceptionType.receiveTimeout:
          return '下载超时，请重试';
        case DioExceptionType.cancel:
          return '下载已取消';
        case DioExceptionType.connectionError:
          return '网络连接失败，请检查网络';
        default:
          return '下载失败: ${error.message}';
      }
    }
    return '下载失败: $error';
  }
}
