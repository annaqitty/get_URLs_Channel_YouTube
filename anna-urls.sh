#!/bin/bash

# Replace with your API key and channel ID
API_KEY="YOUR_API_KEY_HERE"
CHANNEL_ID="YOUR_CHANNEL_ID_HERE"

# API endpoint for fetching videos by channel ID
API_ENDPOINT="https://www.googleapis.com/youtube/v3/search"

# Number of videos per page (max 50)
MAX_RESULTS=25

# ANSI escape sequence for pink color
COLOR_PINK='\033[95m'

# Function to fetch video URLs for a specific page token
function fetch_videos {
    local page_token="$1"
    local response

    if [ -z "$page_token" ]; then
        response=$(curl -s "${API_ENDPOINT}?key=${API_KEY}&channelId=${CHANNEL_ID}&part=id&order=date&maxResults=${MAX_RESULTS}&type=video")
    else
        response=$(curl -s "${API_ENDPOINT}?key=${API_KEY}&channelId=${CHANNEL_ID}&part=id&order=date&maxResults=${MAX_RESULTS}&type=video&pageToken=${page_token}")
    fi

    echo "API Response:"
    echo "$response"

    # Check if response is empty or not valid JSON
    if [ -z "$response" ]; then
        echo "Error: Empty API response."
        exit 1
    fi

    local video_ids=$(echo "$response" | jq -r '.items[].id.videoId')

    # Check if video_ids is null or empty
    if [ -z "$video_ids" ]; then
        echo "Error: No video IDs found in API response."
        exit 1
    fi

    for video_id in $video_ids; do
        local video_url="https://www.youtube.com/watch?v=${video_id}"
        echo "$video_url" >> urls.txt
        echo -e "${COLOR_PINK}Saved: ${video_url}\033[0m"
    done

    next_page_token=$(echo "$response" | jq -r '.nextPageToken')

    # Recursively fetch next page if nextPageToken exists
    if [ ! -z "$next_page_token" ]; then
        fetch_videos "$next_page_token"
    fi
}

# Start fetching videos
echo "Fetching videos..."
fetch_videos ""

echo "Video URLs saved to urls.txt"
