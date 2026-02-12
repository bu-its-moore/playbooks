#!/bin/bash
# collect_user_stats.sh

# Directory where node_exporter looks for files
# CHANGE THIS if your node_exporter uses a different textfile dir
TEXTFILE_DIR="/var/lib/node_exporter/textfile_collector"
PROM_FILE="$TEXTFILE_DIR/user_stats.prom"
TMP_FILE="$TEXTFILE_DIR/user_stats.tmp"

# Ensure directory exists
mkdir -p "$TEXTFILE_DIR"

# 1. CPU Usage by User
echo "# HELP node_user_cpu_percentage CPU usage percentage by user" > "$TMP_FILE"
echo "# TYPE node_user_cpu_percentage gauge" >> "$TMP_FILE"
# Sum CPU % by user.
ps axo user:20,pcpu --no-headers | awk '{a[$1]+=$2} END {for (i in a) print "node_user_cpu_percentage{user=\""i"\"}", a[i]}' >> "$TMP_FILE"

# 2. Memory Usage by User (RSS)
echo "# HELP node_user_mem_bytes Memory usage (RSS) by user in bytes" >> "$TMP_FILE"
echo "# TYPE node_user_mem_bytes gauge" >> "$TMP_FILE"
# Sum RSS (kb) by user, convert to bytes (*1024)
ps axo user:20,rss --no-headers | awk '{a[$1]+=$2} END {for (i in a) print "node_user_mem_bytes{user=\""i"\"}", a[i]*1024}' >> "$TMP_FILE"

# Atomic move to prevent partial reads
mv "$TMP_FILE" "$PROM_FILE"