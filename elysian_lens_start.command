#!/bin/bash
# ElysianLens macOS Launcher
# This script launches ElysianLens on macOS with a nice terminal UI
# Save this file as "elysian_lens_start.command" and make it executable

# Change to the script's directory
cd "$(dirname "$0")"

# Terminal colors
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ASCII art
cat << "EOF"
                  .,,'
             .,''''''',.
          .,'',,,,,,,,,,',.
        .'',,,,,,,,,,,,,,,,',.
      .',,,,,,,,,,,,,,,,,,,,,'.
     .',,,,,,,,,,,,,,,,,,,,,,,,'.
    .',,,,,,,,,,,,,,,,,,,,,,,,,,'.
   .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
   .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
  .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
  .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
 .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
 .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
 .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
 ',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
  ',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
   .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
    .,,ElysianLens,,,,,,,,,,,,,,,,,,'.
     .',,,,,,,,,,,,,,,,,,,,,,,,,,'.
       .',,,,,,,,,,,,,,,,,,,,,,'.
         .',,,,,,,,,,,,,,,,,'.
           ..',,,,,,,,,,'.
               ..'''..
EOF

echo -e "${CYAN}======================================================${NC}"
echo -e "${CYAN}   ElysianLens - Advanced Web Scraping & AI Analysis  ${NC}"
echo -e "${CYAN}======================================================${NC}"
echo ""

# Check if first time running
if [ ! -d ".venv" ]; then
    echo -e "${YELLOW}First time setup detected!${NC}"
    echo -e "${BLUE}We'll set everything up for you.${NC}"
    echo ""
    
    # Run the installation script
    bash install_and_run.sh --mode interactive
else
    # Show a menu
    echo -e "${GREEN}What would you like to do?${NC}"
    echo -e "${BLUE}1) Start Interactive Mode${NC}"
    echo -e "${BLUE}2) Scrape a Website${NC}"
    echo -e "${BLUE}3) Analyze Text${NC}"
    echo -e "${BLUE}4) Generate Text with AI${NC}"
    echo -e "${BLUE}5) Run Agent${NC}"
    echo -e "${BLUE}6) Run Tests${NC}"
    echo -e "${BLUE}7) Exit${NC}"
    echo ""
    
    read -p "Enter your choice (1-7): " choice
    
    case $choice in
        1)
            echo -e "${GREEN}Starting Interactive Mode...${NC}"
            bash install_and_run.sh --mode interactive
            ;;
        2)
            echo -e "${GREEN}Scrape a Website${NC}"
            read -p "Enter the URL to scrape: " url
            bash install_and_run.sh --mode scrape --url "$url"
            ;;
        3)
            echo -e "${GREEN}Analyze Text${NC}"
            read -p "Enter the file path to analyze: " file
            bash install_and_run.sh --mode analyze --file "$file"
            ;;
        4)
            echo -e "${GREEN}Generate Text with AI${NC}"
            read -p "Enter your prompt: " prompt
            read -p "Enter model name (default: llama3): " model
            model=${model:-llama3}
            bash install_and_run.sh --mode generate --prompt "$prompt" --model "$model"
            ;;
        5)
            echo -e "${GREEN}Run Agent${NC}"
            read -p "Enter your instruction for the agent: " prompt
            bash install_and_run.sh --mode agent --prompt "$prompt"
            ;;
        6)
            echo -e "${GREEN}Running Tests...${NC}"
            bash install_and_run.sh --mode test
            ;;
        7)
            echo -e "${GREEN}Exiting. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            exit 1
            ;;
    esac
fi

# Keep terminal open after completion
echo -e "\n${BLUE}Press any key to exit...${NC}"
read -n 1 -s 