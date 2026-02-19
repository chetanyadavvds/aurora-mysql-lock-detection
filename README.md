# Aurora MySQL Lock Detection Script

Shell script to detect blocking sessions, row-level locks, and table locks in Aurora MySQL.

## Features
- Detect blocking and waiting transactions
- Identify active InnoDB locks
- Display long-running queries
- Useful for production troubleshooting

## Prerequisites
- Aurora MySQL 5.7 / 8.0
- MySQL client installed
- performance_schema enabled

## Setup
```bash
chmod +x aurora_mysql_lock_detection.sh
