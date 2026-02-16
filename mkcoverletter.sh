#!/usr/bin/env bash

# base dir for this script
project_path=$(dirname $(realpath $0))

# Contact info from ./.contact-info.env
set -euo pipefail

# load config
. "$HOME/.config/cvforge/app.conf"

# validate
: "${APPLICANT_NAME:?missing APPLICANT_NAME}"
: "${JOBS_DIR:?missing JOBS_DIR}"

applicant="$APPLICANT_NAME"

jobs_path="$(realpath $JOBS_DIR)"

title="" # <title> parameter

OUTPUT_FILENAME=''

# Load helpers
. "$project_path/helpers.sh"

ask_pdf_filename() {
  OUTPUT_FILENAME=''

  local options='Y/n'
  local job_title="$title"

  local suggested="$(fileslug "${applicant}_Cover_Letter_${job_title}").pdf"

  echo "Suggested filename: $suggested"
  echo "Enter [y] to accept, [n] to skip, or type a custom name:"

  local input=''
  printf '> '
  read -r input

  local choice=$(confirm "$options" "$input")
  if [[ $choice = 'q' ]]; then
    echo "Quitting mkcoverletter..."
    exit 0
  fi

  if [[ $choice = 'y' ]]; then
    # Accept suggested filename and create cover letter.
    OUTPUT_FILENAME="$suggested"
    echo "the filename: $OUTPUT_FILENAME"
    return 0
  fi

  if [[ ! $choice = 'y' && ! $choice = 'n' ]]; then
    # An alternate filename was given, transform and ask for confirmation.
    local cover_letter_file="$(fileslug "$input").pdf"

    echo "confirm filename for cover letter: $cover_letter_file (Y/n)"
    read input

    choice=$(confirm 'Y/n' "$input")
    if [[ $input = 'n' ]]; then
      # What actually happens here:
      # 1. User discards the filename
      # 2. Process starts again from top of this function.
      ask_pdf_filename

      return 0
    fi

    OUTPUT_FILENAME="$cover_letter_file"
  fi
}

ask_pdf_title() {
  OUTPUT_TITLE=''

  local options='Y/n'
  local job_title="$title"

  local suggested="Application for $job_title"

  echo "Suggested PDF title: $suggested"
  echo "Enter [y] to accept, [n] to skip, or type a custom name:"

  local input=''
  printf '> '
  read -r input

  local choice=$(confirm "$options" "$input")
  if [[ $choice = 'q' ]]; then
    echo "Quitting mkcoverletter..."
    exit 0
  fi

  if [[ $choice = 'y' ]]; then
    # Accept suggested filename and create cover letter.
    OUTPUT_TITLE="$suggested"
    return 0
  fi

  if [[ ! $choice = 'y' && ! $choice = 'n' ]]; then
    # An alternate filename was given, transform and ask for confirmation.
    local pdf_title="$input"

    echo "confirm PDF title for cover letter: $pdf_title (Y/n)"
    read input

    choice=$(confirm 'Y/n' "$input")
    if [[ $input = 'n' ]]; then
      # What actually happens here:
      # 1. User discards the filename
      # 2. Process starts again from top of this function.
      ask_pdf_title

      return 0
    fi

    OUTPUT_TITLE="$pdf_title"
  fi
}

main() {

  cd "$jobs_path"

  local md_file=$(fzf)
  local job_dir="$jobs_path/$(dirname $md_file)"

  local out="$job_dir/${md_file%.*}.pdf"

  if [ -z "$title" ]; then
    # load title from kv store
    . "$job_dir/kv_store.txt"

    title="$JOB_TITLE"

    if [[ -z "$title" ]]; then
      echo "No --title was passed in and no JOB_TITLE environment variable was found."
      echo "Make sure the value is set in kv_store.txt in the same directory as the cover letter."
      exit 1
    fi

    ask_pdf_filename
    echo

    ask_pdf_title
    echo

    out="$job_dir/$OUTPUT_FILENAME"
    title="$OUTPUT_TITLE"
  fi

  mkpdf $md_file --title "$title" --output "$out" --css "$project_path/resume-styles.css"

  if [ "$?" -eq 7 ]; then
    echo "Cannot connect to mkpdf-server. Did you forget to start the server?"
    exit 7
  fi

  local output_dir="$jobs_path/$(dirname $md_file)"
  xdg-open $output_dir

  cd -
}

# Start to build resume
main


