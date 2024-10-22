# smart-xcode-build.sh taken from https://x.com/rudrankriyam/status/1847734299740811675 
# Intelligently chooses between xcodemake and make for building Xcode projects
# with domain blocking functionality

# Path to xcodemake script
# replace this xcodemake path with your local path
XCODEMAKE_PATH="XXXXX/xcodemake"

# Default build arguments if none provided
DEFAULT_ARGS="-scheme MyScheme -sdk iphonesimulator"

# Use provided arguments or default
BUILD_ARGS="${@:-$DEFAULT_ARGS}"

# Function to block the domain
block_domain() {
    echo "🔒 Blocking Apple developer services domain..."
    echo "127.0.0.1 http://developerservices2.apple.com" | sudo tee -a /etc/hosts > /dev/null
}

# Function to unblock the domain
unblock_domain() {
    echo "🔓 Unblocking Apple developer services domain..."
    sudo sed -i '' '/developerservices2\.apple\.com/d' /etc/hosts
}

# Function to check if Makefile exists and is valid
check_makefile() {
    # Check if Makefile exists
    if [ ! -f "Makefile" ]; then
        return 1
    fi
    
    # Check if the Makefile contains the expected log file
    if ! grep -q "xcodemake $BUILD_ARGS.log" Makefile 2>/dev/null; then
        return 1
    fi
    
    return 0
}

# Function to display build start message
show_build_message() {
    local build_type=$1
    echo "🏗  Starting build using $build_type..."
    echo "Build arguments: $BUILD_ARGS"
    echo "----------------------------------------"
}

# Function to format time
format_time() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local remaining_seconds=$((seconds % 60))
    
    if [ $minutes -eq 0 ]; then
        echo "${remaining_seconds} seconds"
    else
        echo "${minutes} minutes and ${remaining_seconds} seconds"
    fi
}

# Function to cleanup and exit
cleanup_and_exit() {
    local exit_code=$1
    unblock_domain
    exit $exit_code
}

# Trap for handling interrupts and errors
trap 'cleanup_and_exit 1' INT TERM

# Check if xcodemake exists
if [ ! -x "$XCODEMAKE_PATH" ]; then
    echo "❌ Error: xcodemake script not found at $XCODEMAKE_PATH"
    echo "Please ensure the script exists and is executable"
    exit 1
fi

# Start timing
START_TIME=$(date +%s)

# Block domain before building
block_domain

# Main build logic
if ! check_makefile; then
    show_build_message "xcodemake"
    echo "⚙️  Generating new Makefile..."
    "$XCODEMAKE_PATH" $BUILD_ARGS
    BUILD_RESULT=$?
else
    show_build_message "make"
    make
    BUILD_RESULT=$?
fi

# End timing
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
FORMATTED_TIME=$(format_time $DURATION)

# Unblock domain after building
unblock_domain

# Handle build result with timing information
if [ $BUILD_RESULT -eq 0 ]; then
    echo "✅ Build completed successfully in $FORMATTED_TIME! ⏱️"
else
    echo "❌ Build failed after $FORMATTED_TIME with error code $BUILD_RESULT"
fi

# Display timing summary
echo "----------------------------------------"
echo "📊 Build Statistics:"
echo "   Start time: $(date -r $START_TIME '+%H:%M:%S')"
echo "   End time:   $(date -r $END_TIME '+%H:%M:%S')"
echo "   Duration:   $FORMATTED_TIME"
echo "----------------------------------------"

# Exit with build result
exit $BUILD_RESULT