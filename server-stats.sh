#!/bin/bash

# Script to analyse basic server performance stats

echo "-------------------- Server Performance Stats --------------------"
echo "Date: $(date)"
echo

# --- OS Information  ---
echo "--- Operating System ---"
if command -v lsb_release &> /dev/null; then
  lsb_release -ds
elif [ -f /etc/os-release ]; then
  cat /etc/os-release | grep -E '^(NAME|VERSION)=' | sed 's/=/ /'
else
  uname -a
fi
echo

# --- Uptime and Load Average  ---
echo "--- Uptime and Load Average ---"
uptime
echo

# --- Logged In Users  ---
echo "--- Logged In Users ---"
who | awk '{print $1}' | sort -u
echo

# --- Total CPU Usage ---
echo "--- Total CPU Usage ---"
cpu_idle=$(vmstat 1 2 | tail -n 1 | awk '{print $15}')
cpu_usage=$((100 - cpu_idle))
echo "Total CPU Usage: ${cpu_usage}%"
echo

# --- Total Memory Usage ---
echo "--- Total Memory Usage ---"
total_mem=$(free -m | awk '/Mem:/ {print $2}')
used_mem=$(free -m | awk '/Mem:/ {print $3}')
free_mem=$(free -m | awk '/Mem:/ {print $4}')
mem_percent=$((used_mem * 100 / total_mem))
echo "Total Memory: ${total_mem} MB"
echo "Used Memory: ${used_mem} MB (${mem_percent}%)"
echo "Free Memory: ${free_mem} MB ($((${total_mem} - ${used_mem})) MB)"
echo

# --- Total Disk Usage ---
echo "--- Total Disk Usage ---"
disk_total=$(df -h / | awk '/\// {print $2}')
disk_used=$(df -h / | awk '/\// {print $3}')
disk_avail=$(df -h / | awk '/\// {print $4}')
disk_percent=$(df -h / | awk '/\// {print $5}' | sed 's/%//')
echo "Total Disk Space: ${disk_total}"
echo "Used Disk Space: ${disk_used} (${disk_percent}%)"
echo "Available Disk Space: ${disk_avail}"
echo

# --- Top 5 Processes by CPU Usage ---
echo "--- Top 5 Processes by CPU Usage ---"
ps aux --sort=-%cpu | head -n 6 | awk 'NR>1 {printf "%-10s %-5s %-5s %s\n", $2, $3, $4, $11}'
echo

# --- Top 5 Processes by Memory Usage ---
echo "--- Top 5 Processes by Memory Usage ---"
ps aux --sort=-%mem | head -n 6 | awk 'NR>1 {printf "%-10s %-5s %-5s %s\n", $2, $3, $4, $11}'
echo

# --- Failed Login Attempts (Stretch Goal - Basic Attempt) ---
echo "--- Failed Login Attempts (Last 24 Hours - Basic) ---"
lastb --since 24 hours | wc -l
echo

echo "-------------------- End of Stats --------------------"