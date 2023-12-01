#!/bin/bash

set -euo pipefail

# Accept inputs from action configuration
token_expiration="$1" # The date that the token is set to expire
token="$2" # The token to check (unused in this script, but you can add logic to use it if needed)
warn_days="$3" # The number of days before token expiration to start warning
error_early="$4" # Trigger an error if true, before the token has actually expired
token_name="$5" # The name of the token.
current_date=$(date +%Y-%m-%d)
rotation_warning_days=$(test "$error_early" = "true" && echo $((warn_days + 16)) || echo 16)

export GITHUB_TOKEN="${token}"

# Calculate the time to token expiration so we can display a message.
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    days_until_expiry=$(echo $(($(date -jf "%Y-%m-%d" "$token_expiration" +%s) - $(date +%s))) | awk '{print int($1/86400)}')
else
    # Linux and others
    days_until_expiry=$(( ( $(date -d "$token_expiration" +%s) - $(date -d "$current_date" +%s) ) / 86400 ))
fi

expiration_message="This token will expire in ${days_until_expiry} days."

if [[ $days_until_expiry -ge $warn_days ]]; then
    if [[ $error_early == "true" ]]; then
        # Display an error if the token is set to expire in the future.
        echo "ERROR: ${expiration_message}. Please rotate the token now."
        exit 1
    fi
    # Display a notice that says how many days are left on the token.
    echo "${expiration_message}"
elif [[ $days_until_expiry -le 0 ]]; then
    # Display an error if the token has already expired.
    echo "ERROR: This token has expired."
    exit 1
else
    # Display a notice that the token is going to expire within the month.
    echo "WARNING: ${expiration_message}"
fi

# Display a reminder to add token rotation to the upcoming sprint.
if [[ $days_until_expiry -le $rotation_warning_days ]]; then
    echo "Please make a plan to rotate the token in the next couple weeks."
fi

ssh -T git@github.com

# Check the authenticated user.
user=$(gh api /user | jq -r '"\(.name) (\(.login))"')
if [[ $token_name ]]; then
	echo "Logged in as ${user} using the \"${token_name}\" fine-grained personal access token."
	exit 0
else 
	echo "Logged in as ${user} using a fine-grained personal access token."
	exit 0
fi
