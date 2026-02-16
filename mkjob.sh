#!/usr/bin/env bash

# base dir for this script
project_path=$(dirname $(realpath $0))
job_app_path=''

# load config
. "$HOME/.config/cvforge/app.conf"

# validate
: "${APPLICANT_NAME:?missing APPLICANT_NAME}"
: "${JOBS_DIR:?missing JOBS_DIR}"

applicant="$APPLICANT_NAME"
jobs_path="$(realpath $JOBS_DIR)"

# Variables

DRY_RUN=false
if [[ "$1" = '--dry-run' ]]; then
    DRY_RUN=true
fi

company_name=''
job_title=''
company_dir=''
job_dir=''
has_readme=false
has_posting=false
has_resume=false
has_letter=false

warning="(This may appear in filenames and titles of your application docs)"

# Helpers

# load common helpers
. "$project_path/helpers.sh"

print_config() {
    echo "----------------------------------------------------------------"
    echo "Job information"
    echo "----------------------------------------------------------------"
    printf 'Applicant: %s\n' "$applicant"
    printf 'Company name: %s\n' "$company_name"
    printf 'Job title: %s\n' "$job_title"
    printf 'Company dir: %s\n' "$company_dir"
    if [[ ! -z $job_dir ]]; then
        printf 'Job dir: %s\n' "$job_dir"
    fi
    printf 'Job path: %s\n' "$job_app_path"

    echo
    if $has_readme; then 
        echo "Created README.md"
    fi

    if $has_posting; then
        echo "Created job_posting.txt"
    fi

    if $has_resume; then
        echo "Created resume.md"
    fi

    if $has_letter; then
        echo "Created cover_letter.md"
    fi
    echo "----------------------------------------------------------------"
    echo
}

ask_company_name() {
    echo "Name of the company? $warning"

    printf 'Name: '
    read company_name

    echo "Company name: $company_name"
    company_dir="$(dirslug "$company_name")"

    if [[ ! -z "$company_dir" ]]; then
        job_app_path="$jobs_path/$company_dir"

        if ! $DRY_RUN; then
            mkdir -p "$job_app_path"

        else
            echo "Would create dir: $job_app_path"
        fi
    fi
}

ask_job_title() {
    echo "Title of job posting? $warning"

    printf 'Title: '
    read job_title

    echo "Job posting title: $job_title"
}

ask_should_create_subdir() {
    echo "Create sub-directory for position? (Type 'y' to accept suggestion, 'N' to skip, or type your own...)"
    echo "Suggestion: $(dirslug "$job_title") (y/N) "

    local input=''
    printf '> '
    read input

    choice=$(confirm 'y/N' "$input")
    if [[ $choice = 'n' ]]; then
        return 0
    fi

    if [[ $choice = 'y' ]]; then
        job_dir="$(dirslug "$job_title")"
    else
        job_dir="$(dirslug "$input")"
    fi

    if [[ ! -z "$job_dir" ]]; then
        job_app_path="$job_app_path/$job_dir"
        echo "job_app_path is: $job_app_path"

        if ! $DRY_RUN; then
            mkdir -p "$job_app_path"

            if [[ -d "$job_app_path" ]]; then
                echo "Created successfully!"
            fi
        else
            echo "Would create dir: $job_app_path"
        fi
    fi
}

ask_should_create_readme() {
    printf "create file: README.md? (Y/n) "

    local input=''
    read input

    choice=$(confirm 'Y/n' "$input")
    if [[ $choice = 'y' ]]; then
        has_readme=true
    fi

    if $has_readme; then
        if ! $DRY_RUN; then
            touch "$job_app_path/README.md"
        fi
    fi
}

ask_should_create_job_posting_file() {
    printf "create file: job_posting.txt? (Y/n) "

    local input=''
    read input

    choice=$(confirm 'Y/n' "$input")
    if [[ $choice = 'y' ]]; then
        has_posting=true
    fi

    if $has_posting; then
        if ! $DRY_RUN; then
            touch "$job_app_path/job_posting.txt"
        fi
    fi
}

ask_should_create_resume_file() {
    printf "create file: resume.md? (Y/n) "

    local input=''
    read input

    choice=$(confirm 'Y/n' "$input")
    if [[ $choice = 'y' ]]; then
        has_resume=true
    fi

    if $has_resume; then
        if ! $DRY_RUN; then
            touch "$job_app_path/resume.md"
        fi
    fi
}

ask_should_create_blank_cover_letter() {
    printf "create file: cover_letter.md? (Y/n) "

    local input=''
    read input

    choice=$(confirm 'Y/n' "$input")
    if [[ $choice = 'y' ]]; then
        has_letter=true
    fi

    if $has_letter; then
        if ! $DRY_RUN; then
            touch "$job_app_path/cover_letter.md"
        fi
    fi
}


# ---------------------------------------------------------------
# Main 
# ---------------------------------------------------------------

main() {
    ask_company_name
    echo

    ask_job_title
    echo

    ask_should_create_subdir

    ask_should_create_readme

    ask_should_create_job_posting_file

    ask_should_create_resume_file

    ask_should_create_blank_cover_letter

    kv_file="$job_app_path/kv_store.txt"
        if ! $DRY_RUN; then
        set_kv_item "COMPANY_NAME" "$company_name" "$kv_file"
        set_kv_item "JOB_TITLE" "$job_title" "$kv_file"
    fi
}

# Run main
main $@

print_config
