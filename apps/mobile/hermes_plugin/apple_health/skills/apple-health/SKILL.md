---
name: apple-health
description: Read Apple Health data synced directly from Hermes Go through the private gateway plugin.
category: health
---

# Apple Health via Hermes Go

Hermes Go reads HealthKit directly on the user's iPhone and syncs samples to
the authenticated Hermes gateway. This is the authoritative Apple Health data
source for this profile.

## How to answer health-data questions

1. Call `apple_health_status` to see which metrics have reached the gateway.
2. Call `apple_health_summary` with an explicit ISO-8601 date range and the
   relevant metrics. For “last night,” include the prior evening through the
   current morning in the user's local timezone.
3. State clearly when the requested metric is absent or its latest sample is
   stale. Never substitute an older value as if it were current.
4. Analyze trends conservatively and do not diagnose medical conditions.

`STEPS` records marked `healthkit_daily_total` are HealthKit's reconciled
daily statistics. Treat each as the complete total for its included `date` and
use the supplied `weekday`; do not add source samples or recalculate weekdays.

Do not inspect `~/.hermes/health/daily_data`, use an iOS Shortcut export, or
ask the user to run a Shortcut. Those files belong to a retired pipeline and
are not the source used by Hermes Go.
