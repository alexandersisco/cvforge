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
    cvforge — Prepare and navigate your CV/resumes, and cover letters.

    A CV (Curriculum Vitae), Latin for "course of life," is a comprehensive,
    detailed document outlining a person's entire educational and professional
    history. Unlike a short resume, a CV often spans multiple pages and is
    typically used for academic, research, or scientific job applications to
    highlight publications, awards, and credentials. 

    USAGE
    cvforge start - create a new job directory
    cvforge resume - choose a resume and produce a PDF
    cvforge coverletter - choose a cover letter and produce a PDF
    cvforge open - choose a file from your job directory and open it in the file
        explorer
    cvforge path - print the path of the job directory
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
