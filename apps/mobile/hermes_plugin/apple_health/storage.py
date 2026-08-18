"""Local, read-only-for-agents Apple Health sample store.

The database lives beside the installed plugin so it is intentionally shared
by Hermes profiles on this gateway. Profile isolation is still enforced at the
model boundary: only profiles with the ``apple_health`` toolset enabled receive
these tools. Hermes Go is the sole writer through the authenticated dashboard
route.
"""

from __future__ import annotations

import json
import sqlite3
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

PLUGIN_DIR = Path(__file__).resolve().parent
DEFAULT_DB = PLUGIN_DIR / "data" / "apple_health.sqlite3"
DAILY_STEP_SOURCE_ID = "app.hermes.go.healthkit.statistics.daily"
ALLOWED_TYPES = {
    "ACTIVE_ENERGY_BURNED",
    "APPLE_MOVE_TIME",
    "APPLE_STAND_HOUR",
    "APPLE_STAND_TIME",
    "ATRIAL_FIBRILLATION_BURDEN",
    "BASAL_ENERGY_BURNED",
    "BLOOD_GLUCOSE",
    "BLOOD_OXYGEN",
    "BLOOD_PRESSURE_DIASTOLIC",
    "BLOOD_PRESSURE_SYSTOLIC",
    "BODY_FAT_PERCENTAGE",
    "BODY_MASS_INDEX",
    "BODY_TEMPERATURE",
    "DIETARY_CAFFEINE",
    "DIETARY_CARBS_CONSUMED",
    "DIETARY_ENERGY_CONSUMED",
    "DIETARY_FATS_CONSUMED",
    "DIETARY_FIBER",
    "DIETARY_PROTEIN_CONSUMED",
    "DIETARY_SODIUM",
    "DIETARY_SUGAR",
    "DISTANCE_CYCLING",
    "DISTANCE_SWIMMING",
    "DISTANCE_WALKING_RUNNING",
    "ELECTROCARDIOGRAM",
    "ELECTRODERMAL_ACTIVITY",
    "EXERCISE_TIME",
    "FLIGHTS_CLIMBED",
    "HEADACHE_MILD",
    "HEADACHE_MODERATE",
    "HEADACHE_NOT_PRESENT",
    "HEADACHE_SEVERE",
    "HEADACHE_UNSPECIFIED",
    "HEART_RATE",
    "HEART_RATE_VARIABILITY_SDNN",
    "HEIGHT",
    "HIGH_HEART_RATE_EVENT",
    "INSULIN_DELIVERY",
    "IRREGULAR_HEART_RATE_EVENT",
    "LEAN_BODY_MASS",
    "LOW_HEART_RATE_EVENT",
    "MINDFULNESS",
    "PERIPHERAL_PERFUSION_INDEX",
    "RESTING_HEART_RATE",
    "RESPIRATORY_RATE",
    "SLEEP_ASLEEP",
    "SLEEP_AWAKE",
    "SLEEP_DEEP",
    "SLEEP_IN_BED",
    "SLEEP_LIGHT",
    "SLEEP_REM",
    "SLEEP_WRIST_TEMPERATURE",
    "STEPS",
    "VO2_MAX",
    "WAIST_CIRCUMFERENCE",
    "WALKING_HEART_RATE",
    "WALKING_SPEED",
    "WATER",
    "WEIGHT",
    "WORKOUT",
}


def db_path() -> Path:
    marker = PLUGIN_DIR / "dataset.json"
    try:
        configured = json.loads(marker.read_text(encoding="utf-8")).get("path")
        if configured:
            return Path(configured).expanduser().resolve()
    except (OSError, ValueError, TypeError):
        pass
    return DEFAULT_DB


def connect() -> sqlite3.Connection:
    path = db_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(path, timeout=10)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA foreign_keys=ON")
    conn.executescript(
        """
        CREATE TABLE IF NOT EXISTS samples (
          uuid TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          start_at TEXT NOT NULL,
          end_at TEXT NOT NULL,
          value_json TEXT NOT NULL,
          unit TEXT,
          source_name TEXT,
          source_id TEXT,
          recording_method TEXT,
          updated_at TEXT NOT NULL
        );
        CREATE INDEX IF NOT EXISTS samples_type_start
          ON samples(type, start_at);
        CREATE TABLE IF NOT EXISTS devices (
          device_id TEXT PRIMARY KEY,
          last_sync_at TEXT NOT NULL,
          app_version TEXT,
          sample_count INTEGER NOT NULL DEFAULT 0
        );
        CREATE TABLE IF NOT EXISTS batches (
          batch_id TEXT PRIMARY KEY,
          device_id TEXT NOT NULL,
          received_at TEXT NOT NULL,
          sample_count INTEGER NOT NULL
        );
        """
    )
    return conn


def ingest(*, device_id: str, batch_id: str, app_version: str | None,
           samples: Iterable[dict[str, Any]]) -> dict[str, Any]:
    now = datetime.now(timezone.utc).isoformat()
    rows = list(samples)
    with connect() as conn:
        if conn.execute("SELECT 1 FROM batches WHERE batch_id=?", (batch_id,)).fetchone():
            return {"ok": True, "duplicate": True, "accepted": 0}
        accepted = 0
        for item in rows:
            kind = str(item.get("type") or "").upper()
            uid = str(item.get("uuid") or "").strip()
            start = str(item.get("dateFrom") or item.get("start_at") or "").strip()
            end = str(item.get("dateTo") or item.get("end_at") or start).strip()
            if not uid or kind not in ALLOWED_TYPES or not start or not end:
                continue
            value = item.get("value")
            conn.execute(
                """INSERT INTO samples
                   (uuid,type,start_at,end_at,value_json,unit,source_name,source_id,recording_method,updated_at)
                   VALUES (?,?,?,?,?,?,?,?,?,?)
                   ON CONFLICT(uuid) DO UPDATE SET
                     type=excluded.type,start_at=excluded.start_at,end_at=excluded.end_at,
                     value_json=excluded.value_json,unit=excluded.unit,
                     source_name=excluded.source_name,source_id=excluded.source_id,
                     recording_method=excluded.recording_method,updated_at=excluded.updated_at""",
                (uid, kind, start, end, json.dumps(value, separators=(",", ":")),
                 item.get("unit"), item.get("sourceName"), item.get("sourceId"),
                 item.get("recordingMethod"), now),
            )
            accepted += 1
        conn.execute(
            "INSERT INTO batches(batch_id,device_id,received_at,sample_count) VALUES(?,?,?,?)",
            (batch_id, device_id, now, accepted),
        )
        conn.execute(
            """INSERT INTO devices(device_id,last_sync_at,app_version,sample_count)
               VALUES(?,?,?,?) ON CONFLICT(device_id) DO UPDATE SET
               last_sync_at=excluded.last_sync_at,app_version=excluded.app_version,
               sample_count=devices.sample_count+excluded.sample_count""",
            (device_id, now, app_version, accepted),
        )
    return {"ok": True, "duplicate": False, "accepted": accepted}


def status() -> dict[str, Any]:
    with connect() as conn:
        total = conn.execute("SELECT COUNT(*) FROM samples").fetchone()[0]
        types = [r[0] for r in conn.execute("SELECT DISTINCT type FROM samples ORDER BY type")]
        last = conn.execute("SELECT MAX(last_sync_at) FROM devices").fetchone()[0]
    return {"available": total > 0, "sample_count": total, "types": types,
            "last_sync_at": last}


def summary(start: str, end: str, metrics: list[str] | None = None) -> dict[str, Any]:
    requested = [m.upper() for m in (metrics or []) if m.upper() in ALLOWED_TYPES]
    if metrics is not None and not requested:
        return {
            "start": start,
            "end": end,
            "sample_count": 0,
            "metrics": {},
            "truncated": False,
            "error": "No recognized Apple Health metrics were requested",
        }
    params: list[Any] = [start, end]
    where = "start_at >= ? AND start_at < ?"
    if requested:
        where += " AND type IN (%s)" % ",".join("?" for _ in requested)
        params.extend(requested)
    with connect() as conn:
        rows = conn.execute(
            f"SELECT type,start_at,end_at,value_json,unit,source_name,source_id "
            f"FROM samples WHERE {where} ORDER BY start_at",
            params,
        ).fetchall()
    authoritative_step_dates = {
        row["start_at"][:10]
        for row in rows
        if row["type"] == "STEPS" and row["source_id"] == DAILY_STEP_SOURCE_ID
    }
    by_type: dict[str, list[dict[str, Any]]] = {}
    for row in rows:
        kind = row["type"]
        is_daily_step_total = (
            kind == "STEPS" and row["source_id"] == DAILY_STEP_SOURCE_ID
        )
        if (
            kind == "STEPS"
            and row["start_at"][:10] in authoritative_step_dates
            and not is_daily_step_total
        ):
            continue
        value = {
            "start": row["start_at"], "end": row["end_at"],
            "value": json.loads(row["value_json"]), "unit": row["unit"],
            "source": row["source_name"],
        }
        if is_daily_step_total:
            local_date = row["start_at"][:10]
            value.update({
                "date": local_date,
                "weekday": datetime.fromisoformat(local_date).strftime("%A"),
                "aggregation": "healthkit_daily_total",
            })
        by_type.setdefault(kind, []).append(value)
    # Bound tool output. Daily coaching needs trends, not an unbounded raw dump.
    truncated = False
    for kind, values in list(by_type.items()):
        if len(values) > 500:
            truncated = True
            by_type[kind] = values[-500:]
    returned_count = sum(len(values) for values in by_type.values())
    return {"start": start, "end": end, "sample_count": returned_count, "metrics": by_type,
            "truncated": truncated}


def clear() -> int:
    with connect() as conn:
        count = conn.execute("SELECT COUNT(*) FROM samples").fetchone()[0]
        conn.execute("DELETE FROM samples")
        conn.execute("DELETE FROM batches")
        conn.execute("DELETE FROM devices")
    return int(count)
