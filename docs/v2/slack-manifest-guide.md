# Slack Manifest Guide (v2)

Two manifests are provided:

- `manifests/slack/alice-starter.manifest.json`
- `manifests/slack/alice-operator.manifest.json`

## Which one to use

### Starter
Use for first install and fast trust-building.
- lower scope footprint
- enough capability for briefing/reconciliation workflows

### Operator
Use once trust is established and workflow ownership expands.
- richer write/admin-adjacent capabilities
- better for channel/topic automation and reminders

## Import flow

1. Open Slack app config
2. Create app from manifest
3. Paste chosen manifest JSON
4. Install to workspace
5. Add bot to target channels
6. Enable desired slash commands and event subscriptions

## Safety recommendation

Start with Starter manifest, then graduate to Operator after calibration.
