# Facebook / Meta Ads MCP

A Model Context Protocol (MCP) server for Meta Ads. Connect Claude (or any MCP-compatible AI client) directly to your Facebook and Instagram ad accounts to query performance, analyse audiences, research competitors, and more — all in natural language.

## What you can do

### Account & Campaign Management
- List all ad accounts linked to your token
- Get detailed account info — spend, balance, currency, status
- Browse campaigns, ad sets, and ads with filtering and pagination
- Inspect individual campaigns, ad sets, ads, and creatives

### Performance & Insights
- Pull performance metrics at account, campaign, ad set, and ad level
- Break down results by age, gender, country, device, placement, and more
- Set custom date ranges or use presets (last 7d, last 30d, last quarter, etc.)
- Use attribution windows: 1-day click, 7-day click, 1-day view, and more

### Audiences
- List custom audiences (CRM uploads, pixel-based, engagement-based, lookalikes)
- View saved audience definitions and their estimated sizes
- Estimate audience reach before launching a campaign
- Get projected delivery metrics for an existing ad set
- Get a plain-English description of any ad set's targeting

### Targeting Research
- Search available interests, behaviours, and demographics by keyword
- Get targeting suggestions based on an existing audience spec

### Pixels & Conversions
- List Meta Pixels on the account
- List custom conversion events being tracked

### Creative Library
- Browse the image library for an ad account
- Preview how any ad renders across Facebook, Instagram, Stories, Reels, and more

### Automation & Organisation
- List automated ad rules (auto-pause, budget adjustment rules)
- Review the execution history of any ad rule
- List ad labels used to organise campaigns and ads

### Lead Generation
- Fetch lead form submissions for any Lead Gen ad

### Pages
- List Facebook Pages the authenticated user manages
- Get Page-level performance metrics (reach, impressions, engagement, fans)
- Browse published posts and see which organic content is eligible to boost

---

## Prerequisites

- Python 3.10+
- A Meta access token with the following permissions:
  - `ads_read` — required for all ad account tools
  - `pages_show_list` + `pages_read_engagement` — required for Page tools
- Dependencies listed in `requirements.txt`

---

## Step 1: Get a Meta Access Token

1. Go to the [Meta Developer Portal](https://developers.facebook.com/) and create an app (or use an existing one)
2. Under your app, go to **Tools → Graph API Explorer**
3. Select your app, then click **Generate Access Token**
4. Add the permissions: `ads_read`, `pages_show_list`, `pages_read_engagement`
5. Copy the generated token

> For long-lived tokens, exchange your short-lived token using the [token exchange endpoint](https://developers.facebook.com/docs/facebook-login/guides/access-tokens/get-long-lived). Short-lived tokens expire in ~1 hour; long-lived tokens last ~60 days.

---

## Step 2: Local Setup

```bash
git clone https://github.com/your-username/facebook-ads-mcp-server
cd facebook-ads-mcp-server

# Create and activate a virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

---

## Step 3: Connect to Claude

### Option A: Local (Claude Desktop — single user)

Add to your Claude Desktop config at `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "facebook-ads": {
      "command": "python",
      "args": ["/absolute/path/to/facebook-ads-mcp-server/server.py"],
      "env": {
        "FB_ACCESS_TOKEN": "your_meta_access_token_here"
      }
    }
  }
}
```

Alternatively, pass the token as a CLI argument:

```json
{
  "mcpServers": {
    "facebook-ads": {
      "command": "python",
      "args": [
        "/absolute/path/to/facebook-ads-mcp-server/server.py",
        "--fb-token",
        "your_meta_access_token_here"
      ]
    }
  }
}
```

Restart Claude Desktop after saving the config.

---

### Option B: Hosted Server (shared team access)

Run a persistent HTTP server that your whole team connects to via SSE transport.

**Start the server:**

```bash
FB_ACCESS_TOKEN=your_token python server.py
```

The server listens on port `8000` by default. Override with the `PORT` environment variable.

**Connect via Claude Desktop:**

```json
{
  "mcpServers": {
    "facebook-ads": {
      "url": "http://localhost:8000/sse"
    }
  }
}
```

---

### Option C: Deploy to Google Cloud Run (recommended for teams)

**Deploy:**

```bash
gcloud run deploy facebook-ads-mcp \
  --source . \
  --region YOUR_REGION \
  --project YOUR_PROJECT_ID \
  --platform managed \
  --port 8000 \
  --allow-unauthenticated \
  --set-env-vars "FB_ACCESS_TOKEN=your_token"
```

**Connect team members via Claude Desktop:**

```json
{
  "mcpServers": {
    "facebook-ads": {
      "url": "https://YOUR-SERVICE-URL.run.app/sse"
    }
  }
}
```

---

## Environment Variables

| Variable | Required | Description |
| --- | --- | --- |
| `FB_ACCESS_TOKEN` | Yes (or `--fb-token` arg) | Meta user access token with `ads_read` permission |
| `PORT` | No | HTTP server port (default: `8000`) |

---

## Available Tools

### Account

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `list_ad_accounts` | List all ad accounts linked to your token | "List all my Facebook ad accounts" |
| `get_details_of_ad_account` | Get details for a specific ad account — spend, balance, currency, status | "What's the current balance and status of ad account act_123456?" |

### Campaigns

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_campaigns_by_adaccount` | List campaigns in an ad account with optional filters | "Show me all active campaigns in my account" |
| `get_campaign_by_id` | Get full details for a specific campaign | "What's the objective and budget of campaign 987654321?" |
| `get_campaign_insights` | Performance metrics for a campaign | "Show me clicks, spend, and ROAS for my top campaign last month" |

### Ad Sets

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_adsets_by_adaccount` | List all ad sets in an account | "List all ad sets in my account with their budgets" |
| `get_adsets_by_campaign` | List ad sets within a specific campaign | "What ad sets are running under my Summer Sale campaign?" |
| `get_adset_by_id` | Get full details for a specific ad set | "Show me the targeting and bid strategy for ad set 555666777" |
| `get_adsets_by_ids` | Batch fetch multiple ad sets | "Get details for ad sets 111, 222, and 333 at once" |
| `get_adset_insights` | Performance metrics for an ad set | "What's the CPM and frequency for my retargeting ad set this week?" |
| `get_targeting_sentence_lines` | Human-readable targeting description for an ad set | "Describe the audience targeting for ad set 555666777 in plain English" |
| `get_delivery_estimate` | Projected reach and impressions for an ad set | "How many people is my current ad set expected to reach daily?" |

### Ads

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_ads_by_adaccount` | List all ads in an account | "Show me all paused ads in my account" |
| `get_ads_by_campaign` | List ads within a campaign | "What ads are running in my lead gen campaign?" |
| `get_ads_by_adset` | List ads within an ad set | "Show me all ads in my retargeting ad set" |
| `get_ad_by_id` | Get full details for a specific ad | "What creative and status does ad 111222333 have?" |
| `get_ad_insights` | Performance metrics for an individual ad | "Which of my ads has the lowest cost per result this month?" |
| `get_ad_previews` | See how an ad renders across placements | "Show me a preview of ad 111222333 in Instagram Story format" |

### Ad Creatives

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_ad_creative_by_id` | Get details for a specific creative | "What's the headline and body copy for creative 444555666?" |
| `get_ad_creatives_by_ad_id` | List creatives associated with an ad | "Show me all creatives attached to ad 111222333" |
| `get_ad_images` | Browse the image library for an account | "List all images in my ad account's creative library" |

### Insights & Reporting

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_adaccount_insights` | Account-level performance metrics | "Show me total spend, impressions, and purchases for my account last quarter" |
| `get_campaign_insights` | Campaign-level performance | "Break down my campaign results by age and gender last week" |
| `get_adset_insights` | Ad set-level performance | "What's the cost per lead for each of my ad sets this month?" |
| `get_ad_insights` | Ad-level performance | "Rank all my ads by ROAS for the last 30 days" |
| `fetch_pagination_url` | Fetch the next page of any paginated result | "Get the next page of campaign insights" |

### Audiences

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_custom_audiences` | List custom audiences (CRM, pixel, lookalike, engagement) | "Show me all my custom audiences and their sizes" |
| `get_saved_audiences` | List saved audience templates | "What saved audiences do I have available?" |
| `get_reach_estimate` | Estimate audience size for a targeting spec | "How large is the audience for women 25–44 interested in yoga in the US?" |

### Targeting Research

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `search_targeting_options` | Search interests, behaviours, and demographics by keyword | "What targeting interests are available related to 'sustainable fashion'?" |
| `get_targeting_suggestions` | Get related targeting options based on existing interests | "Suggest more interests similar to the ones I'm already targeting" |

### Pixels & Conversions

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_pixels` | List Meta Pixels on the account | "What pixels are installed on my ad account?" |
| `get_custom_conversions` | List custom conversion events | "What custom conversions am I tracking?" |

### Automation

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_ad_rules` | List automated ad rules | "What automated rules do I have set up?" |
| `get_ad_rule_history` | See what actions a rule has taken | "Has my auto-pause rule triggered in the last 7 days?" |

### Organisation

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_ad_labels` | List labels used to tag campaigns, ad sets, and ads | "What labels am I using to organise my ads?" |

### Lead Generation

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_ad_leads` | Fetch lead form submissions for a Lead Gen ad | "Download all leads submitted through ad 111222333 this month" |

### Budget

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_minimum_budgets` | Get minimum daily budget requirements by objective | "What's the minimum daily budget I need for a conversions campaign?" |

### Activity / Change History

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `get_activities_by_adaccount` | Change history for an ad account | "Who changed the budget on my account last week?" |
| `get_activities_by_adset` | Change history for a specific ad set | "Show me all changes made to ad set 555666777 in the last 30 days" |

### Pages

| Tool | Description | Example Prompt |
| --- | --- | --- |
| `list_pages` | List Facebook Pages the authenticated user manages | "Which Facebook Pages do I have access to?" |
| `get_page_insights` | Page-level metrics — reach, impressions, engagement, fans | "How many people did my Page reach organically last month?" |
| `get_page_posts` | Browse published posts on a Page | "Show me the last 20 posts on my Facebook Page" |
| `get_promotable_posts` | List organic posts eligible to be boosted as ads | "Which of my recent posts can I boost?" |

---

## Example Prompts

```
What's my total ad spend and number of purchases this month?

Which campaigns have the best ROAS over the last 30 days?

Show me all active ad sets with their daily budgets and targeting

Which of my ads has the highest click-through rate this week?

Break down my account performance by age group and gender last quarter

What does the targeting look like for my best-performing ad set, in plain English?

How large is the audience for men aged 30–50 interested in golf in Australia?

Show me all my custom audiences and which ones are large enough to use

Search for targeting interests related to "plant-based diet"

What ads is my competitor running in the US right now? Their page ID is 123456789

Are there any automated rules that have paused my ads recently?

Which organic posts on my Page are eligible to boost?

How has my Facebook Page reach trended over the last 28 days?

Show me all leads submitted through my lead gen campaign this month

What's the minimum daily budget I need for a conversions-objective campaign?
```

---

## Attribution

Forked from [gomarble-ai/facebook-ads-mcp-server](https://github.com/gomarble-ai/facebook-ads-mcp-server), with additions:
- `FB_ACCESS_TOKEN` environment variable support (alongside `--fb-token` CLI arg)
- SSE/HTTP transport for hosted team deployments
- 20 additional read-only tools: audiences, reach estimates, delivery estimates, targeting research, pixels, custom conversions, image library, ad previews, ad rules, lead gen, page insights, page posts, and page insights/posts

---

## License

MIT
