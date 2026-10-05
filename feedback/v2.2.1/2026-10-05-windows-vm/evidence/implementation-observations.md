# 安装包代码与文档定位（只读检查）

检查对象：本机 2.2.1 安装包，发布标识 v221-release-019。以下是与本次故障直接相关的短片段，保留原文件行号；不是修复补丁，也不是产品核心源码整包。实际行为与建议分别见主报告。

## 编译消息读取失败扩大为整个请求不确定

第 859 行取得消息对象；对象引用失效可能抛异常。外层捕获把结果改为 UNKNOWN / DIAGNOSTICS_UNREADABLE（结果不确定、诊断无法完整读取）。这里只证明代码路径，具体失效消息仍须在开发机定位。

安装目录内路径：`watcher/v22_native.py`。

```text
835:         diagnostics = []
836:         try:
837:             diagnostic_paths = {}
838:             if inventory is not None:
839:                 for key, value in inventory.identities.items():
840:                     diagnostic_paths.setdefault(value, []).append(inventory.paths[key])
841:             after = [(c, d) for c, d in categories() if compiler(c, d)]
842:             if not after:
843:                 raise RuntimeError('Compiler message category is absent.')
844:             for category, description in after:
```

```text
848:                 for message in messages:
849:                     severity = text(getattr(message, 'severity', '')).lower()
850:                     severity = 'error' if 'error' in severity else 'warning' if 'warning' in severity else 'info' if 'info' in severity or severity == 'text' else None
851:                     if severity is None:
852:                         raise RuntimeError('Compiler message severity is unknown.')
853:                     entry = {'severity': severity, 'message': text(getattr(message, 'text', getattr(message, 'message', message)))}
854:                     # ScriptMessage exposes object/position_text/prefix/number;
855:                     # its private numeric position must not be invented as a line.
856:                     position = getattr(message, 'position_text', None)
857:                     if position is not None:
858:                         entry['positionText'] = text(position)
859:                     message_object = getattr(message, 'object', None)
860:                     if message_object is not None and inventory is not None:
861:                         message_id = identity(message_object)
862:                         paths = diagnostic_paths.get(message_id, [])
863:                         if len(paths) == 1:
864:                             entry['objectPath'] = paths[0]
865:                     number, prefix = getattr(message, 'number', None), getattr(message, 'prefix', None)
866:                     if number is not None:
867:                         entry['nativeCodeNumber'] = int(number)
868:                     if prefix is not None:
869:                         entry['nativeCodePrefix'] = text(prefix)
```

```text
877:                     diagnostics.append(entry)
878:             result['diagnostics'] = diagnostics
879:             result['status'] = 'FAIL' if any(d['severity'] == 'error' for d in diagnostics) else 'PASS'
880:             if result['status'] == 'FAIL':
881:                 result['code'] = 'COMPILE_ERRORS'
882:         except Exception as error:
883:             result.update({'status': 'UNKNOWN', 'code': 'DIAGNOSTICS_UNREADABLE',
884:                            'message': text(error), 'diagnostics': diagnostics})
```

## 重复诊断和全部队列阻断

原结果 diagnostics 被再次拼接；UNKNOWN（结果不确定）会使队列停止派发。恢复只读取原结果是正确的保护原则，但需要可用的故障结束和只读核对入口，不能通过自动重放解决。

安装目录内路径：`dist/core/service.js`。

```text
240:     hasUnknown() { return [...this.entries.values()].some(entry => entry.record.stage === 'dispatched' && entry.record.result.status === 'UNKNOWN'); }
241:     kick() { void this.pump().catch(error => { this.initError = error instanceof Error ? error : new Error(String(error)); }); }
242:     async pump() {
243:         if (this.pumping || this.active || this.closed || this.initError || this.hasUnknown())
244:             return;
245:         this.pumping = true;
246:         try {
247:             while (this.queue.length && !this.closed && !this.hasUnknown()) {
```

```text
344:     async acceptNative(entry, native, recovered = false) {
345:         const returnedAt = this.now();
346:         this.validateNative(entry, native);
347:         const { protocolVersion: _version, payloadHash: _hash, watcherInstanceId: _watcher, ...publicResult } = native;
348:         const result = { ...clone(publicResult), requestId: entry.record.requestId, queueOrdinal: entry.record.queueOrdinal,
349:             ...(recovered ? { timingScope: 'recovered-native-only' } : { timingScope: 'current-request' }),
350:             timings: recovered ? { ...native.timings } : { ...entry.record.result.timings, ...native.timings,
351:                 ...(entry.dispatchedAt !== undefined ? { transportMs: Math.max(0, returnedAt - entry.dispatchedAt) } : {}) } };
352:         const warnings = entry.record.result.diagnostics ?? [];
353:         if (warnings.length)
354:             result.diagnostics = [...warnings, ...(result.diagnostics ?? [])];
355:         if (native.status === 'UNKNOWN') {
356:             entry.record.result = result;
357:             await this.markUnknown(entry);
358:             return;
```

```text
434:     async recoverUnknown() {
435:         if (!this.options.transport.recover)
436:             return;
437:         if (this.recovery)
438:             return this.recovery;
439:         this.recovery = (async () => {
440:             for (const entry of this.entries.values()) {
441:                 if (entry.record.stage !== 'dispatched' || entry.record.result.status !== 'UNKNOWN' || !entry.record.command)
442:                     continue;
443:                 try {
444:                     const result = await this.options.transport.recover(entry.record.command);
445:                     if (result)
446:                         await this.acceptNative(entry, result, true);
447:                 }
448:                 catch (error) {
449:                     entry.record.result.message = `Original result still unavailable: ${(0, util_1.errorMessage)(error)}`;
450:                 }
451:             }
452:         })().finally(() => { this.recovery = undefined; });
453:         return this.recovery;
```

```text
455:     async request(action, requestId, waitMs) {
456:         const entry = this.entries.get(requestId);
457:         if (!entry)
458:             return this.failure((0, util_1.errorWithCode)('REQUEST_NOT_FOUND', 'No receipt exists for this requestId.'), requestId);
459:         await entry.persisted;
460:         if (action === 'cancel') {
461:             if (entry.record.result.status !== 'QUEUED' || this.active === entry)
462:                 return { ...clone(entry.record.result), code: 'REQUEST_NOT_CANCELLABLE', message: 'Only requests that have not begun execution can be cancelled.' };
463:             const index = this.queue.indexOf(entry);
464:             if (index >= 0)
465:                 this.queue.splice(index, 1);
466:             await this.finish(entry, { status: 'CANCELLED', requestId, counts: (0, util_1.zeroCounts)() });
467:         }
468:         else if (entry.record.result.status === 'UNKNOWN') {
469:             await this.recoverUnknown();
470:             this.kick();
```

## 默认试用创建路径与正式授权入口

正式授权未提供时，记录和时间记录均不存在可进入默认 30 天创建分支。本轮仅静态查看代码与已有状态，没有删除授权数据执行绕过。用户最终要求取消全部自动试用，以下片段用于开发定位。

安装目录内路径：`dist/licensing/service.js`。

```text
23:     constructor(options = {}) {
24:         this.options = options;
25:         this.trialDirectory = options.machineDirectory || node_path_1.default.join(process.env.ProgramData || 'C:\\ProgramData', 'CODESYS API MCP', 'licensing', 'default-month');
26:         this.licenseDirectory = options.licenseDirectory || node_path_1.default.join(process.env.LOCALAPPDATA || '', 'CODESYS API MCP', 'licensing', 'v22');
27:         this.keys = options.trustedKeys || JSON.parse(node_fs_1.default.readFileSync(node_path_1.default.join((0, paths_1.installationRoot)(), 'config', 'license-public-keys.json'), 'utf8')).keys;
28:         this.utcAnchor = this.now();
```

```text
64:     status(startOnActualUse = false) {
65:         try {
66:             const fingerprint = this.hardware();
67:             const formal = this.read(node_path_1.default.join(this.licenseDirectory, 'license.json'));
68:             if (formal) {
69:                 const verified = (0, format_1.authenticateLicense)(formal.code, { trustedKeys: this.keys, fingerprint });
70:                 const clock = this.read(node_path_1.default.join(this.licenseDirectory, 'clock.json'));
71:                 if (!clock || clock.licenseId !== verified.claims.licenseId || clock.codeSha256 !== verified.codeSha256
72:                     || !(0, format_1.isUtcSeconds)(clock.lastSeenUtc) || clock.lastSeenUtc < verified.claims.notBefore)
73:                     throw Object.assign(new Error('License clock record is missing or mismatched.'), { code: 'LICENSE_TIME_STATE_MISSING' });
74:                 const now = this.effectiveNow(clock.lastSeenUtc);
75:                 (0, format_1.assertLicenseTime)(verified.claims, now);
76:                 if (now - clock.lastSeenUtc >= 5)
77:                     this.write(node_path_1.default.join(this.licenseDirectory, 'clock.json'), { ...clock, lastSeenUtc: now });
78:                 return { status: 'VALID', source: 'FORMAL', code: 'LICENSE_VALID', expiresAt: verified.claims.expiresAt, keyId: verified.keyId, remainingSeconds: verified.claims.expiresAt - now, publicKeyIds: Object.keys(this.keys) };
79:             }
80:             const recordPath = node_path_1.default.join(this.trialDirectory, 'default-month.json');
81:             const clockPath = node_path_1.default.join(this.trialDirectory, 'default-month-time.json');
82:             let record = this.read(recordPath);
83:             let clock = this.read(clockPath);
84:             if (!record) {
85:                 if (clock)
86:                     throw Object.assign(new Error('Permanent trial record is missing.'), { code: 'LICENSE_STATE_DAMAGED' });
87:                 if (!startOnActualUse)
88:                     return { status: 'NOT_STARTED', source: 'DEFAULT_MONTH', code: 'DEFAULT_MONTH_NOT_STARTED', durationDays: 30, publicKeyIds: Object.keys(this.keys) };
89:                 const now = this.effectiveNow();
90:                 record = { schemaVersion: 1, source: 'DEFAULT_MONTH', productId: hardware_1.LICENSE_PRODUCT_ID, fingerprintVersion: 1, machineDigest: fingerprint.machineDigest, entitlementId: (0, node_crypto_1.randomUUID)(), startUtc: now, expiresAtUtc: now + 30 * 86400, durationSeconds: 30 * 86400 };
91:                 node_fs_1.default.mkdirSync(this.trialDirectory, { recursive: true });
92:                 // Exclusive first creation preserves the original start across versions and homes.
93:                 try {
94:                     node_fs_1.default.writeFileSync(recordPath, JSON.stringify(record), { encoding: 'utf8', flag: 'wx' });
95:                     clock = { schemaVersion: 1, entitlementId: record.entitlementId, machineDigest: record.machineDigest, recordSha256: (0, format_1.sha256)(JSON.stringify(record)), revision: 0, lastSeenUtc: now };
96:                     node_fs_1.default.writeFileSync(clockPath, JSON.stringify(clock), { encoding: 'utf8', flag: 'wx' });
```

```text
105:             if (!record || record.schemaVersion !== 1 || record.source !== 'DEFAULT_MONTH' || record.productId !== hardware_1.LICENSE_PRODUCT_ID
106:                 || record.fingerprintVersion !== 1 || record.machineDigest !== fingerprint.machineDigest
107:                 || typeof record.entitlementId !== 'string' || record.entitlementId.length === 0
108:                 || !(0, format_1.isUtcSeconds)(record.startUtc) || !(0, format_1.isUtcSeconds)(record.expiresAtUtc)
109:                 || record.durationSeconds !== 30 * 86400 || record.expiresAtUtc !== record.startUtc + 30 * 86400
110:                 || !clock || clock.schemaVersion !== 1 || clock.entitlementId !== record.entitlementId || clock.machineDigest !== record.machineDigest
111:                 || !Number.isSafeInteger(clock.revision) || clock.revision < 0
112:                 || clock.recordSha256 !== (0, format_1.sha256)(JSON.stringify(record)) || !(0, format_1.isUtcSeconds)(clock.lastSeenUtc) || clock.lastSeenUtc < record.startUtc)
113:                 throw Object.assign(new Error('Retained trial state is missing or invalid; its start will not be reset.'), { code: 'LICENSE_STATE_DAMAGED' });
114:             if (this.now() < record.startUtc)
115:                 return { status: 'BLOCKED', source: 'DEFAULT_MONTH', code: 'LICENSE_NOT_YET_VALID', publicKeyIds: Object.keys(this.keys) };
116:             const now = this.effectiveNow(clock.lastSeenUtc);
117:             if (now >= record.expiresAtUtc)
118:                 return { status: 'BLOCKED', source: 'DEFAULT_MONTH', code: 'LICENSE_EXPIRED', expiresAt: record.expiresAtUtc, remainingSeconds: 0, publicKeyIds: Object.keys(this.keys) };
119:             if (now - clock.lastSeenUtc >= 5)
120:                 this.write(clockPath, { ...clock, revision: clock.revision + 1, lastSeenUtc: now });
121:             return { status: 'VALID', source: 'DEFAULT_MONTH', code: 'DEFAULT_MONTH_ACTIVE', startUtc: record.startUtc, expiresAt: record.expiresAtUtc, remainingSeconds: record.expiresAtUtc - now, publicKeyIds: Object.keys(this.keys) };
```

```text
128:     async gate() {
129:         const status = this.status(true);
130:         return { allowed: status.status === 'VALID', code: String(status.code), message: typeof status.message === 'string' ? status.message : undefined };
```

## 操作说明文件分布

实际枚举到以下操作资料；第三方许可材料已排除。现有文件数量和格式是文档分散的证据，不代表它们每一段都互相矛盾。用户要求后续合并为一个完整图文操作说明。

- `resources/client-setup/PATHS-AND-DISCOVERY.md`
- `resources/client-setup/README.md`
- `resources/client-setup/guides/codex.md`
- `resources/client-setup/guides/deepseek.md`
- `resources/client-setup/guides/generic.md`
- `resources/client-setup/guides/opencode.md`
- `resources/client-setup/guides/trae.md`
- `resources/client-setup/guides/workbuddy.md`
- `resources/manager/CODESYS-Script-Guide.html`
- `resources/manager/CODESYS-Script-Guide.txt`
- `resources/manager/Environment-Setup.md`
- `resources/manager/Manager-Usage.md`
- `resources/manager/Manager-Usage.txt`
- `resources/manager/Project-Usage.md`
- `resources/manager/README.md`
- `resources/manager/guides/codex.html`
- `resources/manager/guides/deepseek.html`
- `resources/manager/guides/generic.html`
- `resources/manager/guides/opencode.html`
- `resources/manager/guides/trae.html`
- `resources/manager/guides/workbuddy.html`
