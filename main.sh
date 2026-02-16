#!/usr/bin/env bash

# base dir for this script
project_path=$(dirname $(realpath $0))

if [[ ! -f "$HOME/.config/cvforge/app.conf" ]]; then
    echo "error: missing configuration file"
    exit 1
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
        xdg-open "$job_dir"
        ;;
    *) echo "error: not a command"; exit 1 ;;
esac
