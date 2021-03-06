// Created by 超悟空 on 2018/9/25.
// Version 1.0 2018/9/25
// Since 1.0 2018/9/25

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import 'package:dio/dio.dart' as dio;

import '_print.dart';
import 'communication.dart' as com;
import 'work_config.dart' as work;

/// 发起请求
///
/// dio实现
Future<com.Response> request(String tag, com.Options options) async {
  final dioOptions = _onConfigOptions(tag, options);

  dio.Response dioResponse;

  bool success = false;

  com.HttpErrorType errorType;

  // 总接收子节数
  int receiveByteCount = 0;

  // 结果解析器
  dio.ResponseDecoder decoder = (responseBytes, options, responseBody) {
    receiveByteCount = responseBytes.length;
    return utf8.decode(responseBytes, allowMalformed: true);
  };

  dioOptions.responseDecoder = decoder;

  try {
    switch (options.method) {
      case com.HttpMethod.download:
        log(tag, "download path:${options.downloadPath}");

        // 接收进度代理
        onReceiveProgress(int receive, int total) {
          receiveByteCount = receive;
          options.onReceiveProgress?.call(receive, total);
        }

        dioResponse = await work.dio.download(options.url, options.downloadPath,
            data: options.params,
            cancelToken: options.cancelToken.data,
            options: dioOptions,
            onReceiveProgress: onReceiveProgress);
        break;
      case com.HttpMethod.get:
        dioResponse = await work.dio.get(
          options.url,
          queryParameters: options.params,
          cancelToken: options.cancelToken.data,
          options: dioOptions,
          onReceiveProgress: options.onReceiveProgress,
        );
        break;
      case com.HttpMethod.upload:
        dioResponse = await work.dio.request(
          options.url,
          data: await _onConvertToDio(options.params),
          cancelToken: options.cancelToken.data,
          options: dioOptions,
          onSendProgress: options.onSendProgress,
          onReceiveProgress: options.onReceiveProgress,
        );
        break;
      default:
        dioResponse = await work.dio.request(
          options.url,
          data: options.params,
          cancelToken: options.cancelToken.data,
          options: dioOptions,
          onSendProgress: options.onSendProgress,
          onReceiveProgress: options.onReceiveProgress,
        );
        break;
    }

    success = true;
  } on dio.DioError catch (e) {
    log(tag, "http error", e.type);

    dioResponse = e.response;
    success = false;
    errorType = _onConvertErrorType(e.type);
  } catch (e) {
    log(tag, "http other error", e);
    errorType = com.HttpErrorType.other;
  }

  if (dioResponse != null) {
    return com.Response(
      success: success,
      statusCode: dioResponse.statusCode,
      headers: dioResponse.headers?.map,
      data: dioResponse.request?.responseType == dio.ResponseType.stream
          ? dioResponse.data.stream
          : dioResponse.data,
      errorType: errorType,
      receiveByteCount: receiveByteCount,
    );
  } else {
    return com.Response(errorType: errorType);
  }
}

/// 转换dio异常类型到work库异常类型
com.HttpErrorType _onConvertErrorType(dio.DioErrorType type) {
  switch (type) {
    case dio.DioErrorType.CONNECT_TIMEOUT:
      return com.HttpErrorType.connectTimeout;
    case dio.DioErrorType.SEND_TIMEOUT:
      return com.HttpErrorType.sendTimeout;
    case dio.DioErrorType.RECEIVE_TIMEOUT:
      return com.HttpErrorType.receiveTimeout;
    case dio.DioErrorType.RESPONSE:
      return com.HttpErrorType.response;
    case dio.DioErrorType.CANCEL:
      return com.HttpErrorType.cancel;
    default:
      return com.HttpErrorType.other;
  }
}

/// 用于[com.HttpMethod.upload]请求类型的数据转换
///
/// [src]原始参数，返回处理后的符合dio接口的参数
Future<dio.FormData> _onConvertToDio(Map<String, dynamic> src) async {
  onConvert(value) async {
    if (value is File) {
      value = com.UploadFileInfo(value.path);
    }

    if (value is com.UploadFileInfo) {
      return dio.MultipartFile.fromFile(
        value.filePath,
        filename: value.fileName,
        contentType: MediaType.parse(value.mimeType),
      );
    }

    return value;
  }

  final params = Map<String, dynamic>();

  for (final entry in src.entries) {
    if (entry.value is List) {
      (entry.value as List);
      params[entry.key] =
          await Stream.fromFutures(entry.value.map(onConvert)).toList();
    } else {
      params[entry.key] = await onConvert(entry.value);
    }
  }

  return dio.FormData.fromMap(params);
}

/// 生成dio专用配置
dio.Options _onConfigOptions(String tag, com.Options options) {
  final dioOptions = dio.Options();

  switch (options.method) {
    case com.HttpMethod.get:
    case com.HttpMethod.download:
      dioOptions.method = "GET";
      break;
    case com.HttpMethod.post:
    case com.HttpMethod.upload:
      dioOptions.method = "POST";
      break;
    case com.HttpMethod.put:
      dioOptions.method = "PUT";
      break;
    case com.HttpMethod.head:
      dioOptions.method = "HEAD";
      break;
    case com.HttpMethod.delete:
      dioOptions.method = "DELETE";
      break;
  }

  if (options.responseType != null) {
    switch (options.responseType) {
      case com.ResponseType.json:
        dioOptions.responseType = dio.ResponseType.json;
        break;
      case com.ResponseType.stream:
        dioOptions.responseType = dio.ResponseType.stream;
        break;
      case com.ResponseType.plain:
        dioOptions.responseType = dio.ResponseType.plain;
        break;
      case com.ResponseType.bytes:
        dioOptions.responseType = dio.ResponseType.bytes;
        break;
    }
  }

  if (options.headers != null) {
    dioOptions.headers.addAll(options.headers);
  }

  dioOptions.contentType = options.contentType;
  dioOptions.receiveTimeout = options.readTimeout;
  dioOptions.sendTimeout = options.sendTimeout;

  if (options.cancelToken.data is! dio.CancelToken) {
    com.CancelToken cancelToken = options.cancelToken;

    cancelToken.data = dio.CancelToken();

    cancelToken.stream.listen((_) {
      if (cancelToken.data is dio.CancelToken) {
        log(tag, "http cancel");
        cancelToken.data.cancel();
        cancelToken.data = null;
      }
    });
  }

  return dioOptions;
}
