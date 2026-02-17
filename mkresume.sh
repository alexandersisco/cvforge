#!/usr/bin/env bash

# base dir for this script
project_path=$(dirname $(realpath $0))

# Contact info from ./.contact-info.env
set -euo pipefail

CONFIG_BASE="$HOME/.config/cvforge"
# load config
. "$CONFIG_BASE/app.conf"

# validate
: "${APPLICANT_NAME:?missing APPLICANT_NAME}"
: "${LOCATION:?missing LOCATION}"
: "${EMAIL:?missing EMAIL}"
: "${PHONE:?missing PHONE}"
: "${JOBS_DIR:?missing JOBS_DIR}"

applicant="$APPLICANT_NAME"

jobs_path="$(realpath $JOBS_DIR)"

# Load Helpers
. "$project_path/helpers.sh"

title="" # <title> parameter

ask_pdf_filename() {
  OUTPUT_FILENAME=''

  local options='Y/n'
  local job_title="$title"

  local suggested="$(fileslug "${applicant}_${job_title}").pdf"

  echo "Suggested filename: $suggested"
  echo "Enter [y] to accept, [n] to skip, or type a custom name:"

  local input=''
  printf '> '
  read -r input

  local choice=$(confirm "$options" "$input")
  if [[ $choice = 'q' ]]; then
    echo "Quitting mkresume..."
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
    local filename="$(fileslug "$input").pdf"

    echo "confirm filename: $filename (Y/n)"
    read input

    choice=$(confirm 'Y/n' "$input")
    if [[ $input = 'n' ]]; then
      # What actually happens here:
      # 1. User discards the filename
      # 2. Process starts again from top of this function.
      ask_pdf_filename

      return 0
    fi

    OUTPUT_FILENAME="$filename"
  fi
}

ask_pdf_title() {
  OUTPUT_TITLE=''

  local options='Y/n'
  local job_title="$title"

  local suggested="$applicant - $job_title"

  echo "Suggested PDF title: $suggested"
  echo "Enter [y] to accept, [n] to skip, or type a custom name:"

  local input=''
  printf '> '
  read -r input

  local choice=$(confirm "$options" "$input")
  if [[ $choice = 'q' ]]; then
    echo "Quitting mkresume..."
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

    echo "confirm PDF title: $pdf_title (Y/n)"
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

get_resume_files() {
    find "$jobs_path" -path "**/resume.md" -type f | sed "s|${jobs_path}/||"
}

make_resume() {

  cd "$jobs_path"

  local md_file=$(get_resume_files | fzf --preview "cat {} 2>/dev/null | sed -n '1,200p'")
  if [[ -z "$md_file" ]]; then
    echo "no file selected. quit."
    exit 1
  fi

  if [[ ! -s "$md_file" ]]; then
    echo "error: file is empty."
    exit 2
  fi

  local job_dir="$jobs_path/$(dirname $md_file)"

  local out="$job_dir/${md_file%.*}.pdf"

  if [ ! "$title" = "" ]; then
    title="$applicant - $title"
    filename="$(echo "$title" | sed -E 's/[ -]+/_/g').pdf"
    out="$job_dir/$filename"
  else
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

    title="$OUTPUT_TITLE"
    out="$job_dir/$OUTPUT_FILENAME"
  fi

  local css_file="$project_path/resume-styles.css"
  # If resume-styles.css exists in ~/.config/cvforge/ then override the default
  if [[ -f "$CONFIG_BASE/resume-styles.css" ]]; then
    css_file="$CONFIG_BASE/resume-styles.css"
    echo "Loaded CSS styles from $CONFIG_BASE" >&2
  fi

  local js_file="$project_path/resume-script.js"
  # If resume-script.js exists in ~/.config/cvforge/ then override the default
  if [[ -f "$CONFIG_BASE/resume-script.js" ]]; then
    js_file="$CONFIG_BASE/resume-script.js"
    echo "Loaded JS from $CONFIG_BASE" >&2
  fi

  tmp_dir="/tmp/cvforge"
  mkdir -p $tmp_dir

  # Inject contact info into the ./resume-script.js
  sed \
    -e "s|<LOCATION>|$LOCATION|g" \
    -e "s|<EMAIL>|$EMAIL|g" \
    -e "s|<PHONE>|$PHONE|g" \
    "$js_file" \
  > "$tmp_dir/resume-script.js"

  mkpdf $md_file --title "$title" --output "$out" --css "$css_file" --js "$tmp_dir/resume-script.js"

  if [ "$?" -eq 7 ]; then
    echo "Cannot connect to mkpdf-server. Did you forget to start the server?"
    exit 7
  fi

  local output_dir="$(dirname $md_file)"
  xdg-open $output_dir
}

# Start to build resume
make_resume

