/*
 * MIT License
 *
 * Copyright (c) 2023 FORM08.COM s.r.o.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Project: Form08
 * Module: ac_http_client
 * File: api_error.g.dart
 *
 */

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
      status: json['status'] as int?,
      error: json['error'] as String,
      message: json['message'] as String?,
      path: json['path'] as String?,
      datetime: json['datetime'] == null
          ? null
          : DateTime.parse(json['datetime'] as String),
    );

_ApiErrorErrors _$ApiErrorErrorsFromJson(Map<String, dynamic> json) =>
    _ApiErrorErrors()
      ..codes =
          (json['codes'] as List<dynamic>?)?.map((e) => e as String).toList();

_ApiErrorArguments _$ApiErrorArgumentsFromJson(Map<String, dynamic> json) =>
    _ApiErrorArguments()
      ..codes =
          (json['codes'] as List<dynamic>?)?.map((e) => e as String).toList();
