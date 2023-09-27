#!/bin/bash

# Function to prompt for user input with a default value and validation
function prompt {
  local message="$1"
  local default="$2"
  local valid_options="$3"
  
  while true; do
    read -p "$message [$default]: " input
    if [ -z "$input" ]; then
      echo "$default"
      return
    elif [ -n "$valid_options" ] && [[ ! "$valid_options" =~ (^| )"$input"($| ) ]]; then
      echo "Invalid input. Using default value: $default"
      return
    else
      echo "$input"
      return
    fi
  done
}

# Ask for the project name
project_name=$(prompt "Enter the project name" "my-react-app")

# Ask for package manager (npm, yarn, pnpm)
package_manager=$(prompt "Choose a package manager (npm/yarn/pnpm)" "npm" "npm yarn pnpm")

# Ask if React Icons should be installed
install_icons=$(prompt "Do you want to install React Icons? (y/n)" "n" "y n")

# Ask if the user wants to install all project dependencies
install_dependencies=$(prompt "Do you want to install all project dependencies? (y/n)" "n" "y n")

# Create the project using Vite
echo "Setting up a React project in /$project_name using $package_manager..."
if [ "$package_manager" = "npm" ]; then
    npm create vite@latest "$project_name" -- --template react > /dev/null 2>&1
else
    $package_manager create vite "$project_name" --template react > /dev/null 2>&1
fi

# Check if the project directory was created
if [ ! -d "$project_name" ]; then
  echo "Project directory was not created. Exiting..."
  exit 1
fi

# Navigate to the project directory
cd "$project_name"

# Install and configure Tailwind CSS
echo "Installing and configuring Tailwind CSS..."
$package_manager add -D tailwindcss@latest postcss@latest autoprefixer@latest
npx tailwindcss init -p

# Remove the old tailwind.config.js
rm tailwind.config.js src/index.css

# Create a new tailwind.config.js
echo "/** @type {import('tailwindcss').Config} */" > tailwind.config.js
echo "export default {" >> tailwind.config.js
echo "  content: [" >> tailwind.config.js
echo "    \"./index.html\"," >> tailwind.config.js
echo "    \"./src/**/*.{js,ts,jsx,tsx}\"," >> tailwind.config.js
echo "  ]," >> tailwind.config.js
echo "  theme: {" >> tailwind.config.js
echo "    extend: {}," >> tailwind.config.js
echo "  }," >> tailwind.config.js
echo "  plugins: []," >> tailwind.config.js
echo "}" >> tailwind.config.js

# Create a new index.css file
echo "@tailwind base;" > src/index.css
echo "@tailwind components;" >> src/index.css
echo "@tailwind utilities;" >> src/index.css

# Remove the old src/App.css and src/App.jsx
rm src/App.css src/App.jsx

# Create a new src/App.jsx with the specified content
echo "import React from 'react';" > src/App.jsx
echo "" >> src/App.jsx
echo "export default function App() {" >> src/App.jsx
echo "  return (" >> src/App.jsx
if [ "$install_icons" = "y" ]; then
  echo "    <div>" >> src/App.jsx
  echo "      React Project with Vite, Tailwind, and React Icons" >> src/App.jsx
  echo "    </div>" >> src/App.jsx
else
  echo "    <div>" >> src/App.jsx
  echo "      React Project with Vite and Tailwind" >> src/App.jsx
  echo "    </div>" >> src/App.jsx
fi
echo "  );" >> src/App.jsx
echo "}" >> src/App.jsx
echo "" >> src/App.jsx

# Add React Icons to package.json
echo "Adding React Icons to package.json..."
$package_manager add react-icons

# Install all dependencies if requested
if [ "$install_dependencies" = "y" ]; then
  echo "Installing all project dependencies..."
  $package_manager install
fi

# Provide some next steps
echo "Project setup complete!"
echo "You can now navigate to your project directory using 'cd $project_name'"
if [ $install_dependencies != "y" ]; then
  echo "To install all project dependencies, run '$package_manager install'"
fi
echo "To start the development server, run '$package_manager run dev'"