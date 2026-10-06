#!/usr/bin/env bash
set -euo pipefail

WINDOW_NAME="$(tmux display-message -p '#{window_name}')"
TICKET_ID="$(grep -oE '[A-Za-z]+-[0-9]+' <<< "$WINDOW_NAME" | head -n1 || true)"

if [[ -z "$TICKET_ID" ]]; then
    echo "No ticket ID found in window name: $WINDOW_NAME"
    exit 1
fi
TICKET_ID="$(tr '[:lower:]' '[:upper:]' <<< "$TICKET_ID")"

if [[ -z "${LINEAR_API_KEY:-}" && -f ~/.private_env ]]; then
    source ~/.private_env
fi

if [[ -z "${LINEAR_API_KEY:-}" ]]; then
    echo "LINEAR_API_KEY is not set."
    echo "Add 'export LINEAR_API_KEY=lin_api_...' to ~/.private_env."
    exit 1
fi

QUERY='query($id: String!) { issue(id: $id) { identifier title state { name } assignee { name } url description comments { nodes { body user { name } createdAt } } } }'

PAYLOAD="$(jq -n --arg q "$QUERY" --arg id "$TICKET_ID" '{query: $q, variables: {id: $id}}')"

RESPONSE="$(curl -s -X POST https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")"

if [[ "$(echo "$RESPONSE" | jq -r '.data.issue')" == "null" ]]; then
    echo "Could not find ticket $TICKET_ID (window: $WINDOW_NAME)"
    echo "$RESPONSE" | jq -r '.errors[]?.message // empty'
    exit 1
fi

MARKDOWN="$(echo "$RESPONSE" | jq -r '
  .data.issue as $i |
  "# \($i.identifier): \($i.title)\n" +
  "\n" +
  "- **Status:** \($i.state.name)\n" +
  "- **Assignee:** \($i.assignee.name // "unassigned")\n" +
  "- **URL:** \($i.url)\n" +
  "\n---\n" +
  "\n\($i.description // "_(no description)_")\n" +
  "\n---\n" +
  "\n## Comments (\($i.comments.nodes | length))\n" +
  (
    if ($i.comments.nodes | length) == 0
    then "\n_(none)_"
    else [$i.comments.nodes[] | "\n**\(.user.name)** _\(.createdAt)_\n\n> \(.body | gsub("\n"; "\n> "))\n"] | join("\n")
    end
  )
')"

if command -v glow &> /dev/null && command -v fzf &> /dev/null; then
    TICKET_FILE="$(mktemp "${TMPDIR:-/tmp}/tmux-linear-ticket.XXXXXX.md")"
    trap 'rm -f "$TICKET_FILE"' EXIT
    printf '%s\n' "$MARKDOWN" > "$TICKET_FILE"

    export LINEAR_TICKET_URL="$(echo "$RESPONSE" | jq -r '.data.issue.url')"
    export LINEAR_TICKET_FILE="$TICKET_FILE"

    printf '%s\n' "$TICKET_ID" | env -u NO_COLOR -u FZF_DEFAULT_OPTS fzf \
        --ansi \
        --color=dark \
        --no-mouse \
        --no-info \
        --prompt='' \
        --pointer='' \
        --footer='o: open in Linear  ·  q: quit' \
        --footer-border=none \
        --preview-window='up,95%,border-none,wrap' \
        --preview 'env -u NO_COLOR CLICOLOR_FORCE=1 glow -s dark -w "${FZF_PREVIEW_COLUMNS:-80}" "$LINEAR_TICKET_FILE"' \
        --bind 'o:execute-silent("$HOME/bin/open-linear-ticket.sh" "$LINEAR_TICKET_URL")' \
        --bind 'j:preview-down,k:preview-up,pgdn:preview-page-down,pgup:preview-page-up' \
        --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up' \
        --bind 'q:abort,esc:abort' \
        >/dev/null || true
elif command -v glow &> /dev/null && command -v python3 &> /dev/null; then
    TICKET_FILE="$(mktemp "${TMPDIR:-/tmp}/tmux-linear-ticket.XXXXXX.md")"
    trap 'rm -f "$TICKET_FILE"' EXIT
    printf '%s\n' "$MARKDOWN" > "$TICKET_FILE"

    TICKET_URL="$(echo "$RESPONSE" | jq -r '.data.issue.url')"
    python3 "$HOME/bin/glow-linear-ticket.py" "$TICKET_URL" "$TICKET_FILE"
elif command -v glow &> /dev/null; then
    echo "$MARKDOWN" | glow -p -
else
    echo "$MARKDOWN" | less -R
fi
