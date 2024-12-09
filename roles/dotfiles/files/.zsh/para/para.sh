#!/bin/bash
EDITOR=nvim
standup() {
  export TITLE="AVMS Standup"
  export DATE="$(date +%F)"
  export TIME="$(date +%H:%M)"
  NAME="${DATE} $(date +%H%M) Meeting ${TITLE}"
  FILE_PATH="/home/camstark/Documents/notes/📁PARA/2. Area/📊 Yarra Trams - AVMS/${NAME}.md"

  if [ -f "${FILE_PATH}" ]; then
    echo "File already exists: ${FILE_PATH}"
    return
  fi

  cat "/home/camstark/.zsh/para/templates/standup.md" | envsubst > "${FILE_PATH}"
  $EDITOR "${FILE_PATH}"
  return 0
}

note() {
  if [ -z "$1" ] || [[ "$@" == "-p" ]]; then
    echo "Please provide a title for the meeting"
    return
  fi

  PARA_PATH="/home/camstark/.zsh/para/templates"
  export DATE="$(date +%F)"
  export TIME="$(date +%H:%M)"

  if [[ "$1" == "-p" ]]; then
    shift
    export TITLE="$@"
    NAME="${DATE} $(date +%H%M) ${TITLE}"
    FILE_PATH="$(find '/home/camstark/Documents/notes/📁PARA/1. Project/' -type d | sort | fzf -m --with-nth=8,9 --delimiter='/')/${NAME}.md";
  elif [[ "$1" == "-m" ]]; then
    shift
    export TITLE="$@"
    NAME="${DATE} $(date +%H%M) Meeting ${TITLE}"
    FILE_PATH="$(find '/home/camstark/Documents/notes/⬇️ Inbox/${NAME}.md' -type d | sort | fzf -m --with-nth=8,9 --delimiter='/')/${NAME}.md";
    cat "/home/camstark/.zsh/para/templates/meeting.md" | envsubst > "${FILE_PATH}"
    $EDITOR "${FILE_PATH}"
    return 0
  elif [[ "$1" == "-s" ]]; then
    shift
    export TITLE="$@"
    NAME="${DATE} ${TITLE}"
    FILE_PATH="$(find '/home/camstark/Documents/notes/📥Seedbox/' -type d | sort | fzf -m --with-nth=7,8 --delimiter='/')";
    case $FILE_PATH in
       *'Article ('*)
        SYMBOL="("
        MARKDOWN_TEMPLATE="${PARA_PATH}/article.md"
       ;;
       *'Book {'*)
        SYMBOL="{"
       	MARKDOWN_TEMPLATE="${PARA_PATH}/book.md"
       ;;
       *'Course &'*)
        SYMBOL="&"
       	MARKDOWN_TEMPLATE="${PARA_PATH}/course.md"
       ;;
       *'Game )'*)
        SYMBOL=")"
       	MARKDOWN_TEMPLATE="${PARA_PATH}/game.md"
       ;;
       *'Podcast *'*)
        SYMBOL="*"
       	MARKDOWN_TEMPLATE="${PARA_PATH}/podcast.md"
       ;;
       *'Slack _'*)
        SYMBOL="_"
       	MARKDOWN_TEMPLATE="${PARA_PATH}/slack.md"
       ;;
       *'Social !'*)
        SYMBOL="!"
       	MARKDOWN_TEMPLATE="${PARA_PATH}/social.md"
       ;;
       *'Thought }'*)
        SYMBOL="}"
       	MARKDOWN_TEMPLATE="${PARA_PATH}/thought.md"
       ;;
       *'Video +'*)
        SYMBOL="+"
       	MARKDOWN_TEMPLATE="${PARA_PATH}/video.md"
       ;;
    esac
    FILE_PATH="${FILE_PATH}/${SYMBOL} ${NAME}.md"
    cat "${MARKDOWN_TEMPLATE}" | envsubst > "${FILE_PATH}"
    $EDITOR "${FILE_PATH}"
    return 0
  elif [[ "$1" == "-o" ]]; then
    shift
    FILE_PATH="$1"
    if [ -f "${FILE_PATH}" ]; then
      $EDITOR "${FILE_PATH}"
      return 0
    else 
      echo "File does not exist: ${FILE_PATH}"
      return 1
    fi
  else 
    export TITLE="$@"
    NAME="${DATE} $(date +%H%M) ${TITLE}"
    FILE_PATH="/home/camstark/Documents/notes/⬇️ Inbox/${NAME}.md";
  fi

  if [ -f "${FILE_PATH}" ]; then
    $EDITOR "${FILE_PATH}"
    return 0
  fi

  cat "/home/camstark/.zsh/para/templates/note.md" | envsubst > "${FILE_PATH}"
  $EDITOR "${FILE_PATH}"
  return 0
}

weekly() {
  $EDITOR "/home/camstark/Documents/notes/📓Journal/Weekly/$(date +%Y)-W$(date +%W).md"
}

archive_folders() {
  find '/home/camstark/Documents/notes/📁PARA/1. Project/' -type d | fzf -m --with-nth=8,9 --delimiter='/' | xargs -I {} mv {} '/home/camstark/Documents/notes/📁PARA/4. Archive/'
}

unarchive_folders() {
  find '/home/camstark/Documents/notes/📁PARA/4. Archive/' -type d | fzf -m --with-nth=8,9 --delimiter='/' | xargs -I {} mv {} '/home/camstark/Documents/notes/📁PARA/1. Project/'
}

seedbox() {
  cd '/home/camstark/Documents/notes/📥Seedbox/'
}

file_thisweek() {
  local DATES=$(for i in {0..6}; do date -d "-$i days" +%Y-%m-%d; done | paste -sd '|')
  find '/home/camstark/Documents/notes/📓Journal/' '/home/camstark/Documents/notes/📥Seedbox/' '/home/camstark/Documents/notes/⬇️ Inbox/' '/home/camstark/Documents/notes/📁PARA/1. Project' '/home/camstark/Documents/notes/📁PARA/2. Area' '/home/camstark/Documents/notes/📁PARA/3. Reference' -type f -exec grep -El "date: ($DATES)" {} + | sort | fzf -m --with-nth=6,7,8,9 --delimiter='/' 
}

thisweek() {
  $EDITOR -p "$(file_thisweek)"
}

file_recent() {
  local DATES=$(for i in {0..2}; do date -d "-$i days" +%Y-%m-%d; done | paste -sd '|')
  find '/home/camstark/Documents/notes/📓Journal/' '/home/camstark/Documents/notes/📥Seedbox/' '/home/camstark/Documents/notes/⬇️ Inbox/' '/home/camstark/Documents/notes/📁PARA/1. Project' '/home/camstark/Documents/notes/📁PARA/2. Area' '/home/camstark/Documents/notes/📁PARA/3. Reference' -type f -exec grep -El "date: ($DATES)" {} + | sort | fzf -m --with-nth=6,7,8,9 --delimiter='/' 
}

recent() {
  $EDITOR -p "$(file_recent)"
}

file_today() {
  DATE="${1:-$(date +%F)}"
  find '/home/camstark/Documents/notes/📓Journal/' '/home/camstark/Documents/notes/📥Seedbox/' '/home/camstark/Documents/notes/⬇️ Inbox/' '/home/camstark/Documents/notes/📁PARA/1. Project' '/home/camstark/Documents/notes/📁PARA/2. Area' '/home/camstark/Documents/notes/📁PARA/3. Resource' -type f -exec grep -l "date: ${DATE}" {} + | sort | fzf -m --print0 --with-nth=6,7,8,9 --delimiter='/'
}

note_find() {
  DATE="${1:-$(date +%F)}"
  file_today "$1" | xargs -o -0 $EDITOR
}


# Weekly notes
daily_note(){ 
  echo "${DOCS}/notes/📓Journal/Daily/$(date +%F).md" 
}

morning_note(){ 
  echo "${DOCS}/notes/📓Journal/Routine/$(date +%F) Morning Routine.md" 
}

weekly_note(){ 
  echo "${DOCS}/notes/📓Journal/Weekly/$(date +%Y)-W$(date +%W).md" 
}

preflight_check() {
  FILE_PATH="$(daily_note)" 
  if [ ! -f "${FILE_PATH}" ]; then
    bash "${HOME}/Documents/scripts/stream-deck/linux/daily-note.sh"
  fi

  FILE_PATH="$(morning_note)" 
  if [ ! -f "${FILE_PATH}" ]; then
    bash "${HOME}/Documents/scripts/stream-deck/run.sh" "action-checklist" "morning-checklist"
  fi

  FILE_PATH="$(weekly_note)" 
  if [ ! -f "${FILE_PATH}" ]; then
    bash "${HOME}/Documents/scripts/stream-deck/run.sh" "action-checklist" "weekly-checklist"
  fi
}

daily(){ 
  preflight_check
  $EDITOR -p "$(weekly_note)" "$(daily_note)" "$(morning_note)" 
}
