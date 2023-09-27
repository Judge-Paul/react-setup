#!/bin/bash

# Function to prompt for user input with a default value
function prompt {
  local message="$1"
  local default="$2"
  read -p "$message [$default]: " input
  if [ -z "$input" ]; then
    echo "$default"
  else
    echo "$input"
  fi
}

# Ask for the project name
project_name=$(prompt "Enter the project name" "my-react-app")

# Ask for package manager (npm, yarn, pnpm)
package_manager=$(prompt "Choose a package manager (npm/yarn/pnpm)" "npm")

# Validate package_manager input
if [[ ! "$package_manager" =~ ^(npm|yarn|pnpm)$ ]]; then
  echo "Invalid package manager choice. Using 'npm' by default."
  package_manager="npm"
fi

# Ask if React Icons should be installed
read -p "Do you want to install React Icons? (y/n): " install_icons

# Create the project using Vite
echo "Setting up a React project in /$project_name using $package_manager..."
if [ "$package_manager" = "npm" ]; then
    npm create vite@latest "$project_name" -- --template react
else
    $package_manager create "$project_name" -- --template react
fi

# Check if the project directory was created
if [ ! -d "$project_name" ]; then
  echo "Project directory was not created. Exiting..."
  exit 1
fi

# Navigate to the project directory and install dependencies
cd "$project_name"
if ! $package_manager install; then
  echo "Failed to install dependencies. Exiting..."
  exit 1
fi

# Install and configure Tailwind CSS
echo "Installing and configuring Tailwind CSS..."
$package_manager install -D tailwindcss@latest postcss@latest autoprefixer@latest
npx tailwindcss init -p

# Remove the old tailwind.config.js
rm tailwind.config.js

# Create a new tailwind.config.js with the provided content
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

# Install React Icons if chosen
if [ "$install_icons" = "y" ]; then
  echo "Installing React Icons..."
  $package_manager install react-icons
fi

# Provide some next steps
echo "Project setup complete!"
echo "You can now navigate to your project directory using 'cd $project_name'"
echo "To start the development server, run '$package_manager run dev'"
