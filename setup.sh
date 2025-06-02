#!/bin/bash
set -e
mkdir -p services
cd services

declare -a repos=("sim" "storage" "sync" "control")

for repo in "${repos[@]}"; do
  if [ ! -d "traffic-$repo" ]; then
    echo "📥 Clonando traffic-$repo..."
    git clone https://github.com/pinv01-25/traffic-$repo.git traffic-$repo
  else
    echo "🔁 traffic-$repo ya está presente, omitiendo..."
  fi
done

cd ..
echo "✅ Repositorios clonados."
