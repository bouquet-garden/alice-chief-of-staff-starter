# Obsidian PARA Vault — Alice Setup

This folder contains the scaffold for an Obsidian vault structured around the PARA method (Projects, Areas, Resources, Archives). Alice reads from and writes to this vault to maintain your operating context, surface decisions, and produce structured notes.

---

## Folder structure

```
00 Inbox/          — Unprocessed notes, quick captures, and Alice-imported items
01 Projects/       — One note (or subfolder) per active project
02 Areas/          — Ongoing responsibilities: Alice config, personal ops
03 Resources/      — Reference material: people, companies, meeting notes
04 Archive/        — Completed projects, retired notes, historical context
Templates/         — Note templates used by Alice and Obsidian Templater
```

---

## Setup instructions

### 1. Open as a vault

1. Open Obsidian.
2. Click **Open folder as vault**.
3. Select this directory (or copy its contents into your existing vault).

### 2. Install recommended plugins

Alice works best with the following community plugins:

| Plugin | Purpose |
|---|---|
| **Templater** | Powers the template files in `Templates/` |
| **Dataview** | Enables Alice to query notes as a database |
| **Tasks** | Renders task lists with due dates and filters |
| **Calendar** | Links daily notes to date-based navigation |
| **Git** | Auto-commits vault changes so Alice can track history |

Install via: **Settings → Community plugins → Browse**

### 3. Configure Templater

1. Go to **Settings → Templater**.
2. Set the template folder to `Templates/`.
3. Enable **Trigger Templater on new file creation**.

### 4. Configure Alice's vault path

Add the vault path to Alice's environment config:

```env
OBSIDIAN_VAULT_PATH=/path/to/this/vault
```

Alice will use this path to read existing notes, write new ones, and update frontmatter fields.

---

## YAML frontmatter conventions

Alice reads and writes structured YAML frontmatter. Keep these fields consistent:

- `status`: draft | active | complete | archived
- `tags`: array of lowercase strings
- `date`: ISO 8601 (YYYY-MM-DD)
- `alice_updated`: ISO 8601 timestamp of last Alice modification

---

## Inbox workflow

Drop raw notes, links, or transcripts into `00 Inbox/`. Alice will:
1. Parse the content.
2. Extract action items, decisions, and entities.
3. Route the note to the appropriate folder.
4. Apply the correct template and frontmatter.

Run `/alice-reconcile` in Slack to trigger a manual inbox sweep.
