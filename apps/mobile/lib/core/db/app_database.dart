import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Sessions cached per gateway. Server is source of truth after pull;
/// local rows exist so the UI works offline and deploys keep history.
class CachedSessions extends Table {
  TextColumn get gatewayId => text()();
  TextColumn get id => text()();
  TextColumn get source => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get startedAt => text().nullable()();
  TextColumn get endedAt => text().nullable()();
  TextColumn get endReason => text().nullable()();
  IntColumn get messageCount => integer().nullable()();
  IntColumn get toolCallCount => integer().nullable()();
  TextColumn get lastActive => text().nullable()();
  TextColumn get preview => text().nullable()();
  TextColumn get parentSessionId => text().nullable()();

  /// pending | synced | deleted_pending
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {gatewayId, id};
}

class CachedMessages extends Table {
  TextColumn get gatewayId => text()();
  TextColumn get sessionId => text()();
  TextColumn get id => text()();
  TextColumn get role => text()();
  TextColumn get content => text().nullable()();
  TextColumn get toolCallId => text().nullable()();
  TextColumn get toolName => text().nullable()();
  TextColumn get timestamp => text().nullable()();
  IntColumn get tokenCount => integer().nullable()();
  TextColumn get finishReason => text().nullable()();
  TextColumn get reasoning => text().nullable()();

  /// Opaque JSON for tool_calls when present.
  TextColumn get toolCallsJson => text().nullable()();
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  /// pending | synced
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  /// Gateway `display_kind` tag (model_switch, personality_switch, …) when
  /// present — see [HermesMessage.displayKind] / [HermesMessage.isVisibleUser].
  TextColumn get displayKind => text().nullable()();

  @override
  Set<Column> get primaryKey => {gatewayId, sessionId, id};
}

/// Tombstones for messages the user deleted **locally**. The gateway has no
/// arbitrary single-message delete (only whole-session delete and
/// `session.undo`, which drops the trailing turn), so a deleted message keeps
/// existing server-side and would otherwise resurface the next time
/// [AppDatabase.replaceMessages] repopulates the cache from a server pull.
/// Rows here are filtered out at read time instead (see
/// `SessionSyncRepository.loadMessagesLocal`).
class DeletedMessages extends Table {
  TextColumn get gatewayId => text()();
  TextColumn get sessionId => text()();
  TextColumn get messageId => text()();
  DateTimeColumn get deletedAt => dateTime()();

  /// Content-derived identity for the deleted message (`role` + a stable hash
  /// of the body — see `SessionSyncRepository.messageFingerprint`).
  ///
  /// [messageId] alone is **not** stable across a server-side rewind: a
  /// gateway edit/retry calls `replace_messages(..., archive_dropped=True)`
  /// (`hermes_state.py`), which soft-archives the old rows and re-inserts the
  /// surviving prefix as **fresh** rows with new AUTOINCREMENT ids. Every
  /// message id in the session changes, the tombstone stops matching, and the
  /// message the user deleted silently reappears. The fingerprint lets a pull
  /// re-point the tombstone at the message's new id (and garbage-collect the
  /// tombstone when the message is genuinely gone from server history).
  ///
  /// Null on rows written before schema v5 — those degrade to id-only
  /// matching, exactly the pre-v5 behaviour.
  TextColumn get fingerprint => text().nullable()();

  @override
  Set<Column> get primaryKey => {gatewayId, sessionId, messageId};
}

/// Outbound ops to flush when the gateway is reachable.
class PendingOps extends Table {
  TextColumn get id => text()();
  TextColumn get gatewayId => text()();

  /// create_session | delete_session | patch_session | chat
  TextColumn get opType => text()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get payloadJson => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cron jobs cached per gateway (local-first; survive offline / connection blips).
///
/// Rows with [syncStatus] `deleted_pending` stay until a successful server pull
/// confirms the job is gone — never drop on network error alone.
class CachedJobs extends Table {
  TextColumn get gatewayId => text()();
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get schedule => text().nullable()();
  TextColumn get prompt => text().nullable()();
  TextColumn get deliver => text().nullable()();
  BoolColumn get enabled => boolean().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get lastRunAt => text().nullable()();
  TextColumn get lastStatus => text().nullable()();
  TextColumn get nextRunAt => text().nullable()();

  /// Full server row for richer offline details and forward compatibility.
  TextColumn get detailsJson => text().nullable()();

  /// synced | deleted_pending
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {gatewayId, id};
}

/// Bounded run-history cache for a cron job. Each row is the ordinary Hermes
/// session returned by `/api/cron/jobs/{id}/runs`, retained separately from
/// recents so a general session-list refresh cannot evict job history.
class CachedJobRuns extends Table {
  TextColumn get gatewayId => text()();
  TextColumn get jobId => text()();
  TextColumn get sessionId => text()();
  TextColumn get sessionJson => text()();
  TextColumn get lastActive => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {gatewayId, jobId, sessionId};
}

/// Installed skills cached per gateway (survive offline / failed pulls).
class CachedSkills extends Table {
  TextColumn get gatewayId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get provenance => text().nullable()();
  IntColumn get usage => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {gatewayId, name};
}

@DriftDatabase(
  tables: [
    CachedSessions,
    CachedMessages,
    PendingOps,
    CachedJobs,
    CachedJobRuns,
    CachedSkills,
    DeletedMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(cachedJobs);
      }
      if (from < 3) {
        await m.createTable(cachedSkills);
      }
      if (from < 4) {
        await m.addColumn(cachedMessages, cachedMessages.displayKind);
        await m.createTable(deletedMessages);
      }
      // `from == 4`, NOT `from < 5`. Migrator.createTable builds its DDL from
      // the table class's *current* columns — drift keeps no historical
      // snapshot — so the `from < 4` step above already creates
      // `deleted_messages` including `fingerprint`. Only a device that ran a
      // v4 build has the table without it. Guarding on `from < 5` made every
      // upgrade from v3 or earlier throw `duplicate column name: fingerprint`
      // on the first cache read, which is every shipped install, while fresh
      // installs (onCreate -> createAll) were fine — so it would have passed
      // review and broken existing users.
      if (from == 4) {
        // Additive only: a nullable column on an existing table (plain
        // `ALTER TABLE ... ADD COLUMN`). No row is rewritten or dropped, and
        // pre-v5 tombstones keep working with a null fingerprint.
        await m.addColumn(deletedMessages, deletedMessages.fingerprint);
      }
      if (from < 6) {
        // v1 had no jobs table; its from<2 step above creates the current
        // table (already including detailsJson), so only older existing job
        // tables need ALTER TABLE.
        if (from >= 2) {
          await m.addColumn(cachedJobs, cachedJobs.detailsJson);
        }
        await m.createTable(cachedJobRuns);
      }
    },
  );

  // ── Sessions ───────────────────────────────────────────────────────

  Future<List<CachedSession>> sessionsForGateway(String gatewayId) {
    return (select(cachedSessions)
          ..where(
            (r) =>
                r.gatewayId.equals(gatewayId) &
                r.syncStatus.isNotValue('deleted_pending'),
          )
          ..orderBy([
            (r) => OrderingTerm(
              expression: r.lastActive,
              mode: OrderingMode.desc,
              nulls: NullsOrder.last,
            ),
            (r) => OrderingTerm.desc(r.updatedAt),
          ]))
        .get();
  }

  Future<void> upsertSession(CachedSessionsCompanion row) {
    return into(cachedSessions).insertOnConflictUpdate(row);
  }

  /// Statuses [replaceSessions] must never clobber with a server row: local
  /// intent the gateway has not accepted (or not yet confirmed) yet.
  static const _localOnlySessionStatuses = ['pending', 'deleted_pending'];

  /// Apply a successful server session list.
  ///
  /// Server wins for everything it has accepted, with two local-intent
  /// exceptions that must survive the replace:
  ///
  /// - `pending` — a session created offline that the gateway has never seen.
  /// - `deleted_pending` — a session the user deleted here while the delete op
  ///   is still in the outbox. The gateway still lists it, so a blind replace
  ///   re-inserted it as `synced` and the deleted session **reappeared in the
  ///   list** until (and only if) the queued delete happened to land. The
  ///   tombstone now wins until a pull confirms the session is gone
  ///   server-side, mirroring [mergeJobsFromServer].
  Future<void> replaceSessions(
    String gatewayId,
    List<CachedSessionsCompanion> rows,
  ) {
    return transaction(() async {
      // Keep local-only pending creates not yet on server.
      final pending =
          await (select(cachedSessions)..where(
                (r) =>
                    r.gatewayId.equals(gatewayId) &
                    r.syncStatus.equals('pending'),
              ))
              .get();
      final tombstoned =
          (await (select(cachedSessions)..where(
                    (r) =>
                        r.gatewayId.equals(gatewayId) &
                        r.syncStatus.equals('deleted_pending'),
                  ))
                  .get())
              .map((r) => r.id)
              .toSet();
      final remoteIds = {for (final r in rows) r.id.value};
      await (delete(cachedSessions)..where(
            (r) =>
                r.gatewayId.equals(gatewayId) &
                r.syncStatus.isNotIn(_localOnlySessionStatuses),
          ))
          .go();
      // Server no longer lists a locally-deleted session → delete confirmed,
      // drop the tombstone row (and its cached transcript) for real.
      for (final id in tombstoned) {
        if (remoteIds.contains(id)) continue;
        await (delete(
          cachedSessions,
        )..where((r) => r.gatewayId.equals(gatewayId) & r.id.equals(id))).go();
        await (delete(cachedMessages)..where(
              (r) => r.gatewayId.equals(gatewayId) & r.sessionId.equals(id),
            ))
            .go();
        await _dropTombstonesForSession(gatewayId, id);
      }
      await batch(
        (b) => b.insertAllOnConflictUpdate(cachedSessions, [
          for (final r in rows)
            if (!tombstoned.contains(r.id.value)) r,
        ]),
      );
      // Re-apply pending if not overwritten by server id collision.
      for (final p in pending) {
        final exists = rows.any((r) => r.id.value == p.id);
        if (!exists) {
          await into(cachedSessions).insertOnConflictUpdate(
            CachedSessionsCompanion.insert(
              gatewayId: p.gatewayId,
              id: p.id,
              source: Value(p.source),
              userId: Value(p.userId),
              model: Value(p.model),
              title: Value(p.title),
              startedAt: Value(p.startedAt),
              endedAt: Value(p.endedAt),
              endReason: Value(p.endReason),
              messageCount: Value(p.messageCount),
              toolCallCount: Value(p.toolCallCount),
              lastActive: Value(p.lastActive),
              preview: Value(p.preview),
              parentSessionId: Value(p.parentSessionId),
              syncStatus: const Value('pending'),
              updatedAt: p.updatedAt,
            ),
          );
        }
      }
    });
  }

  Future<void> markSessionDeleted(String gatewayId, String sessionId) {
    return (update(
          cachedSessions,
        )..where((r) => r.gatewayId.equals(gatewayId) & r.id.equals(sessionId)))
        .write(
          CachedSessionsCompanion(
            syncStatus: const Value('deleted_pending'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  Future<void> removeSession(String gatewayId, String sessionId) {
    return transaction(() async {
      await (delete(cachedSessions)..where(
            (r) => r.gatewayId.equals(gatewayId) & r.id.equals(sessionId),
          ))
          .go();
      await (delete(cachedMessages)..where(
            (r) =>
                r.gatewayId.equals(gatewayId) & r.sessionId.equals(sessionId),
          ))
          .go();
      await _dropTombstonesForSession(gatewayId, sessionId);
    });
  }

  /// Drop every tombstone belonging to [sessionId].
  ///
  /// Tombstones deliberately outlive the cached rows they hide (see
  /// [tombstoneMessage]), so anything that removes a *session* has to clear
  /// them explicitly or they leak forever — and, worse, a later session that
  /// reuses the id (a local_* create that the gateway echoes back, or a
  /// re-imported history) would silently start with rows hidden by a stranger's
  /// tombstone.
  Future<void> _dropTombstonesForSession(String gatewayId, String sessionId) {
    return (delete(deletedMessages)..where(
          (r) => r.gatewayId.equals(gatewayId) & r.sessionId.equals(sessionId),
        ))
        .go();
  }

  // ── Messages ───────────────────────────────────────────────────────

  Future<List<CachedMessage>> messagesForSession(
    String gatewayId,
    String sessionId,
  ) {
    return (select(cachedMessages)
          ..where(
            (r) =>
                r.gatewayId.equals(gatewayId) & r.sessionId.equals(sessionId),
          )
          ..orderBy([
            (r) => OrderingTerm.asc(r.sortIndex),
            (r) => OrderingTerm.asc(r.timestamp),
          ]))
        .get();
  }

  Future<void> replaceMessages(
    String gatewayId,
    String sessionId,
    List<CachedMessagesCompanion> rows,
  ) {
    return transaction(() async {
      final pending =
          await (select(cachedMessages)..where(
                (r) =>
                    r.gatewayId.equals(gatewayId) &
                    r.sessionId.equals(sessionId) &
                    r.syncStatus.equals('pending'),
              ))
              .get();
      await (delete(cachedMessages)..where(
            (r) =>
                r.gatewayId.equals(gatewayId) &
                r.sessionId.equals(sessionId) &
                r.syncStatus.isNotValue('pending'),
          ))
          .go();
      await batch((b) => b.insertAllOnConflictUpdate(cachedMessages, rows));
      for (final p in pending) {
        final exists = rows.any((r) => r.id.value == p.id);
        if (!exists) {
          await into(cachedMessages).insertOnConflictUpdate(
            CachedMessagesCompanion.insert(
              gatewayId: p.gatewayId,
              sessionId: p.sessionId,
              id: p.id,
              role: p.role,
              content: Value(p.content),
              toolCallId: Value(p.toolCallId),
              toolName: Value(p.toolName),
              timestamp: Value(p.timestamp),
              tokenCount: Value(p.tokenCount),
              finishReason: Value(p.finishReason),
              reasoning: Value(p.reasoning),
              toolCallsJson: Value(p.toolCallsJson),
              sortIndex: Value(p.sortIndex),
              syncStatus: const Value('pending'),
              // Must be carried: `HermesMessage.isVisibleUser` is
              // `role == 'user' && displayKind` empty, so dropping it here
              // promotes a synthetic timeline marker (model_switch, …) back
              // into a *visible* user turn and shifts every later user
              // ordinal — the gateway then rejects the edit/retry with
              // error 4018.
              displayKind: Value(p.displayKind),
            ),
          );
        }
      }
    });
  }

  Future<void> upsertMessage(CachedMessagesCompanion row) {
    return into(cachedMessages).insertOnConflictUpdate(row);
  }

  /// Drop one cached message row without writing a tombstone.
  ///
  /// For local-only artifacts (an expired `local_error_*` bubble), **not** for
  /// user deletes — those must go through [tombstoneMessage] or the next
  /// server pull puts the message straight back.
  Future<void> deleteMessage(
    String gatewayId,
    String sessionId,
    String messageId,
  ) {
    return (delete(cachedMessages)..where(
          (r) =>
              r.gatewayId.equals(gatewayId) &
              r.sessionId.equals(sessionId) &
              r.id.equals(messageId),
        ))
        .go();
  }

  // ── Local message deletion (tombstones) ──────────────────────────────

  /// Record a local-only delete and drop the cached row. The tombstone
  /// outlives the row: a later server pull repopulates `cachedMessages`
  /// (the gateway still has the message), and the tombstone is what keeps it
  /// filtered out of every read afterward.
  Future<void> tombstoneMessage(
    String gatewayId,
    String sessionId,
    String messageId, {
    String? fingerprint,
  }) {
    return transaction(() async {
      await into(deletedMessages).insertOnConflictUpdate(
        DeletedMessagesCompanion.insert(
          gatewayId: gatewayId,
          sessionId: sessionId,
          messageId: messageId,
          deletedAt: DateTime.now().toUtc(),
          fingerprint: Value(fingerprint),
        ),
      );
      await (delete(cachedMessages)..where(
            (r) =>
                r.gatewayId.equals(gatewayId) &
                r.sessionId.equals(sessionId) &
                r.id.equals(messageId),
          ))
          .go();
    });
  }

  Future<Set<String>> tombstonedMessageIds(
    String gatewayId,
    String sessionId,
  ) async {
    final rows = await tombstonesForSession(gatewayId, sessionId);
    return rows.map((r) => r.messageId).toSet();
  }

  Future<List<DeletedMessage>> tombstonesForSession(
    String gatewayId,
    String sessionId,
  ) {
    return (select(deletedMessages)..where(
          (r) => r.gatewayId.equals(gatewayId) & r.sessionId.equals(sessionId),
        ))
        .get();
  }

  /// Move a tombstone from [fromId] to [toId] after a server-side rewind
  /// re-stamped the message's row id (see [DeletedMessages.fingerprint]).
  Future<void> retargetTombstone(
    String gatewayId,
    String sessionId, {
    required String fromId,
    required String toId,
    String? fingerprint,
  }) {
    if (fromId == toId) return Future<void>.value();
    return transaction(() async {
      await into(deletedMessages).insertOnConflictUpdate(
        DeletedMessagesCompanion.insert(
          gatewayId: gatewayId,
          sessionId: sessionId,
          messageId: toId,
          deletedAt: DateTime.now().toUtc(),
          fingerprint: Value(fingerprint),
        ),
      );
      await removeTombstone(gatewayId, sessionId, fromId);
      await (delete(cachedMessages)..where(
            (r) =>
                r.gatewayId.equals(gatewayId) &
                r.sessionId.equals(sessionId) &
                r.id.equals(toId),
          ))
          .go();
    });
  }

  /// Drop a tombstone whose message the gateway no longer has at all.
  Future<void> removeTombstone(
    String gatewayId,
    String sessionId,
    String messageId,
  ) {
    return (delete(deletedMessages)..where(
          (r) =>
              r.gatewayId.equals(gatewayId) &
              r.sessionId.equals(sessionId) &
              r.messageId.equals(messageId),
        ))
        .go();
  }

  // ── Outbox ─────────────────────────────────────────────────────────

  Future<List<PendingOp>> pendingOpsForGateway(String gatewayId) {
    return (select(pendingOps)
          ..where((r) => r.gatewayId.equals(gatewayId))
          ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
        .get();
  }

  /// Whether any outbox op still targets [sessionId] — used to tell a
  /// genuinely-still-queued send apart from one the background/foreground
  /// flush already resolved, so the UI can drop a stale "Queued for sync"
  /// banner instead of leaving it stuck forever.
  Future<bool> hasPendingOpsForSession(
    String gatewayId,
    String sessionId,
  ) async {
    // `..limit(1)` + `get()`, never `getSingleOrNull()`: a session can hold
    // several queued ops at once (two offline sends, or a create followed by a
    // chat). `getSingleOrNull` throws on >1 row, so the "is this send still
    // queued?" check blew up in exactly the case it exists for.
    final rows =
        await (select(pendingOps)
              ..where(
                (r) =>
                    r.gatewayId.equals(gatewayId) &
                    r.sessionId.equals(sessionId),
              )
              ..limit(1))
            .get();
    return rows.isNotEmpty;
  }

  Future<void> enqueueOp(PendingOpsCompanion row) {
    return into(pendingOps).insertOnConflictUpdate(row);
  }

  /// Atomically lease a due outbox operation to one flush worker.
  ///
  /// A chat operation remains pending for the entire agent turn, which may
  /// take a minute while a wake-on-demand model loads.  Repository instances
  /// have their own in-memory `_flushing` guard, so reconnect, foreground,
  /// and background workers could previously read and submit the same row
  /// concurrently. SQLite serializes this transaction; only the first worker
  /// moves [nextAttemptAt] into the future and receives the row.
  Future<PendingOp?> claimPendingOp(
    String id, {
    Duration lease = const Duration(minutes: 30),
  }) {
    return transaction(() async {
      final row = await (select(
        pendingOps,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (row == null) return null;

      final now = DateTime.now().toUtc();
      if (row.nextAttemptAt?.isAfter(now) == true) return null;

      await (update(pendingOps)..where((r) => r.id.equals(id))).write(
        PendingOpsCompanion(
          nextAttemptAt: Value(now.add(lease)),
          lastError: const Value('Sending to gateway…'),
        ),
      );
      return row;
    });
  }

  Future<void> removeOp(String id) {
    return (delete(pendingOps)..where((r) => r.id.equals(id))).go();
  }

  Future<void> bumpOpFailure(String id, String error) {
    return transaction(() async {
      final row = await (select(
        pendingOps,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (row == null) return;
      await (update(pendingOps)..where((r) => r.id.equals(id))).write(
        PendingOpsCompanion(
          attemptCount: Value(row.attemptCount + 1),
          lastError: Value(error),
          nextAttemptAt: Value(
            DateTime.now().toUtc().add(
              Duration(seconds: (row.attemptCount + 1).clamp(1, 8) * 5),
            ),
          ),
        ),
      );
    });
  }

  // ── Jobs (cron) ────────────────────────────────────────────────────

  Future<List<CachedJob>> jobsForGateway(
    String gatewayId, {
    bool includeDeletedPending = false,
  }) {
    return (select(cachedJobs)
          ..where((r) {
            final gw = r.gatewayId.equals(gatewayId);
            if (includeDeletedPending) return gw;
            return gw & r.syncStatus.isNotValue('deleted_pending');
          })
          ..orderBy([
            (r) => OrderingTerm(
              expression: r.nextRunAt,
              mode: OrderingMode.asc,
              nulls: NullsOrder.last,
            ),
            (r) => OrderingTerm.desc(r.updatedAt),
          ]))
        .get();
  }

  Future<void> upsertJob(CachedJobsCompanion row) {
    return into(cachedJobs).insertOnConflictUpdate(row);
  }

  /// Apply a successful server list without wiping local tombstones on blips.
  ///
  /// - Upserts every remote job as `synced` (unless local is `deleted_pending`)
  /// - Removes local `synced` rows missing from [remote] (server confirmed gone)
  /// - Removes `deleted_pending` only when remote no longer includes them
  Future<void> mergeJobsFromServer(
    String gatewayId,
    List<CachedJobsCompanion> remote,
  ) {
    return transaction(() async {
      final local = await (select(
        cachedJobs,
      )..where((r) => r.gatewayId.equals(gatewayId))).get();
      final remoteIds = {for (final r in remote) r.id.value};

      for (final row in remote) {
        final existing = local.where((l) => l.id == row.id.value).firstOrNull;
        if (existing?.syncStatus == 'deleted_pending') {
          // Tombstone wins until server no longer lists the id.
          continue;
        }
        await into(cachedJobs).insertOnConflictUpdate(row);
      }

      for (final l in local) {
        if (remoteIds.contains(l.id)) continue;
        if (l.syncStatus == 'deleted_pending') {
          // Server confirmed deletion.
          await (delete(cachedJobs)..where(
                (r) => r.gatewayId.equals(gatewayId) & r.id.equals(l.id),
              ))
              .go();
          await (delete(cachedJobRuns)..where(
                (r) => r.gatewayId.equals(gatewayId) & r.jobId.equals(l.id),
              ))
              .go();
          continue;
        }
        // Was synced, not on server anymore → gone for real.
        if (l.syncStatus == 'synced') {
          await (delete(cachedJobs)..where(
                (r) => r.gatewayId.equals(gatewayId) & r.id.equals(l.id),
              ))
              .go();
          await (delete(cachedJobRuns)..where(
                (r) => r.gatewayId.equals(gatewayId) & r.jobId.equals(l.id),
              ))
              .go();
        }
      }
    });
  }

  Future<void> markJobDeleted(String gatewayId, String jobId) {
    return (update(
      cachedJobs,
    )..where((r) => r.gatewayId.equals(gatewayId) & r.id.equals(jobId))).write(
      CachedJobsCompanion(
        syncStatus: const Value('deleted_pending'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> removeJob(String gatewayId, String jobId) {
    return transaction(() async {
      await (delete(
        cachedJobs,
      )..where((r) => r.gatewayId.equals(gatewayId) & r.id.equals(jobId))).go();
      await (delete(cachedJobRuns)..where(
            (r) => r.gatewayId.equals(gatewayId) & r.jobId.equals(jobId),
          ))
          .go();
    });
  }

  Future<List<CachedJobRun>> jobRunsForJob(String gatewayId, String jobId) {
    return (select(cachedJobRuns)
          ..where((r) => r.gatewayId.equals(gatewayId) & r.jobId.equals(jobId))
          ..orderBy([
            (r) => OrderingTerm(
              expression: r.lastActive,
              mode: OrderingMode.desc,
              nulls: NullsOrder.last,
            ),
            (r) => OrderingTerm.desc(r.updatedAt),
          ]))
        .get();
  }

  /// Replace history only after a successful server response. A failed or
  /// offline refresh leaves the last known runs intact.
  Future<void> replaceJobRuns(
    String gatewayId,
    String jobId,
    List<CachedJobRunsCompanion> rows,
  ) {
    return transaction(() async {
      await (delete(cachedJobRuns)..where(
            (r) => r.gatewayId.equals(gatewayId) & r.jobId.equals(jobId),
          ))
          .go();
      if (rows.isNotEmpty) {
        await batch((b) => b.insertAllOnConflictUpdate(cachedJobRuns, rows));
      }
    });
  }

  // ── Skills ─────────────────────────────────────────────────────────

  Future<List<CachedSkill>> skillsForGateway(String gatewayId) {
    return (select(cachedSkills)
          ..where((r) => r.gatewayId.equals(gatewayId))
          ..orderBy([
            (r) => OrderingTerm.asc(r.category),
            (r) => OrderingTerm.asc(r.name),
          ]))
        .get();
  }

  /// Replace the full skill catalog for [gatewayId] after a successful pull.
  Future<void> replaceSkills(
    String gatewayId,
    List<CachedSkillsCompanion> rows,
  ) {
    return transaction(() async {
      await (delete(
        cachedSkills,
      )..where((r) => r.gatewayId.equals(gatewayId))).go();
      if (rows.isNotEmpty) {
        await batch((b) => b.insertAllOnConflictUpdate(cachedSkills, rows));
      }
    });
  }

  Future<void> clearGatewayData(String gatewayId) {
    return transaction(() async {
      await (delete(
        cachedSessions,
      )..where((r) => r.gatewayId.equals(gatewayId))).go();
      await (delete(
        cachedMessages,
      )..where((r) => r.gatewayId.equals(gatewayId))).go();
      await (delete(
        cachedJobs,
      )..where((r) => r.gatewayId.equals(gatewayId))).go();
      await (delete(
        cachedJobRuns,
      )..where((r) => r.gatewayId.equals(gatewayId))).go();
      await (delete(
        cachedSkills,
      )..where((r) => r.gatewayId.equals(gatewayId))).go();
      await (delete(
        pendingOps,
      )..where((r) => r.gatewayId.equals(gatewayId))).go();
      // Tombstones are per-gateway local state too: leaving them behind after
      // a disconnect/wipe means the next sign-in to the same gateway
      // re-hides messages the user has no record of deleting.
      await (delete(
        deletedMessages,
      )..where((r) => r.gatewayId.equals(gatewayId))).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'hermes_sessions.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
