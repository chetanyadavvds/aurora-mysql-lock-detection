#!/bin/bash
###############################################################################
# Script Name : aurora_mysql_lock_detection.sh
# Purpose     : Detect Row and Table Locks in Aurora MySQL
# Description :
#   - Detects blocking and waiting transactions
#   - Identifies row-level locks
#   - Shows table-level locks
#
# Prerequisites:
#   - Aurora MySQL 5.7 / 8.0
#   - performance_schema enabled
#   - MySQL client installed
###############################################################################

MYSQL_USER="admin"
MYSQL_HOST="localhost"
MYSQL_PORT=3306

LOG_DIR="/var/log/aurora_monitor"
DATE=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$LOG_DIR/aurora_lock_$DATE.log"

mkdir -p "$LOG_DIR"

echo "Aurora MySQL Lock Detection started at $(date)" > "$LOG_FILE"

echo "===============================" >> "$LOG_FILE"
echo "CURRENT INNODB LOCK WAITS" >> "$LOG_FILE"
echo "===============================" >> "$LOG_FILE"

mysql -u"$MYSQL_USER" -h"$MYSQL_HOST" -P"$MYSQL_PORT" -e "
SELECT
    r.trx_id waiting_trx_id,
    r.trx_mysql_thread_id waiting_thread,
    r.trx_query waiting_query,
    b.trx_id blocking_trx_id,
    b.trx_mysql_thread_id blocking_thread,
    b.trx_query blocking_query
FROM information_schema.innodb_lock_waits w
JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;
" >> "$LOG_FILE" 2>&1

echo "===============================" >> "$LOG_FILE"
echo "ACTIVE LOCKS (InnoDB)" >> "$LOG_FILE"
echo "===============================" >> "$LOG_FILE"

mysql -u"$MYSQL_USER" -h"$MYSQL_HOST" -P"$MYSQL_PORT" -e "
SELECT * FROM information_schema.innodb_locks;
" >> "$LOG_FILE" 2>&1

echo "===============================" >> "$LOG_FILE"
echo "PROCESSLIST (LONG RUNNING)" >> "$LOG_FILE"
echo "===============================" >> "$LOG_FILE"

mysql -u"$MYSQL_USER" -h"$MYSQL_HOST" -P"$MYSQL_PORT" -e "
SELECT id, user, host, db, command, time, state, info
FROM information_schema.processlist
WHERE command != 'Sleep'
ORDER BY time DESC;
" >> "$LOG_FILE" 2>&1

echo "Aurora MySQL Lock Detection completed at $(date)" >> "$LOG_FILE"

exit 0
