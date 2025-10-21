#!/bin/bash
# Push .env.staging to Dokploy staging compose
# This script automates the interactive dokploy env push command

set -e

cd "$(dirname "$0")/.."

# Install expect if not available
if ! command -v expect &> /dev/null; then
    echo "Installing expect..."
    sudo apt-get update && sudo apt-get install -y expect
fi

# Create expect script
expect << 'EOF'
set timeout 60

spawn dokploy env push .env.staging

# Confirm override
expect "Do you want to continue?"
send "y\r"

# Select project: G-app (should be first option)
expect "Select the project:"
send "\r"

# Wait for service selection (compose selection)
expect {
    "Select the service:" {
        send "\r"
        exp_continue
    }
    "Select the compose:" {
        # Select staging compose (might be first or need to navigate)
        send "\r"
    }
    timeout {
        send_user "Timeout waiting for service/compose selection\n"
        exit 1
    }
}

# Wait for completion
expect {
    "Successfully" {
        send_user "Environment variables pushed successfully\n"
    }
    "Error" {
        send_user "Error pushing environment variables\n"
        exit 1
    }
    timeout {
        send_user "Timeout waiting for completion\n"
        exit 1
    }
}

expect eof
EOF

echo "Environment variables pushed to Dokploy staging compose"
