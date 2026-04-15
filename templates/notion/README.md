# Notion Database Setup

This guide walks through creating the six Alice-managed Notion databases via the Notion API. Once created, Alice can read and write to these databases to track projects, tasks, meetings, people, experiments, and OKRs.

---

## Prerequisites

1. A Notion workspace where you have admin permissions.
2. A Notion integration with the following capabilities:
   - Read content
   - Update content
   - Insert content
3. Your integration token exported as `NOTION_API_TOKEN`.
4. A root page (or existing database parent) where the databases will live.

Create your integration at: https://www.notion.so/my-integrations

---

## Step 1 — Share your root page with the integration

1. Open the page in Notion where you want Alice's databases to live.
2. Click **Share** → **Invite** → search for your integration name.
3. Grant **Full access**.
4. Copy the page ID from the URL (the 32-character hex string after the last `/`).

---

## Step 2 — Create each database

Use the Notion API to create databases as children of your root page. All schema definitions are in `database-schemas.json`.

### Example: create the Projects database

```bash
curl -X POST https://api.notion.com/v1/databases \
  -H "Authorization: Bearer $NOTION_API_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": { "type": "page_id", "page_id": "YOUR_ROOT_PAGE_ID" },
    "title": [{ "type": "text", "text": { "content": "Projects" } }],
    "properties": {
      "Name": { "title": {} },
      "Status": {
        "select": {
          "options": [
            { "name": "Backlog", "color": "gray" },
            { "name": "Planning", "color": "blue" },
            { "name": "Active", "color": "green" },
            { "name": "On Hold", "color": "yellow" },
            { "name": "Complete", "color": "purple" },
            { "name": "Cancelled", "color": "red" }
          ]
        }
      },
      "Owner": { "people": {} },
      "Priority": {
        "select": {
          "options": [
            { "name": "P0 — Critical", "color": "red" },
            { "name": "P1 — High", "color": "orange" },
            { "name": "P2 — Medium", "color": "yellow" },
            { "name": "P3 — Low", "color": "blue" }
          ]
        }
      },
      "Due Date": { "date": {} },
      "Links": { "url": {} },
      "Notes": { "rich_text": {} },
      "Last Updated": { "last_edited_time": {} }
    }
  }'
```

Repeat for Tasks, Meetings, People, Experiments, and OKRs using the property definitions in `database-schemas.json`.

---

## Step 3 — Create relations between databases

After creating all six databases, add relation properties to link them:

- **Tasks → Projects**: Link the `Project` property in Tasks to the Projects database ID.
- **Meetings → Projects**: Link the `Project` property in Meetings to the Projects database ID.

### Example: add a relation property

```bash
curl -X PATCH https://api.notion.com/v1/databases/TASKS_DB_ID \
  -H "Authorization: Bearer $NOTION_API_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "properties": {
      "Project": {
        "relation": {
          "database_id": "PROJECTS_DB_ID",
          "single_property": {}
        }
      }
    }
  }'
```

---

## Step 4 — Store database IDs in Alice config

Once all databases are created, add their IDs to Alice's environment config:

```env
NOTION_PROJECTS_DB_ID=<id>
NOTION_TASKS_DB_ID=<id>
NOTION_MEETINGS_DB_ID=<id>
NOTION_PEOPLE_DB_ID=<id>
NOTION_EXPERIMENTS_DB_ID=<id>
NOTION_OKRS_DB_ID=<id>
```

Alice will use these IDs to query and update records during daily operations.

---

## Database ID format note

Notion database IDs are 32-character hex strings. They appear in the URL as:
```
https://www.notion.so/your-workspace/DATABASE_ID?v=VIEW_ID
```

Strip hyphens if the API returns them with hyphens — both formats (`abc123` and `abc-123`) are accepted.
