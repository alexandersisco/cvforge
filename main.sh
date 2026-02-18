#!/usr/bin/env bash

# base dir for this script
project_path=$(dirname $(realpath $0))

CONFIG_BASE="$HOME/.config/cvforge"

# Load Helpers
. "$project_path/helpers.sh"

blank_config() {
    cat <<'EOF'
APPLICATION="JOHN DOE"
LOCATION="Dallas, TX"
EMAIL="john.doe@example.com"
PHONE="1234567890"
JOBS_DIR="$HOME/Documents/jobs"
EOF
}

if [[ ! -d "$CONFIG_BASE" ]]; then
    echo "Missing config files for cvforge."
    echo "Setting up config files..."

    mkdir -p "$CONFIG_BASE"

    if [[ -d "$CONFIG_BASE" ]]; then
        blank_config > "$CONFIG_BASE/app.conf"

        cp "$project_path/resume-script.js" "$CONFIG_BASE/resume-script.js"
        cp "$project_path/resume-styles.css" "$CONFIG_BASE/resume-styles.css"

        echo "Config directory created successfully."
        echo "Update your config at $CONFIG_BASE"
        echo
    fi
fi

# ----------------------------
# Usage
# ----------------------------
usage() {
    cat <<'EOF'
cvforge — Prepare tailored resumes and cover letters for job applications.

USAGE
cvforge <command>

COMMANDS
    start
        Create a new job directory

    resume
        Select a resume and generate a PDF

    coverletter
        Select a cover letter and generate a PDF

    open
        Select a job directory and open it in the file explorer

    path
        Select a job directory and print its path

CONFIGURATION
    You can edit your config by navigation to ~/.config/cvforge/app.conf
EOF
}

if [[ "$#" == 0 ]]; then
    usage
    exit 0
fi

case "$1" in
    start)
        "${project_path}/mkjob.sh" ;;
    resume)
        "${project_path}/mkresume.sh" ;;
    coverletter)
        "${project_path}/mkcoverletter.sh" ;;
    path)
        "${project_path}/jobdir.sh" ;;
    open)
        job_dir=$("${project_path}/jobdir.sh")
        if [ ! -d "$job_dir" ]; then
            echo "nothing selected"; exit 1
        fi
        open_file "$job_dir"
        ;;
    *) echo "error: not a command"; exit 1 ;;
esac
