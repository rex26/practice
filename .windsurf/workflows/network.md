---
description: 用于规范网络请求以及对应数据的生成规则
auto_execution_mode: 1
---

数据模型规范
1. 命名规范
  - 文件名采用snake_case, 例如: message_model.dart
  - 模型类名采用 PascalCase 命名法，通常以 Model结尾, 例如: MessageListModel
  - 字段名使用 camelCase，而对应的 JSON 字段使用 snake_case
  - API 相关的模型通常放在 models/ 或 models/view_model/ 目录下
2. 类结构
  - 所有属性都声明为可空类型（使用 ? 标记），便于处理 API 可能缺失的字段
  - 提供全参构造函数，参数通常为命名可选参数
  - 实现 fromJson 和 toJson 方法用于序列化和反序列化
  - 使用 @JsonSerializable()注解，生成相应的 .g.dart 文件
  - 枚举类型使用 @JsonEnum(valueField: 'value') 标注
  - 枚举类型提供 unknown 值作为默认值和异常处理
  - 使用 @JsonKey 注解自定义字段转换逻辑
  - 处理未知枚举值：unknownEnumValue: SourceType.unknown
  - 提供默认值：defaultValue: MessageType.unknown
  - 相关联的 model 都放在一个 model 文件中, 例如: message_model.dart 有: MessageListModel, MessageChatModel, MessageHouseModel等
3. 序列化方式
  - 使用 @JsonSerializable() 注解自动生成序列化代码
  - 集合类型转换时需要处理空值情况
  - 日期, 字符串, 数值等类型相互转换时, 优先使用 tryParse 而不是 parse, 例如: num.tryParse(amount)
4. 字段处理
  - 在 fromJson 中对嵌套对象进行判空处理
  - 提供便捷的 getter 方法处理数据转换或条件判断（如 success getter）
5. 参考代码

  ```
     @JsonSerializable()
class MessageListModel {
  String? id;
  @JsonKey(
    defaultValue: SourceType.unknown,
    unknownEnumValue: SourceType.unknown,
  )
  SourceType? sourceType;
  String? messageType;
  String? description;
  String? houseId;
  bool? unread;
  String? sourceLogoSquare;
  @JsonKey(
    fromJson: _dateFromTimeStr,
  )
  DateTime? startsAt;
  @JsonKey(
    fromJson: _dateFromTimeStr,
  )
  DateTime? endsAt;
  String? callerDeviceName;
  @JsonKey(
    fromJson: _dateFromTimeStr,
  )
  DateTime? createdAt;
  @JsonKey(
    fromJson: _dateFromTimeStr,
  )
  DateTime? updatedAt;
  String? roomNo;
  String? roomName;
  int? guests;
  int? messageCount;
  MessageUserModel? user;
  MessageHouseModel? house;
  LastMessageModel? lastMessage;

  /// The following are the locally used fields
  bool canUpdateTicket;

  MessageListModel({
    this.id,
    this.sourceType,
    this.messageType,
    this.description,
    this.houseId,
    this.unread,
    this.sourceLogoSquare,
    this.startsAt,
    this.endsAt,
    this.callerDeviceName,
    this.createdAt,
    this.updatedAt,
    this.roomNo,
    this.roomName,
    this.guests,
    this.messageCount,
    this.user,
    this.house,
    this.lastMessage,
    this.canUpdateTicket = false,
  });

  factory MessageListModel.fromJson(Map<String, dynamic> json) => _$MessageListModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageListModelToJson(this);

  static DateTime? _dateFromTimeStr(String? timeStr) {
    if (timeStr == null) {
      return null;
    }
    return DateTime.parse(timeStr);
  }

  String get roomInfo {
    final String houseName = house?.name ?? '';
    if (house?.isApartment ?? false) return houseName;
    final String firstStr = (roomName?.isNotEmpty ?? false) ? ' - $roomName' : '';
    final String secondStr = (roomNo?.isNotEmpty ?? false) ? '-$roomNo' : '';
    return '$houseName$firstStr$secondStr';
  }

  String get lastMessageContent {
    if (lastMessage?.commentType == 'system_comment' && (lastMessage?.title?.isNotEmpty ?? false)) {
      return getSystemCommentTitle(lastMessage?.title);
    }
    if (lastMessage?.comment?.isNotEmpty ?? false) {
      return lastMessage?.comment?.replaceAll(RegExp(r'\s+'), ' ') ?? '';
    }
    if (lastMessage?.attachments?.isNotEmpty ?? false) {
      final MessageAttachmentModel? attachment = lastMessage?.attachments?.last;
      return attachment?.filename ?? '';
    }
    return description ?? '';
  }
  
  String getSystemCommentTitle(String? title) {
    final Map<String, String> titleMap = <String, String>{
      'booking_confirmed': T.current.bookingConfirmed,
      'pre_approved': T.current.preApproved,
      'booking_cancelled': T.current.bookingCancelled,
      'bookingcom_report_guest_no_show_room_reservation': T.current.bookingComReportGuestNoShow,
      'bookingcom_report_guest_no_show': T.current.bookingComReportGuestNoShow,
      'bookingcom_report_stay_changed': T.current.bookingComReportStayChanged,
      'bookingcom_report_invalid_credit_card': T.current.bookingComReportInvalidCreditCard,
      'bookingcom_report_cancellation_due_to_invalid_credit_card': T.current.bookingComReportCancellationDueToInvalidCreditCard,
      'bookingcom_report_guest_misconduct': T.current.bookingComReportGuestMisconduct,
      'airbnb_reservation_alteration_pending': T.current.airbnbReservationAlterationPending,
      'airbnb_reservation_alteration_accepted': T.current.airbnbReservationAlterationAccepted,
      'airbnb_reservation_alteration_declined': T.current.airbnbReservationAlterationDeclined,
      'airbnb_reservation_alteration_canceled': T.current.airbnbReservationAlterationCanceled,
      'airbnb_reservation_alteration_void': T.current.airbnbReservationAlterationVoided,
    };
    return titleMap[title] ?? title ?? '';
  }

  DateTime? get updatedTime => updatedAt ?? lastMessage?.updatedAt;

  bool get isAirbnbSystemComment {
    return lastMessage?.commentType == 'system_comment'
        && (lastMessage?.comment == 'airbnb_review_created' || lastMessage?.comment == 'airbnb_review_published');
  }
}

```

网络请求规范
1. 服务类设计
  - 因为使用 Mockito 不支持静态方法 Mock, 所以需要采用非静态方法组织 API 调用，同时方法名表明操作
  - 服务类通常以 Service 结尾, 例如: PaymentService
  - 相关的 API 放在同一个服务类中
  - 使用具体的返回类型而不是 dynamic
2. 参数传递
  - 查询参数使用 queryParameters，表单数据使用 data
  - 使用 FormData.fromMap 处理表单提交
  - 在特定情况下添加额外的参数（如来源信息 sourceData）
  - 支持传入 CancelToken 以便取消请求
3. 请求处理
  - 使用 NetworkManager.request 统一处理请求，不直接使用 Dio
  - 请求方法使用 HttpMethod 枚举类型
  - 请求参数使用类型安全的 Map
  - 通过 removeWhere 过滤掉参数中的空值, 例如: ..removeWhere((String k, dynamic v) => v == null || '' == v);
  - URL 路径以 static 属性放到 APIConstants 中, 例如: static String getMessageDetail(String messageId) => '/api/one/pms/tickets/$messageId/messages';
3. 响应处理
  - 使用 ApiResponse 类统一处理响应
  - 先判断 res.success，再进行数据类型检查和转换
  - 对返回的 JSON 数据进行安全转换，处理类型强制转换
  - 针对不同的数据结构提供适当的处理
  - 对集合类型数据进行标准化处理
  - 不用额外添加 try catch 处理异常情况
4. 错误处理
  - 通过 catchExceptions 参数控制是否捕获异常
  - 在某些情况下显式抛出异常, 如：throw Exception(res.error ?? 'Failed to update data');
  - 返回类型使用可空类型，失败时返回 null
  - 选择性显示错误提示（如 showTopSnackOnError: isMobileShowTopSnack）
  - 使用元组返回多种状态信息, 如：({bool success, String? errorMsg})
5. 参考代码
  ```
Future<({bool hasMore, List<MessageTemplateModel> dataList})?> getMessageTemplates({
  String? keyword,
  String? language,
  String? houseId,
  String? tag,
  int? pageNum,
  int pageSize = 10,
  bool recent = false,
  CancelToken? cancelToken,
}) async {
  final Map<String, dynamic> queryParameters = <String, dynamic>{
    'keyword': keyword,
    'language': language,
    'house_id': houseId,
    'tag': tag,
    'page_num': pageNum,
    'page_size': pageSize,
    'recent': recent,
  }..removeWhere((String k, dynamic v) => v == null || '' == v);
  final ApiResponse res = await NetworkManager.request(
    url: APIConstants.getMessageTemplates,
    method: HttpMethod.get,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );
  if (res.success && res.data is List) {
    final List<MessageTemplateModel> list = <MessageTemplateModel>[];
    for (final dynamic item in res.data) {
      list.add(MessageTemplateModel.fromJson(item));
    }
    final int matchCount = res.meta?['match_count'] ?? 0;
    final int pageNum = res.meta?['page_num'] ?? 0;
    final int pageSize = res.meta?['page_size'] ?? 0;
    return (hasMore: pageNum * pageSize < matchCount, dataList: list);
  }
  return null;
}

```