#!/bin/sh
set -e

mkdir -p "$HOME/.claude"

if [ -d "/host-claude" ]; then
    for f in .credentials.json statsig.json; do
        [ -f "/host-claude/$f" ] && cp "/host-claude/$f" "$HOME/.claude/$f"
    done
    if [ ! -f "$HOME/.claude/settings.json" ]; then
        [ -f "/host-claude/settings.json" ] && cp "/host-claude/settings.json" "$HOME/.claude/settings.json"
    fi
fi

# Only copy .claude.json if one doesn't already exist in persistent home
if [ ! -f "$HOME/.claude.json" ]; then
    [ -f "/host-claude.json" ] && cp "/host-claude.json" "$HOME/.claude.json"
fi

# Load API credentials and model overrides from settings.json
if [ -f "$HOME/.claude/settings.json" ]; then
    export ANTHROPIC_BASE_URL=$(cat "$HOME/.claude/settings.json" | grep -o '"ANTHROPIC_BASE_URL": *"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')
    export ANTHROPIC_AUTH_TOKEN=$(cat "$HOME/.claude/settings.json" | grep -o '"ANTHROPIC_AUTH_TOKEN": *"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')
    ANTHROPIC_DEFAULT_OPUS_MODEL=$(cat "$HOME/.claude/settings.json" | grep -o '"ANTHROPIC_DEFAULT_OPUS_MODEL": *"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')
fi

MODEL_FLAG=""
if [ -n "$ANTHROPIC_DEFAULT_OPUS_MODEL" ]; then
    MODEL_FLAG="--model $ANTHROPIC_DEFAULT_OPUS_MODEL"
fi

if [ "$1" = "resume" ]; then
    shift
    exec claude --resume $MODEL_FLAG "$@"
else
    exec claude $MODEL_FLAG "$@"
fi
