#!/usr/bin/env bash
set -euo pipefail

# Simple bootstrap script for WSL Ubuntu 24.04
# Run this from the repo root: ./setup.sh

echo "==> Installing system packages (apt). You might be asked for sudo password"
sudo apt update; sudo apt install -y build-essential libsqlite3-dev sqlite3 nodejs yarn curl git

if ! command -v ruby >/dev/null 2>&1; then
  echo "Ruby not found. Please install Ruby (recommended via rbenv or apt). Aborting."
  exit 1
fi

echo "==> Installing bundler and rails gems (if missing)"
gem install bundler --no-document || true
gem install rails --no-document || true

if [ -f "Gemfile" ]; then
  echo "Gemfile already exists. Skipping rails new. If you want a clean app, remove Gemfile and run again."
else
  echo "==> Generating new Rails app in current directory (sqlite3, skip git)"
  rails new . -d sqlite3 --skip-git
fi

echo "==> Installing gems"
bundle install

echo "==> Setup helpers are prepared. Next: copy files from templates/ into the Rails app (see README.md)."
echo "Example copy commands (run from repo root):"
echo "  cp templates/config/routes.rb config/routes.rb"
echo "  cp templates/app/controllers/* app/controllers/"
echo "  cp templates/app/models/* app/models/"
echo "  cp -r templates/app/views app/"
echo "  cp templates/db/seeds.rb db/seeds.rb"

echo "Done. Now run: bin/rails db:create db:migrate db:seed"
