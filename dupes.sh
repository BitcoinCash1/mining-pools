OUTPUT=$(cat pools-v2.json | jq 'group_by(.id) | map(select(length>1) | .[])')

if [ "$OUTPUT" = "[]" ]; then
    echo "no duplicate pool ids found"
    exit 0
else
    echo "duplicate pool ids found: $OUTPUT"
    exit 1
fi