#!/bin/bash

source /home/camstark/.zsh/para/para.sh
FILE_PATH="/home/camstark/Documents/notes/⬇️ Inbox"
export DATE="$(date +%F)"
export TIME="$(date +%H%M)"

prompt_note() {

  # Open, continue, New
  while true; do
    echo "Do you want to open a previous note, continue with the previous note, or create a new note?"
    read -p "o/c/n: " oc

    if [ "$oc" == "o" ]; then
      note -o "$FILE_PATH/$(find "$FILE_PATH" -type f -printf "%T@ %p\n" | sort -n | tail -10 | cut -f2- -d" " | awk -F'/' '{print $NF}' | fzf )"
      return 0
    elif [ "$oc" == "c" ]; then
      # This only works if its in the Inbox directory.. need to think best way if in another dir
      PREVIOUS="$(find "$FILE_PATH" -type f -printf "%T@ %p\n" | sort -n | tail -10 | cut -f2- -d" " | awk -F'/' '{print $NF}' | fzf | sed 's/.md//' )"

      export PREV_REF="[[$PREVIOUS]]"

      NEW_NAME="$(echo $PREVIOUS | cut -d" "  -f3- )"

      note "$NEW_NAME"
      return 0
    elif [ "$oc" == "n" ]; then
      echo "Please enter title:" 
      read title

      if [ -z "$title" ]; then
        echo "Please provide a title for note"
        return
      fi

      note "$title"
      return 0
    fi
  done
}

prompt_note
