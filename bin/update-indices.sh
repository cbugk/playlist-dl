#!/bin/bash

# --- Configuration ---
DIGIT_COUNT=4
MAX_VAL=$((10**DIGIT_COUNT - 1))
MODE="" 
MIN_VAL_INPUT=""
TARGET_DIR=""

usage() {
    echo "Usage: $0 {--increment | --decrement} <index> --directory <path>"
    exit 1
}

# --- Argument Parsing ---
if [ $# -ne 4 ]; then usage; fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --increment) [ -n "$MODE" ] && usage; MODE="inc"; shift ;;
        --decrement) [ -n "$MODE" ] && usage; MODE="dec"; shift ;;
        --directory|-d) [ -n "$TARGET_DIR" ] && usage; TARGET_DIR="$2"; shift 2 ;;
        [0-9]*) [ -n "$MIN_VAL_INPUT" ] && usage; MIN_VAL_INPUT=$1; shift ;;
        *) usage ;;
    esac
done

if [ -z "$MODE" ] || [ -z "$MIN_VAL_INPUT" ] || [ -z "$TARGET_DIR" ]; then usage; fi

# --- Environment Setup ---
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

cd "$TARGET_DIR" || exit 1
MIN_VAL=$((10#$MIN_VAL_INPUT))

# --- Logical Constraints ---
if [ "$MIN_VAL" -eq 0 ]; then
    echo "Error: 0 is not a valid index. Use a value between 1 and $MAX_VAL."
    exit 1
fi

if [ "$MIN_VAL" -eq 1 ] && [ "$MODE" == "dec" ]; then
    echo "Error: Cannot decrement index 1. Decrementing is only valid for indices > 1."
    exit 1
fi

if [ "$MIN_VAL" -eq "$MAX_VAL" ] && [ "$MODE" == "inc" ]; then
    echo "Error: Cannot increment $MAX_VAL. Upper limit reached."
    exit 1
fi

# --- Safety Checks ---

# DECREMENT SAFETY: Check if the immediate lower slot is occupied.
if [ "$MODE" == "dec" ]; then
    TARGET_NUM=$((MIN_VAL - 1))
    TARGET_PREFIX=$(printf "%0${DIGIT_COUNT}d" $TARGET_NUM)
    BLOCKER=$(ls "${TARGET_PREFIX}"* 2>/dev/null | head -n 1)
    if [ -n "$BLOCKER" ]; then
        echo "Error: Safety Triggered. The target index '$TARGET_PREFIX' is already occupied by '$BLOCKER'."
        exit 1
    fi
fi

# INCREMENT SAFETY: Check if the absolute ceiling (9999) is occupied.
if [ "$MODE" == "inc" ]; then
    MAX_PREFIX=$(printf "%0${DIGIT_COUNT}d" $MAX_VAL)
    CEILING_BLOCKER=$(ls "${MAX_PREFIX}"* 2>/dev/null | head -n 1)
    if [ -n "$CEILING_BLOCKER" ]; then
        echo "Error: Safety Triggered. Prefix $MAX_VAL is occupied by '$CEILING_BLOCKER'. No room to increment."
        exit 1
    fi
fi

# --- Processing ---
pattern=$(printf '[0-9]%.0s' $(seq 1 $DIGIT_COUNT))"*"
if [ "$MODE" == "inc" ]; then
    files=$(ls -1 $pattern 2>/dev/null | sort -r)
else
    files=$(ls -1 $pattern 2>/dev/null | sort)
fi

OLDIFS=$IFS
IFS=$'\n'

for item in $files; do
    [ -f "$item" ] || continue
    prefix=${item:0:$DIGIT_COUNT}
    rest=${item:$DIGIT_COUNT}
    current_num=$((10#$prefix))

    if [ "$current_num" -lt "$MIN_VAL" ]; then continue; fi

    [[ "$MODE" == "inc" ]] && new_num=$((current_num + 1)) || new_num=$((current_num - 1))

    new_prefix=$(printf "%0${DIGIT_COUNT}d" $new_num)
    new_filename="${new_prefix}${rest}"

    if [ -e "$new_filename" ]; then
        echo "Critical: '$new_filename' exists. Aborting."
        exit 1
    else
        echo "[$MODE] $item -> $new_filename"
        mv "$item" "$new_filename"
    fi
done

IFS=$OLDIFS
echo "Finished."
