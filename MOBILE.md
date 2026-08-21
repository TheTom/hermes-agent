# Mobile gateway fork

Branch: **`mobile-gateway`**

Upstream: [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)  
Remote name in this clone: `upstream`  
(Add your GitHub fork as `origin` when ready:  
`git remote add origin git@github.com:<you>/hermes-go.git`
Live fork: [TheTom/hermes-go](https://github.com/TheTom/hermes-go))

## What this fork is for

A **Flutter phone connector** under `apps/mobile` that talks to an already-running,
authenticated Hermes dashboard gateway. It is **not** a full agent port and it
does not connect to the OpenAI-compatible `API_SERVER_*` service on port 8642.

| Product | Path | Role |
| --- | --- | --- |
| Hermes Agent + gateway | repo root | Source of truth (tools, memory, cron, sessions) |
| Hermes Desktop | `apps/desktop` | Full desktop client |
| **Hermes Mobile** | `apps/mobile` | Sessions · chat · model picker · jobs/notifications |

See `apps/mobile/README.md` and `apps/mobile/DESIGN.md`.

## Host checklist

```bash
# Configure dashboard username/password authentication first, then:
hermes dashboard --host 0.0.0.0 --no-open
# Hermes Go connects to the dashboard on port 9119 by default.
```

For a narrower Tailscale-only bind, use the host's tailnet address instead of
`0.0.0.0`, then enter `http://<tailscale-ip>:9119` in Hermes Go:

```bash
hermes dashboard --host "$(tailscale ip -4)" --no-open
```

Do not bind the dashboard to `127.0.0.1` and then access it through a remote
hostname without configuring the proxy accordingly. Hermes validates the HTTP
`Host` header and WebSocket origin against its bind host; a reverse proxy that
forwards its public hostname to a loopback-bound dashboard will be rejected with
`400 Invalid Host header`. Direct access over the private tunnel is the simplest
supported setup. See `apps/mobile/README.md` for HTTPS proxy alternatives and
security notes.

## Run mobile

```bash
cd apps/mobile
flutter pub get
flutter run
```
