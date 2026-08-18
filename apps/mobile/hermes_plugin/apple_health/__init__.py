"""Hermes Go Apple Health tools."""

from __future__ import annotations

import json

from .storage import status, summary


_STATUS_DESCRIPTION = (
    "Check whether Hermes Go has synced Apple Health data and which metrics "
    "are available."
)
_SUMMARY_DESCRIPTION = (
    "Read Apple Health samples for an explicit, bounded date range. Always "
    "choose only the metrics needed for the user's question. For sleep, "
    "request the available SLEEP_* metrics and bound start/end to the night "
    "being discussed. STEPS uses HealthKit's reconciled daily totals and "
    "includes authoritative date and weekday labels. Use for health coaching "
    "and trends; do not diagnose."
)
_STATUS_SCHEMA = {
    "name": "apple_health_status",
    "description": _STATUS_DESCRIPTION,
    "parameters": {
        "type": "object",
        "properties": {},
        "required": [],
        "additionalProperties": False,
    },
}
_SUMMARY_SCHEMA = {
    "name": "apple_health_summary",
    "description": _SUMMARY_DESCRIPTION,
    "parameters": {
        "type": "object",
        "properties": {
            "start": {
                "type": "string",
                "description": (
                    "Inclusive ISO-8601 start with timezone, e.g. the local "
                    "evening before a requested night's sleep."
                ),
            },
            "end": {
                "type": "string",
                "description": (
                    "Exclusive ISO-8601 end with timezone, e.g. noon after "
                    "a requested night's sleep."
                ),
            },
            "metrics": {
                "type": "array",
                "items": {"type": "string"},
                "minItems": 1,
                "description": (
                    "Metric names returned by apple_health_status. Request "
                    "only relevant metrics; for sleep use the available "
                    "SLEEP_* names."
                ),
            },
        },
        "required": ["start", "end", "metrics"],
        "additionalProperties": False,
    },
}


def _available() -> bool:
    return bool(status()["available"])


def _status_handler(args: dict, **_: object) -> str:
    return json.dumps(status())


def _summary_handler(args: dict, **_: object) -> str:
    end = str(args.get("end") or "").strip()
    start = str(args.get("start") or "").strip()
    metrics = args.get("metrics")
    clean_metrics = (
        [str(metric).strip() for metric in metrics if str(metric).strip()]
        if isinstance(metrics, list)
        else []
    )
    if not start or not end or not clean_metrics:
        return json.dumps({
            "error": "start, end, and at least one metric are required",
            "available_metrics": status().get("types", []),
        })
    return json.dumps(summary(start, end, clean_metrics))


def register(ctx) -> None:
    ctx.register_tool(
        name="apple_health_status",
        toolset="apple_health",
        description=_STATUS_DESCRIPTION,
        schema=_STATUS_SCHEMA,
        handler=_status_handler,
        check_fn=_available,
        emoji="❤️",
    )
    ctx.register_tool(
        name="apple_health_summary",
        toolset="apple_health",
        description=_SUMMARY_DESCRIPTION,
        schema=_SUMMARY_SCHEMA,
        handler=_summary_handler,
        check_fn=_available,
        emoji="📈",
    )
