#!/bin/bash

if ! which tmux; then
  tput setaf 1
  echo "tmux does not seem to be installed in this system."
  echo "Learn more about it on: $(tput smul)https://tmux.github.io$(tput rmul)"
  echo "Exiting."
  tput sgr0
  exit 1
fi

if [ -n "${TMUX+is_set}" ]; then
  echo "Already in a TMUX session."
  echo "Use 'prefix d' to detach or 'prefix s' to list sessions, where 'prefix' is Ctrl-A."
  exit 0
fi

# the name of your primary tmux session
SESSION="basimilch"
CURRENT_DIR="$(pwd)"

# if the session is already running, just attach to it
tmux has-session -t $SESSION
if [ $? -eq 0 ]; then
	echo "Session $SESSION already exists. Attaching..."
	tmux -2 attach-session -t $SESSION
	exit 0;
fi

# create a new session, named $SESSION, with a new window named 'git', and detach from it
tmux new-session -d -s $SESSION -n git

# create further windows
tmux new-window -t $SESSION:2 -n console -c "${CURRENT_DIR}"
tmux new-window -t $SESSION:3 -n tests -c "${CURRENT_DIR}"
tmux new-window -t $SESSION:4 -n server -c "${CURRENT_DIR}"
tmux new-window -t $SESSION:5 -n rake -c "${CURRENT_DIR}"

# # create two vertical panes in first window
# tmux select-window -t $SESSION:dev
# tmux select-pane   -t 0
# tmux split-window  -h -p 50 -c './war' # one pane
# tmux select-pane   -t 0
# tmux split-window  -v -p 50 -c './war' # another pane
# tmux select-pane   -t 2
# tmux split-window  -v -p 50 -c './war' # a third pane

# start some commands
tmux select-window -t $SESSION:console
tmux select-pane   -t $SESSION:console.0
tmux send-keys     'rails console' Enter
tmux select-window -t $SESSION:tests
tmux select-pane   -t $SESSION:tests.0
tmux send-keys     '#bundle exec guard' Enter
tmux send-keys     'bundle exec rake test' Enter
tmux select-window -t $SESSION:server
tmux select-pane   -t $SESSION:server.0
tmux send-keys     '#rails server' Enter
tmux select-window -t $SESSION:rake
tmux select-pane   -t $SESSION:rake.0
tmux send-keys     '#bundle exec rake db:migrate' Enter
tmux send-keys     '#bundle exec rake db:reset' Enter

# all done, select starting window and get to work
tmux select-window -t $SESSION:git
tmux select-pane   -t $SESSION:git.0

tmux -2 attach-session -t $SESSION
